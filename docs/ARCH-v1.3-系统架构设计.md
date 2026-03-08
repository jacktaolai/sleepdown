# Sleepdown 系统架构设计文档

**版本**: v1.3
**日期**: 2026-03-08
**状态**: 待评审
**变更说明**: 重构数据模型，支持多课程表、课程信息与安排分离、离散周次存储

---

## 1. 架构概述

### 1.1 设计目标

基于 PRD-v1.2 需求文档与架构师评审意见，MVP 阶段架构设计聚焦以下核心目标：

| 目标 | 说明 | 对应需求 |
|------|------|----------|
| 快速启动 | 应用启动时间 < 1秒 | 用户体验需求 P0 |
| 离线可用 | 核心功能无需网络 | 用户体验需求 P0 |
| 轻量架构 | 最小化抽象层，快速迭代 | 开发效率需求 |
| 易于扩展 | 预留扩展点，支持后续功能 | 可维护性需求 |

### 1.2 架构原则

- **YAGNI 原则**：只实现当前需要的功能，避免过度设计
- **KISS 原则**：保持简单，优先选择直接方案
- **渐进式架构**：先用简单架构上线，根据需求逐步演进
- **扁平化目录**：按技术分层组织代码，降低导航复杂度

### 1.3 整体架构图

```
┌─────────────────────────────────────────────────────────────┐
│                      UI Layer (表现层)                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Screens   │  │  Widgets    │  │    Theme/Styles     │  │
│  │  (5个页面)   │  │  (3个核心)   │  │                     │  │
│  └──────┬──────┘  └──────┬──────┘  └──────────┬──────────┘  │
└─────────┼────────────────┼───────────────────┼──────────────┘
          │                │                   │
          ▼                ▼                   ▼
┌─────────────────────────────────────────────────────────────┐
│                    Logic Layer (逻辑层)                      │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              Riverpod StateNotifiers                  │  │
│  │   (CourseTableNotifier, SettingsNotifier, WeekNotifier)│  │
│  └───────────────────────────┬───────────────────────────┘  │
└──────────────────────────────┼──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                     Data Layer (数据层)                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │ Repository  │  │   SQLite    │  │   SharedPreferences │  │
│  │ (数据仓库)   │  │  (课程存储)  │  │    (简单设置)        │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. 分层架构设计

### 2.1 UI Layer（表现层）

负责 UI 渲染和用户交互。

#### 2.1.1 Screens（页面）

| 页面 | 路由 | 说明 | MVP优先级 |
|------|------|------|-----------|
| HomeScreen | `/` | 周视图课程表主页 | P0 必须 |
| CourseDetailScreen | `/course/:id` | 课程详情查看 | P0 必须 |
| CourseEditScreen | `/course/edit` | 课程编辑/新增 | P0 必须 |
| SettingsScreen | `/settings` | 应用设置（含时间设置入口） | P0 必须 |
| TimeSettingsScreen | `/settings/time` | 节次时间设置 | P0 必须 |

#### 2.1.2 Widgets（组件）

| 组件 | 说明 | MVP优先级 |
|------|------|-----------|
| CourseCard | 课程卡片（支持颜色标识） | P0 必须 |
| WeekSelector | 周次选择器（基础切换） | P0 必须 |
| ScheduleGrid | 课程表网格布局 | P0 必须 |

#### 2.1.3 Theme（主题）

- 统一管理应用色彩、间距
- 支持明/暗主题切换基础能力
- 支持应用主色调的切换（例如基于壁纸的主色）
- **字体策略**：优先使用系统默认字体，确保与平台体验一致

### 2.2 Logic Layer（逻辑层）

负责业务逻辑处理和状态管理，使用 Riverpod 简化实现。

#### 2.2.1 状态管理方案

采用 **Riverpod + StateNotifier** 作为状态管理方案。

#### 2.2.2 Notifiers 设计

```dart
/// 课程表数据管理
final courseTableProvider = StateNotifierProvider<CourseTableNotifier, CourseTable?>((ref) {
  return CourseTableNotifier(ref.read(courseTableRepositoryProvider));
});

