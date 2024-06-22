import 'package:path/path.dart' as p;
import 'dart:io';

typedef RuleCallback = bool Function(RegExpMatch match);

class Rule {
  final RegExp regex;
  final RuleCallback callback;

  Rule({required this.regex, required this.callback});
}

class RedscriptAst {
  static final RegExp moduleRule = RegExp('^[ \t]*module[ \t]+(?<module>[A-Za-z_.*]+)');
  static final RegExp importRule = RegExp('^[ \t]*import[ \t]+(?<dependency>[A-Za-z_.*]+)');
}

class ScriptFile {
  final String relativePath;
  final String fileName;

  String module = 'global';
  final List<String> dependencies = [];
  final List<String> lines = [];

  late final List<Rule> rules;

  ScriptFile(this.relativePath, this.fileName) {
    rules = [
      Rule(regex: RedscriptAst.moduleRule, callback: onModuleRule),
      Rule(regex: RedscriptAst.importRule, callback: onImportRule),
    ];
  }

  String get path => p.join('.', relativePath, fileName);

  File get file => File(path);

  void read() {
    String data = file.readAsStringSync();
    List<String> lines = data.split('\r\n');

    if (lines.isEmpty) {
      return;
    }
    for (final line in lines) {
      bool matched = false;

      for (final rule in rules) {
        final match = rule.regex.firstMatch(line);

        if (match != null) {
          if (rule.callback(match)) {
            this.lines.add(line);
          }
          matched = true;
          break;
        }
      }
      if (!matched) {
        this.lines.add(line);
      }
    }
  }

  bool onModuleRule(RegExpMatch match) {
    module = match.namedGroup('module')!;
    return false;
  }

  bool onImportRule(RegExpMatch match) {
    final dependency = match.namedGroup('dependency')!;

    addDependency(dependency);
    return false;
  }

  void addDependency(String dependency) {
    if (dependencies.contains(dependency)) {
      return;
    }
    dependencies.add(dependency);
  }
}
