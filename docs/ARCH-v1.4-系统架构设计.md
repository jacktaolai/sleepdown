# Sleepdown 系统架构设计文档

**版本**: v1.4
**日期**: 2026-03-09
**状态**: 待评审
**变更说明**: 精简文档，专注接口定义，移除实现细节

---

## 1. 架构概述

### 1.1 设计目标

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

### 1.3 整体架构图

```
┌─────────────────────────────────────────────────────────────┐
│                      UI Layer (表现层)                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Screens   │  │  Widgets    │  │    Theme/Styles     │  │
│  └──────┬──────┘  └──────┬──────┘  └──────────┬──────────┘  │
└─────────┼────────────────┼───────────────────┼──────────────┘
          │                │                   │
          ▼                ▼                   ▼
┌─────────────────────────────────────────────────────────────┐
│                    Logic Layer (逻辑层)                      │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              Riverpod Providers & Notifiers           │  │
│  └───────────────────────────┬───────────────────────────┘  │
└──────────────────────────────┼──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                     Data Layer (数据层)                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │ Repository  │  │   SQLite    │  │   SharedPreferences │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. 数据模型设计

### 2.1 核心实体关系图

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

### 2.2 实体定义

#### 2.2.1 CourseTable（课程表）

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | String | 是 | UUID |
| name | String | 是 | 课程表名称 |
| semesterStartDate | DateTime | 是 | 学期开始日期 |
| totalWeeks | int | 是 | 学期总周数，默认 18 |
| timeScheduleId | String | 是 | 关联的作息时间表 ID |

#### 2.2.2 CourseInfo（课程信息）

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | String | 是 | UUID |
| courseTableId | String | 是 | 所属课程表 ID |
| name | String | 是 | 课程名称 |
| credit | double? | 否 | 学分 |
| colorValue | int | 是 | 颜色值 (ARGB) |
| note | String? | 否 | 备注 |
| createdAt | DateTime | 是 | 创建时间 |
| updatedAt | DateTime | 是 | 更新时间 |

#### 2.2.3 CourseSchedule（课程安排）

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | String | 是 | UUID |
| courseInfoId | String | 是 | 关联的课程信息 ID |
| teacher | String | 是 | 教师姓名 |
| location | String | 是 | 上课地点 |
| dayOfWeek | int | 是 | 星期几 (1-7) |
| startSection | int? | 条件 | 开始节次（节次模式） |
| endSection | int? | 条件 | 结束节次（节次模式） |
| startHour | int? | 条件 | 开始时（时间模式） |
| startMinute | int? | 条件 | 开始分（时间模式） |
| endHour | int? | 条件 | 结束时（时间模式） |
| endMinute | int? | 条件 | 结束分（时间模式） |
| weeks | List\<int\> | 是 | 离散周次列表 |
| createdAt | DateTime | 是 | 创建时间 |
| updatedAt | DateTime | 是 | 更新时间 |

**时间模式约束**：
- 节次模式：`startSection` 和 `endSection` 必须同时有值
- 时间模式：四个时间字段必须同时有值
- 两组字段互斥，不能同时有值

#### 2.2.4 TimeSchedule（作息时间表）

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | String | 是 | UUID |
| name | String | 是 | 模板名称 |
| slots | List\<TimeSlot\> | 是 | 时间槽列表 |
| isDefault | bool | 是 | 是否为默认 |

**TimeSlot（时间槽）**：

| 字段 | 类型 | 说明 |
|------|------|------|
| section | int | 节次 (1, 2, 3...) |
| startHour | int | 开始时 |
| startMinute | int | 开始分 |
| endHour | int | 结束时 |
| endMinute | int | 结束分 |

#### 2.2.5 AppSettings（应用设置）

| 字段 | 类型 | 说明 |
|------|------|------|
| themeMode | ThemeMode | 主题模式 |
| currentCourseTableId | String? | 当前使用的课程表 ID |

---

## 3. 数据库设计

### 3.1 表结构

#### 3.1.1 course_tables 表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | TEXT | PRIMARY KEY | UUID |
| name | TEXT | NOT NULL | 课程表名称 |
| semester_start_date | INTEGER | NOT NULL | 学期开始日期（时间戳） |
| total_weeks | INTEGER | NOT NULL DEFAULT 18 | 学期总周数 |
| time_schedule_id | TEXT | NOT NULL | 关联的作息时间表 ID |
| created_at | INTEGER | NOT NULL | 创建时间戳 |
| updated_at | INTEGER | NOT NULL | 更新时间戳 |

#### 3.1.2 course_infos 表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | TEXT | PRIMARY KEY | UUID |
| course_table_id | TEXT | NOT NULL, FK | 所属课程表 ID |
| name | TEXT | NOT NULL | 课程名称 |
| credit | REAL | | 学分 |
| color_value | INTEGER | NOT NULL | 颜色值 (ARGB) |
| note | TEXT | | 备注 |
| created_at | INTEGER | NOT NULL | 创建时间戳 |
| updated_at | INTEGER | NOT NULL | 更新时间戳 |

#### 3.1.3 course_schedules 表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | TEXT | PRIMARY KEY | UUID |
| course_info_id | TEXT | NOT NULL, FK | 关联的课程信息 ID |
| teacher | TEXT | NOT NULL | 教师姓名 |
| location | TEXT | NOT NULL | 上课地点 |
| day_of_week | INTEGER | NOT NULL | 星期几 (1-7) |
| start_section | INTEGER | | 开始节次 |
| end_section | INTEGER | | 结束节次 |
| start_hour | INTEGER | | 开始时 |
| start_minute | INTEGER | | 开始分 |
| end_hour | INTEGER | | 结束时 |
| end_minute | INTEGER | | 结束分 |
| weeks | TEXT | NOT NULL | 离散周次 JSON |
| created_at | INTEGER | NOT NULL | 创建时间戳 |
| updated_at | INTEGER | NOT NULL | 更新时间戳 |

#### 3.1.4 time_schedules 表

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | TEXT | PRIMARY KEY | UUID |
| name | TEXT | NOT NULL | 模板名称 |
| slots | TEXT | NOT NULL | 时间槽 JSON |
| is_default | INTEGER | NOT NULL DEFAULT 0 | 是否默认 (0/1) |

### 3.2 外键与索引

```sql
-- 外键约束
ALTER TABLE course_infos ADD CONSTRAINT fk_course_table
  FOREIGN KEY (course_table_id) REFERENCES course_tables(id) ON DELETE CASCADE;

