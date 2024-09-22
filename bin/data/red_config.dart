import 'dart:convert';
import 'dart:io';

import 'package:chalkdart/chalkstrings.dart';
import 'package:path/path.dart' as p;
import 'package:toml/toml.dart';

import '../data/toml_config.dart';
import '../extensions/chalk_ext.dart';
import '../extensions/path_ext.dart';
import '../logger.dart';
import '../tasks/bundle_task.dart';
import 'script_language.dart';

class RedConfig {
  String name;
  String version;
  bool license;
  String game;
  String stage;
  RedConfigScripts scripts;
  RedConfigPlugin? plugin;

  RedConfig({
    this.name = '',
    this.license = false,
    this.version = '',
    this.game = '',
    this.stage = 'stage\\',
    this.scripts = const RedConfigScripts(),
    this.plugin,
  });

  File get licenseFile => File('LICENSE');

  Directory get gameDir => Directory(game);

  Directory get stageDir => Directory(stage);

  Directory get rhtDir => Directory(p.join(game, 'red4ext', 'plugins', 'RedHotTools'));

  File get rlsFile => File(p.join(p.current, '.redscript-ide'));

  /// File created by Redscript Language Server when the workspace
  /// successfully type checks.
  File get tcFile => File(p.join(p.current, '.reds-ready'));

  File get archiveFile => File('$name-$version.zip');

  bool hasScripts() {
    return hasRedscript() || hasCET();
  }

  bool hasRedscript() {
    return scripts.redscript?.exists ?? false;
  }

  bool hasCET() {
    return scripts.cet?.exists ?? false;
  }

  bool hasRED4ext(BundleMode mode) {
    return ((mode == BundleMode.debug) ? plugin?.debugDir.existsSync() : plugin?.releaseDir.existsSync()) ?? false;
  }

  bool hasRHT() {
    final pluginFile = File(p.join(rhtDir.path, 'RedHotTools.dll'));

    return pluginFile.existsSync();
  }

  Directory getStageDir(ScriptLanguage language) {
    switch (language) {
      case ScriptLanguage.redscript:
        return Directory(p.join(stage, scripts.redscript!.output, name));
      case ScriptLanguage.cet:
        return Directory(p.join(stage, scripts.cet!.output, name));
      case ScriptLanguage.red4ext:
        return Directory(p.join(stage, 'red4ext', 'plugins', name));
    }
  }

  Directory getLanguageDir(ScriptLanguage language) {
    switch (language) {
      case ScriptLanguage.redscript:
        return Directory(p.join(game, scripts.redscript!.output));
      case ScriptLanguage.cet:
        return Directory(p.join(game, scripts.cet!.output));
      case ScriptLanguage.red4ext:
        return Directory(p.join(game, 'red4ext', 'plugins'));
    }
  }

  Directory getInstallDir(ScriptLanguage language) {
    switch (language) {
      case ScriptLanguage.redscript:
        return Directory(p.join(game, scripts.redscript!.output, name));
      case ScriptLanguage.cet:
        return Directory(p.join(game, scripts.cet!.output, name));
      case ScriptLanguage.red4ext:
        return Directory(p.join(game, 'red4ext', 'plugins', name));
    }
  }

  File getPluginFile(BundleMode mode) {
    final pluginPath = (mode == BundleMode.debug) ? plugin!.debug : plugin!.release;

    return File(p.join(pluginPath, '$name.dll'));
  }

  /// Get Redscript Language Server configuration file.
  ///
  /// See https://github.com/jac3km4/redscript-ide?tab=readme-ov-file#configuration
  File? getRLSConfigFile() {
    return Directory.current.findFile(".redscript-ide", recursive: true);
  }

  /// Get Redscript Language Service successful typechecks file.
  File? getRLSTrigger() {
    final file = getRLSConfigFile();

    if (file == null) {
      return null;
    }
    final document = TomlDocument.parse(file.readAsStringSync());
    final toml = TomlConfig.fromDocument(document);

    if (toml.hasErrors()) {
      return null;
    }
    return File(toml.path);
  }

  /// Get RedHotTools file to trigger hot reload.
  File getRHTTrigger() {
    return File(p.join(rhtDir.path, '.hot-scripts'));
  }

