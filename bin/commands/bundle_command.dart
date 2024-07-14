import 'package:args/command_runner.dart';
import 'package:chalkdart/chalkstrings.dart';

import '../data/red_config.dart';
import '../extensions/chalk_ext.dart';
import '../format.dart';
import '../logger.dart';
import '../tasks/bundle_task.dart';

class BundleCommand extends Command {
  @override
  final String name = 'bundle';

  @override
  final String description = 'Bundle scripts.';

  final RedConfig config;

  BundleCommand({
    required this.config,
  }) {
    argParser.addFlag(
      'debug',
      negatable: false,
      defaultsTo: false,
      help: 'Include scripts to run tests (ending with ${'Test.reds'.path}).',
    );
    argParser.addFlag(
      'release',
      negatable: false,
      defaultsTo: true,
      help: 'Exclude test scripts.',
    );
  }

  @override
  void run() {
    if (argResults == null) {
      return;
    }
    BundleMode mode = argResults!.flag('debug') ? BundleMode.debug : BundleMode.release;
    DateTime start = DateTime.now();

    Logger.log('Bundling in ${mode.name.cyan} mode:');
    BundleInfo info = bundle(config, mode);

    bundlePlugin(config, mode);
    int elapsedTime = DateTime.now().difference(start).inMilliseconds;

    logRedscript(info.redscriptInfo);
    logCET(info.cetInfo);
    Logger.done('Bundle ${config.name.bold} ready in ${formatTime(elapsedTime).bold} (${formatSize(info.size).cyan})');
  }
}
