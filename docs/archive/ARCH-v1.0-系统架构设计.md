# Sleepdown 系统架构设计文档

**版本**: v1.0
**日期**: 2026-02-19
**状态**: 设计中

---

## 1. 架构概述

### 1.1 设计目标

基于 PRD-v1.2 需求文档，系统架构设计需满足以下核心目标：

| 目标 | 说明 | 对应需求 |
|------|------|----------|
| 快速启动 | 应用启动时间 < 1秒 | 用户体验需求 P0 |
| 离线可用 | 核心功能无需网络 | 用户体验需求 P0 |
| 跨平台 | iOS / Android / 鸿蒙 | 平台适配需求 |
| 可扩展 | 支持新增教务系统解析规则 | 可维护性需求 |
| 模块化 | 低耦合、高内聚 | 可维护性需求 |

### 1.2 架构原则

- **单一职责**：每个模块只负责一个功能领域
- **依赖倒置**：高层模块不依赖低层模块，两者都依赖抽象
- **接口隔离**：使用小接口而非大接口
- **开闭原则**：对扩展开放，对修改关闭

### 1.3 整体架构图

```
┌─────────────────────────────────────────────────────────────┐
│                      Presentation Layer                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Screens   │  │  Widgets    │  │   Platform Widgets  │  │
│  │  (Pages)    │  │ (UI组件)     │  │  (iOS/Android/HM)   │  │
│  └──────┬──────┘  └──────┬──────┘  └──────────┬──────────┘  │
└─────────┼────────────────┼───────────────────┼──────────────┘
          │                │                   │
          ▼                ▼                   ▼
┌─────────────────────────────────────────────────────────────┐
│                      Application Layer                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   State     │  │   UseCase   │  │   Platform Channel  │  │
│  │ Management  │  │  (业务用例)  │  │   (平台通信)         │  │
│  └──────┬──────┘  └──────┬──────┘  └──────────┬──────────┘  │
└─────────┼────────────────┼───────────────────┼──────────────┘
          │                │                   │
          ▼                ▼                   ▼
┌─────────────────────────────────────────────────────────────┐
│                        Domain Layer                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Entities  │  │ Repository  │  │   Parser Interface  │  │
│  │  (领域实体)  │  │  Interfaces │  │   (解析器接口)       │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
          │                │                   │
          ▼                ▼                   ▼
┌─────────────────────────────────────────────────────────────┐
│                         Data Layer                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │  SQLite DB  │  │   Network   │  │   File Storage      │  │
│  │  (本地存储)  │  │  (网络请求)  │  │   (文件存储)         │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. 分层架构设计

### 2.1 Presentation Layer（表现层）

负责 UI 渲染和用户交互。

#### 2.1.1 Screens（页面）

| 页面 | 路由 | 说明 |
|------|------|------|
| HomePage | `/` | 主页，周视图课程表 |
| DayViewPage | `/day` | 日视图课程表 |
| CourseDetailPage | `/course/:id` | 课程详情 |
| CourseEditPage | `/course/edit` | 课程编辑/新增 |
| SettingsPage | `/settings` | 设置页面 |
| ImportPage | `/import` | 导入页面 |
| TimeSettingsPage | `/settings/time` | 节次时间设置 |

#### 2.1.2 Widgets（组件）

| 组件 | 说明 |
|------|------|
| CourseCard | 课程卡片 |
| WeekSelector | 周次选择器 |
| TimeSlot | 时间槽 |
| ScheduleGrid | 课程表网格 |
| ImportDialog | 导入对话框 |

#### 2.1.3 Platform Widgets（平台小组件）

| 平台 | 技术方案 |
|------|----------|
| iOS | WidgetKit (Swift) + Flutter Widget Background |
| Android | Home Screen Widget (Kotlin) |
| 鸿蒙 | Form Link (ArkTS) |

### 2.2 Application Layer（应用层）

负责业务逻辑编排和状态管理。

#### 2.2.1 状态管理方案

采用 **Riverpod** 作为状态管理方案：

| 方案对比 | Riverpod | Bloc | Provider |
|----------|----------|------|----------|
| 学习曲线 | 中等 | 较高 | 低 |
| 编译时安全 | ✅ | ✅ | ❌ |
| 可测试性 | ✅ | ✅ | 中等 |
| 性能 | 高 | 高 | 中等 |
| 依赖注入 | 内置 | 需额外配置 | 需额外配置 |

#### 2.2.2 Providers 设计

```dart
// 课程数据 Provider
final courseListProvider = StateNotifierProvider<CourseListNotifier, List<Course>>((ref) {
  return CourseListNotifier(ref.read(courseRepositoryProvider));
});

