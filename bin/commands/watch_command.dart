import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:chalkdart/chalkstrings.dart';

import '../data/red_config.dart';
import '../logger.dart';
import '../tasks/bundle_task.dart';
import '../tasks/watch_task.dart';

class WatchCommand extends Command {
  @override
  final String name = 'watch';

  @override
  final String description = 'Watch files to hot reload scripts using VSCode extension and RedHotTools.';

  final RedConfig config;

  WatchCommand({
    required this.config,
  });

  @override
  Future<void> run() async {
    if (argResults == null) {
      return;
    }
    if (!watchSetup(config)) {
      exit(2);
    }
    BundleMode mode = BundleMode.debug;
    //DateTime start = DateTime.now();

    Logger.log('Watching in ${mode.name.cyan} mode (${"CTRL + C".bold} to stop):');
    await watch(config, mode);
    /*
    int elapsedTime = DateTime.now().difference(start).inMilliseconds;

    Logger.done('Installation of ${config.name.bold} done in ${formatTime(elapsedTime).bold}');
    */
  }
}
