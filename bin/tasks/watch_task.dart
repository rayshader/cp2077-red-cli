import 'dart:io';

import 'package:chalkdart/chalkstrings.dart';
import 'package:path/path.dart' as p;
import 'package:rxdart/rxdart.dart';

import '../data/red_config.dart';
import '../data/script_language.dart';
import '../data/toml_config.dart';
import '../extensions/chalk_ext.dart';
import '../extensions/filesystem_ext.dart';
import '../logger.dart';
import 'bundle_task.dart';

class FileSystemAction {
  final int event;
  final FileSystemEntity src;
  final FileSystemEntity? dst;

  const FileSystemAction({required this.src, required this.event, this.dst});

  String get srcPath => src.path;

  String? get dstPath => dst?.path;

  String get type => src is Directory ? 'directory' : 'file';
}

bool watchSetup(RedConfig config) {
  if (!config.hasRHT()) {
    Logger.error('Could not find RedHotTools directory in ${config.rhtDir.path.path}.');
    Logger.info('Did you install RedHotTools? '
        'See https://github.com/psiberx/cp2077-red-hot-tools.');
    return false;
  }
  File? rlsConfig = config.getRLSConfigFile();

  if (rlsConfig == null) {
    Logger.error('Could not find ${".redscript-ide".path} in your project.');
    Logger.log('  Do you want to generate this file now (${"Y/n".bold})? ', withoutNewline: true);
    final confirm = stdin.readLineSync() == "Y";

    if (!confirm) {
      Logger.info('This feature cannot be used without ${".redscript-ide".path}.');
      return false;
    }
    rlsConfig = TomlConfig.create(config);
    if (rlsConfig == null) {
      return false;
    }
    Logger.info('You need to reload VS Code for changes to take effect.');
    return false;
  }
  final rlsOutput = config.getRLSTrigger();

  if (rlsOutput == null) {
    Logger.error('Failed to parse TOML content of ${".redscript-ide".path}.');
    return false;
  }
  Logger.done('${".redscript-ide".path} is ready.');
  return true;
}

Future<void> watch(RedConfig config, BundleMode mode) async {
  Stream<Object> redscript$ = Stream.empty();
  Stream<Object> cet$ = Stream.empty();
  final rlsTrigger = config.getRLSTrigger();
  final rhtTrigger = config.getRHTTrigger();

  if (config.hasRedscript()) {
    final rls$ = rlsTrigger!.parent
        .watch(events: FileSystemEvent.create | FileSystemEvent.modify)
        .where((event) => event.path == rlsTrigger.path)
        .doOnData((_) {
      Logger.restoreCursor();
      Logger.clearLine();
      Logger.info('Redscript: ${'good'.bold.green}');
    });
    final rht$ = rhtTrigger.parent
        .watch(events: FileSystemEvent.delete)
        .startWith(FileSystemDeleteEvent(rhtTrigger.path, false))
        .where((event) => event.path == rhtTrigger.path)
        .doOnData((_) {
      Logger.restoreCursor(1);
      Logger.clearLine();
      Logger.info('Hot reload: ${'ready'.bold.green}');
    });

    redscript$ = _watchRedscript(config)
        .doOnData((_) {
          Logger.restoreCursor();
          Logger.clearLine();
          Logger.info('Redscript: ${'wait'.bold.yellow}');
        })
        .buffer(rls$)
        .debounceTime(config.scripts.redscript!.debounceTime)
        .withLatestFrom(rht$, (left, right) => {})
        .doOnData((_) {
          if (rhtTrigger.existsSync()) {
            Logger.restoreCursor(1);
            Logger.clearLine();
            Logger.info('Hot reload: ${'skip'.bold.yellow}');
            return;
          }
          rhtTrigger.createSync();
          Logger.restoreCursor(1);
          Logger.clearLine();
          Logger.info('Hot reload: ${'trigger'.bold.cyan}');
        });
  }
  if (config.hasCET()) {
    //cet$ = _watchCET(config);
    Logger.info('Feature is not available with CET.');
  }
  Logger.saveCursor();
  Logger.info('Redscript: ${'wait'.bold}');
  Logger.info('Hot reload: ${'wait'.bold}');
  final fs$ = Rx.merge([redscript$, cet$]);

  await fs$.drain();
  if (rlsTrigger != null && rlsTrigger.existsSync()) {
    rlsTrigger.deleteSync();
  }
}

bool _filterDirectory(FileSystemEvent event) => (event.isDirectoryLike && event.type != FileSystemEvent.modify);

