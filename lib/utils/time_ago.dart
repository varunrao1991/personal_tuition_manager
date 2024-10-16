String timeAgoString(DateTime dateTime) {
  final DateTime currentDate = DateTime.now();

  final int daysAgo = currentDate.difference(dateTime).inDays;
  final int monthsAgo = (currentDate.year - dateTime.year) * 12 +
      currentDate.month -
      dateTime.month;
  final int yearsAgo = currentDate.year - dateTime.year;

  if (yearsAgo >= 1) {
    return yearsAgo == 1 ? '1 year ago' : '$yearsAgo years ago';
  } else if (monthsAgo >= 1) {
    return monthsAgo == 1 ? '1 month ago' : '$monthsAgo months ago';
  } else {
    return daysAgo == 1 ? '1 day ago' : '$daysAgo days ago';
  }
}
