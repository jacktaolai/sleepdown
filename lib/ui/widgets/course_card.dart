import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../../models/course.dart';
import '../../models/course_view_model.dart';
import '../../theme/app_theme.dart';

/// 课程卡片组件
///
/// Flutter 核心概念：
/// - Widget: Flutter 中所有 UI 元素都是 Widget，分为 StatelessWidget（无状态）和 StatefulWidget（有状态）
/// - 这个组件继承自 StatelessWidget，是一个无状态组件
/// - build() 方法是核心，每次需要渲染时都会调用，返回一个 Widget 树
class CourseCard extends StatelessWidget {
  /// final 关键字表示这个字段只能被赋值一次（Dart 中所有变量默认都是可变的）
  /// 支持 Course（旧设计）和 CourseViewModel（新三表设计）
  final dynamic course;

  /// bool 是 Dart 的布尔类型，默认值是 null（因为可能是可空类型）
  /// 这里表示是否是当前周的课程
  final bool isCurrentWeek;

  /// VoidCallback 是 Flutter 中定义的类型别名：typedef VoidCallback = void Function()
  /// ? 表示可空类型，即 onTap 可以是 null（用户可能不传这个参数）
  /// 用于处理卡片点击事件
  final VoidCallback? onTap;

  /// const 构造函数：表示这个 Widget 可以在编译时确定，提高性能
  /// Flutter 会缓存 const 构造的 Widget，避免重复构建
  /// 
  /// 参数说明：
  /// - super.key: 传递给父类的 key，用于 Flutter 识别和比较 Widget
  /// - required: 表示这个参数是必须的，调用时必须提供
  /// - this.course: 将参数直接赋值给同名字段（Dart 的语法糖）
  /// - this.isCurrentWeek = true: 带默认值的可选参数
  const CourseCard({
    super.key,
    required this.course,
    this.isCurrentWeek = true,
    this.onTap,
  });

