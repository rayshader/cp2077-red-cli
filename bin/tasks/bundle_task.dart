import 'dart:io';

import 'package:chalkdart/chalkstrings.dart';
import 'package:path/path.dart' as p;

import '../data/red_config.dart';
import '../data/script_file.dart';
import '../data/script_module.dart';
import '../extensions/path_ext.dart';
import '../logger.dart';

enum BundleMode {
  debug,
  release,
}

class BundleInfo {
  final BundleRedscriptInfo redscriptInfo;
  final BundleCETInfo cetInfo;
  final int size;

  const BundleInfo({
    required this.redscriptInfo,
    required this.cetInfo,
    required this.size,
  });
}

class BundleRedscriptInfo {
  final List<ScriptModule> modules;
  final int size;

  const BundleRedscriptInfo({
    this.modules = const [],
    this.size = 0,
  });
}

class BundleCETInfo {
  final int files;
  final int size;

  const BundleCETInfo({
    this.files = 0,
    this.size = 0,
  });
}

BundleInfo bundle(RedConfig config, BundleMode mode) {
  if (config.isMissingScripts()) {
    Logger.error(
        'You need to provide a path to scripts in ${'red.config.json'.bold} for Redscript or CET (${'one required'.cyan}).');
    exit(2);
  }
  var redInfo = BundleRedscriptInfo();
  var cetInfo = BundleCETInfo();

  if (config.hasRedScripts()) {
    redInfo = _bundleRedscript(config, mode);
  }
  if (config.hasCETScripts()) {
    cetInfo = _bundleCET(config, mode);
  }
  return BundleInfo(
    redscriptInfo: redInfo,
    cetInfo: cetInfo,
    size: redInfo.size + cetInfo.size,
  );
}

BundleRedscriptInfo _bundleRedscript(RedConfig config, BundleMode mode) {
  final srcDir = config.redscriptSrcDir;
  final scripts = getScripts(srcDir, mode);
  final modules = getModules(scripts);
  final size = bundleModules(modules, config);

  if (mode == BundleMode.release && config.license) {
    config.licenseFile.copySync(p.join(config.outputRedscriptDir.path, 'LICENSE'));
  }
  return BundleRedscriptInfo(
    modules: modules,
    size: size,
  );
}

BundleCETInfo _bundleCET(RedConfig config, BundleMode mode) {
  final outputDir = config.outputCETDir;

  if (outputDir.existsSync()) {
    deleteCETDirectorySync(outputDir);
  }
  outputDir.createSync(recursive: true);
  final srcDir = config.cetSrcDir;
  final scripts = copyDirectorySync(srcDir, outputDir);
  int size = scripts.map((file) => file.statSync().size).reduce((previous, current) => previous + current);

  return BundleCETInfo(
    files: scripts.length,
    size: size,
  );
}

void bundlePlugin(RedConfig config, BundleMode mode) {
  if (config.plugin == null) {
    return;
  }
  String pluginPath = (mode == BundleMode.debug) ? config.plugin!.debug : config.plugin!.release;
  File srcPluginFile = File(p.join(pluginPath, '${config.name}.dll'));
  Directory dstPluginDir = Directory(p.join(config.dist, 'red4ext', 'plugins', config.name));

  dstPluginDir.createSync(recursive: true);
  File dstPluginFile = File(p.join(dstPluginDir.path, '${config.name}.dll'));

  srcPluginFile.copySync(dstPluginFile.path);
}

// Redscript

List<ScriptFile> getScripts(Directory srcDir, BundleMode mode) {
  final entries = srcDir.listSync(recursive: true, followLinks: false);

  return entries.where((file) {
    return filterRedscriptFile(file, mode);
  }).map((file) {
    final script = ScriptFile(p.dirname(file.path), p.basename(file.path));

    script.read();
    return script;
  }).toList();
}

List<ScriptModule> getModules(List<ScriptFile> scripts) {
  List<ScriptModule> modules = [];

  for (final script in scripts) {
    ScriptModule module;

    if (script.module == 'global') {
      module = modules.firstWhere((m) => m.name == 'global', orElse: () => ScriptModule('global'));
      if (!modules.contains(module)) {
        modules.add(module);
      }
    } else {
      module = modules.firstWhere((m) => m.name == script.module, orElse: () => ScriptModule(script.module));
      if (!modules.contains(module)) {
        modules.add(module);
      }
    }
    module.addScript(script);
  }
  modules.sort((a, b) {
    if (b.name == 'global') {
      return 1;
    }
    return a.name.compareTo(b.name);
  });
  return modules;
}

int bundleModules(List<ScriptModule> modules, RedConfig config) {
  final outputDir = config.outputRedscriptDir;

  if (outputDir.existsSync()) {
    outputDir.deleteSync(recursive: true);
  }
  outputDir.createSync(recursive: true);
  int size = 0;

  for (final module in modules) {
    size += module.write(config, outputDir.path);
  }
  return size;
}

void logRedscript(BundleRedscriptInfo info) {
  for (final module in info.modules) {
    String scripts = '${module.scripts.length} script';

    if (module.scripts.length > 1) {
      scripts += 's';
    }
    if (module.name == 'global') {
      Logger.log('· ${'Global scope'.bold} (${scripts.cyan})');
      Logger.log('');
    } else {
      Logger.log('· module ${module.name.bold} (${scripts.cyan})');
    }
  }
  Logger.log('');
}

bool filterRedscriptFile(FileSystemEntity file, BundleMode mode) {
  if (file is! File) {
    return false;
  }
  final name = p.basename(file.path);

  if (!name.endsWith('.reds')) {
    return false;
  }
  if (mode == BundleMode.debug) {
    return true;
  }
  return !name.endsWith('Test.reds');
}

// CET

void logCET(BundleCETInfo info) {
  String scripts = '${info.files} script';

  if (info.files > 1) {
    scripts += 's';
  }
  Logger.log('· CET content (${scripts.cyan})');
  Logger.log('');
}

/// Remove all CET mod content except .log / .sqlite3 files.
void deleteCETDirectorySync(Directory source) {
  final entities = source.listSync();

  for (final entity in entities) {
    if (entity is Directory) {
      entity.deleteSync(recursive: true);
    } else if (entity is File && _filterCETFile(entity)) {
      entity.deleteSync();
    }
  }
}

bool _filterCETFile(File file) {
  return !file.path.endsWith('.log') && !file.path.endsWith('.sqlite3');
}
