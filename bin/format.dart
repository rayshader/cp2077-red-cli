String formatTime(int time) {
  String text;

  if (time < 1000) {
    text = '$time ms';
  } else if (time < 60 * 1000) {
    text = '${(time / 1000).toStringAsFixed(3)} s';
  } else {
    text = '${(time / 60 / 1000).toStringAsFixed(0)} m';
  }
  return text;
}

String formatSize(int size) {
  String text;

  if (size < 1000) {
    text = '$size bytes';
  } else if (size < 1000 * 1000) {
    text = '${(size / 1000).toStringAsFixed(3)} KB';
  } else {
    text = '${(size / 1000 / 1000).toStringAsFixed(3)} MB';
  }
  return text;
}
