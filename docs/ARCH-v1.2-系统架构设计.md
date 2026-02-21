# Sleepdown 系统架构设计文档

**版本**: v1.2
**日期**: 2026-02-21
**状态**: 已评审
**变更说明**: 基于架构评审意见修订，调整目录结构、完善数据模型

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
│  │   (CourseNotifier, SettingsNotifier, WeekNotifier)    │  │
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

#### 2.1.3 Screen 与 Widget 的区别

| 维度 | Screen（页面） | Widget（组件） |
|------|----------------|----------------|
| **职责** | 完整的页面逻辑，负责数据获取、状态管理 | 可复用的 UI 片段，负责展示和交互 |
| **路由** | 有独立路由，可直接导航 | 无独立路由，嵌入页面中使用 |
| **生命周期** | 管理页面级生命周期 | 由父组件管理生命周期 |
| **数据来源** | 直接从 Provider 获取数据 | 通过参数传入数据 |
| **示例** | HomeScreen、SettingsScreen | CourseCard、WeekSelector |

#### 2.1.4 WeekSelector 组件设计

**功能定位**：WeekSelector 是一个可复用的 UI 组件，用于在周视图页面中切换当前显示的周次。

**组件职责**：
- 显示当前周次信息
- 提供左右切换按钮或滑动切换手势
- 支持快速跳转到指定周次
- 显示当前周次的日期范围

**组件划分合理性**：
- ✅ 可复用：日视图页面也可能需要周次切换
- ✅ 职责单一：只负责周次选择，不涉及课程数据
- ✅ 独立性：通过回调函数通知父组件周次变化

```dart
class WeekSelector extends StatelessWidget {
  final int currentWeek;
  final int totalWeeks;
  final ValueChanged<int> onWeekChanged;
  
  const WeekSelector({
    required this.currentWeek,
    required this.totalWeeks,
    required this.onWeekChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left),
          onPressed: currentWeek > 1 
            ? () => onWeekChanged(currentWeek - 1) 
            : null,
        ),
        GestureDetector(
          onTap: () => _showWeekPicker(context),
          child: Text('第 $currentWeek 周'),
        ),
        IconButton(
          icon: Icon(Icons.chevron_right),
          onPressed: currentWeek < totalWeeks 
            ? () => onWeekChanged(currentWeek + 1) 
            : null,
        ),
      ],
    );
  }
}
```

#### 2.1.5 Theme（主题）

- 统一管理应用色彩、间距
- 支持明/暗主题切换基础能力
- 支持应用主色调的切换（例如基于壁纸的主色）
- **字体策略**：优先使用系统默认字体，确保与平台体验一致
  - iOS：使用 SF Pro（系统自动回退）
  - Android：使用 Roboto（系统自动回退）
  - 通过 `ThemeData.useMaterial3: true` 获得更好的系统适配

### 2.2 Logic Layer（逻辑层）

负责业务逻辑处理和状态管理，使用 Riverpod 简化实现。

#### 2.2.1 状态管理方案

采用 **Riverpod + StateNotifier** 作为状态管理方案：

| 优势 | 说明 |
|------|------|
| 编译时安全 | 类型检查，减少运行时错误 |
| 内置依赖注入 | 无需额外配置 |
| 可测试性好 | 易于 Mock 和单元测试 |
| 学习曲线适中 | 团队已有经验 |

#### 2.2.2 Notifiers 设计

```dart
/// 课程数据管理
final courseListProvider = StateNotifierProvider<CourseNotifier, List<Course>>((ref) {
  return CourseNotifier(ref.read(courseRepositoryProvider));
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

#### 2.2.3 核心业务逻辑

CourseNotifier 直接承担业务逻辑（不单独抽 UseCase）：

```dart
class CourseNotifier extends StateNotifier<List<Course>> {
  final CourseRepository _repository;
  
  CourseNotifier(this._repository) : super([]) {
    _loadCourses();
  }
  
  Future<void> _loadCourses() async {
    state = await _repository.getAllCourses();
  }
  