/// 当前周次管理
final currentWeekProvider = StateProvider<int>((ref) {
  return WeekCalculator.calculateCurrentWeek();
});

/// 应用设置管理
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref.read(settingsRepositoryProvider));
});
```

### 2.3 Data Layer（数据层）

负责数据持久化，采用简化的 Repository 模式。

#### 2.3.1 数据源

| 数据源 | 说明 | 技术 | MVP用途 |
|--------|------|------|---------|
| SQLite | 本地关系数据库 | sqflite | 课程表、课程信息、课程安排存储 |
| SharedPreferences | 简单键值存储 | shared_preferences | 应用设置存储 |

---

## 3. 数据模型设计

### 3.1 核心实体关系图

```
┌─────────────────────────────────────────────────────────────────┐
│                        CourseTable (课程表)                      │
│  - id: String                                                    │
│  - name: String                                                  │
│  - semesterStartDate: DateTime                                   │
│  - totalWeeks: int                                               │
│  - timeScheduleId: String ──────────────┐                        │
└──────────────────────────────────────────│────────────────────────┘
                                           │
                                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                      TimeSchedule (作息时间表)                   │
│  - id: String                                                    │
│  - name: String                                                  │
│  - slots: List<TimeSlot>                                         │
│  - isDefault: bool                                               │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                       CourseInfo (课程信息)                      │
│  - id: String                                                    │
│  - courseTableId: String ──────────► CourseTable                 │
│  - name: String                                                  │
│  - credit: double?                                               │
│  - colorValue: int                                               │
│  - note: String?                                                 │
└──────────────────────────────────────────────────────────────────┘
                                           │
                                           │ 1:N
                                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                     CourseSchedule (课程安排)                    │
│  - id: String                                                    │
│  - courseInfoId: String ───────────► CourseInfo                  │
│  - teacher: String                                               │
│  - location: String                                              │
│  - dayOfWeek: int (1-7)                                          │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │ 节次模式 (二选一)                                            │ │
│  │  - startSection: int?                                       │ │
│  │  - endSection: int?                                         │ │
│  ├─────────────────────────────────────────────────────────────┤ │
│  │ 时间模式 (二选一)                                            │ │
│  │  - startHour: int?                                          │ │
│  │  - startMinute: int?                                        │ │
│  │  - endHour: int?                                            │ │
│  │  - endMinute: int?                                          │ │
│  └─────────────────────────────────────────────────────────────┘ │
│  - weeks: List<int>  ← 离散周次，如 [1, 2, 8, 9, 10]             │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 实体定义

#### 3.2.1 CourseTable（课程表）

```dart
/// 课程表 - 支持多课程表管理
class CourseTable {
  final String id;
  final String name;
  final DateTime semesterStartDate;  // 学期开始日期
  final int totalWeeks;              // 学期总周数，默认 18
  final String timeScheduleId;       // 关联的作息时间表 ID
  
  const CourseTable({
    required this.id,
    required this.name,
    required this.semesterStartDate,
    this.totalWeeks = 18,
    required this.timeScheduleId,
  });
}
```

**设计说明**：
- 一个用户可以有多个课程表（如不同学期、不同校区）
- 每个课程表关联一个作息时间表
- 学期开始日期用于计算当前周次

#### 3.2.2 CourseInfo（课程信息）

```dart
/// 课程信息 - 存储课程的基本属性
class CourseInfo {
  final String id;
  final String courseTableId;  // 所属课程表
  final String name;           // 课程名称
  final double? credit;        // 学分（可选）
  final int colorValue;        // 颜色值 (ARGB)
  final String? note;          // 备注
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const CourseInfo({
    required this.id,
    required this.courseTableId,
    required this.name,
    this.credit,
    required this.colorValue,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });
}
```

**设计说明**：
- 课程信息与课程安排分离，一个课程可以有多个上课安排
- 例如：一门课可能在不同时间、不同地点、由不同老师上课

#### 3.2.3 CourseSchedule（课程安排）

