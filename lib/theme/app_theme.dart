import 'package:flutter/material.dart';

/// 应用主题管理器
/// 使用 Material 3 种子颜色自动生成主题，支持亮色/暗色模式
class AppTheme {
  // ==================== 主题种子颜色 ====================

  /// 默认主题种子颜色 (蓝色)
  static const Color defaultSeedColor = Color(0xFF0061A4);

  // ==================== 主题构建 ====================

  /// 亮色主题 - 使用种子颜色自动生成
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _generateColorScheme(
        seedColor: defaultSeedColor,
        brightness: Brightness.light,
      ),
    );
  }

  /// 暗色主题 - 使用种子颜色自动生成
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _generateColorScheme(
        seedColor: defaultSeedColor,
        brightness: Brightness.dark,
      ),
    );
  }

  /// 生成 ColorScheme (兼容旧版本 Flutter)
  static ColorScheme _generateColorScheme({
    required Color seedColor,
    required Brightness brightness,
  }) {
    final isLight = brightness == Brightness.light;

    // 从种子颜色提取 HSL
    final hsl = HSLColor.fromColor(seedColor);

    // 计算主色
    final primary = seedColor;
    final onPrimary = isLight ? Colors.white : Colors.black;
    final primaryContainer = hsl.withLightness(isLight ? 0.9 : 0.3).toColor();
    final onPrimaryContainer = isLight ? Colors.black : Colors.white;

    // 计算次色
    final secondaryHue = (hsl.hue + 60) % 360;
    final secondary = HSLColor.fromAHSL(1, secondaryHue, hsl.saturation, isLight ? 0.5 : 0.6).toColor();
    final onSecondary = isLight ? Colors.white : Colors.black;
    final secondaryContainer = HSLColor.fromAHSL(1, secondaryHue, hsl.saturation, isLight ? 0.9 : 0.3).toColor();
    final onSecondaryContainer = isLight ? Colors.black : Colors.white;

    // 计算 tertiary
    final tertiaryHue = (hsl.hue + 120) % 360;
    final tertiary = HSLColor.fromAHSL(1, tertiaryHue, hsl.saturation, isLight ? 0.5 : 0.6).toColor();
    final onTertiary = isLight ? Colors.white : Colors.black;
    final tertiaryContainer = HSLColor.fromAHSL(1, tertiaryHue, hsl.saturation, isLight ? 0.9 : 0.3).toColor();
    final onTertiaryContainer = isLight ? Colors.black : Colors.white;

    // 错误色
    final error = isLight ? const Color(0xFFBA1A1A) : const Color(0xFFFFB4AB);
    final onError = isLight ? Colors.white : Colors.black;
    final errorContainer = isLight ? const Color(0xFFFFDAD6) : const Color(0xFF93000A);
    final onErrorContainer = isLight ? const Color(0xFF410002) : const Color(0xFFFFDAD6);

    // 表面色
    final surface = isLight ? const Color(0xFFFDFCFF) : const Color(0xFF1A1C1E);
    final onSurface = isLight ? const Color(0xFF1A1C1E) : const Color(0xFFE2E2E6);
    final surfaceContainerLow = isLight ? const Color(0xFFF6F8FC) : const Color(0xFF1A1C1E);
    final surfaceContainer = isLight ? const Color(0xFFF0F4F9) : const Color(0xFF212427);
    final surfaceContainerHighest = isLight ? const Color(0xFFDFE2EB) : const Color(0xFF2F3133);
    final onSurfaceVariant = isLight ? const Color(0xFF43474E) : const Color(0xFFC3C7CF);
    final outline = isLight ? const Color(0xFF73777F) : const Color(0xFF8D9199);
    final outlineVariant = isLight ? const Color(0xFFC3C7CF) : const Color(0xFF43474E);

    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainer: surfaceContainer,
      surfaceContainerHighest: surfaceContainerHighest,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
    );
  }

  // ==================== 课程卡片颜色生成 ====================

  /// 生成课程卡片颜色
  /// 通过调整种子颜色的色相来生成多种颜色
  /// 自动适配当前亮度模式
  static ({Color container, Color onContainer}) getCourseCardColorScheme(
    int colorIndex,
    Brightness brightness,
  ) {
    final baseHue = _getBaseHue(colorIndex);
    final saturation = _getSaturation(colorIndex);
    final isLight = brightness == Brightness.light;

    // 亮色模式用浅色，暗色模式用深色
    final containerLightness = isLight ? 0.92 : 0.25;
    final onContainerLightness = isLight ? 0.15 : 0.85;

    final containerColor = HSLColor.fromAHSL(1.0, baseHue, saturation, containerLightness).toColor();
    final onContainerColor = HSLColor.fromAHSL(1.0, baseHue, saturation * 0.6, onContainerLightness).toColor();

    return (container: containerColor, onContainer: onContainerColor);
  }

  /// 获取基础色相 (0-360)
  static double _getBaseHue(int index) {
    // 使用黄金角度分布，使颜色更均匀分布
    const goldenAngle = 137.508;
    return (index * goldenAngle) % 360;
  }

  /// 获取饱和度
  static double _getSaturation(int index) {
    // 在 0.5-0.7 之间变化
    return 0.5 + (index % 3) * 0.1;
  }

  /// 获取课程卡片的基础颜色（用于预览）
  static const List<Color> courseCardPreviewColors = [
    Color(0xFFFFD8E4), // 粉色
    Color(0xFFD1E4FF), // 蓝色
    Color(0xFFE8DEF8), // 紫色
    Color(0xFFBCECE0), // 绿色
    Color(0xFFE0E0FF), // 靛蓝
  ];
}
