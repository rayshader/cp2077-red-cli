import 'dart:io';

import 'package:path/path.dart' as path;

void copyDirectorySync(Directory source, Directory destination, {bool Function(File)? filter}) {
  final entities = source.listSync(recursive: false);

  filter ??= (File file) => true;
  for (final entity in entities) {
    if (entity is Directory) {
      final dir = Directory(path.join(destination.absolute.path, path.basename(entity.path)));

      dir.createSync();
      copyDirectorySync(entity.absolute, dir, filter: filter);
    } else if (entity is File && filter(entity)) {
      entity.copySync(path.join(destination.path, path.basename(entity.path)));
    }
  }
}
