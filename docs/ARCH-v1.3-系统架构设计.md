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

#### 2.2.2 Provider 架构设计

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           Provider 层级结构                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  ┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐   │
│  │ AppSettings     │     │ CourseTable     │     │ TimeSchedule    │   │
│  │ Provider        │     │ Provider        │     │ Provider        │   │
│  │ (应用设置)       │     │ (当前课程表)     │     │ (当前作息表)     │   │
│  └────────┬────────┘     └────────┬────────┘     └────────┬────────┘   │
│           │                       │                       │            │
│           │                       ▼                       │            │
│           │              ┌─────────────────┐              │            │
│           │              │ CurrentWeek     │              │            │
│           │              │ Provider        │◄─────────────┘            │
│           │              │ (当前周次)       │  根据学期开始时间计算       │
│           │              └────────┬────────┘                           │
│           │                       │                                    │
│           │                       ▼                                    │
│           │              ┌─────────────────┐                           │
│           │              │ WeeklyCourses   │                           │
│           │              │ Provider        │                           │
│           │              │ (某周课程列表)   │                           │
│           │              └────────┬────────┘                           │
│           │                       │                                    │
│           ▼                       ▼                                    │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                        UI Layer                                  │   │
│  │  HomeScreen / CourseCard / ScheduleGrid / WeekSelector          │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

#### 2.2.3 Provider 详细设计

```dart
// ==================== 基础 Provider ====================

/// 应用设置 Provider
/// 存储当前使用的课程表 ID、主题模式等
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref.read(settingsRepositoryProvider));
});

/// 当前课程表 Provider
/// 根据 settings 中的 currentCourseTableId 获取
final courseTableProvider = StateNotifierProvider<CourseTableNotifier, CourseTableState>((ref) {
  final settings = ref.watch(settingsProvider);
  return CourseTableNotifier(
    ref.read(courseTableRepositoryProvider),
    settings.currentCourseTableId,
  );
});

/// 当前作息时间表 Provider
/// 从当前课程表中获取关联的作息时间表
final timeScheduleProvider = FutureProvider<TimeSchedule?>((ref) async {
  final tableState = ref.watch(courseTableProvider);
  if (tableState.table == null) return null;
  
  final repository = ref.read(timeScheduleRepositoryProvider);
  return repository.getTimeScheduleById(tableState.table!.timeScheduleId);
});

/// 当前周次 Provider
/// 根据课程表的学期开始时间自动计算当前周
final currentWeekProvider = StateNotifierProvider<CurrentWeekNotifier, int>((ref) {
  final tableState = ref.watch(courseTableProvider);
  if (tableState.table == null) return 1;
  
  return CurrentWeekNotifier(
    tableState.table!.semesterStartDate,
    tableState.table!.totalWeeks,
  );
});

// ==================== 派生 Provider ====================

/// 某周课程列表 Provider
/// 获取指定周次的所有课程（包含课程信息和课程安排）
final weeklyCoursesProvider = FutureProvider.family<List<CourseScheduleWithInfo>, int>((ref, week) async {
  final tableState = ref.watch(courseTableProvider);
  if (tableState.table == null) return [];
  
  final repository = ref.read(courseScheduleRepositoryProvider);
  return repository.getSchedulesByWeek(tableState.table!.id, week);
});

/// 某天课程列表 Provider
/// 用于周视图中按天显示课程
final dailyCoursesProvider = Provider.family<Map<int, List<CourseScheduleWithInfo>>, int>((ref, week) {
  final weeklyCourses = ref.watch(weeklyCoursesProvider(week));
  
  if (weeklyCourses.value == null) return {};
  
  final Map<int, List<CourseScheduleWithInfo>> result = {};
  for (int day = 1; day <= 7; day++) {
    result[day] = weeklyCourses.value!
        .where((item) => item.schedule.dayOfWeek == day)
        .toList();
  }
  return result;
});

/// 课程详情 Provider
/// 用于课程详情页面
final courseDetailProvider = FutureProvider.family<CourseDetail?, String>((ref, courseInfoId) async {
  final infoRepository = ref.read(courseInfoRepositoryProvider);
  final scheduleRepository = ref.read(courseScheduleRepositoryProvider);
  
  final info = await infoRepository.getCourseInfoById(courseInfoId);
  if (info == null) return null;
  
  final schedules = await scheduleRepository.getSchedulesByCourseInfoId(courseInfoId);
  
  return CourseDetail(info: info, schedules: schedules);
});

// ==================== 聚合查询 Provider ====================

/// 所有教师列表 Provider
final allTeachersProvider = FutureProvider<List<String>>((ref) async {
  final tableState = ref.watch(courseTableProvider);
  if (tableState.table == null) return [];
  
  final repository = ref.read(courseInfoRepositoryProvider);
  return repository.getAllTeachers(tableState.table!.id);
});

/// 所有教室列表 Provider
final allLocationsProvider = FutureProvider<List<String>>((ref) async {
  final tableState = ref.watch(courseTableProvider);
  if (tableState.table == null) return [];
  
  final repository = ref.read(courseInfoRepositoryProvider);
  return repository.getAllLocations(tableState.table!.id);
});

/// 所有颜色列表 Provider
final allColorsProvider = FutureProvider<List<int>>((ref) async {
  final tableState = ref.watch(courseTableProvider);
  if (tableState.table == null) return [];
  
  final repository = ref.read(courseInfoRepositoryProvider);
  return repository.getAllColors(tableState.table!.id);
});
```