```dart
/// 课程安排 - 具体的上课时间和地点
/// 
/// 支持两种时间输入模式（互斥）：
/// - 节次模式：使用 startSection/endSection
/// - 时间模式：使用 startHour/startMinute/endHour/endMinute
class CourseSchedule {
  final String id;
  final String courseInfoId;   // 关联的课程信息
  final String teacher;        // 教师
  final String location;       // 上课地点
  final int dayOfWeek;         // 星期几 (1-7, 周一至周日)
  final List<int> weeks;       // 离散周次列表，如 [1, 2, 8, 9, 10]
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // ========== 节次模式字段（时间模式时为 null）==========
  final int? startSection;     // 开始节次
  final int? endSection;       // 结束节次
  
  // ========== 时间模式字段（节次模式时为 null）==========
  final int? startHour;        // 开始时
  final int? startMinute;      // 开始分
  final int? endHour;          // 结束时
  final int? endMinute;        // 结束分
  
  const CourseSchedule({
    required this.id,
    required this.courseInfoId,
    required this.teacher,
    required this.location,
    required this.dayOfWeek,
    required this.weeks,
    required this.createdAt,
    required this.updatedAt,
    this.startSection,
    this.endSection,
    this.startHour,
    this.startMinute,
    this.endHour,
    this.endMinute,
  });
  
  /// 是否使用时间模式
  /// 当 startSection 为 null 时，表示使用时间模式
  bool get useTimeMode => startSection == null;
  
  /// 判断该安排在指定周次是否有效
  bool isActiveInWeek(int week) => weeks.contains(week);
  
  /// 获取课程时长的节次数（仅节次模式有效）
  int? get sectionCount => 
    startSection != null && endSection != null 
      ? endSection! - startSection! + 1 
      : null;
  
  /// 获取时间显示文本
  /// 节次模式：显示 "第3-4节"
  /// 时间模式：显示 "14:30-16:00"
  String get timeDisplayText {
    if (useTimeMode) {
      return '${startHour!.toString().padLeft(2, '0')}:${startMinute!.toString().padLeft(2, '0')}-'
             '${endHour!.toString().padLeft(2, '0')}:${endMinute!.toString().padLeft(2, '0')}';
    }
    return '第$startSection-${endSection}节';
  }
  
  /// 获取周次范围的显示文本
  String get weeksDisplayText => WeekDisplayFormatter.format(weeks);
}
```

**时间输入模式说明**：

| 模式 | 使用场景 | 存储字段 |
|------|----------|----------|
| 节次模式 | 标准课程，按学校作息时间上课 | `startSection`, `endSection` |
| 时间模式 | 特殊课程、临时安排，时间不在标准节次内 | `startHour`, `startMinute`, `endHour`, `endMinute` |

**互斥约束**：
- 节次模式时：`startSection` 和 `endSection` 必须有值，时间字段为 null
- 时间模式时：四个时间字段必须有值，节次字段为 null
- 通过 `useTimeMode` 属性判断当前使用哪种模式

**WeekDisplayFormatter 示例**：

```dart
class WeekDisplayFormatter {
  /// 将离散周次转换为易读格式
  /// [1, 2, 8, 9, 10] → "1-2、8-10"
  /// [1, 3, 5, 7] → "1、3、5、7"
  /// [1, 2, 3, 4, 5, 6, 7, 8] → "1-8"
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
}
```

#### 3.2.4 TimeSchedule（作息时间表）

```dart
/// 作息时间表
class TimeSchedule {
  final String id;
  final String name;
  final List<TimeSlot> slots;
  final bool isDefault;
  
  const TimeSchedule({
    required this.id,
    required this.name,
    required this.slots,
    this.isDefault = false,
  });
}

/// 时间槽
class TimeSlot {
  final int section;          // 节次 (1, 2, 3...)
  final int startHour;        // 开始时
  final int startMinute;      // 开始分
  final int endHour;          // 结束时
  final int endMinute;        // 结束分
  
  const TimeSlot({
    required this.section,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
  });
  
  String get startTimeString => 
    '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
  String get endTimeString => 
    '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
  
  bool get isValid => 
    (startHour * 60 + startMinute) < (endHour * 60 + endMinute);
}
```

