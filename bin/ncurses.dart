import 'dart:io';

/// Reference from https://gist.github.com/ConnerWill/d4b6c776b509add763e17f9f113fd25b
class NCurses {
  static bool get hasAnsiEscapes => stdout.supportsAnsiEscapes;

  /// Cursor ///

  static String get saveCursorPosition => hasAnsiEscapes ? '\x1B7' : '';

  static String get restoreCursorPosition => hasAnsiEscapes ? '\x1B8' : '';

  static String get hideCursor => hasAnsiEscapes ? '\x1B[?25l' : '';

  static String get showCursor => hasAnsiEscapes ? '\x1B[?25h' : '';

  static String get moveHome => hasAnsiEscapes ? '\x1B[H' : '';

  static String get moveToStartOfLine => hasAnsiEscapes ? '\x0D' : '';

  static String moveDown(int lines) => hasAnsiEscapes ? '\x1B[${lines}B' : '';

  /// Screen ///

  static String get clearScreen => hasAnsiEscapes ? '\x1B[2J' : '';

  static String get clearLine => hasAnsiEscapes ? '\x1B[2K' : '';
}
