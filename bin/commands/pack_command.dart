import 'package:args/command_runner.dart';
import 'package:chalkdart/chalkstrings.dart';

import '../data/red_config.dart';
import '../extensions/chalk_ext.dart';
import '../format.dart';
import '../logger.dart';
import '../tasks/bundle_task.dart';
import '../tasks/pack_task.dart';

class PackCommand extends Command {
  @override
  final String name = 'pack';

  @override
  final String description = 'Pack scripts in an archive for release (include bundle step).';

  final RedConfig config;

  PackCommand({
    required this.config,
  }) {
    argParser.addOption(
      'debug',
      defaultsTo: 'false',
      help: 'Include scripts to run tests (ending with ${'Test.reds'.path}).',
    );
    argParser.addOption(
      'release',
      defaultsTo: 'true',
      help: 'Exclude test scripts.',
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
    BundleMode mode = argResults!.option('debug') == 'true' ? BundleMode.debug : BundleMode.release;
    bool clean = argResults!.flag('clean');
    String cleanInfo = clean ? 'clean output' : 'keep output';
    DateTime start = DateTime.now();

    Logger.log('Packing in ${mode.name.cyan} mode (${cleanInfo.cyan}):');
    ArchiveInfo info = pack(config, mode, clean);
    int elapsedTime = DateTime.now().difference(start).inMilliseconds;

    Logger.done(
        'Archive ${info.path.bold} ready in ${formatTime(elapsedTime).bold} (${formatSize(info.totalSize).cyan}).');
  }
}
