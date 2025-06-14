import 'dart:io';

import 'package:path/path.dart' as p;

import '../data/red_config.dart';
import '../data/script_language.dart';
import '../extensions/chalk_ext.dart';
import '../extensions/filesystem_ext.dart';
import '../logger.dart';
import 'bundle_task.dart';

void install(RedConfig config, BundleMode mode, bool bundleOption, bool cleanOption) {
  if (bundleOption) {
    bundle(config, mode);
  }
  _installRedscript(config, mode, bundleOption, cleanOption);
  _installRedscriptStorage(config, mode, bundleOption);
  _installCET(config, mode, bundleOption, cleanOption);
  if (bundleOption && cleanOption) {
    config.stageDir.deleteSync(recursive: true);
  }
}

void installPlugin(RedConfig config, BundleMode mode) {
  if (!config.hasRED4ext(mode)) {
    return;
  }
  final languageDir = config.getLanguageDir(ScriptLanguage.red4ext);

  if (!languageDir.existsSync()) {
    Logger.error('Could not find red4ext directory in ${languageDir.path.path}.');
    Logger.info('Did you install RED4ext? '
        'See https://docs.red4ext.com/getting-started/installing-red4ext.');
    exit(2);
  }
  File srcFile = config.getPluginFile(mode);
  Directory installDir = config.getInstallDir(ScriptLanguage.red4ext);

  try {
    installDir.createSync(recursive: true);
  } catch (error) {
    Logger.error('Failed to create RED4ext directory for the plugin.');
    Logger.info('Is the game running?');
    return;
  }
  File dstFile = File(p.join(installDir.path, '${config.name}.dll'));

  try {
    srcFile.copySync(dstFile.path);
  } catch (error) {
    Logger.info('Cannot install RED4ext plugin while the game is running.');
  }
}

void _installRedscript(RedConfig config, BundleMode mode, bool bundleOption, bool cleanOption) {
  if (!config.hasRedscript()) {
    return;
  }
  final languageDir = config.getLanguageDir(ScriptLanguage.redscript);

  if (!languageDir.existsSync()) {
    Logger.error('Could not find redscript directory in ${languageDir.path.path}.');
    Logger.info('Did you install redscript? '
        'See https://github.com/jac3km4/redscript?tab=readme-ov-file#integrating-with-the-game.');
    return;
  }
  final installDir = config.getInstallDir(ScriptLanguage.redscript);

  if (installDir.existsSync()) {
    installDir.deleteSync(recursive: true);
  }
  installDir.createSync();
  final srcDir = (bundleOption) ? config.stageDir : config.scripts.redscript!.srcDir;
  final dstDir = (bundleOption) ? config.gameDir : installDir;

  srcDir.copySync(
    dstDir,
    filter: (File file) => filterRedscriptFile(file, mode),
  );
}

void _installRedscriptStorage(RedConfig config, BundleMode mode, bool bundleOption) {
  if (!config.hasRedscript()) {
    return;
  }
  final srcDir = config.scripts.redscript!.storageDir;
  if (srcDir == null) {
    return;
  }
  if (!srcDir.existsSync()) {
    Logger.error('Could not find storage directory in ${srcDir.path.path}.');
    return;
  }

  final dstDir = config.storageDir;
  if (dstDir.existsSync()) {
    dstDir.deleteSync(recursive: true);
  }
  dstDir.createSync(recursive: true);

  srcDir.copySync(dstDir);
}

void _installCET(RedConfig config, BundleMode mode, bool bundleOption, bool cleanOption) {
  if (!config.hasCET()) {
    return;
  }
  final languageDir = config.getLanguageDir(ScriptLanguage.cet);

  if (!languageDir.existsSync()) {
    Logger.error('Could not find CET directory in ${languageDir.path.path}.');
    Logger.info('Did you install CET? '
        'See https://wiki.redmodding.org/cyber-engine-tweaks/getting-started/installing.');
    return;
  }
  final installDir = config.getInstallDir(ScriptLanguage.cet);

  if (installDir.existsSync()) {
    deleteCETDirectorySync(installDir);
  }
  installDir.createSync();
  final srcDir = (bundleOption) ? config.stageDir : config.scripts.cet!.srcDir;
  final dstDir = (bundleOption) ? config.gameDir : installDir;

  srcDir.copySync(dstDir);
}
