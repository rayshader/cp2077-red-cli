import 'dart:io';

import 'package:path/path.dart' show basename, join;

extension FileSystemEventExt on FileSystemEvent {
  /// Get a [File] or a [Directory] based on [isDirectoryLike].
  FileSystemEntity get entity => (isDirectoryLike) ? Directory(path) : File(path);

  /// Get a [File], [Directory], or null based on [isDirectoryLike] when event is [FileSystemEvent.move].
  FileSystemEntity? get entityDestination {
    final self = this;

    if (self is! FileSystemMoveEvent) {
      return null;
    }
    final destination = self.destination;

    if (destination == null) {
      return null;
    }
    return (isDirectoryLike) ? Directory(destination) : File(destination);
  }

  /// Whether [path] is known as a directory or path is without an extension
  /// like a directory?
  bool get isDirectoryLike => isDirectory || !path.contains(RegExp(r'^[\w\-.\\]+(\\[\w\-.]+)*\\[\w\-]+(\.[\w-]+)+$'));
}

extension DirectoryExt on Directory {
  /// Find [fileName] in this directory. Ignores directories starting with
  /// "." (e.g. ".git"). Use [recursive] to search in sub-directories too.
  File? findFile(final String fileName, {bool recursive = false}) {
    final List<FileSystemEntity> entities = listSync();
    File? file;

    for (final entity in entities) {
      if (recursive && entity is Directory && !basename(entity.path).startsWith(".")) {
        file = entity.findFile(fileName, recursive: recursive);
        if (file != null) {
          return file;
        }
      } else if (entity is File) {
        final filePath = basename(entity.path);

        if (filePath == fileName) {
          return entity;
        }
      }
    }
    return null;
  }

  /// Recursively copy content of [this] directory in [destination], optionally
  /// [filter] files to copy.
  ///
  /// Return a list of files created during the operation.
  List<File> copySync(Directory destination, {bool Function(File)? filter}) {
    final List<File> files = [];
    final entities = listSync(recursive: false);

    filter ??= (File file) => true;
    for (final entity in entities) {
      if (entity is Directory) {
        final dir = Directory(join(destination.absolute.path, basename(entity.path)));

        dir.createSync();
        files.addAll(entity.absolute.copySync(dir, filter: filter));
      } else if (entity is File && filter(entity)) {
        entity.copySync(join(destination.path, basename(entity.path)));
        files.add(entity);
      }
    }
    return files;
  }
}
