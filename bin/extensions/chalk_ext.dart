import 'package:chalkdart/chalk.dart';
import 'package:chalkdart/chalkstrings.dart';

extension ChalkExt on Chalk {

  String path(String path) {
    return green('"$path"');
  }

}

extension ChalkStringExt on String {
  static final Chalk _chalk = Chalk();

  String get path => _chalk.path(this);

}