#### 3.2.5 AppSettings（应用设置）

```dart
/// 应用设置
class AppSettings {
  final ThemeMode themeMode;              // 主题模式
  final String? currentCourseTableId;     // 当前使用的课程表 ID
}
```

### 3.3 时间输入模式

支持两种时间输入方式，二者互斥：

| 模式 | 输入内容 | 存储方式 |
|------|----------|----------|
| 节次模式 | 开始节次、结束节次 | `startSection`, `endSection` |
| 时间模式 | 开始时间、结束时间 | `startHour`, `startMinute`, `endHour`, `endMinute` |

**设计说明**：
- 数据库直接存储用户输入的值，无需转换
- 节次模式适用于标准课程，与学校作息时间表对应
- 时间模式适用于特殊课程、临时安排，时间不在标准节次内
- 两种模式在 UI 展示时统一处理，通过 `useTimeMode` 判断

**周视图展示逻辑**：

```dart
/// 计算课程卡片在周视图中的位置和高度
class SchedulePositionCalculator {
  /// 计算课程卡片的顶部位置
  static double calculateTop(CourseSchedule schedule, TimeSchedule timeSchedule) {
    if (schedule.useTimeMode) {
      // 时间模式：根据时间计算位置
      final startMinutes = schedule.startHour! * 60 + schedule.startMinute!;
      final dayStartMinutes = timeSchedule.slots.first.startHour * 60 + 
                              timeSchedule.slots.first.startMinute;
      return (startMinutes - dayStartMinutes) * pixelsPerMinute;
    } else {
      // 节次模式：根据节次计算位置
      return (schedule.startSection! - 1) * sectionHeight;
    }
  }
  
  /// 计算课程卡片的高度
  static double calculateHeight(CourseSchedule schedule, TimeSchedule timeSchedule) {
    if (schedule.useTimeMode) {
      // 时间模式：根据时长计算高度
      final startMinutes = schedule.startHour! * 60 + schedule.startMinute!;
      final endMinutes = schedule.endHour! * 60 + schedule.endMinute!;
      return (endMinutes - startMinutes) * pixelsPerMinute;
    } else {
      // 节次模式：根据节次数计算高度
      return schedule.sectionCount! * sectionHeight;
    }
  }
}
```

---

## 4. 数据库设计

### 4.1 表结构

#### 4.1.1 course_tables 表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | TEXT PRIMARY KEY | UUID |
| name | TEXT NOT NULL | 课程表名称 |
| semester_start_date | INTEGER NOT NULL | 学期开始日期（时间戳） |
| total_weeks | INTEGER NOT NULL DEFAULT 18 | 学期总周数 |
| time_schedule_id | TEXT NOT NULL | 关联的作息时间表 ID |
| created_at | INTEGER NOT NULL | 创建时间戳 |
| updated_at | INTEGER NOT NULL | 更新时间戳 |

#### 4.1.2 course_infos 表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | TEXT PRIMARY KEY | UUID |
| course_table_id | TEXT NOT NULL | 所属课程表 ID |
| name | TEXT NOT NULL | 课程名称 |
| credit | REAL | 学分（可为空） |
| color_value | INTEGER NOT NULL | 颜色值 (ARGB) |
| note | TEXT | 备注 |
| created_at | INTEGER NOT NULL | 创建时间戳 |
| updated_at | INTEGER NOT NULL | 更新时间戳 |