  void copyLicenseSync(ScriptLanguage language) {
    licenseFile.copySync(p.join(getStageDir(language).path, 'LICENSE'));
  }

  factory RedConfig.fromJson(Map<String, dynamic> json) {
    // Deprecated, still present to support versions below 0.3.0
    if (json['dist'] != null) {
      json['stage'] = json['dist'];
    }
    return RedConfig(
      name: json['name'] ?? '',
      version: json['version'] ?? '',
      license: json['license'] ?? false,
      game: json['game'] ?? '',
      stage: json['stage'] ?? 'stage\\',
      scripts: RedConfigScripts.fromJson(json['scripts']),
      plugin: json['plugin'] != null ? RedConfigPlugin.fromJson(json['plugin']) : null,
    );
  }
}

class RedConfigScripts {
  final RedConfigRedscript? redscript;
  final RedConfigCET? cet;

  const RedConfigScripts({
    this.redscript,
    this.cet,
  });

  factory RedConfigScripts.fromJson(Map<String, dynamic> json) {
    return RedConfigScripts(
      redscript: json['redscript'] != null ? RedConfigRedscript.fromJson(json['redscript']) : null,
      cet: json['cet'] != null ? RedConfigCET.fromJson(json['cet']) : null,
    );
  }
}

abstract class RedConfigScriptLanguage {
  final String src;
  final String output;

  bool get exists => srcDir.existsSync();

  Directory get srcDir => Directory(src);

  Directory get outputDir => Directory(output);

  const RedConfigScriptLanguage({
    required this.src,
    required this.output,
  });
}

class RedConfigRedscript extends RedConfigScriptLanguage {
  static const String defaultOutput = 'r6\\scripts\\';

  const RedConfigRedscript({
    super.src = '',
    super.output = RedConfigRedscript.defaultOutput,
  });

  factory RedConfigRedscript.fromJson(Map<String, dynamic> json) {
    return RedConfigRedscript(
      src: json['src'] ?? '',
      output: json['output'] ?? RedConfigRedscript.defaultOutput,
    );
  }
}

class RedConfigCET extends RedConfigScriptLanguage {
  static const String defaultOutput = "bin\\x64\\plugins\\cyber_engine_tweaks\\mods\\";

  const RedConfigCET({
    super.src = '',
    super.output = RedConfigCET.defaultOutput,
  });

  factory RedConfigCET.fromJson(Map<String, dynamic> json) {
    return RedConfigCET(
      src: json['src'] ?? '',
      output: json['output'] ?? RedConfigCET.defaultOutput,
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

  Directory getDir(BundleMode mode) {
    return (mode == BundleMode.debug) ? debugDir : releaseDir;
  }

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
  if (config.license && !config.licenseFile.existsSync()) {
    Logger.info('Ignoring license, file not found in ${'LICENSE'.path}.');
    config.license = false;
  }
  config.game = config.game.trim();
  _resolveGamePath(config);
  config.stage = config.stage.trim();
  config.stage = config.stage.isEmpty ? 'stage\\' : config.stage;
  Logger.log('');
  return config;
}

final gameDirs = [
  Directory('C:\\Program Files (x86)\\Steam\\steamapps\\common\\Cyberpunk 2077'),
  Directory('C:\\Program Files (x86)\\GOG Galaxy\\Games\\Cyberpunk 2077'),
  Directory('C:\\Program Files\\Epic Games\\Cyberpunk 2077)')
];

void _resolveGamePath(RedConfig config) {
  final environment = Platform.environment;
  final gamePath = config.game;

  if (environment.containsKey("REDCLI_GAME")) {
    config.game = environment["REDCLI_GAME"]!;
    if (!config.gameDir.existsSync()) {
      Logger.error(
          'Could not find game\'s directory in ${config.game.path} using environment variable (${'REDCLI_GAME'.cyan}).');
      exit(2);
    }
    return;
  }
  if (config.gameDir.existsSync()) {
    return;
  }
  config.game = _detectGamePath() ?? '';
  if (config.game.isEmpty) {
    Logger.error('Could not find game\'s directory in ${gamePath.path}.');
    exit(2);
  }
}

String? _detectGamePath() {
  for (final dir in gameDirs) {
    if (dir.existsSync()) {
      return dir.path;
    }
  }
  return null;
}
