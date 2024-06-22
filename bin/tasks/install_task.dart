import 'dart:io';

import 'package:path/path.dart' as p;

import '../data/red_config.dart';
import '../extensions/path_ext.dart';
import '../logger.dart';
import 'bundle_task.dart';

void install(RedConfig config, BundleMode mode, bool bundleOption, bool cleanOption) {
  if (bundleOption) {
    bundle(config, mode);
  }
  final redscriptDir = config.installRedscriptDir;

  if (!redscriptDir.existsSync()) {
    Logger.error('Could not find redscript directory in ${redscriptDir.path}.');
    Logger.info('Did you install redscript? '
        'See https://github.com/jac3km4/redscript?tab=readme-ov-file#integrating-with-the-game.');
    exit(2);
  }
  final scriptsDir = Directory(p.join(redscriptDir.path, config.name));

  if (scriptsDir.existsSync()) {
    scriptsDir.deleteSync(recursive: true);
  }
  scriptsDir.createSync();
  final srcDir = (bundleOption) ? config.distDir : config.redscriptSrcDir;
  final dstDir = (bundleOption) ? config.gameDir : scriptsDir;

  copyDirectorySync(srcDir, dstDir);
  if (bundleOption && cleanOption) {
    srcDir.deleteSync(recursive: true);
  }
}