#### 2.2.4 State 定义

```dart
/// 课程表状态
class CourseTableState {
  final CourseTable? table;
  final bool isLoading;
  final String? error;
  
  const CourseTableState({
    this.table,
    this.isLoading = false,
    this.error,
  });
  
  CourseTableState copyWith({
    CourseTable? table,
    bool? isLoading,
    String? error,
  }) {
    return CourseTableState(
      table: table ?? this.table,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 课程详情（用于详情页面）
class CourseDetail {
  final CourseInfo info;
  final List<CourseSchedule> schedules;
  
  const CourseDetail({
    required this.info,
    required this.schedules,
  });
}
```

#### 2.2.5 Notifier 实现

```dart
/// 课程表 Notifier
class CourseTableNotifier extends StateNotifier<CourseTableState> {
  final CourseTableRepository _repository;
  String? _tableId;
  
  CourseTableNotifier(this._repository, this._tableId) : super(const CourseTableState()) {
    _loadCourseTable();
  }
  
  /// 加载课程表
  Future<void> _loadCourseTable() async {
    if (_tableId == null) {
      state = const CourseTableState();
      return;
    }
    
    state = state.copyWith(isLoading: true);
    
    try {
      final table = await _repository.getCourseTableById(_tableId!);
      state = CourseTableState(table: table);
    } catch (e) {
      state = CourseTableState(error: e.toString());
    }
  }
  
  /// 切换课程表
  Future<void> switchCourseTable(String tableId) async {
    _tableId = tableId;
    await _loadCourseTable();
  }
  
  /// 更新课程表信息
  Future<void> updateCourseTable(CourseTable table) async {
    await _repository.updateCourseTable(table);
    state = CourseTableState(table: table);
  }
}

/// 当前周次 Notifier
class CurrentWeekNotifier extends StateNotifier<int> {
  final DateTime _semesterStartDate;
  final int _totalWeeks;
  
  CurrentWeekNotifier(this._semesterStartDate, this._totalWeeks) : super(_calculateCurrentWeek(_semesterStartDate, _totalWeeks));
  
  /// 计算当前周次
  static int _calculateCurrentWeek(DateTime semesterStart, int totalWeeks) {
    final now = DateTime.now();
    final diff = now.difference(semesterStart).inDays;
    if (diff < 0) return 1;
    final week = (diff / 7).floor() + 1;
    return week > totalWeeks ? totalWeeks : week;
  }
  
  /// 切换到指定周
  void setWeek(int week) {
    if (week >= 1 && week <= _totalWeeks) {
      state = week;
    }
  }
  
  /// 上一周
  void previousWeek() {
    if (state > 1) {
      state--;
    }
  }
  
  /// 下一周
  void nextWeek() {
    if (state < _totalWeeks) {
      state++;
    }
  }
  
  /// 重置为当前周
  void resetToCurrentWeek() {
    state = _calculateCurrentWeek(_semesterStartDate, _totalWeeks);
  }
}

/// 课程信息 Notifier
class CourseInfoNotifier extends StateNotifier<AsyncValue<List<CourseInfo>>> {
  final CourseInfoRepository _repository;
  final String _courseTableId;
  
  CourseInfoNotifier(this._repository, this._courseTableId) : super(const AsyncValue.loading()) {
    _loadCourseInfos();
  }
  
  Future<void> _loadCourseInfos() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getCourseInfosByTableId(_courseTableId));
  }
  
  /// 添加课程信息
  Future<CourseInfo> addCourseInfo({
    required String name,
    double? credit,
    required int colorValue,
    String? note,
  }) async {
    final info = CourseInfo(
      id: const Uuid().v4(),
      courseTableId: _courseTableId,
      name: name,
      credit: credit,
      colorValue: colorValue,
      note: note,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await _repository.addCourseInfo(info);
    await _loadCourseInfos();
    return info;
  }
  
  /// 更新课程信息
  Future<void> updateCourseInfo(CourseInfo info) async {
    await _repository.updateCourseInfo(info);
    await _loadCourseInfos();
  }
  
  /// 删除课程信息（同时删除所有关联的课程安排）
  Future<void> deleteCourseInfo(String id) async {
    await _repository.deleteCourseInfo(id);
    await _loadCourseInfos();
  }
}

/// 课程安排 Notifier
class CourseScheduleNotifier extends StateNotifier<AsyncValue<List<CourseSchedule>>> {
  final CourseScheduleRepository _repository;
  final String _courseInfoId;
  
  CourseScheduleNotifier(this._repository, this._courseInfoId) : super(const AsyncValue.loading()) {
    _loadSchedules();
  }
  
  Future<void> _loadSchedules() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getSchedulesByCourseInfoId(_courseInfoId));
  }
  
  /// 添加课程安排
  Future<CourseSchedule> addSchedule({
    required String teacher,
    required String location,
    required int dayOfWeek,
    int? startSection,
    int? endSection,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
    required List<int> weeks,
  }) async {
    final schedule = CourseSchedule(
      id: const Uuid().v4(),
      courseInfoId: _courseInfoId,
      teacher: teacher,
      location: location,
      dayOfWeek: dayOfWeek,
      startSection: startSection,
      endSection: endSection,
      startHour: startHour,
      startMinute: startMinute,
      endHour: endHour,
      endMinute: endMinute,
      weeks: weeks,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await _repository.addSchedule(schedule);
    await _loadSchedules();
    return schedule;
  }
  
  /// 更新课程安排
  Future<void> updateSchedule(CourseSchedule schedule) async {
    await _repository.updateSchedule(schedule);
    await _loadSchedules();
  }
  
  /// 删除课程安排
  Future<void> deleteSchedule(String id) async {
    await _repository.deleteSchedule(id);
    await _loadSchedules();
  }
}

/// 作息时间表 Notifier
class TimeScheduleNotifier extends StateNotifier<AsyncValue<List<TimeSchedule>>> {
  final TimeScheduleRepository _repository;
  
  TimeScheduleNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadTimeSchedules();
  }
  
  Future<void> _loadTimeSchedules() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getAllTimeSchedules());
  }
  
  /// 添加作息时间表
  Future<void> addTimeSchedule(TimeSchedule schedule) async {
    await _repository.addTimeSchedule(schedule);
    await _loadTimeSchedules();
  }
  
  /// 更新作息时间表
  Future<void> updateTimeSchedule(TimeSchedule schedule) async {
    await _repository.updateTimeSchedule(schedule);
    await _loadTimeSchedules();
  }
  
  /// 删除作息时间表
  Future<void> deleteTimeSchedule(String id) async {
    await _repository.deleteTimeSchedule(id);
    await _loadTimeSchedules();
  }
  
  /// 设置默认作息时间表
  Future<void> setDefault(String id) async {
    await _repository.setDefaultTimeSchedule(id);
    await _loadTimeSchedules();
  }
}

/// 设置 Notifier
class SettingsNotifier extends StateNotifier<AppSettings> {
  final SettingsRepository _repository;
  
  SettingsNotifier(this._repository) : super(const AppSettings()) {
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final settings = await _repository.getSettings();
    state = settings;
  }
  
  /// 切换当前课程表
  Future<void> setCurrentCourseTable(String tableId) async {
    state = state.copyWith(currentCourseTableId: tableId);
    await _repository.updateSettings(state);
  }
  
  /// 切换主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _repository.updateSettings(state);
  }
}
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

### 5.6 Repository 实现示例

#### 5.6.1 SQLite 数据库帮助类

```dart
/// 数据库帮助类
class DatabaseHelper {
  static Database? _database;
  
