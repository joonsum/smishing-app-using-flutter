import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ThemeNotifier extends ChangeNotifier {
  final String key = "theme";
  bool _darkTheme;

  bool get darkTheme => _darkTheme;

  ThemeNotifier() : _darkTheme = false {
    _darkTheme = false;
  }

  toggleTheme() {
    _darkTheme = !_darkTheme;
    notifyListeners();
  }
}