#### 4.1.3 course_schedules 表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | TEXT PRIMARY KEY | UUID |
| course_info_id | TEXT NOT NULL | 关联的课程信息 ID |
| teacher | TEXT NOT NULL | 教师姓名 |
| location | TEXT NOT NULL | 上课地点 |
| day_of_week | INTEGER NOT NULL | 星期几 (1-7) |
| start_section | INTEGER | 开始节次（节次模式） |
| end_section | INTEGER | 结束节次（节次模式） |
| start_hour | INTEGER | 开始时（时间模式） |
| start_minute | INTEGER | 开始分（时间模式） |
| end_hour | INTEGER | 结束时（时间模式） |
| end_minute | INTEGER | 结束分（时间模式） |
| weeks | TEXT NOT NULL | 离散周次 JSON，如 `[1,2,8,9,10]` |
| created_at | INTEGER NOT NULL | 创建时间戳 |
| updated_at | INTEGER NOT NULL | 更新时间戳 |

**时间模式约束**：
- `start_section` 和 `end_section` 同时有值或同时为 NULL
- `start_hour`, `start_minute`, `end_hour`, `end_minute` 同时有值或同时为 NULL
- 两组字段互斥，不能同时有值

#### 4.1.4 time_schedules 表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | TEXT PRIMARY KEY | UUID |
| name | TEXT NOT NULL | 模板名称 |
| slots | TEXT NOT NULL | 时间槽 JSON |
| is_default | INTEGER NOT NULL DEFAULT 0 | 是否默认 (0/1) |

### 4.2 外键约束

```sql
-- course_infos 关联 course_tables
CREATE TABLE course_infos (
  ...
  course_table_id TEXT NOT NULL,
  FOREIGN KEY (course_table_id) REFERENCES course_tables(id) ON DELETE CASCADE
);

-- course_schedules 关联 course_infos
CREATE TABLE course_schedules (
  ...
  course_info_id TEXT NOT NULL,
  FOREIGN KEY (course_info_id) REFERENCES course_infos(id) ON DELETE CASCADE
);

-- course_tables 关联 time_schedules
CREATE TABLE course_tables (
  ...
  time_schedule_id TEXT NOT NULL,
  FOREIGN KEY (time_schedule_id) REFERENCES time_schedules(id)
);
```

### 4.3 索引设计

```sql
-- 按课程表查询课程信息
CREATE INDEX idx_course_infos_table ON course_infos(course_table_id);

-- 按课程信息查询课程安排
CREATE INDEX idx_course_schedules_info ON course_schedules(course_info_id);

-- 按星期查询课程安排（最常用查询）
CREATE INDEX idx_course_schedules_day ON course_schedules(day_of_week);
```

---

## 5. Repository 接口设计

### 5.1 CourseTableRepository

```dart
/// 课程表数据仓库接口
abstract class CourseTableRepository {
  /// 获取所有课程表
  Future<List<CourseTable>> getAllCourseTables();
  
  /// 根据 ID 获取课程表
  Future<CourseTable?> getCourseTableById(String id);
  
  /// 获取当前使用的课程表
  Future<CourseTable?> getCurrentCourseTable();
  
  /// 添加课程表
  Future<void> addCourseTable(CourseTable table);
  
  /// 更新课程表
  Future<void> updateCourseTable(CourseTable table);
  
  /// 删除课程表
  Future<void> deleteCourseTable(String id);
}
```

### 5.2 CourseInfoRepository

```dart
/// 课程信息数据仓库接口
abstract class CourseInfoRepository {
  /// 获取指定课程表的所有课程信息
  Future<List<CourseInfo>> getCourseInfosByTableId(String tableId);
  
  /// 根据 ID 获取课程信息
  Future<CourseInfo?> getCourseInfoById(String id);
  
  /// 添加课程信息
  Future<void> addCourseInfo(CourseInfo info);
  
  /// 更新课程信息
  Future<void> updateCourseInfo(CourseInfo info);
  
  /// 删除课程信息
  Future<void> deleteCourseInfo(String id);
  
  // ========== 聚合查询接口 ==========
  
  /// 获取指定课程表中所有唯一的教师名称
  Future<List<String>> getAllTeachers(String tableId);
  
  /// 获取指定课程表中所有唯一的上课地点
  Future<List<String>> getAllLocations(String tableId);
  
  /// 获取指定课程表中所有使用过的颜色值
  Future<List<int>> getAllColors(String tableId);
}
```

