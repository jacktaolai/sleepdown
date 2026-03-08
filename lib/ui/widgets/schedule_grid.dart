import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widget_previews.dart';
import '../../models/course.dart';
import 'course_card.dart';

/// ScheduleGrid: 课程表网格组件
/// 
/// 继承自 ConsumerWidget：就是可滚动的页面
/// - ConsumerWidget 是 Riverpod 提供的 Widget，可以访问 Provider 的状态
/// - 当 Provider 的数据变化时，ConsumerWidget 会自动重建（类似 setState）
/// - 相比 StatefulWidget，不需要手动管理状态，更简洁
class ScheduleGrid extends ConsumerWidget {
  /// 课程列表 - 显示在课表中的所有课程
  final List<Course> courses;
  
  /// 当前周次 - 用于判断课程是否在当前周显示
  final int currentWeek;
  
  /// 列宽 - 课程格子的宽度，0 表示自动计算
  final double columnWidth;
  
  /// 时间列宽度 - 左侧显示时间的列宽度
  final double timeColumnWidth;

  /// const 构造函数，可以被缓存
  const ScheduleGrid({
    super.key,
    required this.courses,
    required this.currentWeek,
    this.columnWidth = 0,
    this.timeColumnWidth = 48.0,
  });

  /// 静态常量：一节课的高度（64 逻辑像素）
  /// static const 表示这是类级别的常量，类似于其他语言的 static final
  static const double sectionHeight = 64.0;
  
  /// 默认时间列宽度
  static const double defaultTimeColumnWidth = 48.0;
  
  /// 总节数，一天最多 12 节课程
  static const int totalSections = 12;

  /// build 方法是 Widget 的核心渲染方法
  /// 
  /// 参数：
  /// - BuildContext context: 包含 Widget 树的位置信息，用于获取主题、尺寸、导航等
  /// - WidgetRef ref: Riverpod 提供的引用，用于读取 Provider 状态
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// Theme.of(context).colorScheme: 获取主题的颜色方案
    /// 这是 Flutter 的 "InheritedWidget" 机制，父节点设置后，子节点可以访问
    final colorScheme = Theme.of(context).colorScheme;
    
    /// 计算有效的时间列宽度
    /// 如果传入的值不为 0，使用传入值；否则使用默认值
    /// 三元运算符: condition ? valueIfTrue : valueIfFalse
    final effectiveTimeColumnWidth = timeColumnWidth != 0 ? timeColumnWidth : defaultTimeColumnWidth;
    
    /// 计算有效的课程列宽度
    /// 
    /// MediaQuery.of(context).size: 获取屏幕尺寸
    /// .size.width: 屏幕宽度
    /// 
    /// 计算公式：(屏幕宽度 - 左右内边距 32 - 时间列宽度) / 7 天
    /// 这样可以确保课程列自适应屏幕宽度
    final effectiveColumnWidth = columnWidth != 0
        ? columnWidth
        : (MediaQuery.of(context).size.width - 32 - effectiveTimeColumnWidth) / 7;

