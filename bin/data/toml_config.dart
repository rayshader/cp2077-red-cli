import 'dart:io';

import 'package:toml/toml.dart';

import '../extensions/chalk_ext.dart';
import '../logger.dart';
import 'red_config.dart';

class TomlConfig {
  final String path;

  const TomlConfig({
    required this.path,
  });

  bool hasErrors() {
    return path.isEmpty;
  }

  static File? create(RedConfig config) {
    final document = TomlDocument.fromMap({
      'hooks': {
        'successful_check': [
          {'create_file': TomlBasicString(config.tcFile.path)},
        ],
      },
    });
    final file = config.rlsFile;

    try {
      file.writeAsStringSync(document.toString());
      return file;
    } catch (error) {
      Logger.error('Failed to setup ${".redscript-ide".path} due to: ${error.toString()}');
      return null;
    }
  }

  factory TomlConfig.fromDocument(TomlDocument document) {
    try {
      final toml = document.toMap();
      final path = toml['hooks']?['successful_check']?[0]?['create_file'] ?? '';

      return TomlConfig(path: path);
    } catch (error) {
      return TomlConfig(path: '');
    }
  }
}