  static const String dbName = 'sleepdown.db';
  static const int dbVersion = 1;
  
  /// 获取数据库实例
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  /// 初始化数据库
  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), dbName);
    return await openDatabase(
      path,
      version: dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  /// 创建表
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE course_tables (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        semester_start_date INTEGER NOT NULL,
        total_weeks INTEGER NOT NULL DEFAULT 18,
        time_schedule_id TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (time_schedule_id) REFERENCES time_schedules(id)
      )
    ''');
    
    await db.execute('''
      CREATE TABLE course_infos (
        id TEXT PRIMARY KEY,
        course_table_id TEXT NOT NULL,
        name TEXT NOT NULL,
        credit REAL,
        color_value INTEGER NOT NULL,
        note TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (course_table_id) REFERENCES course_tables(id) ON DELETE CASCADE
      )
    ''');
    
    await db.execute('''
      CREATE TABLE course_schedules (
        id TEXT PRIMARY KEY,
        course_info_id TEXT NOT NULL,
        teacher TEXT NOT NULL,
        location TEXT NOT NULL,
        day_of_week INTEGER NOT NULL,
        start_section INTEGER,
        end_section INTEGER,
        start_hour INTEGER,
        start_minute INTEGER,
        end_hour INTEGER,
        end_minute INTEGER,
        weeks TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (course_info_id) REFERENCES course_infos(id) ON DELETE CASCADE
      )
    ''');
    
    await db.execute('''
      CREATE TABLE time_schedules (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        slots TEXT NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0
      )
    ''');
    
    // 创建索引
    await db.execute('CREATE INDEX idx_course_infos_table ON course_infos(course_table_id)');
    await db.execute('CREATE INDEX idx_course_schedules_info ON course_schedules(course_info_id)');
    await db.execute('CREATE INDEX idx_course_schedules_day ON course_schedules(day_of_week)');
    
    // 插入默认作息时间表
    await _insertDefaultTimeSchedule(db);
  }
  
  /// 插入默认作息时间表
  Future<void> _insertDefaultTimeSchedule(Database db) async {
    const defaultSlots = [
      {'section': 1, 'startHour': 8, 'startMinute': 0, 'endHour': 8, 'endMinute': 45},
      {'section': 2, 'startHour': 8, 'startMinute': 50, 'endHour': 9, 'endMinute': 35},
      {'section': 3, 'startHour': 9, 'startMinute': 50, 'endHour': 10, 'endMinute': 35},
      {'section': 4, 'startHour': 10, 'startMinute': 40, 'endHour': 11, 'endMinute': 25},
      {'section': 5, 'startHour': 11, 'startMinute': 35, 'endHour': 12, 'endMinute': 20},
      {'section': 6, 'startHour': 14, 'startMinute': 0, 'endHour': 14, 'endMinute': 45},
      {'section': 7, 'startHour': 14, 'startMinute': 50, 'endHour': 15, 'endMinute': 35},
      {'section': 8, 'startHour': 15, 'startMinute': 50, 'endHour': 16, 'endMinute': 35},
      {'section': 9, 'startHour': 16, 'startMinute': 40, 'endHour': 17, 'endMinute': 25},
      {'section': 10, 'startHour': 19, 'startMinute': 0, 'endHour': 19, 'endMinute': 45},
      {'section': 11, 'startHour': 19, 'startMinute': 50, 'endHour': 20, 'endMinute': 35},
    ];
    
    await db.insert('time_schedules', {
      'id': 'default',
      'name': '默认作息',
      'slots': jsonEncode(defaultSlots),
      'is_default': 1,
    });
  }
  
  /// 升级数据库
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // 预留数据库升级逻辑
  }
}
```

#### 5.6.2 CourseScheduleRepository 实现

```dart
/// 课程安排数据仓库实现
class CourseScheduleRepositoryImpl implements CourseScheduleRepository {
  final DatabaseHelper _dbHelper;
  
  CourseScheduleRepositoryImpl(this._dbHelper);
  
  @override
  Future<List<CourseSchedule>> getSchedulesByCourseInfoId(String infoId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'course_schedules',
      where: 'course_info_id = ?',
      whereArgs: [infoId],
    );
    return maps.map(_mapToSchedule).toList();
  }
  
  @override
  Future<List<CourseScheduleWithInfo>> getSchedulesByWeek(
    String tableId,
    int week,
  ) async {
    final db = await _dbHelper.database;
    
    // 联表查询：获取指定课程表中，在指定周次有课的所有安排
    final results = await db.rawQuery('''
      SELECT cs.*, ci.name as course_name, ci.credit, ci.color_value, ci.note
      FROM course_schedules cs
      INNER JOIN course_infos ci ON cs.course_info_id = ci.id
      WHERE ci.course_table_id = ?
    ''', [tableId]);
    
    // 在 Dart 中过滤周次（SQLite 不支持 JSON 数组查询）
    return results
        .where((map) {
          final weeksJson = map['weeks'] as String;
          final weeks = List<int>.from(jsonDecode(weeksJson));
          return weeks.contains(week);
        })
        .map((map) {
          final schedule = _mapToSchedule(map);
          final info = CourseInfo(
            id: map['course_info_id'] as String,
            courseTableId: tableId,
            name: map['course_name'] as String,
            credit: map['credit'] as double?,
            colorValue: map['color_value'] as int,
            note: map['note'] as String?,
            createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
            updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
          );
          return CourseScheduleWithInfo(schedule: schedule, info: info);
        })
        .toList();
  }
  
  @override
  Future<void> addSchedule(CourseSchedule schedule) async {
    final db = await _dbHelper.database;
    await db.insert('course_schedules', _scheduleToMap(schedule));
  }
  
  @override
  Future<void> updateSchedule(CourseSchedule schedule) async {
    final db = await _dbHelper.database;
    await db.update(
      'course_schedules',
      _scheduleToMap(schedule),
      where: 'id = ?',
      whereArgs: [schedule.id],
    );
  }
  
  @override
  Future<void> deleteSchedule(String id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'course_schedules',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  /// Map 转 CourseSchedule
  CourseSchedule _mapToSchedule(Map<String, dynamic> map) {
    return CourseSchedule(
      id: map['id'] as String,
      courseInfoId: map['course_info_id'] as String,
      teacher: map['teacher'] as String,
      location: map['location'] as String,
      dayOfWeek: map['day_of_week'] as int,
      startSection: map['start_section'] as int?,
      endSection: map['end_section'] as int?,
      startHour: map['start_hour'] as int?,
      startMinute: map['start_minute'] as int?,
      endHour: map['end_hour'] as int?,
      endMinute: map['end_minute'] as int?,
      weeks: List<int>.from(jsonDecode(map['weeks'] as String)),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }
  
  /// CourseSchedule 转 Map
  Map<String, dynamic> _scheduleToMap(CourseSchedule schedule) {
    return {
      'id': schedule.id,
      'course_info_id': schedule.courseInfoId,
      'teacher': schedule.teacher,
      'location': schedule.location,
      'day_of_week': schedule.dayOfWeek,
      'start_section': schedule.startSection,
      'end_section': schedule.endSection,
      'start_hour': schedule.startHour,
      'start_minute': schedule.startMinute,
      'end_hour': schedule.endHour,
      'end_minute': schedule.endMinute,
      'weeks': jsonEncode(schedule.weeks),
      'created_at': schedule.createdAt.millisecondsSinceEpoch,
      'updated_at': schedule.updatedAt.millisecondsSinceEpoch,
    };
  }
}
```

#### 5.6.3 CourseInfoRepository 实现

```dart
/// 课程信息数据仓库实现
class CourseInfoRepositoryImpl implements CourseInfoRepository {
  final DatabaseHelper _dbHelper;
  
  CourseInfoRepositoryImpl(this._dbHelper);
  
  @override
  Future<List<CourseInfo>> getCourseInfosByTableId(String tableId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'course_infos',
      where: 'course_table_id = ?',
      whereArgs: [tableId],
    );
    return maps.map(_mapToInfo).toList();
  }
  
  @override
  Future<CourseInfo?> getCourseInfoById(String id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'course_infos',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return _mapToInfo(maps.first);
  }
  
  @override
  Future<void> addCourseInfo(CourseInfo info) async {
    final db = await _dbHelper.database;
    await db.insert('course_infos', _infoToMap(info));
  }
  
  @override
  Future<void> updateCourseInfo(CourseInfo info) async {
    final db = await _dbHelper.database;
    await db.update(
      'course_infos',
      _infoToMap(info),
      where: 'id = ?',
      whereArgs: [info.id],
    );
  }
  
  @override
  Future<void> deleteCourseInfo(String id) async {
    final db = await _dbHelper.database;
    // 由于外键设置了 ON DELETE CASCADE，删除课程信息时会自动删除关联的课程安排
    await db.delete(
      'course_infos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  @override
  Future<List<String>> getAllTeachers(String tableId) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery('''
      SELECT DISTINCT cs.teacher
      FROM course_schedules cs
      INNER JOIN course_infos ci ON cs.course_info_id = ci.id
      WHERE ci.course_table_id = ?
      ORDER BY cs.teacher
    ''', [tableId]);
    return results.map((map) => map['teacher'] as String).toList();
  }
  
  @override
  Future<List<String>> getAllLocations(String tableId) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery('''
      SELECT DISTINCT cs.location
      FROM course_schedules cs
      INNER JOIN course_infos ci ON cs.course_info_id = ci.id
      WHERE ci.course_table_id = ?
      ORDER BY cs.location
    ''', [tableId]);
    return results.map((map) => map['location'] as String).toList();
  }
  
  @override
  Future<List<int>> getAllColors(String tableId) async {
    final db = await _dbHelper.database;
    final results = await db.rawQuery('''
      SELECT DISTINCT color_value
      FROM course_infos
      WHERE course_table_id = ?
      ORDER BY color_value
    ''', [tableId]);
    return results.map((map) => map['color_value'] as int).toList();
  }
  
  CourseInfo _mapToInfo(Map<String, dynamic> map) {
    return CourseInfo(
      id: map['id'] as String,
      courseTableId: map['course_table_id'] as String,
      name: map['name'] as String,
      credit: map['credit'] as double?,
      colorValue: map['color_value'] as int,
      note: map['note'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }
  
  Map<String, dynamic> _infoToMap(CourseInfo info) {
    return {
      'id': info.id,
      'course_table_id': info.courseTableId,
      'name': info.name,
      'credit': info.credit,
      'color_value': info.colorValue,
      'note': info.note,
      'created_at': info.createdAt.millisecondsSinceEpoch,
      'updated_at': info.updatedAt.millisecondsSinceEpoch,
    };
  }
}
```

### 5.7 Provider 注入配置

```dart
/// Provider 配置文件
/// 在 main.dart 中使用 ProviderScope 覆盖
final providers = <Override>[
  // 数据库帮助类
  databaseHelperProvider.overrideWithValue(DatabaseHelper()),
  
  // Repository Providers
  courseTableRepositoryProvider.overrideWith((ref) {
    return CourseTableRepositoryImpl(ref.read(databaseHelperProvider));
  }),
  
  courseInfoRepositoryProvider.overrideWith((ref) {
    return CourseInfoRepositoryImpl(ref.read(databaseHelperProvider));
  }),
  
  courseScheduleRepositoryProvider.overrideWith((ref) {
    return CourseScheduleRepositoryImpl(ref.read(databaseHelperProvider));
  }),
  
  timeScheduleRepositoryProvider.overrideWith((ref) {
    return TimeScheduleRepositoryImpl(ref.read(databaseHelperProvider));
  }),
  
  settingsRepositoryProvider.overrideWith((ref) {
    return SettingsRepositoryImpl();
  }),
];

/// 在 main.dart 中使用
void main() {
  runApp(
    ProviderScope(
      overrides: providers,
      child: const MyApp(),
    ),
  );
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

### 6.2 页面数据流设计

#### 6.2.1 HomeScreen（周视图主页）

**用例对应**：
- 启动软件，自动显示当前周的所有课程
- 课程块按时间生成长度显示在网格里
- 课程块根据数据库记录显示颜色
- 左右滑动切换周次

```dart
/// 周视图主页
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. 监听当前周次
    final currentWeek = ref.watch(currentWeekProvider);
    
    // 2. 监听当前作息时间表（用于显示时间）
    final timeSchedule = ref.watch(timeScheduleProvider);
    
    // 3. 监听当前周的课程列表
    final weeklyCourses = ref.watch(weeklyCoursesProvider(currentWeek));
    
    // 4. 监听课程表信息（用于显示学期信息）
    final tableState = ref.watch(courseTableProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: WeekSelector(
          currentWeek: currentWeek,
          totalWeeks: tableState.table?.totalWeeks ?? 18,
          onWeekChanged: (week) {
            // 切换周次
            ref.read(currentWeekProvider.notifier).setWeek(week);
          },
        ),
      ),
      body: timeSchedule.when(
        data: (schedule) => weeklyCourses.when(
          data: (courses) => ScheduleGrid(
            courses: courses,
            currentWeek: currentWeek,
            timeSchedule: schedule!,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('加载失败: $e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载作息表失败: $e')),
      ),
    );
  }
}
```

#### 6.2.2 ScheduleGrid（课程表网格）

**用例对应**：
- 课程块按时间生成长度
- 课程块显示颜色

```dart
/// 课程表网格组件
class ScheduleGrid extends ConsumerWidget {
  final List<CourseScheduleWithInfo> courses;
  final int currentWeek;
  final TimeSchedule timeSchedule;
  
  const ScheduleGrid({
    required this.courses,
    required this.currentWeek,
    required this.timeSchedule,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 计算每分钟对应的像素高度
    final pixelsPerMinute = _calculatePixelsPerMinute();
    
    return SingleChildScrollView(
      child: Row(
        children: [
          // 左侧时间列
          _buildTimeColumn(context),
          
          // 课程网格
          Expanded(
            child: Stack(
              children: [
                // 网格线
                _buildGridLines(context),
                
                // 课程卡片
                ...courses.map((item) {
                  return _buildCourseCard(context, ref, item, pixelsPerMinute);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// 构建课程卡片
  Widget _buildCourseCard(
    BuildContext context,
    WidgetRef ref,
    CourseScheduleWithInfo item,
    double pixelsPerMinute,
  ) {
    final schedule = item.schedule;
    final info = item.info;
    
    // 计算卡片位置和高度
    final top = SchedulePositionCalculator.calculateTop(schedule, timeSchedule);
    final height = SchedulePositionCalculator.calculateHeight(schedule, timeSchedule);
    final left = (schedule.dayOfWeek - 1) * _columnWidth;
    
    return Positioned(
      top: top,
      left: left,
      width: _columnWidth,
      height: height,
      child: GestureDetector(
        onTap: () => _showCourseDetail(context, ref, info.id),
        child: CourseCard(
          course: _toCourseModel(item),
          isCurrentWeek: schedule.isActiveInWeek(currentWeek),
        ),
      ),
    );
  }
  
  /// 显示课程详情
  void _showCourseDetail(BuildContext context, WidgetRef ref, String courseInfoId) {
    Navigator.of(context).pushNamed('/course/$courseInfoId');
  }
}
```

#### 6.2.3 CourseDetailScreen（课程详情页）

**用例对应**：
- 点击课程块，弹出窗口显示详细课程信息

```dart
/// 课程详情页
class CourseDetailScreen extends ConsumerWidget {
  final String courseInfoId;
  
  const CourseDetailScreen({
    super.key,
    required this.courseInfoId,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听课程详情
    final detail = ref.watch(courseDetailProvider(courseInfoId));
    
    return detail.when(
      data: (data) {
        if (data == null) {
          return const Scaffold(body: Center(child: Text('课程不存在')));
        }
        
        return Scaffold(
          appBar: AppBar(
            title: Text(data.info.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    '/course/edit',
                    arguments: data.info.id,
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _showDeleteDialog(context, ref, data),
              ),
            ],
          ),
          body: _buildDetailBody(context, data),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('加载失败: $e'))),
    );
  }
  
  Widget _buildDetailBody(BuildContext context, CourseDetail data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 课程基本信息
          _buildInfoCard(
            context,
            title: '基本信息',
            children: [
              _buildInfoRow('课程名称', data.info.name),
              if (data.info.credit != null)
                _buildInfoRow('学分', data.info.credit.toString()),
              _buildInfoRow('备注', data.info.note ?? '无'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 上课安排列表
          _buildInfoCard(
            context,
            title: '上课安排',
            children: data.schedules.map((schedule) {
              return _buildScheduleItem(context, schedule);
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  /// 显示删除对话框
  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    CourseDetail data,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除课程'),
        content: const Text('确定要删除这门课程吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              // 删除课程信息（会级联删除所有安排）
              await ref.read(courseInfoProvider.notifier).deleteCourseInfo(data.info.id);
              if (context.mounted) {
                Navigator.pop(context); // 关闭对话框
                Navigator.pop(context); // 返回上一页
              }
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
```

#### 6.2.4 WeekSelector（周次选择器）

**用例对应**：
- 左右滑动切换周次
- 首页更新第xx周

```dart
/// 周次选择器组件
class WeekSelector extends ConsumerWidget {
  final int currentWeek;
  final int totalWeeks;
  final ValueChanged<int> onWeekChanged;
  
  const WeekSelector({
    required this.currentWeek,
    required this.totalWeeks,
    required this.onWeekChanged,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取课程表信息用于显示日期范围
    final tableState = ref.watch(courseTableProvider);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 上一周按钮
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: currentWeek > 1
            ? () => onWeekChanged(currentWeek - 1)
            : null,
        ),
        
        // 周次显示（可点击选择）
        GestureDetector(
          onTap: () => _showWeekPicker(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('第 $currentWeek 周'),
              if (tableState.table != null)
                Text(
                  _getWeekDateRange(tableState.table!.semesterStartDate, currentWeek),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
            ],
          ),
        ),
        
        // 下一周按钮
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: currentWeek < totalWeeks
            ? () => onWeekChanged(currentWeek + 1)
            : null,
        ),
        
        // 回到当前周按钮
        if (!_isCurrentWeek(tableState.table, currentWeek))
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              ref.read(currentWeekProvider.notifier).resetToCurrentWeek();
            },
            tooltip: '回到当前周',
          ),
      ],
    );
  }
  
  /// 显示周次选择器
  void _showWeekPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => WeekPickerSheet(
        currentWeek: currentWeek,
        totalWeeks: totalWeeks,
        onSelected: (week) {
          onWeekChanged(week);
          Navigator.pop(context);
        },
      ),
    );
  }
}
```

#### 6.2.5 TimeSettingsScreen（时间表设置页）

**用例对应**：
- 时间表设置：一天几节课，每节课时间范围
- 课表显示根据关联的时间表显示上下课时间

```dart
/// 时间表设置页
class TimeSettingsScreen extends ConsumerWidget {
  const TimeSettingsScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听所有作息时间表
    final schedules = ref.watch(timeScheduleNotifierProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('作息时间设置'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(context, ref),
          ),
        ],
      ),
      body: schedules.when(
        data: (list) => ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            final schedule = list[index];
            return ListTile(
              title: Text(schedule.name),
              subtitle: Text('${schedule.slots.length} 节课'),
              trailing: schedule.isDefault 
                ? const Chip(label: Text('当前使用'))
                : null,
              onTap: () => _editSchedule(context, ref, schedule),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
      ),
    );
  }
  
  /// 编辑作息时间表
  void _editSchedule(
    BuildContext context,
    WidgetRef ref,
    TimeSchedule schedule,
  ) {
    Navigator.of(context).pushNamed(
      '/settings/time/edit',
      arguments: schedule.id,
    );
  }
}
```

### 6.3 数据流图

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           数据流向                                       │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  用户操作                    Provider                    Repository      │
│  ────────                    ────────                    ──────────      │
│                                                                         │
│  ┌──────────┐    切换周次    ┌─────────────────┐                        │
│  │ 滑动/点击 │ ───────────► │ currentWeek     │                        │
│  │ 周次选择器 │              │ Provider        │                        │
│  └──────────┘              └────────┬────────┘                        │
│                                     │                                   │
│                                     │ 值变化                            │
│                                     ▼                                   │
│                            ┌─────────────────┐                         │
│                            │ weeklyCourses   │                         │
│                            │ Provider        │                         │
│                            │ (自动重新获取)   │                         │
│                            └────────┬────────┘                         │
│                                     │                                   │
│                                     │ 调用                              │
│                                     ▼                                   │
│                            ┌─────────────────┐                         │
│                            │ CourseSchedule  │                         │
│                            │ Repository      │ ◄─── SQLite             │
│                            └─────────────────┘                         │
│                                                                         │
│  ─────────────────────────────────────────────────────────────────────  │
│                                                                         │
│  ┌──────────┐    点击课程    ┌─────────────────┐                        │
│  │ 点击课程  │ ───────────► │ courseDetail    │                        │
│  │ 卡片      │              │ Provider        │                        │
│  └──────────┘              └────────┬────────┘                        │
│                                     │                                   │
│                                     │ 调用                              │
│                                     ▼                                   │
│                            ┌─────────────────┐                         │
│                            │ CourseInfo      │                         │
│                            │ Repository      │ ◄─── SQLite             │
│                            └─────────────────┘                         │
│                                                                         │
│  ─────────────────────────────────────────────────────────────────────  │
│                                                                         │
│  ┌──────────┐    添加/编辑   ┌─────────────────┐                        │
│  │ 保存课程  │ ───────────► │ CourseInfo      │                        │
│  │          │              │ Notifier        │                        │
│  └──────────┘              └────────┬────────┘                        │
│                                     │                                   │
│                                     │ 调用                              │
│                                     ▼                                   │
│                            ┌─────────────────┐                         │
│                            │ CourseInfo      │                         │
│                            │ Repository      │ ───► SQLite             │
│                            └─────────────────┘                         │
│                                     │                                   │
│                                     │ 成功后刷新                        │
│                                     ▼                                   │
│                            ┌─────────────────┐                         │
│                            │ weeklyCourses   │                         │
│                            │ Provider        │ (自动更新 UI)            │
│                            └─────────────────┘                         │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
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
