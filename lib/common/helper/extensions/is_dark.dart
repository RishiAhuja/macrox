import 'package:flutter/material.dart';

extension DarkModeX on BuildContext {
  bool get isDark {
    return Theme.of(this).brightness == Brightness.dark;
  }
}
