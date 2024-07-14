import 'dart:io';

import 'package:path/path.dart' as path;

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
