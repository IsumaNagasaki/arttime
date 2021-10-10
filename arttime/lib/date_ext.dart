extension OnlyDate on DateTime {
  DateTime onlyDate() {
    return DateTime(year, month, day);
  }

  String formatDate() {
    return "${day.toString().padLeft(2, '0')}.${month.toString().padLeft(2, '0')}.${year.toString()}";
  }
}