  List<Course> getCoursesByWeek(int week) {
    return state.where((c) => c.isActiveInWeek(week)).toList();
  }
  
  Future<void> addCourse(Course course) async {
    await _repository.addCourse(course);
    state = [...state, course];
  }
  
  Future<void> updateCourse(Course course) async {
    await _repository.updateCourse(course);
    state = state.map((c) => c.id == course.id ? course : c).toList();
  }
  
  Future<void> deleteCourse(String id) async {
    await _repository.deleteCourse(id);
    state = state.where((c) => c.id != id).toList();
  }
}
```

### 2.3 Data Layer（数据层）

负责数据持久化，采用简化的 Repository 模式。

#### 2.3.1 数据源

| 数据源 | 说明 | 技术 | MVP用途 |
|--------|------|------|---------|
| SQLite | 本地关系数据库 | sqflite | 课程、作息时间存储 |
| SharedPreferences | 简单键值存储 | shared_preferences | 应用设置存储 |

#### 2.3.2 Repository 接口（简化版）

```dart
/// 课程数据仓库接口
abstract class CourseRepository {
  Future<List<Course>> getAllCourses();
  Future<List<Course>> getCoursesByWeek(int week);
  Future<Course?> getCourseById(String id);
  Future<void> addCourse(Course course);
  Future<void> updateCourse(Course course);
  Future<void> deleteCourse(String id);
}

/// 设置数据仓库接口
abstract class SettingsRepository {
  Future<AppSettings> getSettings();
  Future<void> updateSettings(AppSettings settings);
  Future<TimeSchedule> getTimeSchedule();
  Future<void> updateTimeSchedule(TimeSchedule schedule);
}
```

---

## 3. 数据模型设计

### 3.1 核心实体

> **设计原则**：合并 Entity 与 Model，只维护一套数据类，简化开发。

#### 3.1.1 Course（课程）

```dart
class Course {
  final String id;
  final String name;
  final String teacher;
  final String location;
  final int dayOfWeek;        // 1-7 (周一至周日)
  final int startSection;     // 开始节次
  final int endSection;       // 结束节次
  final List<WeekRange> weekRanges;  // 周次范围列表（支持多种模式）
  final int colorValue;       // 课程颜色 (ARGB)
  final String? note;         // 备注
  final DateTime createdAt;
  final DateTime updatedAt;
  
  /// 判断课程在指定周次是否有效
  bool isActiveInWeek(int week) {
    return weekRanges.any((range) => range.contains(week));
  }
  
  /// 获取课程时长的节次数
  int get sectionCount => endSection - startSection + 1;
}

/// 周次范围
class WeekRange {
  final int start;      // 开始周次
  final int end;        // 结束周次
  final WeekType type;  // 周次类型
  
  bool contains(int week) {
    if (week < start || week > end) return false;
    switch (type) {
      case WeekType.all:
        return true;
      case WeekType.odd:
        return week % 2 == 1;
      case WeekType.even:
        return week % 2 == 0;
    }
  }
}

enum WeekType { all, odd, even }
```

**周次模式说明**：

| 模式 | 示例 | WeekRange 表示 |
|------|------|----------------|
| 连续周次 | 1-16周 | `WeekRange(1, 16, WeekType.all)` |
| 仅单周 | 1-16周单 | `WeekRange(1, 16, WeekType.odd)` |
| 仅双周 | 1-16周双 | `WeekRange(1, 16, WeekType.even)` |
| 列表模式 | 1、2、8周 | `[WeekRange(1,1,all), WeekRange(2,2,all), WeekRange(8,8,all)]` |
| 组合模式 | 1-5、7-11单 | `[WeekRange(1,5,all), WeekRange(7,11,odd)]` |

**列表模式处理策略**：
- 用户输入 `1、2、8` 周时，在 Repository 层转换为 `[WeekRange(1,1,all), WeekRange(2,2,all), WeekRange(8,8,all)]`
- 数据库存储时，将 `weekRanges` 序列化为 JSON 字符串
- 查询时反序列化还原为 `List<WeekRange>`

#### 3.1.2 TimeSchedule（作息时间表）

```dart
class TimeSchedule {
  final String id;
  final String name;
  final List<TimeSlot> slots;
  final bool isDefault;
}

