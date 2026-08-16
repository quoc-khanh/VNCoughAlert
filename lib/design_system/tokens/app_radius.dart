import 'package:flutter/material.dart';

abstract final class AppRadius {
  static const double bubble = 18;
  static const double control = 12;
  static const double pill = 999;

  /// iOS-style continuous corner for sheets, cards, and bubbles.
  static RoundedSuperellipseBorder superellipse(double radius) {
    return RoundedSuperellipseBorder(
      borderRadius: BorderRadius.circular(radius),
    );
  }
}
