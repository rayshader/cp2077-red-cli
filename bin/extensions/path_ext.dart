import 'dart:io';
import 'package:path/path.dart' as path;

void copyDirectorySync(Directory source, Directory destination) {
  final entities = source.listSync(recursive: false);

  for (final entity in entities) {
    if (entity is Directory) {
      final dir = Directory(path.join(destination.absolute.path, path.basename(entity.path)));

      dir.createSync();
      copyDirectorySync(entity.absolute, dir);
    } else if (entity is File) {
      entity.copySync(path.join(destination.path, path.basename(entity.path)));
    }
  }
}
