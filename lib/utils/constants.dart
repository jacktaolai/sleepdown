import '../models/time_schedule.dart';

class Constants {
  static const int maxWeeks = 25;
  static const int defaultTotalWeeks = 18;
  static const int daysPerWeek = 7;

  static const List<TimeSlot> defaultTimeSlots = [
    TimeSlot(section: 1, startHour: 8, startMinute: 0, endHour: 8, endMinute: 45),
    TimeSlot(section: 2, startHour: 8, startMinute: 50, endHour: 9, endMinute: 35),
    TimeSlot(section: 3, startHour: 9, startMinute: 50, endHour: 10, endMinute: 35),
    TimeSlot(section: 4, startHour: 10, startMinute: 40, endHour: 11, endMinute: 25),
    TimeSlot(section: 5, startHour: 11, startMinute: 35, endHour: 12, endMinute: 20),
    TimeSlot(section: 6, startHour: 14, startMinute: 0, endHour: 14, endMinute: 45),
    TimeSlot(section: 7, startHour: 14, startMinute: 50, endHour: 15, endMinute: 35),
    TimeSlot(section: 8, startHour: 15, startMinute: 50, endHour: 16, endMinute: 35),
    TimeSlot(section: 9, startHour: 16, startMinute: 40, endHour: 17, endMinute: 25),
    TimeSlot(section: 10, startHour: 19, startMinute: 0, endHour: 19, endMinute: 45),
    TimeSlot(section: 11, startHour: 19, startMinute: 50, endHour: 20, endMinute: 35),
  ];

  static const List<int> courseColors = [
    0xFF3B82F6,
    0xFF10B981,
    0xFFF97316,
    0xFF8B5CF6,
    0xFF06B6D4,
    0xFF6B7280,
  ];

  static const List<String> weekDayNames = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  static String getWeekDayName(int dayOfWeek) {
    if (dayOfWeek < 1 || dayOfWeek > 7) return '';
    return weekDayNames[dayOfWeek - 1];
  }
}
