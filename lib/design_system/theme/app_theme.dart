import 'package:flutter/material.dart';
import 'package:vncoughalert/design_system/tokens/app_color.dart';
import 'package:vncoughalert/design_system/tokens/app_text_style.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.light(
      primary: AppColor.accentVoice,
      onPrimary: AppColor.textOnAccent,
      surface: AppColor.canvas,
      onSurface: AppColor.textHigh,
      outline: AppColor.border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColor.canvas,
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.standard,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColor.textHigh,
        contentTextStyle: AppTextStyle.body(color: AppColor.textOnAccent),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: AppTextStyle.body(color: AppColor.textPlaceholder),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColor.canvas,
        foregroundColor: AppColor.textHigh,
      ),
      dividerColor: AppColor.divider,
      textTheme: TextTheme(
        titleMedium: AppTextStyle.titleMd(),
        bodyMedium: AppTextStyle.body(),
        labelMedium: AppTextStyle.label(),
      ),
    );
  }

  /// Dark skeleton — not wired in the app yet.
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(primary: AppColor.accentVoice),
  );
}
