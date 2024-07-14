import 'dart:io';

import 'package:path/path.dart' as p;

typedef RuleCallback = bool Function(RegExpMatch match);

class Rule {
  final RegExp regex;
  final RuleCallback callback;

  Rule({required this.regex, required this.callback});
}

class RedscriptAst {
  static final RegExp moduleRule = RegExp(r'^[ \t]*module[ \t]+(?<module>[A-Za-z_.*]+)');
  static final RegExp moduleExistsRule = RegExp(r'^[ \t]*@if[ \t]*\(!?ModuleExists\("(?<dependency>[A-Za-z_.*]+)"\)\)');
  static final RegExp importRule = RegExp(r'^[ \t]*import[ \t]+(?<dependency>[A-Za-z_.*]+)');
}

class DependencyStatement {
  final String? annotation;
  final String dependency;

  const DependencyStatement(this.dependency, this.annotation);

  int compareTo(DependencyStatement other) => dependency.compareTo(other.dependency);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DependencyStatement &&
          runtimeType == other.runtimeType &&
          annotation == other.annotation &&
          dependency == other.dependency;

  @override
  int get hashCode => annotation.hashCode ^ dependency.hashCode;
}

class ScriptFile {
  final String relativePath;
  final String fileName;

  String module = 'global';
  final List<DependencyStatement> dependencies = [];
  final List<String> lines = [];
  final List<String> annotations = [];

  late final List<Rule> rules;

  ScriptFile(this.relativePath, this.fileName) {
    rules = [
      Rule(regex: RedscriptAst.moduleRule, callback: onModuleRule),
      Rule(regex: RedscriptAst.moduleExistsRule, callback: onModuleExistsRule),
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
        if (annotations.isNotEmpty) {
          this.lines.add(annotations.removeAt(0));
        }
        this.lines.add(line);
      }
    }
  }

  bool onModuleRule(RegExpMatch match) {
    module = match.namedGroup('module')!;
    return false;
  }

  bool onModuleExistsRule(RegExpMatch match) {
    annotations.add(match.input);
    return false;
  }

  bool onImportRule(RegExpMatch match) {
    final dependency = match.namedGroup('dependency')!;
    String? annotation;

    if (annotations.isNotEmpty) {
      annotation = annotations.removeAt(0);
    }
    addDependency(dependency, annotation);
    return false;
  }

  void addDependency(String dependency, [String? annotation]) {
    final statement = DependencyStatement(dependency, annotation);

    if (dependencies.contains(statement)) {
      return;
    }
    dependencies.add(statement);
  }
}
