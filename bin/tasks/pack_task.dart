import 'dart:io';

import 'package:archive/archive_io.dart';

import '../data/red_config.dart';
import '../extensions/chalk_ext.dart';
import '../logger.dart';
import 'bundle_task.dart';

class ArchiveInfo {
  final String path;
  final int totalSize;

  const ArchiveInfo({
    required this.path,
    required this.totalSize,
  });
}

ArchiveInfo pack(RedConfig config, BundleMode mode, bool clean) {
  BundleInfo info = bundle(config, mode);

  bundlePlugin(config, mode);
  logRedscript(info.redscriptInfo);
  logCET(info.cetInfo);
  final archiveFile = config.archiveFile;

  try {
    if (archiveFile.existsSync()) {
      archiveFile.deleteSync();
    }
    final encoder = ZipFileEncoder();

    encoder.create(archiveFile.path);
    encoder.addDirectory(config.stageDir, includeDirName: false);
    encoder.close();
    if (clean) {
      config.stageDir.deleteSync(recursive: true);
    }
    final totalSize = archiveFile.statSync().size;

    return ArchiveInfo(path: archiveFile.path, totalSize: totalSize);
  } catch (error) {
    Logger.error('Failed to pack archive ${archiveFile.path.path}:');
    Logger.log('  ${error.toString()}');
    exit(2);
  }
}
