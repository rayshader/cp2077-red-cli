import 'dart:convert';
import 'dart:io';

import 'package:chalkdart/chalkstrings.dart';
import 'package:path/path.dart' as p;

import '../extensions/chalk_ext.dart';
import '../logger.dart';

class RedConfig {
  String name;
  String version;
  String game;
  String dist;
  RedConfigScripts? scripts;
  RedConfigPlugin? plugin;

  RedConfig({
    this.name = '',
    this.version = '',
    this.game = '',
    this.dist = 'dist\\',
    this.scripts,
    this.plugin,
  });

  Directory get gameDir => Directory(game);

  Directory get distDir => Directory(dist);

  Directory get redscriptSrcDir => scripts!.redscript!.srcDir;

  Directory get redscriptOutputDir => scripts!.redscript!.outputDir;

  Directory get outputDir => Directory(p.join(dist, scripts!.redscript!.output, name));

  Directory get installRedscriptDir => Directory(p.join(game, scripts!.redscript!.output));

  Directory get installPluginDir => Directory(p.join(game, 'red4ext', 'plugins'));

  File get archiveFile => File('$name-v$version.zip');

  factory RedConfig.fromJson(Map<String, dynamic> json) {
    return RedConfig(
      name: json['name'] ?? '',
      version: json['version'] ?? '',
      game: json['game'] ?? '',
      dist: json['dist'] ?? 'dist\\',
      scripts: RedConfigScripts.fromJson(json['scripts'] ?? {}),
      plugin: RedConfigPlugin.fromJson(json['plugin'] ?? {}),
    );
  }
}

class RedConfigScripts {
  RedConfigRedscript? redscript;

  RedConfigScripts({
    this.redscript,
  });

  factory RedConfigScripts.fromJson(Map<String, dynamic> json) {
    return RedConfigScripts(
      redscript: RedConfigRedscript.fromJson(json['redscript'] ?? {}),
    );
  }
}

class RedConfigRedscript {
  String src;
  String output;

  RedConfigRedscript({
    this.src = '',
    this.output = 'r6\\scripts',
  });

  Directory get srcDir => Directory(src);

  Directory get outputDir => Directory(output);

  factory RedConfigRedscript.fromJson(Map<String, dynamic> json) {
    return RedConfigRedscript(
      src: json['src'] ?? '',
      output: json['output'] ?? 'r6\\scripts\\',
    );
  }
}

class RedConfigPlugin {
  final String debug;
  final String release;

  Directory get debugDir => Directory(debug);

  Directory get releaseDir => Directory(release);

  const RedConfigPlugin({
    this.debug = '',
    this.release = '',
  });

  factory RedConfigPlugin.fromJson(Map<String, dynamic> json) {
    return RedConfigPlugin(
      debug: json['debug'] ?? '',
      release: json['release'] ?? '',
    );
  }
}

RedConfig? getConfig() {
  final file = File('red.config.json');

  if (!file.existsSync()) {
    Logger.error('Could not find configuration file (${'red.config.json'.cyan}).');
    return null;
  }
  final data = file.readAsStringSync();
  final config = RedConfig.fromJson(jsonDecode(data));

  if (config.name.isEmpty) {
    Logger.error('You must provide a name (${'red.config.json'.cyan}).');
    return null;
  }
  if (config.version.isEmpty) {
    config.version = '0.1.0';
    Logger.info('Version number not defined, fallback to ${'0.1.0'.cyan}.');
  }
  config.game = config.game.isEmpty ? '' : config.game;
  final gamePath = config.game;

  if (!config.gameDir.existsSync()) {
    config.game = detectGamePath() ?? '';
    if (config.game.isEmpty) {
      Logger.error('Could not find game\'s directory in ${gamePath.path}.');
    }
  }
  config.dist = config.dist.isEmpty ? 'dist\\' : config.dist;
  config.scripts ??= RedConfigScripts(
    redscript: RedConfigRedscript(),
  );
  config.scripts!.redscript ??= RedConfigRedscript();
  if (config.scripts!.redscript!.output.isEmpty) {
    config.scripts!.redscript!.output = 'r6\\scripts\\';
  }
  Logger.log('');
  return config;
}

final gameDirs = [
  Directory('C:\\Program Files (x86)\\Steam\\steamapps\\common\\Cyberpunk 2077'),
  Directory('C:\\Program Files (x86)\\GOG Galaxy\\Games\\Cyberpunk 2077'),
  Directory('C:\\Program Files\\Epic Games\\Cyberpunk 2077)')
];

String? detectGamePath() {
  for (final dir in gameDirs) {
    if (dir.existsSync()) {
      return dir.path;
    }
  }
  return null;
}
