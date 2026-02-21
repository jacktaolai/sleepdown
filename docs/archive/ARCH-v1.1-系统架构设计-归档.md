# Sleepdown 系统架构设计文档

**版本**: v1.1  
**日期**: 2026-02-19  
**状态**: 需修改  
**变更说明**: 基于 MVP 最小实现原则，精简架构设计

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
- **功能优先**：按功能模块划分代码，而非按技术分层

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

负责 UI 渲染和用户交互，采用功能模块化组织。

#### 2.1.1 Screens（页面）

| 页面 | 路由 | 说明 | MVP优先级 |
|------|------|------|-----------|
| HomeScreen | `/` | 周视图课程表主页 | P0 必须 |
| CourseDetailScreen | `/course/:id` | 课程详情查看 | P0 必须 |
| CourseEditScreen | `/course/edit` | 课程编辑/新增 | P0 必须 |
| SettingsScreen | `/settings` | 应用设置（含时间设置入口） | P0 必须 |

#### 2.1.2 Widgets（组件）

| 组件 | 说明 | MVP优先级 |
|------|------|-----------|
| CourseCard | 课程卡片（支持颜色标识） | P0 必须 |
| WeekSelector | 周次选择器（基础切换） | P0 必须 |
| ScheduleGrid | 课程表网格布局 | P0 必须 |

> 请简要回答评审问题
> 如何理解周次选择器，这样的组件划分是正确的吗？如何理解screen和widgerts的不同功能

#### 2.1.3 Theme（主题）

- 统一管理应用色彩、字体、间距
- 支持明/暗主题切换基础能力
- 支持app主色调的切换（例如基于壁纸的主色）
> 字体尽量与系统字体相匹配，以提升用户使用体验的一致性
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
  
  // 加载所有课程
  Future<void> _loadCourses() async {
    state = await _repository.getAllCourses();
  }
  
  // 获取指定周次的课程
  List<Course> getCoursesByWeek(int week) {
    return state.where((c) => c.isActiveInWeek(week)).toList();
  }
  
  // 添加课程
  Future<void> addCourse(Course course) async {
    await _repository.addCourse(course);
    state = [...state, course];
  }
  
  // 更新课程
  Future<void> updateCourse(Course course) async {
    await _repository.updateCourse(course);
    state = state.map((c) => c.id == course.id ? course : c).toList();
  }
  
  // 删除课程
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
  final int startWeek;        // 开始周次
  final int endWeek;          // 结束周次
  final bool isOddWeek;       // 仅单周
  final bool isEvenWeek;      // 仅双周
  final int colorValue;       // 课程颜色 (ARGB)
  final String? note;         // 备注
  final DateTime createdAt;
  final DateTime updatedAt;
  
  /// 判断课程在指定周次是否有效
  bool isActiveInWeek(int week) {
    if (week < startWeek || week > endWeek) return false;
    if (isOddWeek && week % 2 == 0) return false;
    if (isEvenWeek && week % 2 == 1) return false;
    return true;
  }
  
  /// 获取课程时长的节次数
  int get sectionCount => endSection - startSection + 1;
}
```

**周次模式说明**：
- MVP 阶段简化周次表达，支持以下模式：
  - 连续周次：`startWeek=1, endWeek=16, isOddWeek=false, isEvenWeek=false`
  - 仅单周：`startWeek=1, endWeek=16, isOddWeek=true, isEvenWeek=false`
  - 仅双周：`startWeek=1, endWeek=16, isOddWeek=false, isEvenWeek=true`
> 评审建议
> 这里还应该支持列表模式，例如1、2、8周这样的
> 建议列表模式在Repository阶段统一转换为区间模式，例如1、2、8周转换为1-1、2-2、8-8

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
  
  /// 校验时间槽是否有效（开始时间必须早于结束时间）
  bool get isValid {
    return (startHour * 60 + startMinute) < (endHour * 60 + endMinute);
  }
}
```
> 评审建议
> 确保 final bool isDefault;（默认时间表）全局只有一个，这个需要在数据库层面设置，另外这个默认时间表的应用场景在哪里？

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
| start_week | INTEGER | 开始周次 |
| end_week | INTEGER | 结束周次 |
| is_odd_week | INTEGER | 仅单周 (0/1) |
| is_even_week | INTEGER | 仅双周 (0/1) |
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

### 4.1 功能优先的目录结构

