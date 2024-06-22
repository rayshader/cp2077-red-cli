import 'package:chalkdart/chalk.dart';

class Logger {
  static log(String message) {
    print(message);
  }

  static info(String message) {
    print('${chalk.blue('ⓘ')} $message');
  }

  static error(String message) {
    print('${chalk.bold.red('✗')} ${chalk.bold(message)}');
  }

  static done(String message) {
    print('${chalk.green('✓')} $message');
  }
}
