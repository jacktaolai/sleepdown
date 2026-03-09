/// 周次显示格式化工具
///
/// 将离散周次转换为易读格式
/// [1, 2, 8, 9, 10] → "1-2、8-10"
/// [1, 3, 5, 7] → "1、3、5、7"
/// [1, 2, 3, 4, 5, 6, 7, 8] → "1-8"
class WeekDisplayFormatter {
  /// 将离散周次转换为易读格式
  static String format(List<int> weeks) {
    if (weeks.isEmpty) return '';

    final sorted = List<int>.from(weeks)..sort();
    final ranges = <String>[];
    int start = sorted[0];
    int end = sorted[0];

    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i] == end + 1) {
        end = sorted[i];
      } else {
        ranges.add(_formatRange(start, end));
        start = sorted[i];
        end = sorted[i];
      }
    }
    ranges.add(_formatRange(start, end));

    return ranges.join('、');
  }

  static String _formatRange(int start, int end) {
    if (start == end) return '$start';
    return '$start-$end';
  }

  /// 解析周次字符串为列表
  /// 支持格式：
  /// - 单周: "1"
  /// - 连续: "1-8"
  /// - 混合: "1、3、5、7" 或 "1-2、8-10"
  static List<int> parse(String input) {
    if (input.isEmpty) return [];

    final weeks = <int>[];
    final parts = input.split('、');

    for (final part in parts) {
      if (part.contains('-')) {
        final range = part.split('-');
        if (range.length == 2) {
          final start = int.tryParse(range[0]);
          final end = int.tryParse(range[1]);
          if (start != null && end != null) {
            for (int i = start; i <= end; i++) {
              weeks.add(i);
            }
          }
        }
      } else {
        final week = int.tryParse(part);
        if (week != null) {
          weeks.add(week);
        }
      }
    }

    return weeks.toSet().toList()..sort();
  }
}