ALTER TABLE course_schedules ADD CONSTRAINT fk_course_info
  FOREIGN KEY (course_info_id) REFERENCES course_infos(id) ON DELETE CASCADE;

ALTER TABLE course_tables ADD CONSTRAINT fk_time_schedule
  FOREIGN KEY (time_schedule_id) REFERENCES time_schedules(id);

-- 索引
CREATE INDEX idx_course_infos_table ON course_infos(course_table_id);
CREATE INDEX idx_course_schedules_info ON course_schedules(course_info_id);
CREATE INDEX idx_course_schedules_day ON course_schedules(day_of_week);
```

---

## 4. Provider 接口设计

### 4.1 Provider 层级结构

```
AppSettings Provider (应用设置)
        │
        ▼
CourseTable Provider (当前课程表)
        │
        ├──► TimeSchedule Provider (当前作息表)
        │
        └──► CurrentWeek Provider (当前周次)
                    │
                    ▼
            WeeklyCourses Provider (某周课程)
```

### 4.2 Provider 定义

#### 4.2.1 基础 Provider

| Provider 名称 | 类型 | 状态类型 | 说明 |
|---------------|------|----------|------|
| `settingsProvider` | StateNotifierProvider | AppSettings | 应用设置 |
| `courseTableProvider` | StateNotifierProvider | CourseTableState | 当前课程表 |
| `timeScheduleProvider` | FutureProvider | TimeSchedule? | 当前作息时间表 |
| `currentWeekProvider` | StateNotifierProvider | int | 当前周次 |

#### 4.2.2 派生 Provider

| Provider 名称 | 类型 | 参数 | 返回类型 | 说明 |
|---------------|------|------|----------|------|
| `weeklyCoursesProvider` | FutureProvider.family | week: int | List\<CourseScheduleWithInfo\> | 某周课程列表 |
| `dailyCoursesProvider` | Provider.family | week: int | Map\<int, List\> | 某天课程列表 |
| `courseDetailProvider` | FutureProvider.family | courseInfoId: String | CourseDetail? | 课程详情 |

#### 4.2.3 聚合查询 Provider

| Provider 名称 | 返回类型 | 说明 |
|---------------|----------|------|
| `allTeachersProvider` | List\<String\> | 所有教师列表 |
| `allLocationsProvider` | List\<String\> | 所有教室列表 |
| `allColorsProvider` | List\<int\> | 所有使用过的颜色 |

### 4.3 Notifier 接口

#### 4.3.1 CourseTableNotifier

| 方法 | 参数 | 返回值 | 说明 |
|------|------|--------|------|
| `switchCourseTable` | tableId: String | Future\<void\> | 切换课程表 |
| `updateCourseTable` | table: CourseTable | Future\<void\> | 更新课程表信息 |

#### 4.3.2 DisplayedWeekNotifier

| 方法 | 参数 | 返回值 | 说明 |
|------|------|--------|------|
| `setDisplayedWeek` | week: int | void | 设置指定的展示周 |
| `switchToPreviousWeek` | - | void | 切换到上一个展示周 |
| `switchToNextWeek` | - | void | 切换到下一个展示周 |
| `resetToActualCurrentWeek` | - | void | 重置展示周为学期/系统的真实当前周 |

#### 4.3.3 CourseInfoNotifier

| 方法 | 参数 | 返回值 | 说明 |
|------|------|--------|------|
| `addCourseInfo` | name, credit?, colorValue, note? | Future\<CourseInfo\> | 添加课程信息 |
| `updateCourseInfo` | info: CourseInfo | Future\<void\> | 更新课程信息 |
| `deleteCourseInfo` | id: String | Future\<void\> | 删除课程信息（级联删除安排） |

#### 4.3.4 CourseScheduleNotifier

| 方法 | 参数 | 返回值 | 说明 |
|------|------|--------|------|
| `addSchedule` | teacher, location, dayOfWeek, weeks, 时间/节次参数 | Future\<CourseSchedule\> | 添加课程安排 |
| `updateSchedule` | schedule: CourseSchedule | Future\<void\> | 更新课程安排 |
| `deleteSchedule` | id: String | Future\<void\> | 删除课程安排 |

#### 4.3.5 TimeScheduleNotifier

| 方法 | 参数 | 返回值 | 说明 |
|------|------|--------|------|
| `addTimeSchedule` | schedule: TimeSchedule | Future\<void\> | 添加作息时间表 |
| `updateTimeSchedule` | schedule: TimeSchedule | Future\<void\> | 更新作息时间表 |
| `deleteTimeSchedule` | id: String | Future\<void\> | 删除作息时间表 |
| `setDefault` | id: String | Future\<void\> | 设置默认作息时间表 |

#### 4.3.6 SettingsNotifier

| 方法 | 参数 | 返回值 | 说明 |
|------|------|--------|------|
| `setCurrentCourseTable` | tableId: String | Future\<void\> | 切换当前课程表 |
| `setThemeMode` | mode: ThemeMode | Future\<void\> | 切换主题模式 |

---

## 5. Repository 接口设计

### 5.1 CourseTableRepository

| 方法 | 参数 | 返回值 | 说明 |
|------|------|--------|------|
| `getAllCourseTables` | - | Future\<List\<CourseTable\>\> | 获取所有课程表 |
| `getCourseTableById` | id: String | Future\<CourseTable?\> | 根据 ID 获取 |
| `addCourseTable` | table: CourseTable | Future\<void\> | 添加课程表 |
| `updateCourseTable` | table: CourseTable | Future\<void\> | 更新课程表 |
| `deleteCourseTable` | id: String | Future\<void\> | 删除课程表 |

### 5.2 CourseInfoRepository

| 方法 | 参数 | 返回值 | 说明 |
|------|------|--------|------|
| `getCourseInfosByTableId` | tableId: String | Future\<List\<CourseInfo\>\> | 获取课程表的所有课程信息 |
| `getCourseInfoById` | id: String | Future\<CourseInfo?\> | 根据 ID 获取 |
| `addCourseInfo` | info: CourseInfo | Future\<void\> | 添加课程信息 |
| `updateCourseInfo` | info: CourseInfo | Future\<void\> | 更新课程信息 |
| `deleteCourseInfo` | id: String | Future\<void\> | 删除课程信息 |
| `getAllTeachers` | tableId: String | Future\<List\<String\>\> | 获取所有教师 |
| `getAllLocations` | tableId: String | Future\<List\<String\>\> | 获取所有教室 |
| `getAllColors` | tableId: String | Future\<List\<int\>\> | 获取所有颜色 |

### 5.3 CourseScheduleRepository

| 方法 | 参数 | 返回值 | 说明 |
|------|------|--------|------|
| `getSchedulesByCourseInfoId` | infoId: String | Future\<List\<CourseSchedule\>\> | 获取课程信息的所有安排 |
| `getSchedulesByWeek` | tableId: String, week: int | Future\<List\<CourseScheduleWithInfo\>\> | 获取某周的所有课程 |
| `addSchedule` | schedule: CourseSchedule | Future\<void\> | 添加课程安排 |
| `updateSchedule` | schedule: CourseSchedule | Future\<void\> | 更新课程安排 |
| `deleteSchedule` | id: String | Future\<void\> | 删除课程安排 |

**CourseScheduleWithInfo**：

| 字段 | 类型 | 说明 |
|------|------|------|
| schedule | CourseSchedule | 课程安排 |
| info | CourseInfo | 课程信息 |

### 5.4 TimeScheduleRepository

| 方法 | 参数 | 返回值 | 说明 |
|------|------|--------|------|
| `getAllTimeSchedules` | - | Future\<List\<TimeSchedule\>\> | 获取所有作息时间表 |
| `getTimeScheduleById` | id: String | Future\<TimeSchedule?\> | 根据 ID 获取 |
| `getDefaultTimeSchedule` | - | Future\<TimeSchedule?\> | 获取默认作息时间表 |
| `addTimeSchedule` | schedule: TimeSchedule | Future\<void\> | 添加作息时间表 |
| `updateTimeSchedule` | schedule: TimeSchedule | Future\<void\> | 更新作息时间表 |
| `deleteTimeSchedule` | id: String | Future\<void\> | 删除作息时间表 |
| `setDefaultTimeSchedule` | id: String | Future\<void\> | 设置默认 |

### 5.5 SettingsRepository

| 方法 | 参数 | 返回值 | 说明 |
|------|------|--------|------|
| `getSettings` | - | Future\<AppSettings\> | 获取应用设置 |
| `updateSettings` | settings: AppSettings | Future\<void\> | 更新应用设置 |

**存储方式**：使用 SharedPreferences

| Key | 类型 | 说明 |
|-----|------|------|
| `theme_mode` | int | ThemeMode 枚举索引 (0=system, 1=light, 2=dark) |
| `current_course_table_id` | String? | 当前使用的课程表 ID |

---

## 6. 数据流设计

### 6.1 数据流图

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              数据流向                                    │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  用户操作                    Provider                    Repository      │
│  ────────                    ────────                    ──────────      │
│                                                                         │
│  切换周次 ────────► currentWeekProvider                                  │
│                              │                                          │
│                              ▼                                          │
│                    weeklyCoursesProvider ──────► CourseScheduleRepo     │
│                              │                                          │
│                              ▼                                          │
│                         UI 自动更新                                      │
│                                                                         │
│  ─────────────────────────────────────────────────────────────────────  │
│                                                                         │
│  点击课程卡片 ─────► courseDetailProvider ──────► CourseInfoRepo        │
│                              │                                          │
│                              ▼                                          │
│                         显示详情页                                       │
│                                                                         │
│  ─────────────────────────────────────────────────────────────────────  │
│                                                                         │
│  添加/编辑课程 ─────► CourseInfoNotifier ──────► CourseInfoRepo         │
│                              │                                          │
│                              ▼                                          │
│                    weeklyCoursesProvider 自动刷新                        │
│                              │                                          │
│                              ▼                                          │
│                         UI 自动更新                                      │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### 6.2 页面数据依赖

| 页面 | 依赖的 Provider | 说明 |
|------|-----------------|------|
| HomeScreen | currentWeekProvider, weeklyCoursesProvider, timeScheduleProvider, courseTableProvider | 周视图主页 |
| CourseDetailScreen | courseDetailProvider | 课程详情页 |
| CourseEditScreen | CourseInfoNotifier, CourseScheduleNotifier | 课程编辑页 |
| SettingsScreen | settingsProvider | 设置页 |
| TimeSettingsScreen | TimeScheduleNotifier | 作息时间设置页 |

---

## 7. 目录结构

```
lib/
├── main.dart
├── models/                      # 数据模型
│   ├── models.dart              # 导出所有模型
│   ├── app_settings.dart
│   ├── course_info.dart
│   ├── course_schedule.dart
│   ├── course_table.dart
│   └── time_schedule.dart
├── providers/                   # 状态管理
│   ├── providers.dart           # 导出所有 Provider
│   ├── settings_provider.dart
│   ├── course_table_provider.dart
│   ├── time_schedule_provider.dart
│   └── weekly_courses_provider.dart
├── repository/                  # 数据仓库
│   ├── repository.dart          # 导出所有 Repository
│   ├── course_table_repository.dart
│   ├── course_info_repository.dart
│   ├── course_schedule_repository.dart
│   ├── time_schedule_repository.dart
│   └── settings_repository.dart
└── database/                    # SQLite 数据库
    └── db_helper.dart
