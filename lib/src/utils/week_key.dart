// FILE: lib/src/utils/week_key.dart
class WeekKey {
  static String nowIsoWeekId([DateTime? now]) {
    final d = (now ?? DateTime.now()).toUtc();
    final isoWeek = _isoWeekNumber(d);
    final year = _isoWeekYear(d);
    return '$year-W${isoWeek.toString().padLeft(2, '0')}';
  }

  static ({int year, int week}) parseWeekId(String weekId) {
    final parts = weekId.split('-W');
    if (parts.length != 2) {
      throw FormatException('Invalid weekId: $weekId');
    }
    final year = int.parse(parts[0]);
    final week = int.parse(parts[1]);
    return (year: year, week: week);
  }

  static int weekIndex(String weekId) {
    final p = parseWeekId(weekId);
    return p.year * 53 + p.week; // stable across years
  }

  static int dutyRoom({
    required int startRoom,
    required int roomCount,
    DateTime? now,
  }) {
    final weekId = nowIsoWeekId(now);
    final offset = weekIndex(weekId) % roomCount;
    final sr = startRoom.clamp(1, roomCount);
    return (((sr - 1) + offset) % roomCount) + 1;
  }

  static int _isoWeekNumber(DateTime date) {
    final thursday = date.add(Duration(days: 3 - ((date.weekday + 6) % 7)));
    final firstThursday = DateTime.utc(thursday.year, 1, 4);
    final diff = thursday.difference(firstThursday);
    return 1 + (diff.inDays ~/ 7);
  }

  static int _isoWeekYear(DateTime date) {
    final thursday = date.add(Duration(days: 3 - ((date.weekday + 6) % 7)));
    return thursday.year;
  }

  static String prettyWeekLabel(String weekId) => weekId.replaceAll('-W', ' / Week ');
}