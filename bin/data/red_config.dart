import 'dart:convert';
import 'dart:io';

import 'package:chalkdart/chalkstrings.dart';
import 'package:path/path.dart' as p;
import 'package:toml/toml.dart';

import '../data/toml_config.dart';
import '../extensions/chalk_ext.dart';
import '../extensions/filesystem_ext.dart';
import '../logger.dart';
import '../tasks/bundle_task.dart';
import 'script_language.dart';

class RedConfig {
  String name;
  String version;
  bool license;
  String game;
  String stage;
  int watchTime;
  RedConfigScripts scripts;
  RedConfigPlugin? plugin;

  RedConfig({
    this.name = '',
    this.license = false,
    this.version = '',
    this.game = '',
    this.stage = 'stage\\',
    this.watchTime = 0,
    this.scripts = const RedConfigScripts(),
    this.plugin,
  });

  File get licenseFile => File('LICENSE');

  Directory get gameDir => Directory(game);

  Directory get stageDir => Directory(stage);

  Directory get rhtDir => Directory(p.join(game, 'red4ext', 'plugins', 'RedHotTools'));

  Directory get storageDir => Directory(p.join(game, 'r6', 'storages', name));

  /// Default settings file to generate for Redscript Language Server.
  File get defaultRLSFile => File(p.join(p.current, '.redscript-ide'));

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

  Directory getStorageDir(bool bundleOption) {
    return bundleOption
        ? Directory(p.join(stage, 'r6', 'storages', name))
        : Directory(p.join(game, 'r6', 'storages', name));
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

  /// Get Redscript Language Service file when type check is successful.
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

  void save() {
    final file = File(p.join(Directory.current.path, 'red.config.json'));
    final encoder = JsonEncoder.withIndent('  ');
    final json = encoder.convert(this);

    file.writeAsStringSync(json);
  }

  factory RedConfig.fromJson(Map<String, dynamic> json) {
    return RedConfig(
      name: json['name'] ?? '',
      version: json['version'] ?? '',
      license: json['license'] ?? false,
      game: json['game'] ?? '',
      stage: json['stage'] ?? 'stage\\',
      watchTime: json['watchTime'] ?? 0,
      scripts: RedConfigScripts.fromJson(json['scripts']),
      plugin: json['plugin'] != null ? RedConfigPlugin.fromJson(json['plugin']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['name'] = name;
    json['version'] = version;
    json['license'] = license;
    if (game.isNotEmpty) {
      json['game'] = game;
    }
    if (stage.isNotEmpty) {
      json['stage'] = stage;
    }
    json['watchTime'] = watchTime;
    json['scripts'] = scripts.toJson();
    if (plugin != null) {
      json['plugin'] = plugin!.toJson();
    }
    return json;
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

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    if (redscript != null) {
      json['redscript'] = redscript!.toJson();
    }
    if (cet != null) {
      json['cet'] = cet!.toJson();
    }
    return json;
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

  bool filterFile(String path);

  String toGamePath(RedConfig config, String path);

  String relativeGamePath(RedConfig config, String path);

  Map<String, dynamic> toJson() {
    return {
      'src': src,
    };
  }
}

class RedConfigRedscript extends RedConfigScriptLanguage {
  static const String defaultOutput = 'r6\\scripts\\';
  static const Duration defaultDebounceTime = Duration(seconds: 3);

  final Duration debounceTime;

  /// Path of a RedFileSystem storage.
  final String? storage;

  Directory? get storageDir => storage == null ? null : Directory(storage!);

  const RedConfigRedscript({
    super.src = '',
    super.output = RedConfigRedscript.defaultOutput,
    this.debounceTime = RedConfigRedscript.defaultDebounceTime,
    this.storage,
  });

  @override
  bool filterFile(String path) => path.endsWith('.reds');

  factory RedConfigRedscript.fromJson(Map<String, dynamic> json) {
    final debounceTimeValue = json['debounceTime'] ?? RedConfigRedscript.defaultDebounceTime.inMilliseconds;
    Duration debounceTime = Duration(milliseconds: debounceTimeValue);

    if (debounceTime.inMilliseconds < 1000) {
      debounceTime = RedConfigRedscript.defaultDebounceTime;
    }
    return RedConfigRedscript(
      src: json['src'] ?? '',
      output: json['output'] ?? RedConfigRedscript.defaultOutput,
      debounceTime: debounceTime,
      storage: json['storage'],
    );
  }

  @override
  String toGamePath(RedConfig config, String path) {
    final redscriptInstallDir = config.getInstallDir(ScriptLanguage.redscript);

    if (path.startsWith(src)) {
      path = p.relative(path, from: src);
      path = p.join(redscriptInstallDir.path, path);
    }
    return path;
  }

  @override
  String relativeGamePath(RedConfig config, String path) => p.relative(path, from: config.game);

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();

    if (output != RedConfigRedscript.defaultOutput) {
      json['output'] = output;
    }
    if (debounceTime.inMilliseconds != RedConfigRedscript.defaultDebounceTime.inMilliseconds) {
      json['debounceTime'] = debounceTime.inMilliseconds;
    }
    if (storage != null && storage!.isNotEmpty) {
      json['storage'] = storage;
    }
    return json;
  }
}

class RedConfigCET extends RedConfigScriptLanguage {
  static const String defaultOutput = "bin\\x64\\plugins\\cyber_engine_tweaks\\mods\\";

  const RedConfigCET({
    super.src = '',
    super.output = RedConfigCET.defaultOutput,
  });

  @override
  bool filterFile(String path) => path.endsWith('.lua');

  @override
  String toGamePath(RedConfig config, String path) => throw UnimplementedError();

  @override
  String relativeGamePath(RedConfig config, String path) => throw UnimplementedError();

  factory RedConfigCET.fromJson(Map<String, dynamic> json) {
    return RedConfigCET(
      src: json['src'] ?? '',
      output: json['output'] ?? RedConfigCET.defaultOutput,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();

    if (output != RedConfigCET.defaultOutput) {
      json['output'] = output;
    }
    return json;
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

  Map<String, dynamic> toJson() {
    return {
      'debug': debug,
      'release': release,
    };
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
