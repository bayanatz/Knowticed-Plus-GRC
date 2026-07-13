String capitalizeMonth(String date) {
  List<String> parts = date.split(' ');
  if (parts.length == 3) {
    parts[1] = parts[1][0].toUpperCase() + parts[1].substring(1);
  }
  return parts.join(' ');
}

String capitalizeAmPm(String time) {
  if (time.toLowerCase().contains('am') || time.toLowerCase().contains('pm')) {
    time = time.replaceAll('am', 'AM').replaceAll('pm', 'PM');
  }
  return time;
}
