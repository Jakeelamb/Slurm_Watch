import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/storage_service.dart';

class AuthProvider with ChangeNotifier {
  String? _sessionId;
  String? _username;
  String? _hostname;
  bool _testMode = false;
  
  final StorageService _storage = SharedPrefsStorage();
  final String _baseUrl = 'http://localhost:8080'; // Change in production
  
  bool get isAuth => _sessionId != null;
  String? get sessionId => _sessionId;
  String? get username => _username;
  String? get hostname => _hostname;
  bool get testMode => _testMode;
  
  Future<bool> login(String hostname, String username, String password, bool saveCredentials, {bool forceTestMode = false}) async {
    try {
      _testMode = forceTestMode;
      
      final requestBody = {
        'hostname': hostname,
        'username': username,
        'password': password,
        'save_credentials': saveCredentials,
        'test_mode': _testMode,
      };
      
      print('Attempting login to $_baseUrl/login with test_mode: $_testMode');
      print('Request body: ${json.encode(requestBody)}');
      
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 15)); // Increase timeout for SSH connections
      
      print('Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _sessionId = responseData['session_id'];
        _username = responseData['username'];
        _hostname = responseData['hostname'];
        
        if (saveCredentials) {
          await _saveAuthData(hostname, username, password);
        }
        
        notifyListeners();
        return true;
      } else {
        final errorData = json.decode(response.body);
        print('Login error: ${errorData['detail']}');
        return false;
      }
    } catch (error) {
      print('Login exception: $error');
      rethrow;
    }
  }
  
  Future<bool> tryAutoLogin() async {
    try {
      final savedCredentials = await _getSavedCredentials();
      
      if (savedCredentials != null) {
        final success = await login(
          savedCredentials['hostname']!,
          savedCredentials['username']!,
          savedCredentials['password']!,
          true,
        );
        return success;
      }
      
      return false;
    } catch (error) {
      return false;
    }
  }
  
  Future<void> logout() async {
    if (_sessionId != null) {
      try {
        await http.post(
          Uri.parse('$_baseUrl/logout'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({'session_id': _sessionId}),
        );
      } catch (e) {
        // Handle error
      }
    }
    
    _sessionId = null;
    _username = null;
    _hostname = null;
    notifyListeners();
  }
  
  Future<void> _saveAuthData(String hostname, String username, String password) async {
    await _storage.write(key: 'hostname', value: hostname);
    await _storage.write(key: 'username', value: username);
    await _storage.write(key: 'password', value: password);
  }
  
  Future<Map<String, String>?> _getSavedCredentials() async {
    final hostname = await _storage.read(key: 'hostname');
    final username = await _storage.read(key: 'username');
    final password = await _storage.read(key: 'password');
    
    if (hostname != null && username != null && password != null) {
      return {
        'hostname': hostname,
        'username': username,
        'password': password,
      };
    }
    
    return null;
  }
  
  Future<void> clearSavedCredentials() async {
    await _storage.deleteAll();
  }

  void setTestSession(String sessionId, String username, String hostname) {
    _sessionId = sessionId;
    _username = username;
    _hostname = hostname;
    _testMode = true;
    notifyListeners();
  }
} 