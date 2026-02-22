import 'package:flutter/material.dart';
import '../../models/course.dart';
import '../../theme/app_theme.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final bool isCurrentWeek;
  final VoidCallback? onTap;

  const CourseCard({
    super.key,
    required this.course,
    this.isCurrentWeek = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = _getCardColorScheme(course.colorValue);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(1.5),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isCurrentWeek ? colorScheme.container : AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isCurrentWeek)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '[非本周]',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.onSurfaceVariant.withValues(alpha: 0.7),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            Text(
              course.name,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isCurrentWeek ? colorScheme.onContainer : AppTheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            if (course.location.isNotEmpty)
              _buildInfoRow(
                context,
                Icons.location_on_outlined,
                '@${course.location}',
                isCurrentWeek ? colorScheme.onContainer : AppTheme.onSurfaceVariant,
              ),
            if (course.teacher.isNotEmpty)
              _buildInfoRow(
                context,
                Icons.person_outline,
                course.teacher,
                isCurrentWeek ? colorScheme.onContainer : AppTheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          // Icon(icon, size: 10, color: color.withOpacity(0.8)),
          // const SizedBox(width: 2),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color.withValues(alpha: 0.8),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  ({Color container, Color onContainer}) _getCardColorScheme(int colorValue) {
    // Map colorValue to theme colors
    // This is a simple mapping, you can expand this logic
    // For now, we cycle through the defined card colors based on the value
    const colors = [
      (container: AppTheme.cardBlueContainer, onContainer: AppTheme.cardBlueOnContainer),
      (container: AppTheme.cardPinkContainer, onContainer: AppTheme.cardPinkOnContainer),
      (container: AppTheme.cardPurpleContainer, onContainer: AppTheme.cardPurpleOnContainer),
      (container: AppTheme.cardGreenContainer, onContainer: AppTheme.cardGreenOnContainer),
      (container: AppTheme.cardIndigoContainer, onContainer: AppTheme.cardIndigoOnContainer),
    ];

    return colors[colorValue % colors.length];
  }
}
