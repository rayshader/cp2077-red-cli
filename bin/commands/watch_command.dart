import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:chalkdart/chalkstrings.dart';

import '../data/red_config.dart';
import '../format.dart';
import '../logger.dart';
import '../tasks/bundle_task.dart';
import '../tasks/install_task.dart';
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
    Logger.clearScreen();
    BundleMode mode = BundleMode.debug;

    install(config, mode, false, false);
    DateTime start = DateTime.now();

    ProcessSignal.sigint.watch().listen((signal) => _terminate(start));
    Logger.log('Watching in ${mode.name.cyan} mode (${"CTRL + C".bold} to stop):');
    try {
      Logger.hideCursor();
      await watch(config, mode);
    } catch (_) {
      _terminate(start, 1);
    }
  }

  void _terminate(DateTime start, [int exitCode = 0]) {
    int elapsedTime = DateTime.now().difference(start).inMilliseconds;

    config.watchTime += elapsedTime;
    config.save();
    Logger.clearScreen();
    Logger.showCursor();
    Logger.done('Session watch time ${formatTime(elapsedTime).bold} (total ${formatTime(config.watchTime).bold})');
    exit(exitCode);
  }
}
