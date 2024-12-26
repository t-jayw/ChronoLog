String formatDurationDays(Duration d) {
  final (amount, unit) = formatDuration(d);
  return '$amount $unit';
}

(int amount, String unit) formatDuration(Duration d) {
  if (d.inDays >= 365) {
    final years = d.inDays ~/ 365;
    return (years, years == 1 ? 'year' : 'years');
  }
  
  if (d.inDays >= 30) {
    final months = d.inDays ~/ 30;
    return (months, months == 1 ? 'month' : 'months');
  }
  
  if (d.inDays > 0) {
    return (d.inDays, d.inDays == 1 ? 'day' : 'days');
  }
  
  if (d.inHours > 0) {
    return (d.inHours, d.inHours == 1 ? 'hour' : 'hours');
  }
  
  if (d.inMinutes > 0) {
    return (d.inMinutes, d.inMinutes == 1 ? 'minute' : 'minutes');
  }
  
  return (d.inSeconds, d.inSeconds == 1 ? 'sec' : 'secs');
}
