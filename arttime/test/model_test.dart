import 'package:test/test.dart';
import 'package:arttime/model.dart';

void main() {
  group("Week", () {
    test('.fromDate() should return a correct week', () {
      final week = Week.fromDate(DateTime(2021, 10, 9));
      expect(week.start, equals(DateTime(2021, 10, 4)));
      expect(week.end, equals(DateTime(2021, 10, 10)));
    });

    test('.next() should correctly increment week', () {
      final week = Week.fromDate(DateTime(2021, 10, 9)).next();
      expect(week.start, equals(DateTime(2021, 10, 11)));
      expect(week.end, equals(DateTime(2021, 10, 17)));
    });

    test('.prev() should correctly decrement week', () {
      final week = Week.fromDate(DateTime(2021, 10, 9)).prev();
      expect(week.start, equals(DateTime(2021, 9, 27)));
      expect(week.end, equals(DateTime(2021, 10, 3)));
    });
  });

  group("Challenge", () {
    test(
        '.isPresentIn() should correctly estimate if a challenge is happening during that week',
        () {
      final week = Week.fromDate(DateTime(2021, 10, 9));
      final challenge = Challenge(
          "Title", "Description", "/some/url", "author", Category.single,
          start: DateTime(2021, 10, 6), end: DateTime(2021, 10, 9));
      expect(challenge.isPresentIn(week), isTrue);
      final challengeNoStart = Challenge(
          "Title", "Description", "/some/url", "author", Category.single,
          start: null, end: DateTime(2021, 10, 9));
      expect(challengeNoStart.isPresentIn(week), isTrue);
      final challengeNoEnd = Challenge(
          "Title", "Description", "/some/url", "author", Category.single,
          start: DateTime(2021, 10, 6), end: null);
      expect(challengeNoEnd.isPresentIn(week), isTrue);
    });

    test(
        '.isPresentIn() should correctly estimate if a challenge is not happening during that week',
        () {
      final week = Week.fromDate(DateTime(2021, 10, 9));
      final challenge = Challenge(
          "Title", "Description", "/some/url", "author", Category.single,
          start: DateTime(2021, 10, 12), end: DateTime(2021, 10, 16));
      expect(challenge.isPresentIn(week), isFalse);
      final challengeNoStart = Challenge(
          "Title", "Description", "/some/url", "author", Category.single,
          start: null, end: DateTime(2021, 10, 2));
      expect(challengeNoStart.isPresentIn(week), isFalse);
      final challengeNoEnd = Challenge(
          "Title", "Description", "/some/url", "author", Category.single,
          start: DateTime(2021, 10, 12), end: null);
      expect(challengeNoEnd.isPresentIn(week), isFalse);
    });
  });
}
