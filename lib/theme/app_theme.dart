import 'package:flutter/material.dart';

/// 应用主题管理器
/// 集中管理所有主题颜色，支持亮色/暗色模式
class AppTheme {
  // ==================== 课程卡片颜色 ====================
  // 这些是固定的品牌色，用于课程卡片，不随主题变化
  static const List<Color> courseCardColors = [
    Color(0xFFFFD8E4), // 粉色
    Color(0xFFD1E4FF), // 蓝色
    Color(0xFFE8DEF8), // 紫色
    Color(0xFFBCECE0), // 绿色
    Color(0xFFE0E0FF), // 靛蓝
  ];

  static const List<Color> courseCardOnColors = [
    Color(0xFF31111D), // 粉色文字
    Color(0xFF001D36), // 蓝色文字
    Color(0xFF1D192B), // 紫色文字
    Color(0xFF00201A), // 绿色文字
    Color(0xFF00006E), // 靛蓝文字
  ];

  /// 获取课程卡片的颜色配置
  static ({Color container, Color onContainer}) getCourseCardColorScheme(int colorIndex) {
    final index = colorIndex % courseCardColors.length;
    return (
      container: courseCardColors[index],
      onContainer: courseCardOnColors[index],
    );
  }

  // ==================== MD3 主题构建 ====================

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _lightColorScheme,
      fontFamily: 'Roboto',
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _darkColorScheme,
      fontFamily: 'Roboto',
    );
  }

  // ==================== 亮色主题颜色 ====================

  static const Color _lightPrimary = Color(0xFF0061A4);
  static const Color _lightOnPrimary = Color(0xFFFFFFFF);
  static const Color _lightPrimaryContainer = Color(0xFFD1E4FF);
  static const Color _lightOnPrimaryContainer = Color(0xFF001D36);

  static const Color _lightSecondary = Color(0xFF535F70);
  static const Color _lightOnSecondary = Color(0xFFFFFFFF);
  static const Color _lightSecondaryContainer = Color(0xFFD7E3F7);
  static const Color _lightOnSecondaryContainer = Color(0xFF101C2B);

  static const Color _lightTertiary = Color(0xFF6B5778);
  static const Color _lightOnTertiary = Color(0xFFFFFFFF);
  static const Color _lightTertiaryContainer = Color(0xFFF2DAFF);
  static const Color _lightOnTertiaryContainer = Color(0xFF251431);

  static const Color _lightError = Color(0xFFBA1A1A);
  static const Color _lightOnError = Color(0xFFFFFFFF);
  static const Color _lightErrorContainer = Color(0xFFFFDAD6);
  static const Color _lightOnErrorContainer = Color(0xFF410002);

  static const Color _lightSurface = Color(0xFFFDFCFF);
  static const Color _lightSurfaceContainerLow = Color(0xFFF6F8FC);
  static const Color _lightSurfaceContainer = Color(0xFFF0F4F9);
  static const Color _lightSurfaceContainerHighest = Color(0xFFDFE2EB);
  static const Color _lightOnSurface = Color(0xFF1A1C1E);
  static const Color _lightOnSurfaceVariant = Color(0xFF43474E);
  static const Color _lightOutline = Color(0xFF73777F);
  static const Color _lightOutlineVariant = Color(0xFFC3C7CF);

  static final ColorScheme _lightColorScheme = const ColorScheme(
    brightness: Brightness.light,
    primary: _lightPrimary,
    onPrimary: _lightOnPrimary,
    primaryContainer: _lightPrimaryContainer,
    onPrimaryContainer: _lightOnPrimaryContainer,
    secondary: _lightSecondary,
    onSecondary: _lightOnSecondary,
    secondaryContainer: _lightSecondaryContainer,
    onSecondaryContainer: _lightOnSecondaryContainer,
    tertiary: _lightTertiary,
    onTertiary: _lightOnTertiary,
    tertiaryContainer: _lightTertiaryContainer,
    onTertiaryContainer: _lightOnTertiaryContainer,
    error: _lightError,
    onError: _lightOnError,
    errorContainer: _lightErrorContainer,
    onErrorContainer: _lightOnErrorContainer,
    surface: _lightSurface,
    onSurface: _lightOnSurface,
    surfaceContainerLow: _lightSurfaceContainerLow,
    surfaceContainer: _lightSurfaceContainer,
    surfaceContainerHighest: _lightSurfaceContainerHighest,
    onSurfaceVariant: _lightOnSurfaceVariant,
    outline: _lightOutline,
    outlineVariant: _lightOutlineVariant,
  );

  // ==================== 暗色主题颜色 ====================

  static const Color _darkPrimary = Color(0xFF9ECAFF);
  static const Color _darkOnPrimary = Color(0xFF003258);
  static const Color _darkPrimaryContainer = Color(0xFF00497D);
  static const Color _darkOnPrimaryContainer = Color(0xFFD1E4FF);

  static const Color _darkSecondary = Color(0xFFBBC7DB);
  static const Color _darkOnSecondary = Color(0xFF253140);
  static const Color _darkSecondaryContainer = Color(0xFF3B4858);
  static const Color _darkOnSecondaryContainer = Color(0xFFD7E3F7);

  static const Color _darkTertiary = Color(0xFFD6BEE4);
  static const Color _darkOnTertiary = Color(0xFF3B2948);
  static const Color _darkTertiaryContainer = Color(0xFF523F5F);
  static const Color _darkOnTertiaryContainer = Color(0xFFF2DAFF);

  static const Color _darkError = Color(0xFFFFB4AB);
  static const Color _darkOnError = Color(0xFF690005);
  static const Color _darkErrorContainer = Color(0xFF93000A);
  static const Color _darkOnErrorContainer = Color(0xFFFFDAD6);

  static const Color _darkSurface = Color(0xFF1A1C1E);
  static const Color _darkSurfaceContainerLow = Color(0xFF1A1C1E);
  static const Color _darkSurfaceContainer = Color(0xFF212427);
  static const Color _darkSurfaceContainerHighest = Color(0xFF2F3133);
  static const Color _darkOnSurface = Color(0xFFE2E2E6);
  static const Color _darkOnSurfaceVariant = Color(0xFFC3C7CF);
  static const Color _darkOutline = Color(0xFF8D9199);
  static const Color _darkOutlineVariant = Color(0xFF43474E);

  static final ColorScheme _darkColorScheme = const ColorScheme(
    brightness: Brightness.dark,
    primary: _darkPrimary,
    onPrimary: _darkOnPrimary,
    primaryContainer: _darkPrimaryContainer,
    onPrimaryContainer: _darkOnPrimaryContainer,
    secondary: _darkSecondary,
    onSecondary: _darkOnSecondary,
    secondaryContainer: _darkSecondaryContainer,
    onSecondaryContainer: _darkOnSecondaryContainer,
    tertiary: _darkTertiary,
    onTertiary: _darkOnTertiary,
    tertiaryContainer: _darkTertiaryContainer,
    onTertiaryContainer: _darkOnTertiaryContainer,
    error: _darkError,
    onError: _darkOnError,
    errorContainer: _darkErrorContainer,
    onErrorContainer: _darkOnErrorContainer,
    surface: _darkSurface,
    onSurface: _darkOnSurface,
    surfaceContainerLow: _darkSurfaceContainerLow,
    surfaceContainer: _darkSurfaceContainer,
    surfaceContainerHighest: _darkSurfaceContainerHighest,
    onSurfaceVariant: _darkOnSurfaceVariant,
    outline: _darkOutline,
    outlineVariant: _darkOutlineVariant,
  );
}