class TimeSlot {
  final int section;          // 节次 (1, 2, 3...)
  final int startHour;        // 开始时
  final int startMinute;      // 开始分
  final int endHour;          // 结束时
  final int endMinute;        // 结束分
  
  String get startTimeString => '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
  String get endTimeString => '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
  
  bool get isValid {
    return (startHour * 60 + startMinute) < (endHour * 60 + endMinute);
  }
}
```

**isDefault 全局唯一约束**：

| 层面 | 实现方式 |
|------|----------|
| 数据库层面 | 使用触发器确保只有一个 `is_default = 1` 的记录 |
| 应用层面 | 设置新的默认时间表时，自动清除其他时间表的默认标记 |

**isDefault 应用场景**：

1. **学期初快速配置**：用户首次使用时，自动加载默认时间表，无需手动选择
2. **多时间表切换**：用户可创建多个时间表（如夏季作息、冬季作息），默认时间表为当前使用的作息
3. **数据恢复**：误删时间表后，系统自动将剩余时间表中的一个设为默认

```sql
-- 数据库触发器：确保 is_default 全局唯一
CREATE TRIGGER ensure_single_default_schedule
AFTER UPDATE OF is_default ON time_schedules
WHEN NEW.is_default = 1
BEGIN
  UPDATE time_schedules SET is_default = 0 
  WHERE id != NEW.id AND is_default = 1;
END;
```

#### 3.1.3 AppSettings（应用设置）

```dart
class AppSettings {
  final ThemeMode themeMode;              // 主题模式
  final DateTime? semesterStartDate;      // 学期开始日期
  final int totalWeeks;                   // 学期总周数 (默认18)
  final int currentSemester;              // 当前学期标识
}
```

### 3.2 数据库设计

#### 3.2.1 表结构

**courses 表**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | TEXT PRIMARY KEY | UUID |
| name | TEXT NOT NULL | 课程名称 |
| teacher | TEXT | 教师姓名 |
| location | TEXT | 上课地点 |
| day_of_week | INTEGER | 星期几 (1-7) |
| start_section | INTEGER | 开始节次 |
| end_section | INTEGER | 结束节次 |
| week_ranges | TEXT | 周次范围 JSON |
| color_value | INTEGER | 颜色值 (ARGB) |
| note | TEXT | 备注 |
| created_at | INTEGER | 创建时间戳 |
| updated_at | INTEGER | 更新时间戳 |

**time_schedules 表**

| 字段 | 类型 | 说明 |
|------|------|------|
| id | TEXT PRIMARY KEY | UUID |
| name | TEXT NOT NULL | 模板名称 |
| slots | TEXT | 时间槽 JSON |
| is_default | INTEGER | 是否默认 (0/1) |

#### 3.2.2 索引设计

```sql
-- 按星期查询课程（最常用查询）
CREATE INDEX idx_courses_day ON courses(day_of_week);

-- 按周次范围查询
CREATE INDEX idx_courses_week ON courses(start_week, end_week);
```

---

## 4. 目录结构设计

### 4.1 扁平化目录结构

```
lib/
├── main.dart                    # 入口文件（整个App的启动入口）
├── models/                      # 数据模型
│   ├── course.dart              # 课程模型
│   ├── time_schedule.dart       # 节次时间模型
│   └── app_settings.dart        # 应用设置模型
├── providers/                   # 状态管理
│   ├── course_provider.dart     # 课程数据管理
│   ├── week_provider.dart       # 当前周次管理
│   └── settings_provider.dart   # 应用设置管理
├── repository/                  # 数据仓库
│   ├── course_repository.dart   # 课程仓库（接口+实现，对接sqlite）
│   └── settings_repository.dart # 设置仓库（接口+实现，对接shared_preferences）
├── database/                    # 本地数据库（sqlite，精简表结构）
│   └── db_helper.dart           # 数据库工具类（创建表、初始化、增删改查）
├── screens/                     # 前端页面（精简至5个核心页面）
│   ├── home_screen.dart         # 主页（周视图，核心页面）
│   ├── course_detail_screen.dart # 课程详情页
│   ├── course_edit_screen.dart  # 课程编辑/添加页
│   ├── settings_screen.dart     # 应用设置页
│   └── time_settings_screen.dart # 节次时间设置页
├── widgets/                     # 通用组件
│   ├── course_card.dart         # 课程卡片（周视图中展示课程）
│   ├── week_selector.dart       # 周次选择器（简化版，仅支持切换）
│   └── schedule_grid.dart       # 周视图网格（核心组件，展示每日课程）
└── utils/                       # 工具类（简化，仅保留必需）
    ├── week_calculator.dart     # 周次计算
    └── constants.dart           # 常量类（存储固定值，如默认节次时间）
