import 'dart:io';

extension FileSystemEventExt on FileSystemEvent {
  /// Get a [File] or a [Directory] based on [isDirectoryLike].
  FileSystemEntity get entity => (isDirectoryLike) ? Directory(path) : File(path);

  /// Whether [path] is known as a directory or path is without an extension
  /// like a directory?
  bool get isDirectoryLike => isDirectory || !path.contains(RegExp(r'^[\w\-.\\]+(\\[\w\-.]+)*\\[\w\-]+(\.[\w-]+)+$'));
}