Stream<FileSystemAction> _watchLanguage(RedConfig config, RedConfigScriptLanguage languageConfig) {
  return _watchActions(
    config,
    languageConfig.srcDir
        .watch(recursive: true)
        .where((event) => _filterDirectory(event) || languageConfig.filterFile(event.path)),
  );
}

Stream<FileSystemAction> _watchRedscript(RedConfig config) => _watchLanguage(config, config.scripts.redscript!);

Stream<FileSystemAction> _watchCET(RedConfig config) => _watchLanguage(config, config.scripts.cet!);

Stream<FileSystemAction> _watchActions(RedConfig config, Stream<FileSystemEvent> subject) {
  return subject
      .map((event) => FileSystemAction(src: event.entity, event: event.type, dst: event.entityDestination))
      .doOnData((action) => _applyAction(config, action));
}

void _applyAction(RedConfig config, FileSystemAction action) {
  String tag = _getActionTag(action.event);
  String type = action.src is Directory ? 'DIR ' : 'FILE';

  Logger.restoreCursor(3);
  Logger.clearLine();
  Logger.log('$tag ${type.bold} ', withoutNewline: true);
  if (action.src is Directory) {
    _applyDirectory(config, action);
  } else if (action.src is File) {
    _applyFile(config, action);
  }
}

void _logDiff(String src, String dst) {
  Logger.log(src.green);
  Logger.clearLine();
  Logger.log('       ${dst.green}');
}

void _applyDirectory(RedConfig config, FileSystemAction action) {
  try {
    switch (action.event) {
      case FileSystemEvent.create:
        final src = Directory(action.srcPath);
        final dst = Directory(_toGamePath(config, action.srcPath));

        dst.createSync();
        src.copySync(dst);

        _logDiff(action.srcPath, _relativeGamePath(config, dst.path));
        break;
      case FileSystemEvent.move:
        final src = Directory(_toGamePath(config, action.srcPath));
        final dst = Directory(_toGamePath(config, action.dstPath!));

        src.renameSync(dst.path);

        _logDiff(_relativeGamePath(config, src.path), _relativeGamePath(config, dst.path));
        break;
      case FileSystemEvent.delete:
        final dst = Directory(_toGamePath(config, action.srcPath));

        dst.deleteSync(recursive: true);

        _logDiff(action.srcPath, _relativeGamePath(config, dst.path));
        break;
    }
  } catch (error) {
    stdout.writeln('');
    Logger.error('Unexpected failure:');
    Logger.error(error.toString());
  }
}

void _applyFile(RedConfig config, FileSystemAction action) {
  try {
    switch (action.event) {
      case FileSystemEvent.create:
      case FileSystemEvent.modify:
        final src = File(action.srcPath);
        final dst = File(_toGamePath(config, action.srcPath));

        dst.writeAsBytesSync(src.readAsBytesSync(), flush: true);

        _logDiff(action.srcPath, _relativeGamePath(config, dst.path));
        break;
      case FileSystemEvent.move:
        final src = File(_toGamePath(config, action.srcPath));
        final dstPath = _toGamePath(config, action.dstPath!);

        src.copySync(dstPath);
        src.deleteSync();

        _logDiff(_relativeGamePath(config, src.path), _relativeGamePath(config, dstPath));
        break;
      case FileSystemEvent.delete:
        final dst = File(_toGamePath(config, action.srcPath));

        dst.deleteSync();

        _logDiff(action.srcPath, _relativeGamePath(config, dst.path));
        break;
    }
  } catch (error) {
    stdout.writeln('');
    Logger.error('Unexpected failure:');
    Logger.error(error.toString());
  }
}

String _toGamePath(RedConfig config, String path) {
  final redscriptSrc = config.scripts.redscript!.src;
  final redscriptInstallDir = config.getInstallDir(ScriptLanguage.redscript);

  if (path.startsWith(redscriptSrc)) {
    path = p.relative(path, from: redscriptSrc);
    path = p.join(redscriptInstallDir.path, path);
  }
  return path;
}

String _relativeGamePath(RedConfig config, String path) => p.relative(path, from: config.game);

String _getActionTag(int event) {
  switch (event) {
    case FileSystemEvent.create:
      return '+'.bold.green;
    case FileSystemEvent.modify:
      return '~'.bold.cyan;
    case FileSystemEvent.move:
      return '*'.bold.cyan;
    case FileSystemEvent.delete:
      return '-'.bold.red;
  }
  return '?'.bold.yellow;
}