```

### 4.2 目录设计说明

#### 4.2.1 与其他设计方案的一致性

| 设计方案 | 目录结构对应 | 说明 |
|----------|--------------|------|
| 三层架构 | screens/widgets → providers → repository/database | 完全对应 |
| 数据模型 | models/ | 独立目录，便于管理 |
| MVP 页面 | screens/ | 5个核心页面，与架构共识一致 |

#### 4.2.2 常量类的必要性

**constants.dart 的作用**：

| 常量类型 | 示例 | 说明 |
|----------|------|------|
| 默认节次时间 | `defaultTimeSlots` | 首次启动时初始化数据库 |
| 颜色预设 | `courseColors` | 课程颜色选择器预设值 |
| 应用配置 | `maxWeeks = 25` | 学期最大周数限制 |

**与数据库存储的关系**：

- 常量类存储**系统默认值**，用于初始化和兜底
- 数据库存储**用户自定义值**，优先级高于常量
- 两者不冲突，常量类是必要的

```dart
class Constants {
  static const int maxWeeks = 25;
  static const int defaultTotalWeeks = 18;
  
  // 国内大学通用上课节次时间（适配上午4节、下午4节、晚上2节的主流安排）
  static const List<TimeSlot> defaultTimeSlots = [
    TimeSlot(section: 1, startHour: 8, startMinute: 00, endHour: 8, endMinute: 45),
    TimeSlot(section: 2, startHour: 8, startMinute: 50, endHour: 9, endMinute: 35),
    TimeSlot(section: 3, startHour: 9, startMinute: 50, endHour: 10, endMinute: 35),
    TimeSlot(section: 4, startHour: 10, startMinute: 40, endHour: 11, endMinute: 25),
    TimeSlot(section: 5, startHour: 11, startMinute: 35, endHour: 12, endMinute: 20), // 可选上午第五节
    TimeSlot(section: 6, startHour: 14, startMinute: 00, endHour: 14, endMinute: 45),
    TimeSlot(section: 7, startHour: 14, startMinute: 50, endHour: 15, endMinute: 35),
    TimeSlot(section: 8, startHour: 15, startMinute: 50, endHour: 16, endMinute: 35),
    TimeSlot(section: 9, startHour: 16, startMinute: 40, endHour: 17, endMinute: 25),
    TimeSlot(section: 10, startHour: 19, startMinute: 00, endHour: 19, endMinute: 45), // 晚上第一节
    TimeSlot(section: 11, startHour: 19, startMinute: 50, endHour: 20, endMinute: 35), // 晚上第二节
  ];
  
