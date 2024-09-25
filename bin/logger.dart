import 'dart:io';

import 'package:chalkdart/chalkstrings.dart';

import 'extensions/ncurses_ext.dart';

class Logger {
  /// Logger ///

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

  /// Cursor ///

  static saveCursor() => stdout.write(''.saveCursorPosition);

  static restoreCursor([int linesDown = 0]) {
    if (linesDown <= 0) {
      stdout.write(''.restoreCursorPosition);
    } else {
      stdout.write(''.restoreCursorPosition.moveDown(linesDown));
    }
  }

  static hideCursor() => stdout.write(''.hideCursor);

  static showCursor() => stdout.write(''.showCursor);

  /// Screen ///

  static clearScreen() => stdout.writeln(''.moveHome.clearScreen);

  static clearLine() => stdout.write(''.clearLine.moveToStartOfLine);
}
