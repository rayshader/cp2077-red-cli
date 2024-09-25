import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:chalkdart/chalkstrings.dart';

import 'commands/bundle_command.dart';
import 'commands/install_command.dart';
import 'commands/pack_command.dart';
import 'commands/watch_command.dart';
import 'data/red_config.dart';

class RedRunner extends CommandRunner {
  @override
  final String? usageFooter = '\nGitHub: https://github.com/rayshader/cp2077-red-cli'
      '\nDiscord: https://discord.com/channels/717692382849663036/1254464502968356965';

  RedRunner()
      : super(
          'red-cli',
          '${'red-cli v0.4.0'.bold}\n'
              '\n'
              'A tool to bundle scripts of a mod for Cyberpunk 2077.',
        );
}

void main(List<String> args) async {
  final runner = RedRunner();
  final config = getConfig();

  if (config == null) {
    exit(1);
  }
  runner.addCommand(BundleCommand(config: config));
  runner.addCommand(InstallCommand(config: config));
  runner.addCommand(WatchCommand(config: config));
  runner.addCommand(PackCommand(config: config));
  runner.run(args);
}
