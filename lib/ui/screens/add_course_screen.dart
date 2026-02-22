import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _courseNameController = TextEditingController();
  final _scrollController = ScrollController();
  int _selectedColorIndex = 0;
  final List<_TimeSlot> _timeSlots = [_TimeSlot()];

  // 预定义颜色 (使用 MD3 颜色系统)
  // 这些颜色会在 light/dark 模式下自动适配
  static const List<Color> _colors = [
    Color(0xFFFFD8E4), // 粉色
    Color(0xFFD1E4FF), // 蓝色
    Color(0xFFE8DEF8), // 紫色
    Color(0xFFBCECE0), // 绿色
    Color(0xFFE0E0FF), // 靛蓝
    Color(0xFFFFF9C4), // 黄色
  ];

  // 星期选项
  static const List<String> _weekDays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  // 节次选项
  static const List<String> _sections = ['1-2节', '3-4节', '5-6节', '7-8节', '9-10节', '11-12节'];

  void _addTimeSlot() {
    setState(() {
      _timeSlots.add(_TimeSlot());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _removeTimeSlot(int index) {
    if (_timeSlots.length > 1) {
      setState(() {
        _timeSlots.removeAt(index);
      });
    }
  }

  void _showWeekDayPicker(_TimeSlot slot) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _buildPickerSheet(
          title: '选择星期',
          items: _weekDays,
          selectedIndex: slot.selectedDayIndex,
          onSelected: (index) {
            setState(() {
              slot.selectedDayIndex = index;
            });
          },
        );
      },
    );
  }

  void _showSectionPicker(_TimeSlot slot) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _buildPickerSheet(
          title: '选择节次',
          items: _sections,
          selectedIndex: slot.startSection,
          onSelected: (index) {
            setState(() {
              slot.startSection = index;
            });
          },
        );
      },
    );
  }

  Widget _buildPickerSheet({
    required String title,
    required List<String> items,
    required int selectedIndex,
    required ValueChanged<int> onSelected,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final outlineVariant = colorScheme.outlineVariant;

    return SizedBox(
      height: 300,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: CupertinoPicker(
              itemExtent: 48,
              scrollController: FixedExtentScrollController(initialItem: selectedIndex),
              onSelectedItemChanged: onSelected,
              selectionOverlay: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: outlineVariant.withValues(alpha: 0.3)),
                    bottom: BorderSide(color: outlineVariant.withValues(alpha: 0.3)),
                  ),
                ),
              ),
              children: items.map((item) {
                return Center(
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 20),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _scrollController.dispose();
    for (var slot in _timeSlots) {
      slot.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        title: Text(
          '添加课程',
          style: theme.textTheme.titleLarge,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.check, size: 20),
              label: const Text('保存'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCourseInfoCard(theme, colorScheme),
            const SizedBox(height: 24),
            Text(
              '时间段',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            ..._timeSlots.asMap().entries.map((entry) {
              final index = entry.key;
              final slot = entry.value;
              return _buildTimeSlotCard(theme, colorScheme, slot, index);
            }),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTimeSlot,
        backgroundColor: colorScheme.primaryContainer,
        foregroundColor: colorScheme.onPrimaryContainer,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: const Text('添加时间段'),
      ),
    );
  }

  Widget _buildCourseInfoCard(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIconTextField(
              controller: _courseNameController,
              label: '课程名称',
              icon: Icons.school_outlined,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 20),
            Text(
              '课程颜色',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                ..._colors.asMap().entries.map((entry) {
                  final index = entry.key;
                  final color = entry.value;
                  final isSelected = _selectedColorIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColorIndex = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: colorScheme.primary, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              color: _getCheckIconColor(color),
                              size: 20,
                            )
                          : null,
                    ),
                  );
                }),
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.error.withValues(alpha: 0.3),
                          colorScheme.tertiary.withValues(alpha: 0.3),
                          colorScheme.primary.withValues(alpha: 0.3),
                        ],
                      ),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Icon(
                      Icons.colorize,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCheckIconColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  Widget _buildIconTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ColorScheme colorScheme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: colorScheme.primary.withValues(alpha: 0.8)),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlotCard(ThemeData theme, ColorScheme colorScheme, _TimeSlot slot, int index) {
    final slotColors = _getSlotColors(colorScheme, index);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: slotColors.container,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: slotColors.onContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '上课时间',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (_timeSlots.length > 1)
                    IconButton(
                      onPressed: () => _removeTimeSlot(index),
                      icon: const Icon(Icons.delete_outline),
                      color: colorScheme.onSurfaceVariant,
                      style: IconButton.styleFrom(
                        hoverColor: colorScheme.errorContainer,
                        foregroundColor: colorScheme.error,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPickerButton(
                    context,
                    _weekDays[slot.selectedDayIndex],
                    () => _showWeekDayPicker(slot),
                    colorScheme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPickerButton(
                    context,
                    _sections[slot.startSection],
                    () => _showSectionPicker(slot),
                    colorScheme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildIconInput(
              controller: slot.teacherController,
              label: '任课教师',
              icon: Icons.person_outline,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 12),
            _buildIconInput(
              controller: slot.locationController,
              label: '上课教室',
              icon: Icons.location_on_outlined,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 12),
            _buildIconInput(
              controller: slot.weeksController,
              label: '上课周数',
              icon: Icons.date_range_outlined,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 12),
            _buildIconInput(
              controller: slot.remarkController,
              label: '备注信息',
              icon: Icons.description_outlined,
              colorScheme: colorScheme,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  ({Color container, Color onContainer}) _getSlotColors(ColorScheme colorScheme, int index) {
    final colors = [
      (container: colorScheme.primaryContainer, onContainer: colorScheme.onPrimaryContainer),
      (container: colorScheme.secondaryContainer, onContainer: colorScheme.onSecondaryContainer),
      (container: colorScheme.tertiaryContainer, onContainer: colorScheme.onTertiaryContainer),
    ];
    return colors[index % colors.length];
  }

  Widget _buildPickerButton(BuildContext context, String value, VoidCallback onTap, ColorScheme colorScheme) {
    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ColorScheme colorScheme,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: colorScheme.primary.withValues(alpha: 0.8)),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary, width: 1),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: maxLines > 1 ? 12 : 0),
        ),
      ),
    );
  }
}

class _TimeSlot {
  int selectedDayIndex = 0;
  int startSection = 0;
  final teacherController = TextEditingController();
  final locationController = TextEditingController();
  final weeksController = TextEditingController(text: '1-16周');
  final remarkController = TextEditingController();

  void dispose() {
    teacherController.dispose();
    locationController.dispose();
    weeksController.dispose();
    remarkController.dispose();
  }
}

// ============== Widget Preview Annotations ==============

/// 预览: AddCourseScreen - 添加课程页面 (亮色模式)
@Preview(
  name: 'AddCourseScreen - 添加课程',
  group: 'AddCourseScreen',
  size: Size(390, 844),
)
Widget addCourseScreenPreview() {
  return MaterialApp(
    theme: ThemeData.light(useMaterial3: true),
    home: const AddCourseScreen(),
  );
}

/// 预览: AddCourseScreen - 暗色模式
@Preview(
  name: 'AddCourseScreen - 暗色模式',
  group: 'AddCourseScreen',
  size: Size(390, 844),
  brightness: Brightness.dark,
)
Widget addCourseScreenDarkPreview() {
  return MaterialApp(
    theme: ThemeData.dark(useMaterial3: true),
    home: const AddCourseScreen(),
  );
}
