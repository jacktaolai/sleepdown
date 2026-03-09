import 'package:flutter_test/flutter_test.dart';
import 'package:sleepdown/utils/week_display_formatter.dart';

void main() {
  group('WeekDisplayFormatter', () {
    group('format', () {
      test('should format empty list', () {
        final result = WeekDisplayFormatter.format([]);
        expect(result, equals(''));
      });

      test('should format single week', () {
        final result = WeekDisplayFormatter.format([1]);
        expect(result, equals('1'));
      });

      test('should format consecutive weeks', () {
        final result = WeekDisplayFormatter.format([1, 2, 3, 4, 5, 6, 7, 8]);
        expect(result, equals('1-8'));
      });

      test('should format discrete weeks', () {
        final result = WeekDisplayFormatter.format([1, 3, 5, 7]);
        expect(result, equals('1、3、5、7'));
      });

      test('should format mixed consecutive and discrete weeks', () {
        final result = WeekDisplayFormatter.format([1, 2, 8, 9, 10]);
        expect(result, equals('1-2、8-10'));
      });

      test('should format unsorted weeks correctly', () {
        final result = WeekDisplayFormatter.format([10, 8, 9, 1, 2]);
        expect(result, equals('1-2、8-10'));
      });

      test('should format single range with many weeks', () {
        final result = WeekDisplayFormatter.format([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18]);
        expect(result, equals('1-18'));
      });

      test('should format with large gaps', () {
        final result = WeekDisplayFormatter.format([1, 2, 10, 11, 12, 18, 19, 20]);
        expect(result, equals('1-2、10-12、18-20'));
      });
    });

    group('parse', () {
      test('should parse empty string', () {
        final result = WeekDisplayFormatter.parse('');
        expect(result, isEmpty);
      });

      test('should parse single week', () {
        final result = WeekDisplayFormatter.parse('1');
        expect(result, equals([1]));
      });

      test('should parse consecutive weeks', () {
        final result = WeekDisplayFormatter.parse('1-8');
        expect(result, equals([1, 2, 3, 4, 5, 6, 7, 8]));
      });

      test('should parse discrete weeks', () {
        final result = WeekDisplayFormatter.parse('1、3、5、7');
        expect(result, equals([1, 3, 5, 7]));
      });

      test('should parse mixed format', () {
        final result = WeekDisplayFormatter.parse('1-2、8-10');
        expect(result, equals([1, 2, 8, 9, 10]));
      });

      test('should remove duplicates', () {
        final result = WeekDisplayFormatter.parse('1、2、1、3');
        expect(result, equals([1, 2, 3]));
      });

      test('should handle invalid input gracefully', () {
        final result = WeekDisplayFormatter.parse('abc');
        expect(result, isEmpty);
      });

      test('should handle partial invalid input', () {
        final result = WeekDisplayFormatter.parse('1-abc');
        expect(result, isEmpty);
      });
    });

    group('round trip', () {
      test('should handle format then parse', () {
        final weeks = [1, 2, 8, 9, 10, 15, 16, 17];
        final formatted = WeekDisplayFormatter.format(weeks);
        final parsed = WeekDisplayFormatter.parse(formatted);
        expect(parsed, equals([1, 2, 8, 9, 10, 15, 16, 17]));
      });

      test('should handle parse then format', () {
        final input = '1-2、8-10、15-17';
        final parsed = WeekDisplayFormatter.parse(input);
        final formatted = WeekDisplayFormatter.format(parsed);
        expect(formatted, equals('1-2、8-10、15-17'));
      });
    });
  });
}
