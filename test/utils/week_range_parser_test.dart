import 'package:flutter_test/flutter_test.dart';
import 'package:sleepdown/models/course.dart';
import 'package:sleepdown/utils/week_range_parser.dart';

void main() {
  group('WeekRangeParser', () {
    test('should parse continuous weeks', () {
      final ranges = WeekRangeParser.parse('1-16');
      
      expect(ranges.length, equals(1));
      expect(ranges[0].start, equals(1));
      expect(ranges[0].end, equals(16));
      expect(ranges[0].type, equals(WeekType.all));
    });

    test('should parse odd weeks', () {
      final ranges = WeekRangeParser.parse('1-16单');
      
      expect(ranges.length, equals(1));
      expect(ranges[0].start, equals(1));
      expect(ranges[0].end, equals(16));
      expect(ranges[0].type, equals(WeekType.odd));
    });

    test('should parse even weeks', () {
      final ranges = WeekRangeParser.parse('1-16双');
      
      expect(ranges.length, equals(1));
      expect(ranges[0].start, equals(1));
      expect(ranges[0].end, equals(16));
      expect(ranges[0].type, equals(WeekType.even));
    });

    test('should parse single week', () {
      final ranges = WeekRangeParser.parse('5');
      
      expect(ranges.length, equals(1));
      expect(ranges[0].start, equals(5));
      expect(ranges[0].end, equals(5));
    });

    test('should parse multiple weeks separated by comma', () {
      final ranges = WeekRangeParser.parse('1、2、8');
      
      expect(ranges.length, equals(3));
      expect(ranges[0].start, equals(1));
      expect(ranges[1].start, equals(2));
      expect(ranges[2].start, equals(8));
    });

    test('should parse combined ranges', () {
      final ranges = WeekRangeParser.parse('1-5、7-11单');
      
      expect(ranges.length, equals(2));
      expect(ranges[0].start, equals(1));
      expect(ranges[0].end, equals(5));
      expect(ranges[0].type, equals(WeekType.all));
      expect(ranges[1].start, equals(7));
      expect(ranges[1].end, equals(11));
      expect(ranges[1].type, equals(WeekType.odd));
    });

    test('should handle empty input', () {
      expect(WeekRangeParser.parse(''), isEmpty);
      expect(WeekRangeParser.parse('   '), isEmpty);
    });

    test('should handle invalid input gracefully', () {
      expect(WeekRangeParser.parse('abc'), isEmpty);
      expect(WeekRangeParser.parse('0'), isEmpty);
      expect(WeekRangeParser.parse('26'), isEmpty);
    });

    test('should format ranges correctly', () {
      final ranges = [
        const WeekRange(start: 1, end: 16, type: WeekType.all),
        const WeekRange(start: 17, end: 18, type: WeekType.odd),
      ];

      final formatted = WeekRangeParser.format(ranges);
      expect(formatted, equals('1-16、17-18单'));
    });

    test('should validate input correctly', () {
      expect(WeekRangeParser.isValid('1-16'), isTrue);
      expect(WeekRangeParser.isValid('1-16单'), isTrue);
      expect(WeekRangeParser.isValid('1、2、8'), isTrue);
      expect(WeekRangeParser.isValid(''), isFalse);
      expect(WeekRangeParser.isValid('abc'), isFalse);
    });
  });
}