```
lib/
├── main.dart                          # 应用入口
├── app.dart                           # App 配置
│
├── core/                              # 核心模块
│   ├── constants/
│   │   └── app_constants.dart         # 常量定义
│   ├── theme/
│   │   ├── app_theme.dart             # 主题配置
│   │   ├── colors.dart                # 颜色定义
│   │   └── text_styles.dart           # 文字样式
│   └── utils/
│       ├── week_calculator.dart       # 周次计算
│       └── date_utils.dart            # 日期工具
│
├── features/                          # 功能模块（Feature-first）
│   │
│   ├── course/                        # 课程模块
│   │   ├── data/
│   │   │   ├── course_repository.dart
│   │   │   └── course_repository_impl.dart
│   │   ├── models/
│   │   │   └── course.dart
│   │   ├── providers/
│   │   │   └── course_provider.dart
│   │   └── presentation/
│   │       ├── course_detail_screen.dart
│   │       ├── course_edit_screen.dart
│   │       └── widgets/
│   │           └── course_card.dart
│   │
│   ├── schedule/                      # 课程表模块
│   │   ├── data/
│   │   │   └── time_schedule_repository.dart
│   │   ├── models/
│   │   │   └── time_schedule.dart
│   │   ├── providers/
│   │   │   ├── week_provider.dart
│   │   │   └── time_schedule_provider.dart
│   │   └── presentation/
│   │       ├── home_screen.dart
│   │       └── widgets/
│   │           ├── schedule_grid.dart
│   │           └── week_selector.dart
│   │
│   └── settings/                      # 设置模块
│       ├── data/
│       │   └── settings_repository.dart
│       ├── models/
│       │   └── app_settings.dart
│       ├── providers/
│       │   └── settings_provider.dart
│       └── presentation/
│           ├── settings_screen.dart
│           └── widgets/
│               └── time_slot_editor.dart
│
├── database/                          # 数据库
│   ├── database_helper.dart           # 数据库初始化
│   └── migrations/                    # 迁移脚本
│       └── v1_init.sql
│
└── widgets/                           # 全局通用组件
    └── common_widgets.dart
```

### 4.2 目录设计优势

| 优势 | 说明 |
|------|------|
| 功能内聚 | 每个功能的所有代码都在同一目录，修改不跨目录 |
| 易于导航 | 找课程相关代码只需进入 course 目录 |
| 团队协作 | 不同成员可负责不同 feature，减少冲突 |
| 渐进演进 | 功能稳定后可拆分为独立 package |

> 评审建议
> 这里的目录结构严重不符合要求，不建议按照功能优先来设计目录
> 参考以下目录，但是要尤其注意
> - 与该文档的其他设计方案有没有冲突，是否需要改正
> - 常量类（存储固定值，如默认节次时间），是否有必要，因为我们在实体与数据库里存了该值，当然我们也可以设置系统默认的时间表
> 
```
lib/
├── main.dart                # 入口文件（整个App的启动入口）
├── models/                  # 数据模型
│   ├── course.dart          # 课程模型
│   ├── time_schedule.dart   # 节次时间模型
│   └── app_settings.dart    # 应用设置模型
├── providers/               # 状态管理
│   ├── course_provider.dart # 课程数据管理
│   ├── week_provider.dart   # 当前周次管理
│   └── settings_provider.dart # 应用设置管理
├── repository/              # 数据仓库
│   ├── course_repository.dart # 课程仓库（接口+实现，对接sqlite）
│   └── settings_repository.dart # 设置仓库（接口+实现，对接shared_preferences）
├── database/                # 本地数据库（sqlite，精简表结构，架构共识）
│   └── db_helper.dart       # 数据库工具类（创建表、初始化、增删改查）
├── screens/                 # 前端页面（精简至5个核心页面，架构共识）
│   ├── home_screen.dart     # 主页（周视图，核心页面）
│   ├── course_detail_screen.dart # 课程详情页
│   ├── course_edit_screen.dart   # 课程编辑/添加页
│   ├── settings_screen.dart      # 应用设置页
│   └── time_settings_screen.dart # 节次时间设置页
├── widgets/                 # 通用组件
│   ├── course_card.dart     # 课程卡片（周视图中展示课程）
│   ├── week_selector.dart   # 周次选择器（简化版，仅支持切换）
│   └── schedule_grid.dart   # 周视图网格（核心组件，展示每日课程）
└── utils/                   # 工具类（简化，仅保留必需）
    ├── week_calculator.dart # 周次计算
    └── constants.dart       # 常量类（存储固定值，如默认节次时间）
```

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
    if (diff < 0) return 1;  // 学期未开始
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
      // 不同天不冲突
      if (existing.dayOfWeek != newCourse.dayOfWeek) return false;
      
      // 节次是否重叠
      final sectionOverlap = !(newCourse.endSection < existing.startSection || 
                               newCourse.startSection > existing.endSection);
      if (!sectionOverlap) return false;
      
      // 周次是否重叠
      for (int week = newCourse.startWeek; week <= newCourse.endWeek; week++) {
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
      
      // 检查单条时间槽有效性
      if (!slot.isValid) {
        return '第${slot.section}节：开始时间必须早于结束时间';
      }
      
      // 检查与上一节次的时间衔接
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
- v1.1 (2026-02-19): 基于 MVP 原则精简架构，删除 UseCase 层、合并 Entity/Model、扁平化目录结构
- v1.0 (2026-02-19): 初始版本
