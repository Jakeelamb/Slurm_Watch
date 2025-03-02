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
  bool _autoRefresh = true;
  int _refreshInterval = 30; // seconds
  Timer? _refreshTimer;
  bool _testMode = false;
  
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
    }
  }
  
  List<Job> get jobs => [..._jobs];
  bool get isLoading => _isLoading;
  DateTime? get lastUpdated => _lastUpdated;
  bool get autoRefresh => _autoRefresh;
  int get refreshInterval => _refreshInterval;
  bool get testMode => _testMode;
  
  // Job status counts
  int get runningCount => _jobs.where((job) => job.status == 'RUNNING').length;
  int get pendingCount => _jobs.where((job) => job.status == 'PENDING').length;
  int get completedCount => _jobs.where((job) => 
      job.status == 'COMPLETED' || job.status == 'COMPLETING').length;
  int get failedCount => _jobs.where((job) => 
      ['FAILED', 'TIMEOUT', 'CANCELLED'].contains(job.status)).length;
  
  Future<void> fetchJobs() async {
    if (_sessionId == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final url = '$_baseUrl/jobs?session_id=$_sessionId&test_mode=$_testMode';
      print('Fetching jobs from: $url');
      
      final response = await http.get(
        Uri.parse(url),
      ).timeout(const Duration(seconds: 5));
      
      print('Jobs response status: ${response.statusCode}');
      print('Jobs response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> jobsData = responseData['jobs'];
        
        _jobs = jobsData.map((jobData) => Job.fromJson(jobData)).toList();
        
        if (responseData.containsKey('last_updated')) {
          _lastUpdated = DateTime.parse(responseData['last_updated']);
        } else {
          _lastUpdated = DateTime.now();
        }
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      print('Connection error: $error');
      if (_testMode) {
        _jobs = [
          Job(
            jobId: '1001',
            name: 'test_job_running',
            status: 'RUNNING',
            time: '1:30:00',
            nodes: '2',
            cpus: '8',
            memory: '16G',
          ),
          Job(
            jobId: '1002',
            name: 'test_job_pending',
            status: 'PENDING',
            time: '2:00:00',
            nodes: '1',
            cpus: '4',
            memory: '8G',
          ),
          Job(
            jobId: '1003',
            name: 'test_job_completed',
            status: 'COMPLETED',
            time: '0:45:00',
            nodes: '1',
            cpus: '2',
            memory: '4G',
          ),
        ];
        _lastUpdated = DateTime.now();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void toggleAutoRefresh(bool value) {
    _autoRefresh = value;
    
    if (_autoRefresh) {
      _startAutoRefresh();
    } else {
      _stopAutoRefresh();
    }
    
    notifyListeners();
  }
  
  void setRefreshInterval(int seconds) {
    _refreshInterval = seconds;
    
    if (_autoRefresh) {
      _stopAutoRefresh();
      _startAutoRefresh();
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
  
  @override
  void dispose() {
    _stopAutoRefresh();
    super.dispose();
  }
} 