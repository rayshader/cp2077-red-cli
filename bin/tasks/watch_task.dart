import 'dart:io';

import 'package:chalkdart/chalkstrings.dart';
import 'package:path/path.dart' as p;
import 'package:rxdart/rxdart.dart';

import '../data/red_config.dart';
import '../data/script_language.dart';
import '../data/toml_config.dart';
import '../extensions/chalk_ext.dart';
import '../extensions/filesystem_ext.dart';
import '../extensions/list_ext.dart';
import '../logger.dart';
import 'bundle_task.dart';

class FileSystemOperation {
  final FileSystemEntity file;
  final int event;

  const FileSystemOperation({
    required this.file,
    required this.event,
  });

  String get path => file.path;

  String get type => file is Directory ? 'directory' : 'file';
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
  List<Stream<FileSystemEvent>> sources = [];

  if (config.hasRedscript()) {
    sources.add(config.scripts.redscript!.srcDir.watch(recursive: true).where(
        (event) => (event.isDirectoryLike && event.type != FileSystemEvent.modify) || event.path.endsWith(".reds")));
  }
  if (config.hasCET()) {
    sources.add(config.scripts.cet!.srcDir.watch(recursive: true).where(
        (event) => (event.isDirectoryLike && event.type != FileSystemEvent.modify) || event.path.endsWith(".lua")));
  }
  final rlsTrigger = config.getRLSTrigger()!;
  final rlsEvent = rlsTrigger.parent
      .watch(events: FileSystemEvent.create | FileSystemEvent.modify)
      .where((event) => event.path == rlsTrigger.path);
  final fsEvent = Rx.merge(sources);

  await fsEvent
      .map((event) => FileSystemOperation(file: event.entity, event: event.type))
      .buffer(rlsEvent)
      .forEach((events) {
    final redscriptSrc = config.scripts.redscript!.src;
    final redscriptInstallDir = config.getInstallDir(ScriptLanguage.redscript);
    final cetSrc = config.scripts.cet!.src;
    final cetInstallDir = config.getInstallDir(ScriptLanguage.cet);

    events.toList().distinct((op) => Object.hash(op.type, op.path)).forEach((op) {
      String path = op.path;

      if (path.startsWith(redscriptSrc)) {
        path = p.relative(path, from: redscriptSrc);
        path = p.join(redscriptInstallDir.path, path);
      } else if (path.startsWith(cetSrc)) {
        path = p.relative(path, from: cetSrc);
        path = p.join(cetInstallDir.path, path);
      }
      String action = getOperationTag(op.event);

      Logger.log('[$action][${op.type}][${op.path.path}][${path.path}]');
      // TODO:
      // - apply changes (copy / remove)
      /*
      [create][directory]["scripts\redscript\Add"]["game\r6\scripts\Awesome\Add"]
      [create][file]["scripts\redscript\Add\add.reds"]["game\r6\scripts\Awesome\Add\add.reds"]
      [update][file]["scripts\redscript\Add\add.reds"]["game\r6\scripts\Awesome\Add\add.reds"]
      [delete][directory]["scripts\redscript\Add"]["game\r6\scripts\Awesome\Add"]
      [create][directory]["scripts\redscript\Services\Add"]["game\r6\scripts\Awesome\Services\Add"]
      [update][file]["scripts\redscript\Services\Add\add.reds"]["game\r6\scripts\Awesome\Services\Add\add.reds"]
      [create][file]["scripts\redscript\Services\Add\delete.reds"]["game\r6\scripts\Awesome\Services\Add\delete.reds"]
      [delete][file]["scripts\redscript\Services\Add\delete.reds"]["game\r6\scripts\Awesome\Services\Add\delete.reds"]
      [update][file]["scripts\redscript\Services\Add\add.reds"]["game\r6\scripts\Awesome\Services\Add\add.reds"]
      */
    });
    final rhtTrigger = config.getRHTTrigger();

    if (rhtTrigger.existsSync()) {
      rhtTrigger.deleteSync();
    }
    rhtTrigger.createSync();
    // - trigger hot reload (RHT)
  });
  if (rlsTrigger.existsSync()) {
    rlsTrigger.deleteSync();
  }
}

String getOperationTag(int event) {
  switch (event) {
    case FileSystemEvent.create:
      return 'create';
    case FileSystemEvent.modify:
      return 'update';
    case FileSystemEvent.delete:
      return 'delete';
    case FileSystemEvent.move:
      return 'move';
  }
  return 'N/A';
}
