import '../models/course.dart';

class WeekRangeParser {
  static List<WeekRange> parse(String input) {
    final ranges = <WeekRange>[];
    if (input.trim().isEmpty) return ranges;

    final parts = input.split('、');

    for (var part in parts) {
      part = part.trim();
      if (part.isEmpty) continue;

      WeekType type = WeekType.all;
      if (part.endsWith('单')) {
        type = WeekType.odd;
        part = part.substring(0, part.length - 1);
      } else if (part.endsWith('双')) {
        type = WeekType.even;
        part = part.substring(0, part.length - 1);
      }

      part = part.trim();
      if (part.isEmpty) continue;

      try {
        if (part.contains('-')) {
          final range = part.split('-');
          if (range.length == 2) {
            final start = int.parse(range[0].trim());
            final end = int.parse(range[1].trim());
            if (start <= end && start >= 1 && end <= 25) {
              ranges.add(WeekRange(
                start: start,
                end: end,
                type: type,
              ));
            }
          }
        } else {
          final week = int.parse(part);
          if (week >= 1 && week <= 25) {
            ranges.add(WeekRange(
              start: week,
              end: week,
              type: type,
            ));
          }
        }
      } catch (_) {
        continue;
      }
    }

    return ranges;
  }

  static String format(List<WeekRange> ranges) {
    if (ranges.isEmpty) return '';

    final sortedRanges = List<WeekRange>.from(ranges)
      ..sort((a, b) => a.start.compareTo(b.start));

    return sortedRanges.map((r) => r.toString()).join('、');
  }

  static bool isValid(String input) {
    final ranges = parse(input);
    return ranges.isNotEmpty;
  }
}
