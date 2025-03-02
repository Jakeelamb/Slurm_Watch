import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/job_provider.dart';
import '../widgets/frosted_background.dart';
import '../widgets/job_card.dart';
import '../models/job.dart';
import 'settings_screen.dart';
import '../utils/macos_theme.dart';

class JobsScreen extends StatefulWidget {
  static const routeName = '/jobs';
  
  const JobsScreen({Key? key}) : super(key: key);

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final jobs = jobProvider.jobs;
    final isDesktop = MediaQuery.of(context).size.width > 800;
    
    // Filter jobs based on selection
    final filteredJobs = _filterJobs(jobs, _selectedFilter);
    
    return FrostedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: isDesktop ? null : _buildAppBar(context, authProvider),
        drawer: isDesktop ? null : _buildDrawer(context, jobProvider, authProvider),
        body: Row(
          children: [
            // Desktop sidebar
            if (isDesktop) _buildSidebar(context, jobProvider, authProvider),
            
            // Main content area
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Desktop header
                  if (isDesktop) _buildDesktopHeader(authProvider),
                  
                  // Status summary cards
                  _buildStatusSummary(jobProvider),
                  
                  // Filter chips
                  _buildFilterChips(),
                  
                  // Jobs list
                  Expanded(
                    child: jobProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : filteredJobs.isEmpty
                        ? const Center(child: Text('No jobs found'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: filteredJobs.length,
                            itemBuilder: (ctx, i) => JobCard(
                              job: filteredJobs[i],
                              onTap: () => _showJobDetails(context, filteredJobs[i]),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  AppBar _buildAppBar(BuildContext context, AuthProvider authProvider) {
    return AppBar(
      title: const Text('SWATCH'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => Provider.of<JobProvider>(context, listen: false).fetchJobs(),
          tooltip: 'Refresh Jobs',
        ),
      ],
    );
  }
  
  Widget _buildDrawer(BuildContext context, JobProvider jobProvider, AuthProvider authProvider) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SWATCH',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  authProvider.username ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Text(
                  authProvider.hostname ?? '',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Refresh'),
            onTap: () {
              jobProvider.fetchJobs();
              Navigator.pop(context);
            },
          ),
          SwitchListTile(
            title: const Text('Auto Refresh'),
            secondary: const Icon(Icons.timer),
            value: jobProvider.autoRefresh,
            onChanged: (value) {
              jobProvider.toggleAutoRefresh(value);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, SettingsScreen.routeName);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              authProvider.logout();
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildSidebar(BuildContext context, JobProvider jobProvider, AuthProvider authProvider) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: Column(
        children: [
          // Logo and title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.analytics, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                const Text(
                  'SWATCH',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // User info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    authProvider.username?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authProvider.username ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        authProvider.hostname ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(),
          
          // Actions
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Refresh'),
            onTap: () => jobProvider.fetchJobs(),
          ),
          SwitchListTile(
            title: const Text('Auto Refresh'),
            secondary: const Icon(Icons.timer),
            value: jobProvider.autoRefresh,
            onChanged: (value) => jobProvider.toggleAutoRefresh(value),
          ),
          
          const Spacer(),
          
          const Divider(),
          
          // Bottom actions
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => Navigator.pushNamed(context, SettingsScreen.routeName),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => authProvider.logout(),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  Widget _buildDesktopHeader(AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        children: [
          Text(
            'Hello, ${authProvider.username ?? "User"}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            'Last Updated: ${_formatLastUpdated(Provider.of<JobProvider>(context).lastUpdated)}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusSummary(JobProvider jobProvider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildStatusCard(
            'Running',
            jobProvider.runningCount.toString(),
            Colors.blue,
            Icons.play_arrow,
          ),
          _buildStatusCard(
            'Pending',
            jobProvider.pendingCount.toString(),
            Colors.orange,
            Icons.hourglass_empty,
          ),
          _buildStatusCard(
            'Completed',
            jobProvider.completedCount.toString(),
            Colors.green,
            Icons.check_circle,
          ),
          _buildStatusCard(
            'Failed',
            jobProvider.failedCount.toString(),
            Colors.red,
            Icons.error,
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusCard(String title, String count, Color color, IconData icon) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                count,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All'),
            _buildFilterChip('Running'),
            _buildFilterChip('Pending'),
            _buildFilterChip('Completed'),
            _buildFilterChip('Failed'),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFilterChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: _selectedFilter == label,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = label;
          });
        },
        backgroundColor: Theme.of(context).cardTheme.color,
        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
        checkmarkColor: Theme.of(context).primaryColor,
      ),
    );
  }
  
  List<Job> _filterJobs(List<Job> jobs, String filter) {
    if (filter == 'All') return jobs;
    if (filter == 'Running') return jobs.where((job) => job.status == 'RUNNING').toList();
    if (filter == 'Pending') return jobs.where((job) => job.status == 'PENDING').toList();
    if (filter == 'Completed') {
      return jobs.where((job) => 
          job.status == 'COMPLETED' || job.status == 'COMPLETING').toList();
    }
    if (filter == 'Failed') {
      return jobs.where((job) => 
          ['FAILED', 'TIMEOUT', 'CANCELLED'].contains(job.status)).toList();
    }
    return jobs;
  }
  
  String _formatLastUpdated(DateTime? lastUpdated) {
    if (lastUpdated == null) return 'Never';
    return '${lastUpdated.hour}:${lastUpdated.minute.toString().padLeft(2, '0')}';
  }
  
  void _showJobDetails(BuildContext context, Job job) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: MacOSTheme.getStatusColor(job.status),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text('Job ${job.jobId}'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Name', job.name),
            _buildDetailRow('Status', job.status),
            _buildDetailRow('Time', job.time),
            _buildDetailRow('Nodes', job.nodes),
            _buildDetailRow('CPUs', job.cpus),
            _buildDetailRow('Memory', job.memory),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
} 