import 'package:args/command_runner.dart';
import 'package:chalkdart/chalkstrings.dart';

import '../data/red_config.dart';
import '../extensions/chalk_ext.dart';
import '../format.dart';
import '../logger.dart';
import '../tasks/bundle_task.dart';
import '../tasks/install_task.dart';

class InstallCommand extends Command {
  @override
  final String name = 'install';

  @override
  final String description = 'Install scripts in your game\'s directory.';

  final RedConfig config;

  InstallCommand({
    required this.config,
  }) {
    argParser.addFlag(
      'debug',
      negatable: false,
      defaultsTo: true,
      help: 'Include scripts to run tests (ending with ${'Test.reds'.path}).',
    );
    argParser.addFlag(
      'release',
      negatable: false,
      defaultsTo: false,
      help: 'Exclude test scripts.',
    );
    argParser.addFlag(
      'bundle',
      defaultsTo: false,
      help: 'Bundle scripts before installing.',
    );
    argParser.addFlag(
      'clean',
      negatable: true,
      defaultsTo: true,
      help: 'Remove ${config.dist.path} output after command succeed.',
    );
  }

  @override
  void run() {
    if (argResults == null) {
      return;
    }
    BundleMode mode = argResults!.flag('debug') ? BundleMode.debug : BundleMode.release;
    bool bundle = argResults!.flag('bundle');
    bool clean = argResults!.flag('clean');
    String cleanInfo = clean ? 'clean output' : 'keep output';
    DateTime start = DateTime.now();

    Logger.log('Installing in ${mode.name.cyan} mode (${cleanInfo.cyan}):');
    install(config, mode, bundle, clean);
    installPlugin(config, mode);
    int elapsedTime = DateTime.now().difference(start).inMilliseconds;

    Logger.done('Installation of ${config.name.bold} done in ${formatTime(elapsedTime).bold}');
  }
}
