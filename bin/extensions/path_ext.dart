import 'dart:io';

import 'package:path/path.dart' as path;

extension DirectoryExt on Directory {
  /// Find [fileName] from this directory. Ignores directories starting with
  /// "." (e.g. ".git"). Use [recursive] to search in sub-directories too.
  File? findFile(final String fileName, {bool recursive = false}) {
    final List<FileSystemEntity> entities = listSync();
    File? file;

    for (final entity in entities) {
      if (recursive && entity is Directory && !path.basename(entity.path).startsWith(".")) {
        file = entity.findFile(fileName, recursive: recursive);
        if (file != null) {
          return file;
        }
      } else if (entity is File) {
        final filePath = path.basename(entity.path);

        if (filePath == fileName) {
          return entity;
        }
      }
    }
    return null;
  }
}

List<File> copyDirectorySync(Directory source, Directory destination, {bool Function(File)? filter}) {
  final List<File> files = [];
  final entities = source.listSync(recursive: false);

  filter ??= (File file) => true;
  for (final entity in entities) {
    if (entity is Directory) {
      final dir = Directory(path.join(destination.absolute.path, path.basename(entity.path)));

      dir.createSync();
      files.addAll(copyDirectorySync(entity.absolute, dir, filter: filter));
    } else if (entity is File && filter(entity)) {
      entity.copySync(path.join(destination.path, path.basename(entity.path)));
      files.add(entity);
    }
  }
  return files;
}
