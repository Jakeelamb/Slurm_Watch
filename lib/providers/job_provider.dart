import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/job.dart';

class JobProvider with ChangeNotifier {
  List<Job> _jobs = [];
  String? _sessionId;
  DateTime? _lastUpdated;
  bool _isLoading = false;
  bool _autoRefresh = false;
  int _refreshInterval = 30; // seconds
  Timer? _refreshTimer;
  bool _testMode = false;
  String _currentTimeRange = "24h";
  
  final String _baseUrl = 'http://localhost:8080'; // Change in production
  
  JobProvider(this._sessionId, {bool testMode = false}) {
    _testMode = testMode;
    if (_sessionId != null) {
      fetchJobs();
      _startAutoRefresh();
    }
  }
  
  // Allow transferring state when auth changes
  void updatePrevious(JobProvider? previous) {
    if (previous != null) {
      _autoRefresh = previous._autoRefresh;
      _refreshInterval = previous._refreshInterval;
      _testMode = previous._testMode;
      _currentTimeRange = previous._currentTimeRange;
    }
  }
  
  List<Job> get jobs => [..._jobs];
  bool get isLoading => _isLoading;
  DateTime? get lastUpdated => _lastUpdated;
  bool get autoRefresh => _autoRefresh;
  int get refreshInterval => _refreshInterval;
  bool get testMode => _testMode;
  String get currentTimeRange => _currentTimeRange;
  
  // Job status counts
  int get runningCount => _jobs.where((job) => job.status == 'RUNNING').length;
  int get pendingCount => _jobs.where((job) => job.status == 'PENDING').length;
  int get completedCount => _jobs.where((job) => 
      job.status == 'COMPLETED' || job.status == 'COMPLETING').length;
  int get failedCount => _jobs.where((job) => 
      ['FAILED', 'TIMEOUT', 'CANCELLED'].contains(job.status)).length;
  
  Future<void> fetchJobs({String? timeRange}) async {
    if (_sessionId == null) return;
    
    if (timeRange != null) {
      _currentTimeRange = timeRange;
      print("IMPORTANT: Changed time range to: $_currentTimeRange");
      _jobs = []; // Clear jobs to force UI update
      notifyListeners(); // Notify listeners of the change
    }
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final url = '$_baseUrl/jobs?session_id=$_sessionId&time_range=$_currentTimeRange&test_mode=$_testMode';
      print('Fetching jobs from: $url');
      
      final response = await http.get(
        Uri.parse(url),
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> jobsData = responseData['jobs'];
        
        _jobs = jobsData.map((jobData) => Job.fromJson(jobData)).toList();
        print('IMPORTANT: Received ${_jobs.length} jobs for time range: $_currentTimeRange');
        
        if (responseData.containsKey('last_updated')) {
          _lastUpdated = DateTime.parse(responseData['last_updated']);
        } else {
          _lastUpdated = DateTime.now();
        }
      }
    } catch (error) {
      print('Error: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void toggleAutoRefresh(bool value) {
    _autoRefresh = value;
    if (_autoRefresh) {
      _startRefreshTimer();
    } else {
      _stopRefreshTimer();
    }
    notifyListeners();
  }
  
  void setRefreshInterval(int seconds) {
    _refreshInterval = seconds;
    if (_autoRefresh) {
      _stopRefreshTimer();
      _startRefreshTimer();
    }
    notifyListeners();
  }
  
  void toggleTestMode(bool value) {
    _testMode = value;
    fetchJobs();
    notifyListeners();
  }
  
  void _startAutoRefresh() {
    _stopAutoRefresh();
    _refreshTimer = Timer.periodic(
      Duration(seconds: _refreshInterval),
      (_) => fetchJobs(),
    );
  }
  
  void _stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }
  
  void _startRefreshTimer() {
    _refreshTimer = Timer.periodic(
      Duration(seconds: _refreshInterval),
      (_) => fetchJobs(),
    );
  }
  
  void _stopRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }
  
  @override
  void dispose() {
    _stopAutoRefresh();
    _stopRefreshTimer();
    super.dispose();
  }
} 