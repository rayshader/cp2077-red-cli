import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

import 'red_config.dart';
import 'script_file.dart';

class ScriptModule {
  final List<DependencyStatement> dependencies = [];
  final List<ScriptFile> scripts = [];
  final String name;

  ScriptModule(this.name);

  String getFileName(RedConfig config) {
    if (name != 'global') {
      return '$name.reds';
    } else {
      return '${config.name}.Global.reds';
    }
  }

  void addScript(ScriptFile script) {
    scripts.add(script);
    for (final statement in script.dependencies) {
      if (!dependencies.contains(statement)) {
        dependencies.add(statement);
      }
    }
    dependencies.sort((a, b) => a.compareTo(b));
  }

  int write(RedConfig config, String outputPath) {
    String data = '// ${config.name} v${config.version}\n';

    if (name != 'global') {
      data += 'module $name\n\n';
    }
    for (final statement in dependencies) {
      if (statement.annotation != null) {
        data += '${statement.annotation}\n';
      }
      data += 'import ${statement.dependency}\n';
    }
    if (dependencies.isNotEmpty) {
      data += '\n';
    }
    for (final script in scripts) {
      for (final line in script.lines) {
        if (line.trim().isNotEmpty) {
          data += '$line\n';
        }
      }
    }
    final modulePath = path.join(outputPath, getFileName(config));
    final moduleFile = File(modulePath);

    moduleFile.writeAsStringSync(data, encoding: utf8);
    return moduleFile.statSync().size;
  }
}
