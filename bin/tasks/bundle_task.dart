import 'dart:io';

import 'package:chalkdart/chalkstrings.dart';
import 'package:path/path.dart' as p;

import '../data/red_config.dart';
import '../data/script_file.dart';
import '../data/script_module.dart';
import '../extensions/chalk_ext.dart';
import '../logger.dart';

enum BundleMode {
  debug,
  release,
}

class BundleInfo {
  final List<ScriptModule> modules;
  final int size;

  const BundleInfo({
    required this.modules,
    required this.size,
  });
}

BundleInfo bundle(RedConfig config, BundleMode mode) {
  final srcPath = config.scripts!.redscript!.src;

  if (srcPath.isEmpty) {
    Logger.error('Missing path to scripts in ${'red.config.json'.bold} (${'scripts.redscript.src'.cyan}).');
    exit(2);
  }
  final srcDir = config.redscriptSrcDir;

  if (!srcDir.existsSync()) {
    Logger.error('Path not found: ${srcPath.path}.');
    exit(2);
  }
  final scripts = getScripts(srcDir, mode);
  final modules = getModules(scripts, mode);
  final size = bundleModules(modules, config, mode);

  if (mode == BundleMode.release && config.license) {
    config.licenseFile.copySync(p.join(config.outputDir.path, 'LICENSE'));
  }
  return BundleInfo(
    modules: modules,
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

List<ScriptModule> getModules(List<ScriptFile> scripts, BundleMode _mode) {
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

int bundleModules(List<ScriptModule> modules, RedConfig config, BundleMode mode) {
  final outputDir = config.outputDir;

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

void logModules(List<ScriptModule> modules) {
  for (final module in modules) {
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