### 5.3 CourseScheduleRepository

```dart
/// 课程安排数据仓库接口
abstract class CourseScheduleRepository {
  /// 获取指定课程信息的所有安排
  Future<List<CourseSchedule>> getSchedulesByCourseInfoId(String infoId);
  
  /// 获取指定课程表在某周的所有课程安排
  /// 用于周视图展示
  Future<List<CourseScheduleWithInfo>> getSchedulesByWeek(
    String tableId, 
    int week,
  );
  
  /// 添加课程安排
  Future<void> addSchedule(CourseSchedule schedule);
  
  /// 更新课程安排
  Future<void> updateSchedule(CourseSchedule schedule);
  
  /// 删除课程安排
  Future<void> deleteSchedule(String id);
}

/// 课程安排与课程信息的组合（用于展示）
class CourseScheduleWithInfo {
  final CourseSchedule schedule;
  final CourseInfo info;
  
  const CourseScheduleWithInfo({
    required this.schedule,
    required this.info,
  });
}
```

### 5.4 TimeScheduleRepository

```dart
/// 作息时间表数据仓库接口
abstract class TimeScheduleRepository {
  /// 获取所有作息时间表
  Future<List<TimeSchedule>> getAllTimeSchedules();
  
  /// 根据 ID 获取作息时间表
  Future<TimeSchedule?> getTimeScheduleById(String id);
  
  /// 获取默认作息时间表
  Future<TimeSchedule?> getDefaultTimeSchedule();
  
  /// 添加作息时间表
  Future<void> addTimeSchedule(TimeSchedule schedule);
  
  /// 更新作息时间表
  Future<void> updateTimeSchedule(TimeSchedule schedule);
  
  /// 删除作息时间表
  Future<void> deleteTimeSchedule(String id);
  
  /// 设置默认作息时间表
  Future<void> setDefaultTimeSchedule(String id);
}
```

### 5.5 SettingsRepository

```dart
/// 设置数据仓库接口
abstract class SettingsRepository {
  /// 获取应用设置
  Future<AppSettings> getSettings();
  
  /// 更新应用设置
  Future<void> updateSettings(AppSettings settings);
}
```

---

## 6. 目录结构设计

### 6.1 扁平化目录结构

```
lib/
├── main.dart                    # 入口文件
├── models/                      # 数据模型
│   ├── course_table.dart        # 课程表模型
│   ├── course_info.dart         # 课程信息模型
│   ├── course_schedule.dart     # 课程安排模型
│   ├── time_schedule.dart       # 作息时间模型
│   └── app_settings.dart        # 应用设置模型
├── providers/                   # 状态管理
│   ├── course_table_provider.dart   # 课程表数据管理
│   ├── week_provider.dart       # 当前周次管理
│   └── settings_provider.dart   # 应用设置管理
├── repository/                  # 数据仓库
│   ├── course_table_repository.dart   # 课程表仓库
│   ├── course_info_repository.dart    # 课程信息仓库
│   ├── course_schedule_repository.dart # 课程安排仓库
│   ├── time_schedule_repository.dart  # 作息时间仓库
│   └── settings_repository.dart       # 设置仓库
├── database/                    # 本地数据库
│   └── db_helper.dart           # 数据库工具类
├── screens/                     # 前端页面
│   ├── home_screen.dart         # 主页（周视图）
│   ├── course_detail_screen.dart # 课程详情页
│   ├── course_edit_screen.dart  # 课程编辑/添加页
│   ├── settings_screen.dart     # 应用设置页
│   └── time_settings_screen.dart # 节次时间设置页
├── widgets/                     # 通用组件
│   ├── course_card.dart         # 课程卡片
│   ├── week_selector.dart       # 周次选择器
│   └── schedule_grid.dart       # 周视图网格
└── utils/                       # 工具类
    ├── week_calculator.dart     # 周次计算
    ├── week_display_formatter.dart # 周次显示格式化
    └── constants.dart           # 常量类
```

---

## 7. 关键技术方案

### 7.1 周次计算算法