// 当前周次 Provider
final currentWeekProvider = StateNotifierProvider<WeekNotifier, int>((ref) {
  return WeekNotifier();
});

// 设置 Provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref.read(settingsRepositoryProvider));
});
```

#### 2.2.3 UseCase 设计

| UseCase | 说明 |
|---------|------|
| GetWeekCourses | 获取指定周次的课程列表 |
| AddCourse | 添加新课程 |
| UpdateCourse | 更新课程信息 |
| DeleteCourse | 删除课程 |
| ImportFromCSV | 从 CSV 导入课程 |
| ImportFromWeb | 从教务网站导入课程 |
| ExportToCSV | 导出课程为 CSV |

### 2.3 Domain Layer（领域层）

核心业务逻辑，不依赖任何外部框架。

#### 2.3.1 实体设计

详见第 3 节数据模型设计。

#### 2.3.2 Repository 接口

```dart
abstract class CourseRepository {
  Future<List<Course>> getAllCourses();
  Future<List<Course>> getCoursesByWeek(int week);
  Future<Course> getCourseById(String id);
  Future<void> addCourse(Course course);
  Future<void> updateCourse(Course course);
  Future<void> deleteCourse(String id);
  Future<void> deleteAllCourses();
}

abstract class SettingsRepository {
  Future<AppSettings> getSettings();
  Future<void> updateSettings(AppSettings settings);
  Future<TimeSchedule> getTimeSchedule();
  Future<void> updateTimeSchedule(TimeSchedule schedule);
}
```

#### 2.3.3 Parser 接口

```dart
abstract class CourseParser {
  String get name;
  String get description;
  bool canParse(String input);
  Future<List<Course>> parse(String input);
}

abstract class WebParser {
  String get universityName;
  Future<List<Course>> parse(String html);
}
```

### 2.4 Data Layer（数据层）

负责数据持久化和外部数据访问。

#### 2.4.1 数据源

| 数据源 | 说明 | 技术 |
|--------|------|------|
| LocalDataSource | 本地 SQLite 数据库 | sqflite |
| RemoteDataSource | 网络请求 | dio / http |
| FileDataSource | 文件读写 | path_provider |

#### 2.4.2 Repository 实现

```dart
class CourseRepositoryImpl implements CourseRepository {
  final LocalDataSource _localDataSource;
  
  CourseRepositoryImpl(this._localDataSource);
  
  @override
  Future<List<Course>> getCoursesByWeek(int week) async {
    final courses = await _localDataSource.getAllCourses();
    return courses.where((c) => c.isActiveInWeek(week)).toList();
  }
  
  // ... 其他方法实现
}
```

---

## 3. 数据模型设计

### 3.1 核心实体

#### 3.1.1 Course（课程）

```dart
class Course {
  final String id;
  final String name;
  final String teacher;
  final String location;
  final int dayOfWeek;        // 1-7
  final int startSection;     // 开始节次
  final int endSection;       // 结束节次
  final WeekPattern weekPattern;  // 周次模式
  final String? note;         // 备注
  final DateTime createdAt;
  final DateTime updatedAt;
  
  bool isActiveInWeek(int week) {
    return weekPattern.contains(week);
  }
}
```

#### 3.1.2 WeekPattern（周次模式）

```dart
class WeekPattern {
  final List<WeekRange> ranges;
  
  bool contains(int week);
  String toDisplayString();  // 如 "1-5、7-11单、12-16双"
  
  static WeekPattern parse(String input);  // 解析 "1-5、7-11单、12-16双"
}

class WeekRange {
  final int start;
  final int end;
  final WeekType type;  // all, odd, even
  
  bool contains(int week);
}
```

#### 3.1.3 TimeSchedule（作息时间表）

```dart
class TimeSchedule {
  final String name;
  final List<TimeSlot> slots;
  final int totalSections;  // 每天总节数
}

