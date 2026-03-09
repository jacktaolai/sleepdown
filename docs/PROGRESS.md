# Sleepdown 开发进度记录

## 当前状态

**最后更新**: 2026-03-09  
**测试状态**: ✅ 95 个测试全部通过

---

## 已完成模块

### 1. 数据模型 (Models)

| 文件 | 说明 | 主要接口 |
|------|------|----------|
| `lib/models/app_settings.dart` | 应用设置 | `themeMode`, `currentCourseTableId`, `copyWith()` |
| `lib/models/course_table.dart` | 课程表 | `id`, `name`, `semesterStartDate`, `totalWeeks`, `timeScheduleId` |
| `lib/models/course_info.dart` | 课程信息 | `id`, `courseTableId`, `name`, `credit`, `colorValue`, `note` |
| `lib/models/course_schedule.dart` | 课程安排 | `id`, `courseInfoId`, `teacher`, `location`, `dayOfWeek`, `startSection/endSection`, `startHour/startMinute`, `endHour/endMinute`, `weeks` |
| `lib/models/time_schedule.dart` | 作息时间表 | `id`, `name`, `slots`, `isDefault` |
| `lib/models/time_slot.dart` | 时间段 | `section`, `startHour`, `startMinute`, `endHour`, `endMinute` |

### 2. 数据库层 (Database)

| 文件 | 说明 | 主要接口 |
|------|------|----------|
| `lib/database/db_helper.dart` | SQLite 数据库助手 | `database`, `close()` |

**数据库表结构**:
- `course_tables` - 课程表
- `course_infos` - 课程信息
- `course_schedules` - 课程安排
- `time_schedules` - 作息时间表

### 3. Repository 层

| 文件 | 说明 | 主要接口 |
|------|------|----------|
| `lib/repository/settings_repository.dart` | 设置仓储 | `getSettings()`, `updateSettings()` |
| `lib/repository/course_table_repository.dart` | 课程表仓储 | `getAllCourseTables()`, `getCourseTableById()`, `addCourseTable()`, `updateCourseTable()`, `deleteCourseTable()` |
| `lib/repository/course_info_repository.dart` | 课程信息仓储 | `getCourseInfosByTableId()`, `getCourseInfoById()`, `addCourseInfo()`, `updateCourseInfo()`, `deleteCourseInfo()`, `getAllTeachers()`, `getAllLocations()`, `getAllColors()` |
| `lib/repository/course_schedule_repository.dart` | 课程安排仓储 | `getSchedulesByCourseInfoId()`, `getSchedulesByWeek()`, `addSchedule()`, `updateSchedule()`, `deleteSchedule()` |
| `lib/repository/time_schedule_repository.dart` | 作息时间仓储 | `getAllTimeSchedules()`, `getTimeScheduleById()`, `getDefaultTimeSchedule()`, `addTimeSchedule()`, `updateTimeSchedule()`, `deleteTimeSchedule()`, `setDefaultTimeSchedule()` |

### 4. Provider 层

| 文件 | Notifier | Provider | 说明 |
|------|----------|----------|------|
| `lib/providers/database_helper_provider.dart` | - | `databaseHelperProvider` | 数据库助手 Provider |
| `lib/providers/settings_provider.dart` | `SettingsNotifier` | `settingsRepositoryProvider`, `settingsProvider` | 应用设置管理 |
| `lib/providers/course_table_provider.dart` | `CourseTableNotifier` | `courseTableProvider` | 当前课程表管理 |
| `lib/providers/displayed_week_provider.dart` | `DisplayedWeekNotifier` | `currentWeekProvider` | 当前显示周次管理 |
| `lib/providers/course_info_provider.dart` | `CourseInfoNotifier` | `courseInfoProvider` (family) | 课程信息管理 |
| `lib/providers/course_schedule_provider.dart` | `CourseScheduleNotifier` | `courseScheduleProvider` (family) | 课程安排管理 |
| `lib/providers/time_schedule_provider.dart` | `TimeScheduleNotifier` | `timeScheduleProvider` | 作息时间表管理 |
| `lib/providers/weekly_courses_provider.dart` | `WeeklyCoursesNotifier` | `weeklyCoursesProvider`, `dailyCoursesProvider`, `courseDetailProvider`, `allTeachersProvider`, `allLocationsProvider`, `allColorsProvider` | 派生数据 Provider |

**Provider 依赖关系**:
```
databaseHelperProvider
    ├── settingsRepositoryProvider → settingsProvider
    └── courseTableProvider
            └── currentWeekProvider
                    └── weeklyCoursesProvider
                            ├── dailyCoursesProvider
                            ├── courseDetailProvider
                            ├── allTeachersProvider
                            ├── allLocationsProvider
                            └── allColorsProvider
```

---

## 测试覆盖

### 测试文件列表

| 文件 | 测试数量 | 说明 |
|------|----------|------|
| `test/models/app_settings_test.dart` | 4 | AppSettings 模型测试 |
| `test/providers/settings_provider_test.dart` | 7 | 设置 Provider 测试 |
| `test/providers/course_table_provider_test.dart` | 10 | 课程表 Provider 测试 |
| `test/providers/displayed_week_provider_test.dart` | 8 | 周次 Provider 测试 |
| `test/providers/course_info_provider_test.dart` | 4 | 课程信息 Provider 测试 |
| `test/providers/course_schedule_provider_test.dart` | 5 | 课程安排 Provider 测试 |
| `test/providers/time_schedule_provider_test.dart` | 5 | 作息时间 Provider 测试 |
| `test/providers/weekly_courses_provider_test.dart` | 3 | 周课程 Provider 测试 |
| `test/repository/course_table_repository_test.dart` | 6 | 课程表仓储测试 |
| `test/repository/course_info_repository_test.dart` | 8 | 课程信息仓储测试 |
| `test/repository/course_schedule_repository_test.dart` | 9 | 课程安排仓储测试 |
| `test/repository/time_schedule_repository_test.dart` | 8 | 作息时间仓储测试 |
| `test/repository/settings_repository_test.dart` | 8 | 设置仓储测试 |
| `test/database/db_helper_test.dart` | 10 | 数据库助手测试 |

**总计**: 95 个测试

---

## 待完成工作

### UI 层 (需要更新)

当前 UI 代码使用旧的模型和 Provider，需要重构：

- [ ] `lib/ui/screens/home_screen.dart` - 使用旧的 `courseListProvider`
- [ ] `lib/ui/widgets/week_calendar_strip.dart` - 使用旧的 `weekDateRangeProvider`
- [ ] `lib/ui/widgets/schedule_grid.dart` - 使用旧的 `Course` 模型
- [ ] `lib/ui/widgets/course_card.dart` - 使用旧的 `Course` 模型
- [ ] `lib/ui/widgets/week_schedule_view.dart` - 使用旧的 `Course` 模型
- [ ] `lib/preview.dart` - 使用旧的 Provider

### 功能待实现

- [ ] 课程添加/编辑界面
- [ ] 课程表管理界面
- [ ] 作息时间设置界面
- [ ] 数据导入/导出功能

---

## 架构设计参考

详细架构设计请参考: `docs/ARCH-v1.4-系统架构设计.md`
