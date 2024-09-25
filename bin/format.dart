String formatTime(int time) {
  String text;

  if (time < 1000) {
    text = '${time}ms';
  } else if (time < 60 * 1000) {
    text = '${(time / 1000).truncate()}s';
  } else if (time < 3600 * 1000) {
    final minutes = (time / 60 / 1000).truncate();
    final seconds = (time / 1000 % 60).truncate();

    text = '${minutes}m ${seconds}s';
  } else {
    final hours = (time / 3600 / 1000).truncate();
    final minutes = (time / 60 / 1000 % 60).truncate();
    final seconds = (time / 1000 % 60).truncate();

    text = '${hours}h ${minutes}m ${seconds}s';
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
