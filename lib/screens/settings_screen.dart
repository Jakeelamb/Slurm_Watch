import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/job_provider.dart';
import '../widgets/frosted_background.dart';

class SettingsScreen extends StatefulWidget {
  static const routeName = '/settings';
  
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final jobProvider = Provider.of<JobProvider>(context);
    
    return FrostedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Settings'),
          elevation: 0,
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Connection Info
            _buildCard(
              title: 'Connection',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authProvider.hostname ?? 'localhost',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Connected as ${authProvider.username}',
                              style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark 
                                    ? Colors.white70 
                                    : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => _confirmLogout(context, authProvider),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Job Refresh Settings
            _buildCard(
              title: 'Job Refresh',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Auto refresh toggle
                  SwitchListTile.adaptive(
                    title: const Text('Auto Refresh'),
                    subtitle: const Text('Refresh job list automatically'),
                    value: jobProvider.autoRefresh,
                    onChanged: (value) => jobProvider.toggleAutoRefresh(value),
                    secondary: const Icon(Icons.refresh),
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  // Refresh interval slider
                  if (jobProvider.autoRefresh) 
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.only(left: 12, top: 8),
                          child: Text(
                            'Refresh interval: ${jobProvider.refreshInterval} seconds',
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark 
                                  ? Colors.white70 
                                  : Colors.black54,
                            ),
                          ),
                        ),
                        Slider.adaptive(
                          value: jobProvider.refreshInterval.toDouble(),
                          min: 5,
                          max: 60,
                          divisions: 11,
                          label: '${jobProvider.refreshInterval} seconds',
                          onChanged: (value) => 
                              jobProvider.setRefreshInterval(value.toInt()),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Display Settings
            _buildCard(
              title: 'Appearance',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile.adaptive(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Enable dark color theme'),
                    value: Theme.of(context).brightness == Brightness.dark,
                    onChanged: (value) {
                      // This would require ThemeMode to be managed by a provider
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Dark mode is controlled by your system settings'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    secondary: const Icon(Icons.dark_mode),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // About
            _buildCard(
              title: 'About',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: const Text('SWATCH'),
                    subtitle: const Text('Slurm WATCHer - Job Monitoring Tool'),
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.analytics,
                      color: Theme.of(context).primaryColor,
                      size: 36,
                    ),
                  ),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Version 1.0.0'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ],
    );
  }
  
  void _confirmLogout(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              authProvider.logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
} 