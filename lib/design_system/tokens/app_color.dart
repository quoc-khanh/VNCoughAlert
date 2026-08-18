import 'package:flutter/material.dart';

/// Semantic colors for the VN Cough Alert visual language.
/// Hex values belong only in this file.
abstract final class AppColor {
  // Surface
  static const Color canvas = Color(0xFFF7FAFC);
  static const Color sidebar = Color(0xFFF1F8F8);
  static const Color composerFill = Color(0xFFF0F4F7);
  static const Color surfaceSoft = Color(0xFFF4FAFA);
  static const Color accentSoft = Color(0xFFDDF7F5);
  static const Color accentTint = Color(0xFFEEFCFB);
  static const Color headerTeal = Color(0xFF08A8B6);
  static const Color headerTealDark = Color(0xFF078E9D);
  static const Color overlayScrim = Color(0x66000000);

  // Text
  static const Color textHigh = Color(0xFF20313F);
  static const Color textMedium = Color(0xFF647789);
  static const Color textPlaceholder = Color(0xFF91A1AF);
  static const Color textOnAccent = Color(0xFFFFFFFF);

  // Icon
  static const Color iconDefault = Color(0xFF385363);
  static const Color iconMuted = Color(0xFF91A1AF);
  static const Color iconOnAccent = Color(0xFFFFFFFF);

  // Accent
  static const Color accentVoice = Color(0xFF08B6B0);
  static const Color accentVoicePressed = Color(0xFF078E91);
  static const Color accentUpgrade = Color(0xFF8B54F6);
  static const Color accentSuccess = Color(0xFF10A99D);
  static const Color accentPurple = Color(0xFF8B54F6);
  static const Color warning = Color(0xFFF4B63F);
  static const Color warningSoft = Color(0xFFFFF2D2);

  // Message
  static const Color userBubble = Color(0xFF8B54F6);
  static const Color assistantBubble = Color(0xFFFFFFFF);

  // Border
  static const Color border = Color(0xFFB9ECE8);
  static const Color divider = Color(0xFFE0ECEE);
}
