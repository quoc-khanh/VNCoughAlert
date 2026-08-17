import 'package:flutter/material.dart';

/// Semantic colors for the ChatGPT-like light UI.
/// Hex values belong only in this file.
abstract final class AppColor {
  // Surface
  static const Color canvas = Color(0xFFFFFFFF);
  static const Color sidebar = Color(0xFFF7F8FC);
  static const Color composerFill = Color(0xFFF4F6FA);
  static const Color surfaceSoft = Color(0xFFF8FAFD);
  static const Color accentSoft = Color(0xFFEAF2FF);
  static const Color accentTint = Color(0xFFF4F8FF);
  static const Color overlayScrim = Color(0x66000000);

  // Text
  static const Color textHigh = Color(0xFF0D0D0D);
  static const Color textMedium = Color(0xFF596275);
  static const Color textPlaceholder = Color(0xFF8993A5);
  static const Color textOnAccent = Color(0xFFFFFFFF);

  // Icon
  static const Color iconDefault = Color(0xFF0D0D0D);
  static const Color iconMuted = Color(0xFF8993A5);
  static const Color iconOnAccent = Color(0xFFFFFFFF);

  // Accent
  static const Color accentVoice = Color(0xFF2367E8);
  static const Color accentVoicePressed = Color(0xFF1551C7);
  static const Color accentUpgrade = Color(0xFFAB68FF);
  static const Color accentSuccess = Color(0xFF19A77A);

  // Message
  static const Color userBubble = Color(0xFF2367E8);
  static const Color assistantBubble = Color(0xFFF7F9FC);

  // Border
  static const Color border = Color(0xFFE4E8F0);
  static const Color divider = Color(0xFFEBEEF4);
}
