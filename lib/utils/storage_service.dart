import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Abstract class that all implementations must implement
abstract class StorageService {
  Future<void> write({required String key, required String value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
  Future<void> deleteAll();
}

// Simple in-memory implementation that works everywhere
class InMemoryStorageService implements StorageService {
  final Map<String, String> _mockStorage = {};

  @override
  Future<void> write({required String key, required String value}) async {
    _mockStorage[key] = value;
  }

  @override
  Future<String?> read({required String key}) async {
    return _mockStorage[key];
  }

  @override
  Future<void> delete({required String key}) async {
    _mockStorage.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _mockStorage.clear();
  }
}

class SharedPrefsStorage implements StorageService {
  SharedPreferences? _prefs;
  
  // Initialize the preferences
  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  Future<void> write({required String key, required String value}) async {
    final p = await prefs;
    await p.setString(key, value);
  }

  @override
  Future<String?> read({required String key}) async {
    final p = await prefs;
    return p.getString(key);
  }

  @override
  Future<void> delete({required String key}) async {
    final p = await prefs;
    await p.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    final p = await prefs;
    await p.clear();
  }
} 