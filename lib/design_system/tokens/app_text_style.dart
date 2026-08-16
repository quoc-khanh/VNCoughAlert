import 'package:flutter/material.dart';
import 'package:vncoughalert/design_system/tokens/app_color.dart';

abstract final class AppTextStyle {
  static TextStyle titleMd({Color? color}) {
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: color ?? AppColor.textHigh,
    );
  }

  static TextStyle titleSm({Color? color}) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: color ?? AppColor.textHigh,
    );
  }

  static TextStyle body({Color? color}) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: color ?? AppColor.textHigh,
    );
  }

  static TextStyle label({Color? color}) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.3,
      color: color ?? AppColor.textHigh,
    );
  }

  static TextStyle caption({Color? color}) {
    return TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      height: 1.3,
      color: color ?? AppColor.textMedium,
    );
  }
}