  // MD3（Material Design 3）规范色块（适配不同课程类型，视觉协调且符合设计规范）
  static const List<int> courseColors = [
    0xFF3B82F6,  // 蓝色（理论课）- MD3 Primary Blue
    0xFF10B981,  // 绿色（实验课）- MD3 Primary Green
    0xFFF97316,  // 橙色（体育课）- MD3 Primary Orange
    0xFF8B5CF6,  // 紫色（选修课）- MD3 Primary Purple
    0xFF06B6D4,  // 青色（会议/讲座）- MD3 Primary Cyan
    0xFF6B7280,  // 中性灰（自习）- MD3 Neutral Gray
  ];
}
```

### 4.3 目录设计优势

| 优势 | 说明 |
|------|------|
| 导航简单 | 扁平化结构，减少目录层级 |
| 职责清晰 | 按技术分层，每层职责明确 |
| 易于理解 | 新成员快速上手 |
| 便于扩展 | 功能增加时，在对应目录添加文件 |

---

## 5. 关键技术方案

### 5.1 周次计算算法

```dart
class WeekCalculator {
  /// 计算当前周次
  /// [semesterStart] 学期开始日期
  /// 返回当前是第几周 (从1开始)
  static int calculateCurrentWeek(DateTime semesterStart) {
    final now = DateTime.now();
    final diff = now.difference(semesterStart).inDays;
    if (diff < 0) return 1;
    return (diff / 7).floor() + 1;
  }
  
  /// 获取指定周次的日期范围
  static DateTimeRange getWeekDateRange(DateTime semesterStart, int week) {
    final start = semesterStart.add(Duration(days: (week - 1) * 7));
    final end = start.add(const Duration(days: 6));
    return DateTimeRange(start: start, end: end);
  }
}
```

### 5.2 课程时间冲突检测

```dart
class CourseConflictChecker {
  /// 检测课程是否存在时间冲突
  static List<Course> checkConflict(Course newCourse, List<Course> existingCourses) {
    return existingCourses.where((existing) {
      if (existing.dayOfWeek != newCourse.dayOfWeek) return false;
      
      final sectionOverlap = !(newCourse.endSection < existing.startSection || 
                               newCourse.startSection > existing.endSection);
      if (!sectionOverlap) return false;
      
      for (int week = 1; week <= 25; week++) {
        if (newCourse.isActiveInWeek(week) && existing.isActiveInWeek(week)) {
          return true;
        }
      }
      return false;
    }).toList();
  }
}
```

### 5.3 时间槽校验

```dart
class TimeSlotValidator {
  /// 校验时间槽列表是否有效
  /// 返回错误信息，null 表示有效
  static String? validate(List<TimeSlot> slots) {
    if (slots.isEmpty) return '请至少添加一个节次';
    
    for (int i = 0; i < slots.length; i++) {
      final slot = slots[i];
      
      if (!slot.isValid) {
        return '第${slot.section}节：开始时间必须早于结束时间';
      }
      
      if (i > 0) {
        final prev = slots[i - 1];
        final prevEnd = prev.endHour * 60 + prev.endMinute;
        final currStart = slot.startHour * 60 + slot.startMinute;
        if (currStart < prevEnd) {
          return '第${slot.section}节开始时间早于上一节结束时间';
        }
      }
    }
    return null;
  }
}
```

### 5.4 周次范围解析

```dart
class WeekRangeParser {
  /// 解析周次字符串为 WeekRange 列表
  /// 支持格式：1-16、1-16单、1-16双、1、2、8、1-5、7-11单
  static List<WeekRange> parse(String input) {
    final ranges = <WeekRange>[];
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
      
      if (part.contains('-')) {
        final range = part.split('-');
        ranges.add(WeekRange(
          start: int.parse(range[0]),
          end: int.parse(range[1]),
          type: type,
        ));
      } else {
        final week = int.parse(part);
        ranges.add(WeekRange(
          start: week,
          end: week,
          type: type,
        ));
      }
    }
    
