import 'package:chalkdart/chalkstrings.dart';

class Logger {
  static log(String message) {
    _prefix('', message);
  }

  static info(String message) {
    _prefix('ⓘ '.blue, message);
  }

  static error(String message) {
    _prefix('✗ '.bold.red, message.bold);
  }

  static done(String message) {
    _prefix('✓ '.green, message);
  }

  static _prefix(String prefix, String message) {
    print('$prefix$message');
  }
}