```

**测试目录**：

```
test/
├── database/
│   └── db_helper_test.dart
├── models/
│   ├── app_settings_test.dart
│   ├── course_info_test.dart
│   ├── course_schedule_test.dart
│   ├── course_table_test.dart
│   └── time_schedule_test.dart
├── providers/
│   ├── settings_provider_test.dart
│   ├── course_table_provider_test.dart
│   ├── time_schedule_provider_test.dart
│   └── weekly_courses_provider_test.dart
└── repository/
    ├── course_table_repository_test.dart
    ├── course_info_repository_test.dart
    ├── course_schedule_repository_test.dart
    └── time_schedule_repository_test.dart
```

---

## 8. 依赖库

| 依赖 | 版本 | 用途 |
|------|------|------|
| flutter | SDK | UI 框架 |
| flutter_riverpod | ^2.4.0 | 状态管理 |
| sqflite | ^2.3.0 | SQLite 数据库 |
| uuid | ^4.2.0 | UUID 生成 |
| intl | ^0.18.0 | 日期格式化 |
| shared_preferences | ^2.2.0 | 简单存储 |

---

## 9. 变更记录

### v1.4 (2026-03-09)

- 精简文档，专注接口定义
- 移除详细实现代码
- 移除页面详细代码
- 保留数据模型、Provider 接口、Repository 接口、数据库设计

### v1.3 (2026-03-08)

- 新增 CourseTable 实体
- 拆分 Course 为 CourseInfo + CourseSchedule
- 周次存储改为离散列表
- 新增时间输入模式支持

### v1.2 (2026-02-21)

- 扁平化目录结构
- 完善周次模式支持

### v1.1 (2026-02-19)

- 精简架构
- 合并 Entity/Model

### v1.0 (2026-02-19)

- 初始版本
