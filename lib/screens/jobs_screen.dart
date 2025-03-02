import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/job_provider.dart';
import '../models/job.dart';
import '../widgets/job_list_item.dart';
import '../widgets/job_table.dart';
import 'settings_screen.dart';

class JobsScreen extends StatelessWidget {
  static const routeName = '/jobs';
  
  const JobsScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;
    final auth = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('SWATCH - ${auth.username}@${auth.hostname}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => 
                Provider.of<JobProvider>(context, listen: false).fetchJobs(),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => 
                Navigator.of(context).pushNamed(SettingsScreen.routeName),
          ),
        ],
      ),
      body: Consumer<JobProvider>(
        builder: (ctx, jobProvider, _) {
          if (jobProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (jobProvider.jobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No jobs found'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => jobProvider.fetchJobs(),
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }
          
          return Column(
            children: [
              // Add status summary
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatusIndicator('Running', jobProvider.runningCount, Colors.green),
                    _buildStatusIndicator('Pending', jobProvider.pendingCount, Colors.orange),
                    _buildStatusIndicator('Completed', jobProvider.completedCount, Colors.blue),
                    _buildStatusIndicator('Failed', jobProvider.failedCount, Colors.red),
                  ],
                ),
              ),
              
              // Last updated text
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Last updated: ${jobProvider.lastUpdated?.toString() ?? 'Never'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              
              // Jobs list or table
              Expanded(
                child: isDesktop
                    ? JobTable(jobs: jobProvider.jobs)
                    : ListView.builder(
                        itemCount: jobProvider.jobs.length,
                        itemBuilder: (ctx, i) => JobListItem(job: jobProvider.jobs[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildStatusIndicator(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text('$label: $count'),
      ],
    );
  }
} 