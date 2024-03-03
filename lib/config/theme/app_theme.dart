import 'package:flutter/material.dart';

/// A class that provides the application's theme.
class AppTheme {
  /// Retrieves the theme for the application.
  ///
  /// Returns a ThemeData object configured for use Material 3
  /// and a color scheme based on red color.
  ThemeData getTheme() => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.red,
      );
}