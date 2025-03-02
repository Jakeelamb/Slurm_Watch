import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/storage_service.dart';

class AppearanceProvider with ChangeNotifier {
  final StorageService _storage = SharedPrefsStorage();
  
  // Default values
  double _backgroundOpacity = 0.6;
  String _backgroundStyle = 'gradient';  // 'gradient', 'solid', 'pattern'
  bool _useDarkMode = false;
  
  // Getters
  double get backgroundOpacity => _backgroundOpacity;
  String get backgroundStyle => _backgroundStyle;
  bool get useDarkMode => _useDarkMode;
  ThemeMode get themeMode => _useDarkMode ? ThemeMode.dark : ThemeMode.system;
  
  // Constructor - load saved preferences
  AppearanceProvider() {
    _loadPreferences();
  }
  
  Future<void> _loadPreferences() async {
    try {
      final opacity = await _storage.read(key: 'backgroundOpacity');
      if (opacity != null) {
        _backgroundOpacity = double.parse(opacity);
      }
      
      final style = await _storage.read(key: 'backgroundStyle');
      if (style != null) {
        _backgroundStyle = style;
      }
      
      final darkMode = await _storage.read(key: 'useDarkMode');
      if (darkMode != null) {
        _useDarkMode = darkMode.toLowerCase() == 'true';
      }
      
      notifyListeners();
    } catch (e) {
      // Handle error loading preferences
      print('Error loading appearance preferences: $e');
    }
  }
  
  // Methods to update appearance
  Future<void> setBackgroundOpacity(double opacity) async {
    _backgroundOpacity = opacity;
    await _storage.write(key: 'backgroundOpacity', value: opacity.toString());
    notifyListeners();
  }
  
  Future<void> setBackgroundStyle(String style) async {
    _backgroundStyle = style;
    await _storage.write(key: 'backgroundStyle', value: style);
    notifyListeners();
  }
  
  Future<void> setUseDarkMode(bool useDark) async {
    _useDarkMode = useDark;
    await _storage.write(key: 'useDarkMode', value: useDark.toString());
    notifyListeners();
  }
  
  // Reset to defaults
  Future<void> resetToDefaults() async {
    _backgroundOpacity = 0.6;
    _backgroundStyle = 'gradient';
    _useDarkMode = false;
    
    await _storage.write(key: 'backgroundOpacity', value: '0.6');
    await _storage.write(key: 'backgroundStyle', value: 'gradient');
    await _storage.write(key: 'useDarkMode', value: 'false');
    
    notifyListeners();
  }
} 