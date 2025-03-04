import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/auth_provider.dart';
import '../providers/job_provider.dart';
import '../models/job.dart';
import '../utils/macos_theme.dart';

class JobGraphScreen extends StatefulWidget {
  final String jobId;
  
  const JobGraphScreen({
    Key? key,
    required this.jobId,
  }) : super(key: key);

  @override
  _JobGraphScreenState createState() => _JobGraphScreenState();
}

class _JobGraphScreenState extends State<JobGraphScreen> {
  final Graph graph = Graph()..isTree = true;
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();
  Map<String, dynamic> _graphData = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    builder
      ..siblingSeparation = 100
      ..levelSeparation = 150
      ..subtreeSeparation = 150
      ..orientation = BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM;
    _fetchGraphData();
  }

  Future<void> _fetchGraphData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final timeRange = Provider.of<JobProvider>(context, listen: false).currentTimeRange;
      
      final response = await http.get(
        Uri.parse('http://localhost:8080/job_graph?session_id=${auth.sessionId}&time_range=$timeRange&test_mode=${auth.testMode}'),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        
        setState(() {
          _graphData = data;
          _buildGraph(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load graph data: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
      
      // If in test mode, use mock data
      if (Provider.of<AuthProvider>(context, listen: false).testMode) {
        _useMockData();
      }
    }
  }
  
  void _useMockData() {
    final mockData = {
      "1000": {
        "job": {
          "job_id": "1000",
          "name": "test_job_completed",
          "status": "COMPLETED",
          "time": "0:45:00",
          "nodes": "1",
          "cpus": "2",
          "memory": "4G"
        },
        "dependencies": []
      },
      "1001": {
        "job": {
          "job_id": "1001",
          "name": "test_job_running",
          "status": "RUNNING",
          "time": "1:30:00",
          "nodes": "2",
          "cpus": "8",
          "memory": "16G"
        },
        "dependencies": ["1000"]
      },
      "1002": {
        "job": {
          "job_id": "1002",
          "name": "test_job_pending",
          "status": "PENDING",
          "time": "2:00:00",
          "nodes": "1",
          "cpus": "4",
          "memory": "8G"
        },
        "dependencies": ["1001"]
      },
      "1003": {
        "job": {
          "job_id": "1003",
          "name": "test_job_failed",
          "status": "FAILED",
          "time": "0:30:00",
          "nodes": "1",
          "cpus": "1",
          "memory": "2G"
        },
        "dependencies": ["1000"]
      }
    };
    
    setState(() {
      _graphData = mockData;
      _buildGraph(mockData);
      _isLoading = false;
      _error = null;
    });
  }
  
  void _buildGraph(Map<String, dynamic> data) {
    graph.nodes.clear();
    graph.edges.clear();
    
    // First, add all nodes
    data.forEach((jobId, nodeData) {
      graph.addNode(Node.Id(jobId));
    });
    
    // Then add edges
    data.forEach((jobId, nodeData) {
      final List<dynamic> dependencies = nodeData['dependencies'];
      for (var depId in dependencies) {
        if (data.containsKey(depId)) {
          graph.addEdge(Node.Id(depId), Node.Id(jobId));
        }
      }
    });
  }

  Color _getColorForStatus(String status) {
    return MacOSTheme.getStatusColor(status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Dependency Graph'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchGraphData,
          ),
        ],
      ),
      body: _isLoading 
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: TextStyle(color: Colors.red)))
              : graph.nodeCount() == 0
                  ? Center(child: Text('No job dependencies found'))
                  : InteractiveViewer(
                      constrained: false,
                      boundaryMargin: EdgeInsets.all(100),
                      minScale: 0.1,
                      maxScale: 2.0,
                      child: GraphView(
                        graph: graph,
                        algorithm: BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
                        paint: Paint()
                          ..color = Colors.black
                          ..strokeWidth = 2
                          ..style = PaintingStyle.stroke,
                        builder: (Node node) {
                          final jobId = node.key!.value as String;
                          final jobData = _graphData[jobId]['job'];
                          final job = Job.fromJson(jobData);
                          
                          final isSelected = jobId == widget.jobId;
                          
                          return Card(
                            elevation: isSelected ? 8 : 2,
                            color: _getColorForStatus(job.status),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: isSelected 
                                  ? BorderSide(color: Colors.white, width: 2)
                                  : BorderSide.none,
                            ),
                            child: Container(
                              padding: EdgeInsets.all(16),
                              constraints: BoxConstraints(
                                minWidth: 150,
                                maxWidth: 200,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Job ${job.jobId}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    job.name,
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black26,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      job.status,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
} 