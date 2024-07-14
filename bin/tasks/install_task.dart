import 'dart:io';

import 'package:path/path.dart' as p;

import '../data/red_config.dart';
import '../extensions/chalk_ext.dart';
import '../extensions/path_ext.dart';
import '../logger.dart';
import 'bundle_task.dart';

void install(RedConfig config, BundleMode mode, bool bundleOption, bool cleanOption) {
  if (bundleOption) {
    bundle(config, mode);
  }
  _installRedscript(config, mode, bundleOption, cleanOption);
  _installCET(config, mode, bundleOption, cleanOption);
}

void installPlugin(RedConfig config, BundleMode mode) {
  if (config.plugin == null) {
    return;
  }
  final installDir = config.installPluginDir;

  if (!installDir.existsSync()) {
    Logger.error('Could not find red4ext directory in ${installDir.path.path}.');
    Logger.info('Did you install RED4ext? '
        'See https://docs.red4ext.com/getting-started/installing-red4ext.');
    exit(2);
  }
  String pluginPath = (mode == BundleMode.debug) ? config.plugin!.debug : config.plugin!.release;
  File srcPluginFile = File(p.join(pluginPath, '${config.name}.dll'));
  Directory dstPluginDir = Directory(p.join(installDir.path, config.name));

  try {
    dstPluginDir.createSync(recursive: true);
  } catch (error) {
    Logger.error('Failed to create RED4ext directory for the plugin.');
    Logger.info('Is the game running?');
    return;
  }
  File dstPluginFile = File(p.join(dstPluginDir.path, '${config.name}.dll'));

  try {
    srcPluginFile.copySync(dstPluginFile.path);
  } catch (error) {
    Logger.info('Cannot install DLL plugin while the game is running.');
  }
}

void _installRedscript(RedConfig config, BundleMode mode, bool bundleOption, bool cleanOption) {
  final redscriptDir = config.installRedscriptDir;

  if (!redscriptDir.existsSync()) {
    Logger.error('Could not find redscript directory in ${redscriptDir.path.path}.');
    Logger.info('Did you install redscript? '
        'See https://github.com/jac3km4/redscript?tab=readme-ov-file#integrating-with-the-game.');
    return;
  }
  final scriptsDir = Directory(p.join(redscriptDir.path, config.name));

  if (scriptsDir.existsSync()) {
    scriptsDir.deleteSync(recursive: true);
  }
  scriptsDir.createSync();
  final srcDir = (bundleOption) ? config.distDir : config.redscriptSrcDir;
  final dstDir = (bundleOption) ? config.gameDir : scriptsDir;

  copyDirectorySync(
    srcDir,
    dstDir,
    filter: (File file) => filterRedscriptFile(file, mode),
  );
  if (bundleOption && cleanOption) {
    srcDir.deleteSync(recursive: true);
  }
}

void _installCET(RedConfig config, BundleMode mode, bool bundleOption, bool cleanOption) {
  final cetDir = config.installCETDir;

  if (!cetDir.existsSync()) {
    Logger.error('Could not find CET directory in ${cetDir.path.path}.');
    Logger.info('Did you install CET? '
        'See https://wiki.redmodding.org/cyber-engine-tweaks/getting-started/installing.');
    return;
  }
  final scriptsDir = Directory(p.join(cetDir.path, config.name));

  if (scriptsDir.existsSync()) {
    deleteCETDirectorySync(scriptsDir);
  }
  scriptsDir.createSync();
  final srcDir = (bundleOption) ? config.distDir : config.cetSrcDir;
  final dstDir = (bundleOption) ? config.gameDir : scriptsDir;

  copyDirectorySync(srcDir, dstDir);
  if (bundleOption && cleanOption) {
    srcDir.deleteSync(recursive: true);
  }
}