  /// build 方法是 Widget 的核心
  /// @override 注解表示这是重写父类的方法
  /// BuildContext context: 包含 Widget 在 Widget 树中的位置信息，用于获取主题、尺寸等
  /// 返回值是 Widget，描述了这个组件的 UI 结构
  @override
  Widget build(BuildContext context) {
    /// Theme.of(context): 从 Widget 树中向上查找最近的 Theme
    /// 这是 Flutter 的 "InheritedWidget" 机制，用于在树中传递数据
    final theme = Theme.of(context);

    /// colorScheme 包含一组协调的颜色，用于应用的主题色
    /// 包括 primary, secondary, surface, onSurface 等颜色
    final colorScheme = theme.colorScheme;

    /// brightness 表示当前是亮色模式还是暗色模式
    final brightness = theme.brightness;

    /// 获取课程颜色值（兼容 Course 和 CourseViewModel）
    final int colorValue;
    if (course is Course) {
      colorValue = (course as Course).colorValue;
    } else if (course is CourseViewModel) {
      colorValue = (course as CourseViewModel).colorValue;
    } else {
      colorValue = 0xFF3B82F6; // 默认蓝色
    }

    /// 根据课程颜色和亮度模式获取卡片颜色方案
    final cardColors = AppTheme.getCourseCardColorScheme(colorValue, brightness);

    /// Widget 树从这里开始构建
    /// 
    /// GestureDetector: 手势检测器，可以包裹任何 Widget 并添加点击、长按等手势
    /// 这是 Flutter 的 "组合" 思想：通过嵌套 Widget 来添加功能
    return GestureDetector(
      /// onTap 是一个回调函数，当用户点击时触发
      /// 如果 onTap 为 null，则什么都不发生
      onTap: onTap,
      
      /// child: 被包裹的子 Widget
      /// Flutter 中大多数容器类 Widget 都有 child 或 children 属性
      child: Container(
        /// Container 是最常用的布局容器之一
        /// 可以设置 margin（外边距）、padding（内边距）、decoration（装饰）等
        
        /// EdgeInsets.all(1.5): 所有方向的外边距都是 1.5 逻辑像素
        /// const 表示这是一个编译时常量，避免重复创建对象
        margin: const EdgeInsets.all(1.5),
        
        /// EdgeInsets.all(8): 所有方向的内边距都是 8 逻辑像素
        padding: const EdgeInsets.all(8),
        
        /// BoxDecoration: 用于设置容器的装饰效果
        /// 包括颜色、边框、圆角、阴影、渐变等
        decoration: BoxDecoration(
          /// 三元运算符: condition ? valueIfTrue : valueIfFalse
          /// 根据是否是当前周选择不同的背景色
          color: isCurrentWeek ? cardColors.container : colorScheme.surfaceContainerHighest,
          
          /// BorderRadius.circular(8): 设置圆角，半径为 8 逻辑像素
          borderRadius: BorderRadius.circular(8),
          
          /// boxShadow: 阴影效果，是一个数组，可以添加多个阴影
          boxShadow: [
            /// TODO：1.这个阴影效果根本不明显
            /// TODO：2.增加透明度后应用效果明显，但是暗色模式下会导致阴影为黑色，无效果
            /// TODO：3.非本周是否要添加阴影？
            BoxShadow(
              /// withValues(alpha: 0.05): 设置颜色的透明度
              /// alpha 范围是 0.0（完全透明）到 1.0（完全不透明）
              color: Colors.black.withValues(alpha: 0.05),
              /// blurRadius: 阴影的模糊半径
              blurRadius: 2,
              /// offset: 阴影的偏移量，Offset(x, y)
              /// x 正值向右，y 正值向下
              offset: const Offset(0, 1),
            ),
          ],
        ),
        
        /// Column: 垂直布局容器，将子元素从上到下排列
        /// 对应的还有 Row（水平布局）和 Stack（层叠布局）
        child: Column(
          /// crossAxisAlignment: 子元素在交叉轴（水平方向）的对齐方式
          /// CrossAxisAlignment.start: 左对齐
          /// 其他选项：center（居中）、end（右对齐）、stretch（拉伸填满）
          crossAxisAlignment: CrossAxisAlignment.center,
          
          /// children: 子 Widget 列表
          /// Dart 中使用 [] 表示列表（List）
          children: [
            /// if 语句在列表中的使用
            /// 这是 Dart 的集合 if 语法，只有条件为 true 时才添加这个元素
            /// 如果 !isCurrentWeek 为 true，才会添加这个 Padding Widget
            if (!isCurrentWeek)
              /// Padding: 一个专门用于添加内边距的 Widget
              /// 等价于 Container(padding: ..., child: ...)
              Padding(
                /// EdgeInsets.only(): 可以单独设置某个方向的内边距
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  /// Text: 文本显示 Widget
                  '[非本周]',
                  /// style: 文本样式
                  /// theme.textTheme.labelSmall: 从主题中获取预定义的小标签文本样式
                  /// ?. 是空安全访问操作符，如果 textTheme.labelSmall 为 null，则整个表达式返回 null
                  /// copyWith(): 复制并修改样式，只改变指定的属性
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    /// fontWeight: 字体粗细
                    /// FontWeight.bold 等价于 FontWeight.w700
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            
            /// 课程名称文本
            Text(
              course.name,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isCurrentWeek ? cardColors.onContainer : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                /// height: 行高倍数，1.3 表示行高是字体大小的 1.3 倍
                height: 1.3,
              ),
              /// maxLines: 最大行数限制
              /// TODO: 删除最大行数限制
              maxLines: 3,
              /// overflow: 文本溢出时的处理方式
              /// TextOverflow.ellipsis: 超出部分显示省略号（...）
              overflow: TextOverflow.ellipsis,
            ),
            
            /// Spacer: 占据剩余空间的弹性空间
            /// 在 Column 中，Spacer 会尽可能占据剩余空间
            /// 这样可以让后面的内容推到底部
            const Spacer(),
            
            /// 集合 if 的另一个例子
            /// 只有当 location 不为空时才显示地点信息
            if (course.location.isNotEmpty)
              /// 调用私有方法构建信息行
              /// _ 开头表示私有方法/变量（Dart 的约定，文件级别私有）
              _buildInfoRow(
                context,
                Icons.location_on_outlined,
                /// 字符串插值: ${expression} 将表达式的值插入字符串
                '@${course.location}',
                isCurrentWeek ? cardColors.onContainer : colorScheme.onSurfaceVariant,
              ),
            
            if (course.teacher.isNotEmpty)
              _buildInfoRow(
                context,
                Icons.person_outline,
                course.teacher,
                isCurrentWeek ? cardColors.onContainer : colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }

  /// 私有方法：构建信息行（地点或教师）
  /// 
  /// 参数：
  /// - BuildContext context: 构建上下文
  /// - IconData icon: 图标数据（虽然传入了但当前未使用）
  /// - String text: 要显示的文本
  /// - Color color: 文本颜色
  Widget _buildInfoRow(BuildContext context, IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      /// Row: 水平布局容器，将子元素从左到右排列
      child: Row(
        children: [
          /// Expanded: 让子 Widget 占据剩余空间
          /// 在 Row 中，Expanded 会让子 Widget 占据水平方向的剩余空间
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color.withValues(alpha: 0.8),
                fontSize: 10,
                /// FontWeight.w500: 中等粗细（介于 normal 和 bold 之间）
                fontWeight: FontWeight.w500,
              ),
              // maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ============== Widget Preview Annotations ==============

/// 预览: CourseCard - 当前周课程卡片 (亮色)
@Preview(
  name: 'CourseCard - 当前周',
  group: 'CourseCard',
  size: Size(50, 120),
)
Widget courseCardPreview() {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(
      body: SizedBox(
        width: 50,
        height: 120,
        child: CourseCard(
          course: Course(
            id: '1',
            name: '数据结构',
            teacher: '张三',
            location: '在那遥远的地方A301',
            dayOfWeek: 1,
            startSection: 1,
            endSection: 2,
            weekRanges: [WeekRange(start: 1, end: 16)],
            colorValue: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          isCurrentWeek: true,
        ),
      ),
    ),
  );
}

/// 预览: CourseCard - 当前周课程卡片 (暗色)
@Preview(
  name: 'CourseCard - 当前周(暗色)',
  group: 'CourseCard',
  size: Size(50, 120),
  brightness: Brightness.dark,
)
Widget courseCardDarkPreview() {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    home: Scaffold(
      body: SizedBox(
        width: 50,
        height: 120,
        child: CourseCard(
          course: Course(
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
          isCurrentWeek: true,
        ),
      ),
    ),
  );
}

/// 预览: CourseCard - 非当前周课程卡片
@Preview(
  name: 'CourseCard - 非本周',
  group: 'CourseCard',
  size: Size(100, 80),
)
Widget courseCardNotCurrentWeekPreview() {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(
      body: SizedBox(
        width: 100,
        height: 80,
        child: CourseCard(
          course: Course(
            id: '2',
            name: '算法设计',
            teacher: '李四',
            location: 'B205',
            dayOfWeek: 3,
            startSection: 3,
            endSection: 4,
            weekRanges: [WeekRange(start: 1, end: 16)],
            colorValue: 1,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          isCurrentWeek: false,
        ),
      ),
    ),
  );
}

/// 预览: CourseCard - 多颜色变体 (亮色)
@Preview(
  name: 'CourseCard - 颜色变体',
  group: 'CourseCard',
  size: Size(250, 120),
)
Widget courseCardMultiColorPreview() {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(
      body: Row(
        children: List.generate(5, (index) {
          return SizedBox(
            width: 50,
            height: 120,
            child: CourseCard(
              course: Course(
                id: '$index',
                name: '课程$index',
                teacher: '教师$index',
                location: '教室$index',
                dayOfWeek: 1,
                startSection: 1,
                endSection: 2,
                weekRanges: [WeekRange(start: 1, end: 16)],
                colorValue: index,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
              isCurrentWeek: true,
            ),
          );
        }),
      ),
    ),
  );
}

/// 预览: CourseCard - 多颜色变体 (暗色)
@Preview(
  name: 'CourseCard - 颜色变体(暗色)',
  group: 'CourseCard',
  size: Size(500, 100),
  brightness: Brightness.dark,
)
Widget courseCardMultiColorDarkPreview() {
  return MaterialApp(
    theme: AppTheme.darkTheme,
    home: Scaffold(
      body: Row(
        children: List.generate(5, (index) {
          return SizedBox(
            width: 100,
            height: 80,
            child: CourseCard(
              course: Course(
                id: '$index',
                name: '课程$index',
                teacher: '教师$index',
                location: '教室$index',
                dayOfWeek: 1,
                startSection: 1,
                endSection: 2,
                weekRanges: [WeekRange(start: 1, end: 16)],
                colorValue: index,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
              isCurrentWeek: true,
            ),
          );
        }),
      ),
    ),
  );
}
