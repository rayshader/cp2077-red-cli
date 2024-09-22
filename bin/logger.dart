import 'dart:io';

import 'package:chalkdart/chalkstrings.dart';

class Logger {
  static log(String message, {bool withoutNewline = false}) {
    _prefix('', message, withoutNewline);
  }

  static info(String message, {bool withoutNewline = false}) {
    _prefix('i '.blue, message, withoutNewline);
  }

  static error(String message, {bool withoutNewline = false}) {
    _prefix('✗ '.bold.red, message.bold, withoutNewline);
  }

  static done(String message, {bool withoutNewline = false}) {
    _prefix('✓ '.green, message, withoutNewline);
  }

  static _prefix(String prefix, String message, bool withoutNewline) {
    if (withoutNewline) {
      stdout.write('$prefix$message');
    } else {
      print('$prefix$message');
    }
  }
}