    /// SingleChildScrollView: 单子项滚动视图
    /// 当内容超过屏幕时可以滚动显示
    /// 类似于 Android 的 ScrollView 或 iOS 的 UIScrollView
    return SingleChildScrollView(
      /// padding: 内容与视图边缘的内边距
      padding: const EdgeInsets.only(bottom: 24),
      
      /// child: 滚动的内容
      /// 
      /// Row: 水平布局容器
      /// 将时间列和课程网格区域水平排列
      child: Row(
        /// crossAxisAlignment: 交叉轴对齐方式
        /// CrossAxisAlignment.start: 顶部对齐
        /// 当 Row 高度由子元素决定时，子元素会在顶部对齐
        crossAxisAlignment: CrossAxisAlignment.start,
        
        /// children: Row 的子元素列表
        /// 第一个子元素：时间列
        /// 第二个子元素：课程网格区域（Expanded，会占据剩余空间）
        children: [
          /// 时间列 - 显示 1-12 节的节次和时间
          /// 
          /// SizedBox: 固定尺寸的容器
          /// 可以指定 width、height 或两者都指定
          SizedBox(
            /// width: 指定宽度
            width: effectiveTimeColumnWidth,
            
            /// child: Column，垂直排列 12 个时间块
            child: Column(
              /// List.generate: 生成列表的便捷方法
              /// 第一个参数是数量，第二个是生成每个元素的函数
              /// 这里生成 12 个 Container，代表 12 节课
              children: List.generate(totalSections, (index) {
                /// index 是 0-11，section 是 1-12
                final section = index + 1;
                
                /// 返回一个 Container（课程节次显示块）
                return Container(
                  /// height: 固定高度
                  height: sectionHeight,
                  
                  /// alignment: 子元素在容器内的对齐方式
                  /// Alignment.center: 居中对齐
                  alignment: Alignment.center,
                  
                  /// decoration: 装饰效果（背景色、边框、圆角等）
                  decoration: BoxDecoration(
                    /// border: 边框
                    border: Border(
                      /// bottom: 底部边框
                      bottom: BorderSide(
                        /// color: 边框颜色
                        /// withValues(alpha: 0.1): 设置透明度，0.1 = 10% 不透明度
                        color: colorScheme.outlineVariant.withValues(alpha: 0.1),
                        width: 1,
                      ),
                      /// right: 右边框
                      right: BorderSide(
                        color: colorScheme.outlineVariant.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  
                  /// child: 容器内的子元素
                  /// 
                  /// FittedBox: 自适应尺寸的容器
                  /// 根据 fit 属性自动缩放子元素以适应容器
                  child: FittedBox(
                    /// fit: 适应方式
                    /// BoxFit.scaleDown: 如果子元素比容器大，就缩小；如果比容器小，就保持原大小
                    fit: BoxFit.scaleDown,
                    
                    child: Column(
                      /// mainAxisAlignment: 主轴对齐方式
                      /// 在 Column 中，主轴是垂直方向
                      /// MainAxisAlignment.center: 垂直居中
                      mainAxisAlignment: MainAxisAlignment.center,
                      
                      children: [
                        /// 第一节、第二节...的文本
                        Text(
                          '$section',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        
                        /// 时间文本（如 08:00-08:45）
                        Text(
                          _getTimeForSection(section),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 8,
                            height: 1.1,
                          ),
                          /// textAlign: 文本对齐方式
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          
          /// 课程网格区域 - 实际显示课程的 7x12 网格
          /// 
          /// Expanded: 让子元素占据 Row 的剩余空间
          /// 这会让课程区域占据时间列之外的所有宽度
          Expanded(
            child: SizedBox(
              /// 设置固定高度：总节数 * 每节高度
              height: totalSections * sectionHeight,
              
              /// child: Stack - 层叠布局
              /// Stack 允许子元素重叠在一起（类似 Android 的 FrameLayout）
              /// 这里用 Stack 是为了把网格线、课程卡片叠加在一起
              child: Stack(
                children: [
                  /// 第一个子元素：水平网格线（横向的线）
                  /// 
                  /// Column: 12 个水平线，垂直排列
                  Column(
                    children: List.generate(totalSections, (index) {
                      return Container(
                        height: sectionHeight,
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              /// Color(0x1AC3C7CF): 十六进制颜色表示
                              /// 0x1A = 26 = 10% 透明度
                              color: Color(0x1AC3C7CF),
                              width: 1,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  
                  /// 第二个子元素：垂直网格线（竖向的线）
                  /// 
                  /// Row: 7 条垂直线，水平排列
                  Row(
                    children: List.generate(7, (index) {
                      return Container(
                        width: effectiveColumnWidth,
                        height: totalSections * sectionHeight,
                        decoration: const BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: Color(0x1AC3C7CF),
                              width: 1,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  
                  /// 第三个子元素：课程卡片列表
                  /// 
                  /// ... (展开运算符): 将 Iterable 展开为独立的元素
                  /// courses.map((course) {...}) 返回一个 Iterable
                  /// ...courses.map(...) 会把这个 Iterable 的每个元素作为独立的子元素
                  ...courses.map((course) {
                    /// 判断课程是否在当前周
                    final isActive = course.isActiveInWeek(currentWeek);

                    /// Positioned: Stack 中的定位组件
                    /// 用于在 Stack 中精确指定子元素的位置
                    return Positioned(
                      /// top: 距离 Stack 顶部的距离
                      /// (课程开始节次 - 1) * 每节高度 = 课程顶部的位置
                      /// 节次从 1 开始，所以要减 1
                      top: (course.startSection - 1) * sectionHeight,
                      
                      /// left: 距离 Stack 左侧的距离
                      /// (星期几 - 1) * 每列宽度 = 课程左侧的位置
                      /// 星期从 1（周一）开始，所以要减 1
                      left: (course.dayOfWeek - 1) * effectiveColumnWidth,
                      
                      /// width: 课程卡片宽度 = 一列的宽度
                      width: effectiveColumnWidth,
                      
                      /// height: 课程卡片高度
                      /// = (结束节次 - 开始节次 + 1) * 每节高度
                      /// +1 是因为包含开始和结束的两节
                      height: (course.endSection - course.startSection + 1) * sectionHeight,
                      
                      /// child: 课程卡片组件
                      child: CourseCard(
                        course: course,
                        isCurrentWeek: isActive,
                        
                        /// onTap: 点击回调
                        /// 箭头函数: () => expression
                        /// 这是一个匿名函数/闭包
                        onTap: () {
                          /// Navigator.of(context): 获取导航器
                          /// 用于管理页面栈（类似 Android 的 Intent）
                          Navigator.of(context).pushNamed(
                            '/course/${course.id}',
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 私有方法：根据节次获取上课时间
  /// 
  /// 参数：section 节次（1-12）
  /// 返回：格式化的时间字符串，如 "08:00\n08:45"
  /// 
  /// _ 开头表示这是私有方法，只能在当前文件内访问
  String _getTimeForSection(int section) {
    /// 模拟时间：第 N 节就是 8+N-1 点开始
    final startHour = 8 + (section - 1);
    final startMinute = 0;
    final endHour = startHour;
    final endMinute = 45;

    /// padLeft(2, '0'): 如果字符串不足 2 位，用 '0' 左边填充
    /// 比如 8 变成 "08"，5 变成 "05"
    return '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}\n${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
  }
}

// ============== Widget Preview Annotations ==============

/// 预览: ScheduleGrid - 空课程表
@Preview(
  name: 'ScheduleGrid - 空课程表',
  group: 'ScheduleGrid',
  size: Size(360, 800),
)
Widget scheduleGridEmptyPreview() {
  return MaterialApp(
    theme: ThemeData.light(useMaterial3: true),
    home: Scaffold(
      body: SizedBox(
        width: 360,
        height: 800,
        child: const ScheduleGrid(
          courses: [],
          currentWeek: 1,
        ),
      ),
    ),
  );
}

/// 预览: ScheduleGrid - 有课程
@Preview(
  name: 'ScheduleGrid - 有课程',
  group: 'ScheduleGrid',
  size: Size(360, 800),
)
Widget scheduleGridWithCoursesPreview() {
  final courses = [
    Course(
      id: '1',
      name: '数据结构',
      teacher: '张三',
      location: 'A301',
      dayOfWeek: 1,
      startSection: 1,
      endSection: 2,
      weekRanges: [WeekRange(start: 1, end: 16)],
      colorValue: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Course(
      id: '2',
      name: '算法设计',
      teacher: '李四',
      location: 'B205',
      dayOfWeek: 2,
      startSection: 3,
      endSection: 4,
      weekRanges: [WeekRange(start: 1, end: 16)],
      colorValue: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Course(
      id: '3',
      name: '操作系统',
      teacher: '王五',
      location: 'C402',
      dayOfWeek: 3,
      startSection: 5,
      endSection: 6,
      weekRanges: [WeekRange(start: 1, end: 16)],
      colorValue: 2,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Course(
      id: '4',
      name: '计算机网络',
      teacher: '赵六',
      location: 'D101',
      dayOfWeek: 5,
      startSection: 7,
      endSection: 8,
      weekRanges: [WeekRange(start: 1, end: 16)],
      colorValue: 3,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  return MaterialApp(
    theme: ThemeData.light(useMaterial3: true),
    home: Scaffold(
      body: SizedBox(
        width: 360,
        height: 800,
        child: ScheduleGrid(
          courses: courses,
          currentWeek: 1,
        ),
      ),
    ),
  );
}
