import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/job_provider.dart';
import '../widgets/frosted_background.dart';
import '../widgets/job_card.dart';
import '../models/job.dart';
import 'settings_screen.dart';
import '../utils/macos_theme.dart';
import '../providers/appearance_provider.dart';

class JobsScreen extends StatefulWidget {
  static const routeName = '/jobs';
  
  const JobsScreen({Key? key}) : super(key: key);

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> with SingleTickerProviderStateMixin {
  String _selectedFilter = 'All';
  bool _sidebarExpanded = true;
  late AnimationController _sidebarController;
  late Animation<double> _sidebarAnimation;

  @override
  void initState() {
    super.initState();
    
    _sidebarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    
    _sidebarAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _sidebarController,
      curve: Curves.easeInOut,
    ));
    
    _sidebarController.reverse();
  }
  
  @override
  void dispose() {
    _sidebarController.dispose();
    super.dispose();
  }
  
  void _toggleSidebar() {
    setState(() {
      _sidebarExpanded = !_sidebarExpanded;
      if (_sidebarExpanded) {
        _sidebarController.reverse();
      } else {
        _sidebarController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final jobs = jobProvider.jobs;
    final isDesktop = MediaQuery.of(context).size.width > 800;
    
    final filteredJobs = _filterJobs(jobs, _selectedFilter);
    
    return FrostedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: isDesktop ? null : _buildAppBar(context, authProvider),
        drawer: isDesktop ? null : _buildDrawer(context, jobProvider, authProvider),
        body: Row(
          children: [
            if (isDesktop) 
              AnimatedBuilder(
                animation: _sidebarAnimation,
                builder: (context, child) {
                  return Row(
                    children: [
                      SizeTransition(
                        sizeFactor: _sidebarAnimation,
                        axis: Axis.horizontal,
                        axisAlignment: -1,
                        child: _buildSidebar(context, jobProvider, authProvider),
                      ),
                      
                      Container(
                        width: 24,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: InkWell(
                          onTap: _toggleSidebar,
                          child: Center(
                            child: Icon(
                              _sidebarExpanded 
                                ? Icons.chevron_left 
                                : Icons.chevron_right,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isDesktop) _buildDesktopHeader(authProvider),
                  
                  _buildStatusSummary(jobProvider),
                  
                  _buildFilterChips(),
                  
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
      width: 220,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SWATCH',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authProvider.username ?? 'User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            authProvider.hostname ?? 'localhost',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _buildSidebarItem(
                  context,
                  icon: Icons.refresh_rounded,
                  label: 'Refresh Jobs',
                  onTap: () => jobProvider.fetchJobs(),
                ),
                
                const SizedBox(height: 8),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.autorenew_rounded,
                        color: Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Auto Refresh',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Switch(
                        value: jobProvider.autoRefresh,
                        onChanged: (value) => jobProvider.toggleAutoRefresh(value),
                        activeColor: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                _buildSidebarItem(
                  context,
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  onTap: () => Navigator.pushNamed(context, SettingsScreen.routeName),
                ),
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => authProvider.logout(),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                foregroundColor: Colors.white,
                backgroundColor: Colors.red.shade800.withOpacity(0.8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSidebarItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white70,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDesktopHeader(AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Job Dashboard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Connected to ${authProvider.hostname}',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white70 
                      : Colors.black54,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.1)
                      : Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Last Updated: ${_formatLastUpdated(Provider.of<JobProvider>(context).lastUpdated)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh Jobs',
                onPressed: () => Provider.of<JobProvider>(context, listen: false).fetchJobs(),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusSummary(JobProvider jobProvider) {
    final runningJobs = jobProvider.jobs.where((job) => job.status == 'RUNNING').length;
    final pendingJobs = jobProvider.jobs.where((job) => job.status == 'PENDING').length;
    final completedJobs = jobProvider.jobs.where((job) => 
      job.status == 'COMPLETED' || job.status == 'COMPLETING').length;
    final failedJobs = jobProvider.jobs.where((job) => 
      ['FAILED', 'TIMEOUT', 'CANCELLED'].contains(job.status)).length;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          _buildStatusCard('Running', runningJobs.toString(), MacOSTheme.runningColor, Icons.play_circle_outline),
          _buildStatusCard('Pending', pendingJobs.toString(), MacOSTheme.pendingColor, Icons.pending_outlined),
          _buildStatusCard('Completed', completedJobs.toString(), MacOSTheme.completedColor, Icons.check_circle_outline),
          _buildStatusCard('Failed', failedJobs.toString(), MacOSTheme.failedColor, Icons.error_outline),
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