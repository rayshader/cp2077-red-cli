import '../ncurses.dart';

extension NCursesExt on String {
  /// Cursor ///

  String get saveCursorPosition => '$this${NCurses.saveCursorPosition}';

  String get restoreCursorPosition => '$this${NCurses.restoreCursorPosition}';

  String get hideCursor => '$this${NCurses.hideCursor}';

  String get showCursor => '$this${NCurses.showCursor}';

  String get moveHome => '$this${NCurses.moveHome}';

  String get moveToStartOfLine => '$this${NCurses.moveToStartOfLine}';

  String moveDown(int lines) => '$this${NCurses.moveDown(lines)}';

  /// Screen ///

  String get clearScreen => '$this${NCurses.clearScreen}';

  String get clearLine => '$this${NCurses.clearLine}';
}
