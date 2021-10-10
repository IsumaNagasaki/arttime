import 'package:flutter/foundation.dart';

import 'date_ext.dart';

enum Category {
  single,
  regular,
  unlimited,
  contest,
}

extension Format on Category {
  String format() {
    switch (this) {
      case Category.single:
        return "single";
      case Category.regular:
        return "regular";
      case Category.unlimited:
        return "unlimited";
      case Category.contest:
        return "contest";
    }
  }
}

Category parseCategory(String value) {
  switch (value) {
    case "single":
      return Category.single;
    case "regular":
      return Category.regular;
    case "unlimited":
      return Category.unlimited;
    case "contest":
      return Category.contest;
  }
  // Default
  return Category.single;
}

const List<Category> categoryValues = [
  Category.single,
  Category.regular,
  Category.unlimited,
  Category.contest
];

class Challenge {
  final String title;
  final String description;
  final String imageUrl;
  final String authorContact;
  final Category category;
  final DateTime? start;
  final DateTime? end;

  Challenge(this.title, this.description, this.imageUrl, this.authorContact,
      this.category,
      {this.start, this.end});

  bool isPresentIn(Week week) {
    final endFits = (end?.isAfter(week.start) ?? true) ||
        (end?.isAtSameMomentAs(week.start) ?? true);
    final startFits = (start?.isBefore(week.end) ?? true) ||
        (start?.isAtSameMomentAs(week.end) ?? true);
    return endFits && startFits;
  }

  Challenge.fromJson(Map<String, dynamic> json)
      : title = json['title'] as String,
        description = json['description'] as String,
        imageUrl = json["image_url"] as String,
        authorContact = json["author_contact"] as String,
        category = parseCategory(json["category"] as String),
        start = json["start"] == null
            ? null
            : DateTime.parse(json["start"] as String),
        end =
            json["end"] == null ? null : DateTime.parse(json["end"] as String);

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        "image_url": imageUrl,
        "author_contact": authorContact,
        "category": category.format(),
        "start": start?.toIso8601String(),
        "end": end?.toIso8601String()
      };
}

class Week {
  final DateTime start;
  final DateTime end;

  Week._(this.start, this.end);

  static Week fromDate(DateTime dateTime) {
    final date = dateTime.onlyDate();
    final start = date.subtract(Duration(days: date.weekday - 1));
    final end = start.add(const Duration(days: 6));
    return Week._(start, end);
  }

  static Week current() => fromDate(DateTime.now());

  Week next() => Week._(
      start.add(const Duration(days: 7)), end.add(const Duration(days: 7)));

  Week prev() => Week._(start.subtract(const Duration(days: 7)),
      end.subtract(const Duration(days: 7)));

  bool hasDate(DateTime date) =>
      start.compareTo(date) <= 0 && end.compareTo(date) >= 0;
}