    return ranges;
  }
}
```

---

## 6. 依赖库选型

### 6.1 核心依赖

| 依赖 | 版本 | 用途 | 说明 |
|------|------|------|------|
| flutter | SDK | UI 框架 | - |
| flutter_riverpod | ^2.4.0 | 状态管理 | 编译时安全 |
| sqflite | ^2.3.0 | SQLite 数据库 | 本地持久化 |
| uuid | ^4.2.0 | UUID 生成 | 唯一标识 |
| intl | ^0.18.0 | 日期格式化 | 日期处理 |
| shared_preferences | ^2.2.0 | 简单存储 | 应用设置 |

### 6.2 开发依赖

| 依赖 | 版本 | 用途 |
|------|------|------|
| flutter_test | SDK | 单元测试 |
| flutter_lints | ^3.0.0 | 代码规范 |

### 6.3 延后引入的依赖

以下依赖在后续迭代中按需引入：

| 依赖 | 用途 | 引入阶段 |
|------|------|----------|
| home_widget | 桌面小组件 | Phase 2 |
| dio | 网络请求 | Phase 3+ |
| path_provider | 文件读写 | Phase 2 |

---

## 7. 开发阶段规划

### Phase 1 - MVP 核心功能（当前）

| 任务 | 预估工时 | 说明 |
|------|----------|------|
| 项目初始化与目录结构 | 0.5天 | 按本文档创建项目骨架 |
| 数据库设计与实现 | 1天 | 表结构、Repository |
| 核心数据模型 | 0.5天 | Course、TimeSchedule、AppSettings |
| Provider 状态管理 | 1天 | CourseNotifier、SettingsNotifier |
| 周视图主页 | 2天 | ScheduleGrid、WeekSelector |
| 课程详情/编辑页面 | 1.5天 | CourseDetailScreen、CourseEditScreen |
| 设置页面 | 1天 | SettingsScreen、时间设置 |
| 课程颜色选择 | 0.5天 | 调色板组件 |
| **总计** | **8天** | - |

### Phase 2 - 功能增强

- 日视图课程表
- CSV 导入导出
- 桌面小组件（iOS/Android）
- 多学期管理

### Phase 3 - 高级功能

- 教务网站导入
- 课程提醒通知
- 深色模式完善

### Phase 4 - 平台扩展

- 鸿蒙平台适配
- 多平台小组件优化

---

## 8. 小组件方案（Phase 2）

> **说明**：MVP 阶段不实现桌面小组件，以下为 Phase 2 预留设计。

### 8.1 技术方案

使用 `home_widget` 插件统一处理 iOS/Android 小组件：

```dart
// 数据同步到小组件
Future<void> updateWidgetData(List<Course> todayCourses) async {
  await HomeWidget.saveWidgetData('course_count', todayCourses.length);
  await HomeWidget.saveWidgetData('courses_json', jsonEncode(todayCourses));
  await HomeWidget.updateWidget(name: 'CourseWidget');
}
```

### 8.2 平台支持优先级

| 平台 | 支持阶段 | 说明 |
|------|----------|------|
| Android | Phase 2 | 优先支持 |
| iOS | Phase 2 | 同步支持 |
| 鸿蒙 | Phase 4+ | 生态成熟后评估 |

---

## 9. 风险与应对

| 风险 | 影响 | 应对措施 |
|------|------|----------|
| SQLite 操作性能 | 课程展示卡顿 | 仅保留必要索引，避免复杂查询 |
| 数据迁移兼容性 | 升级后数据丢失 | 预留 migration 机制，做好版本管理 |
| 小组件数据同步 | 数据不一致 | 操作课程后立即同步，Phase 2 解决 |

---

## 10. 架构演进路线

```
Phase 1 (当前)          Phase 2              Phase 3+
    │                      │                     │
    ▼                      ▼                     ▼
┌─────────┐          ┌─────────┐          ┌─────────┐
│ 三层架构 │    →    │ 添加小组件│    →    │ 扩展导入 │
│ SQLite  │          │ 功能    │          │ 网络功能 │
│ 单一数据源│         │ 多学期  │          │ 云同步   │
└─────────┘          └─────────┘          └─────────┘
```

---

**文档维护**: 本文档随项目进展持续更新

**变更记录**:
- v1.2 (2026-02-21): 基于评审意见修订，调整目录结构为扁平化、完善周次模式支持列表模式、说明 isDefault 约束与应用场景、说明常量类必要性
- v1.1 (2026-02-19): 基于 MVP 原则精简架构，删除 UseCase 层、合并 Entity/Model、扁平化目录结构
- v1.0 (2026-02-19): 初始版本
