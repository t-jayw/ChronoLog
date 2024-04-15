String formatDuration(Duration d) {
  if (d.inDays > 365) {
    return '${d.inDays ~/ 365} yr${d.inDays ~/ 365 != 1 ? 's' : ''}';
  } else if (d.inDays > 30) {
    return '${d.inDays ~/ 30} mo${d.inDays ~/ 30 != 1 ? 's' : ''}';
  } else if (d.inDays > 7) {
    return '${d.inDays ~/ 7} wk${d.inDays ~/ 7 != 1 ? 's' : ''}';
  } else if (d.inDays > 0) {
    return '${d.inDays} d${d.inDays != 1 ? 's' : ''}';
  } else if (d.inHours > 0) {
    return '${d.inHours} hr${d.inHours != 1 ? 's' : ''}';
  } else if (d.inMinutes > 0) {
    return '${d.inMinutes} min${d.inMinutes != 1 ? 's' : ''}';
  } else {
    return '${d.inSeconds} s';
  }
}