class TimeSlot {
  final int section;        // 节次
  final TimeOfDay startTime;
  final TimeOfDay endTime;
}
```

#### 3.1.4 AppSettings（应用设置）

```dart
class AppSettings {
  final ThemeMode themeMode;
  final int currentSemesterStart;  // 学期开始日期（周次计算基准）
  final String defaultTimeScheduleId;
  final bool enableNotification;
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
| week_pattern | TEXT | 周次模式 JSON |
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

**settings 表**

| 字段 | 类型 | 说明 |
|------|------|------|
| key | TEXT PRIMARY KEY | 设置项键 |
| value | TEXT | 设置项值 JSON |

#### 3.2.2 索引设计

```sql
CREATE INDEX idx_courses_day ON courses(day_of_week);
CREATE INDEX idx_courses_week_pattern ON courses(week_pattern);
```

---

## 4. 模块划分与目录结构

### 4.1 目录结构

```
lib/
├── main.dart
├── app.dart
│
├── core/                          # 核心模块
│   ├── constants/                 # 常量定义
│   │   ├── app_constants.dart
│   │   └── route_constants.dart
│   ├── errors/                    # 错误处理
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── extensions/                # 扩展方法
│   │   ├── datetime_extension.dart
│   │   └── string_extension.dart
│   ├── theme/                     # 主题配置
│   │   ├── app_theme.dart
│   │   ├── colors.dart
│   │   └── text_styles.dart
│   └── utils/                     # 工具类
│       ├── date_utils.dart
│       ├── week_calculator.dart
│       └── csv_parser.dart
│
├── domain/                        # 领域层
│   ├── entities/                  # 实体
│   │   ├── course.dart
│   │   ├── week_pattern.dart
│   │   ├── time_schedule.dart
│   │   └── app_settings.dart
│   ├── repositories/              # Repository 接口
│   │   ├── course_repository.dart
│   │   └── settings_repository.dart
│   └── parsers/                   # 解析器接口
│       ├── course_parser.dart
│       └── web_parser.dart
│
├── data/                          # 数据层
│   ├── datasources/               # 数据源
│   │   ├── local/
│   │   │   ├── database_helper.dart
│   │   │   └── local_data_source.dart
│   │   ├── remote/
│   │   │   └── remote_data_source.dart
│   │   └── file/
│   │       └── file_data_source.dart
│   ├── models/                    # 数据模型
│   │   ├── course_model.dart
│   │   ├── time_schedule_model.dart
│   │   └── app_settings_model.dart
│   ├── repositories/              # Repository 实现
│   │   ├── course_repository_impl.dart
│   │   └── settings_repository_impl.dart
│   └── parsers/                   # 解析器实现
│       ├── csv_course_parser.dart
│       └── web_parsers/
│           ├── web_parser_registry.dart
│           └── universities/
│               └── example_university_parser.dart
│
├── application/                   # 应用层
│   ├── providers/                 # Riverpod Providers
│   │   ├── course_providers.dart
│   │   ├── settings_providers.dart
│   │   └── import_providers.dart
│   ├── notifiers/                 # State Notifiers
│   │   ├── course_list_notifier.dart
│   │   ├── week_notifier.dart
│   │   └── settings_notifier.dart
│   └── usecases/                  # 用例
│       ├── get_week_courses.dart
│       ├── add_course.dart
│       ├── import_courses.dart
│       └── export_courses.dart
│
├── presentation/                  # 表现层
│   ├── screens/                   # 页面
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── home_controller.dart
│   │   ├── day_view/
│   │   │   └── day_view_screen.dart
│   │   ├── course_detail/
│   │   │   └── course_detail_screen.dart
│   │   ├── course_edit/
│   │   │   └── course_edit_screen.dart
│   │   ├── settings/
│   │   │   └── settings_screen.dart
│   │   ├── import/
│   │   │   └── import_screen.dart
│   │   └── time_settings/
│   │       └── time_settings_screen.dart
│   ├── widgets/                   # 通用组件
│   │   ├── course_card.dart
│   │   ├── week_selector.dart
│   │   ├── schedule_grid.dart
│   │   ├── time_slot_widget.dart
│   │   └── import_dialog.dart
│   └── l10n/                      # 国际化
│       ├── app_localizations.dart
│       └── translations/
│           ├── zh_CN.yaml
│           └── en_US.yaml
│
└── platform/                      # 平台适配层
    ├── channels/
    │   └── platform_channel.dart
    ├── widgets/                   # 平台小组件配置
    │   ├── widget_config.dart
    │   └── widget_data_provider.dart
    └── services/
        ├── ios_widget_service.dart
        ├── android_widget_service.dart
        └── harmony_widget_service.dart
```

### 4.2 模块依赖关系

```
presentation → application → domain ← data
                  ↓           ↓
               core ←──────────
```

---

## 5. 平台适配方案

### 5.1 Flutter 平台通道

```dart
class PlatformChannel {
  static const MethodChannel _channel = MethodChannel('com.sleepdown.app');
  
  // 小组件通信
  Future<void> updateWidget(List<Course> todayCourses);
  
  // 深色模式
  Future<bool> isDarkMode();
}
```

### 5.2 iOS Widget 适配

**架构**：
- Flutter 侧：通过 `home_widget` 包提供数据
- iOS 侧：WidgetKit (Swift) 渲染小组件

**数据同步**：
```
Flutter App → UserDefaults (App Group) → WidgetKit
```

### 5.3 Android Widget 适配

**架构**：
- Flutter 侧：通过 `home_widget` 包提供数据
- Android 侧：AppWidgetProvider (Kotlin) 渲染小组件

**数据同步**：
```
Flutter App → SharedPreferences → AppWidgetProvider
```

### 5.4 鸿蒙卡片适配

**架构**：
- Flutter 侧：通过 Platform Channel 传递数据
- 鸿蒙侧：Form Link (ArkTS) 渲染卡片

**数据同步**：
```
Flutter App → Platform Channel → Form Data Provider
```

---

## 6. 关键技术方案

### 6.1 快速启动优化

| 优化项 | 方案 |
|--------|------|
| 延迟初始化 | 非核心服务延迟加载 |
| 数据库预热 | 启动时预加载常用数据 |
| 资源优化 | 图片压缩、字体子集化 |
| 状态恢复 | 使用 `RestorationMixin` |

### 6.2 周次计算算法

```dart
class WeekCalculator {
  static int calculateCurrentWeek(DateTime semesterStart) {
    final now = DateTime.now();
    final diff = now.difference(semesterStart).inDays;
    return (diff / 7).floor() + 1;
  }
}
```

### 6.3 CSV 解析器

```dart
class CsvCourseParser implements CourseParser {
  @override
  String get name => 'CSV';
  
  @override
  bool canParse(String input) {
    return input.contains(',') && input.contains('\n');
  }
  
  @override
  Future<List<Course>> parse(String input) async {
    final lines = input.split('\n');
    final courses = <Course>[];
    
    for (var i = 1; i < lines.length; i++) {
      if (lines[i].trim().isEmpty) continue;
      final fields = lines[i].split(',');
      courses.add(_parseCourse(fields));
    }
    
    return courses;
  }
  
  Course _parseCourse(List<String> fields) {
    return Course(
      name: fields[0].trim(),
      dayOfWeek: int.parse(fields[1].trim()),
      startSection: int.parse(fields[2].trim()),
      endSection: int.parse(fields[3].trim()),
      teacher: fields[4].trim(),
      location: fields[5].trim(),
      weekPattern: WeekPattern.parse(fields[6].trim()),
    );
  }
}
```

### 6.4 周次模式解析

```dart
class WeekPatternParser {
  static WeekPattern parse(String input) {
    final ranges = <WeekRange>[];
    final parts = input.split('、');  // 中文顿号分隔
    
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
    
    return WeekPattern(ranges: ranges);
  }
}
```

---

## 7. 依赖库选型

### 7.1 核心依赖

| 依赖 | 版本 | 用途 |
|------|------|------|
| flutter | SDK | UI 框架 |
| flutter_riverpod | ^2.4.0 | 状态管理 |
| sqflite | ^2.3.0 | SQLite 数据库 |
| path_provider | ^2.1.0 | 文件路径 |
| dio | ^5.4.0 | 网络请求 |
| uuid | ^4.2.0 | UUID 生成 |
| intl | ^0.18.0 | 国际化 |
| home_widget | ^0.4.0 | 小组件支持 |
| shared_preferences | ^2.2.0 | 简单存储 |

### 7.2 开发依赖

| 依赖 | 版本 | 用途 |
|------|------|------|
| flutter_test | SDK | 单元测试 |
| mockito | ^5.4.0 | Mock 测试 |
| build_runner | ^2.4.0 | 代码生成 |
| flutter_lints | ^3.0.0 | 代码规范 |

---

## 8. 开发阶段规划

### Phase 1 - MVP 基础架构

- [ ] 项目初始化与目录结构
- [ ] 数据库设计与实现
- [ ] 核心实体与 Repository
- [ ] 基础 UI 框架
- [ ] 课程表展示功能

### Phase 2 - 核心功能

- [ ] 课程增删改查
- [ ] 周次切换与计算
- [ ] 节次时间设置
- [ ] CSV 导入导出

### Phase 3 - 平台适配

- [ ] iOS Widget 支持
- [ ] Android Widget 支持
- [ ] 鸿蒙卡片支持

### Phase 4 - 高级功能

- [ ] 教务网站导入
- [ ] 深色模式
- [ ] 课程提醒

---

## 9. 风险与应对

| 风险 | 影响 | 应对措施 |
|------|------|----------|
| 鸿蒙 Flutter 支持不完善 | 无法适配鸿蒙 | 持续关注 ohos_flutter 项目进展 |
| 小组件数据同步延迟 | 用户体验下降 | 使用 WorkManager 定时刷新 |
| 教务网站解析规则变更 | 导入功能失效 | 设计热更新机制，支持远程配置 |

---

**文档维护**: 本文档将随项目进展持续更新

**变更记录**:
- v1.0 (2026-02-19): 初始版本，基于 PRD-v1.2 设计
