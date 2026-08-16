import 'package:flutter/material.dart';

/// Semantic colors for the ChatGPT-like light UI.
/// Hex values belong only in this file.
abstract final class AppColor {
  // Surface
  static const Color canvas = Color(0xFFFFFFFF);
  static const Color sidebar = Color(0xFFFFFFFF);
  static const Color composerFill = Color(0xFFF4F4F4);
  static const Color overlayScrim = Color(0x66000000);

  // Text
  static const Color textHigh = Color(0xFF0D0D0D);
  static const Color textMedium = Color(0xFF5D5D5D);
  static const Color textPlaceholder = Color(0xFF8E8E8E);
  static const Color textOnAccent = Color(0xFFFFFFFF);

  // Icon
  static const Color iconDefault = Color(0xFF0D0D0D);
  static const Color iconMuted = Color(0xFF8E8E8E);
  static const Color iconOnAccent = Color(0xFFFFFFFF);

  // Accent
  static const Color accentVoice = Color(0xFF0F66FE);
  static const Color accentUpgrade = Color(0xFFAB68FF);

  // Message
  static const Color userBubble = Color(0xFFF4F4F4);
  static const Color assistantBubble = Color(0xFFFFFFFF);

  // Border
  static const Color border = Color(0xFFE5E5E5);
  static const Color divider = Color(0xFFEDEDED);
}