```dart
class WeekCalculator {
  /// 计算当前周次
  static int calculateCurrentWeek(DateTime semesterStart, {int totalWeeks = 18}) {
    final now = DateTime.now();
    final diff = now.difference(semesterStart).inDays;
    if (diff < 0) return 1;
    final week = (diff / 7).floor() + 1;
    return week > totalWeeks ? totalWeeks : week;
  }
  
  /// 获取指定周次的日期范围
  static DateTimeRange getWeekDateRange(DateTime semesterStart, int week) {
    final start = semesterStart.add(Duration(days: (week - 1) * 7));
    final end = start.add(const Duration(days: 6));
    return DateTimeRange(start: start, end: end);
  }
}
```

### 7.2 课程时间冲突检测

```dart
class CourseConflictChecker {
  /// 检测课程安排是否存在时间冲突
  static List<CourseScheduleWithInfo> checkConflict(
    CourseSchedule newSchedule,
    List<CourseScheduleWithInfo> existingSchedules,
  ) {
    return existingSchedules.where((existing) {
      // 不同天不冲突
      if (existing.schedule.dayOfWeek != newSchedule.dayOfWeek) return false;
      
      // 节次不重叠
      final sectionOverlap = !(newSchedule.endSection < existing.schedule.startSection || 
                               newSchedule.startSection > existing.schedule.endSection);
      if (!sectionOverlap) return false;
      
      // 周次有交集
      for (final week in newSchedule.weeks) {
        if (existing.schedule.weeks.contains(week)) {
          return true;
        }
      }
      return false;
    }).toList();
  }
}
```

---

## 8. 依赖库选型

### 8.1 核心依赖

| 依赖 | 版本 | 用途 | 说明 |
|------|------|------|------|
| flutter | SDK | UI 框架 | - |
| flutter_riverpod | ^2.4.0 | 状态管理 | 编译时安全 |
| sqflite | ^2.3.0 | SQLite 数据库 | 本地持久化 |
| uuid | ^4.2.0 | UUID 生成 | 唯一标识 |
| intl | ^0.18.0 | 日期格式化 | 日期处理 |
| shared_preferences | ^2.2.0 | 简单存储 | 应用设置 |

---

## 9. 变更记录

### v1.3 (2026-03-08)

**核心变更**：

1. **新增 CourseTable 实体**：支持多课程表管理，每个课程表关联独立的作息时间表和学期设置

2. **拆分 Course 为 CourseInfo + CourseSchedule**：
   - CourseInfo：存储课程基本信息（名称、学分、颜色）
   - CourseSchedule：存储具体的上课安排（时间、地点、教师）
   - 一个课程可以有多个上课安排

3. **周次存储策略变更**：
   - 废弃 WeekRange 连续范围存储
   - 改用离散周次列表存储，如 `[1, 2, 8, 9, 10]`
   - 优点：查询效率高，直接 `weeks.contains(week)`
   - 前端展示通过 `WeekDisplayFormatter` 转换为易读格式

4. **新增学分属性**：CourseInfo 增加 `credit` 字段

5. **新增聚合查询接口**：
   - `getAllTeachers()`：获取所有教师
   - `getAllLocations()`：获取所有教室
   - `getAllColors()`：获取所有使用过的颜色

6. **时间输入模式支持**：
   - CourseSchedule 同时支持节次模式和时间模式
   - 节次模式：存储 `startSection`, `endSection`
   - 时间模式：存储 `startHour`, `startMinute`, `endHour`, `endMinute`
   - 两种模式互斥，通过 `useTimeMode` 判断
   - 数据库直接存储用户输入的值，无需转换

### v1.2 (2026-02-21)

- 基于评审意见修订，调整目录结构为扁平化
- 完善周次模式支持列表模式
- 说明 isDefault 约束与应用场景

### v1.1 (2026-02-19)

- 基于 MVP 原则精简架构
- 删除 UseCase 层、合并 Entity/Model
- 扁平化目录结构

### v1.0 (2026-02-19)

- 初始版本
