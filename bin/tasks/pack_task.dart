import 'package:archive/archive_io.dart';

import '../data/red_config.dart';
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

  logModules(info.modules);
  final archiveFile = config.archiveFile;

  if (archiveFile.existsSync()) {
    archiveFile.deleteSync();
  }
  final encoder = ZipFileEncoder();

  encoder.create(archiveFile.path);
  encoder.addDirectory(config.distDir, includeDirName: false);
  encoder.close();
  if (clean) {
    config.distDir.deleteSync(recursive: true);
  }
  final totalSize = archiveFile.statSync().size;

  return ArchiveInfo(path: archiveFile.path, totalSize: totalSize);
}
