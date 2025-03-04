import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/job.dart';
import '../utils/macos_theme.dart';
import '../screens/job_graph_screen.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback? onTap;
  
  const JobCard({
    Key? key,
    required this.job,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusColor = MacOSTheme.getStatusColor(job.status);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobGraphScreen(jobId: job.jobId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Status dot
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  
                  // Job ID and copy button
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          'Job ${job.jobId}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: job.jobId));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Job ID copied to clipboard'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // Status text
                  Text(
                    job.status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Job name
              Text(
                job.name,
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              
              // Details row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailItem(Icons.timer_outlined, job.time),
                  _buildDetailItem(Icons.computer_outlined, '${job.nodes} Node${job.nodes != "1" ? "s" : ""}'),
                  _buildDetailItem(Icons.memory_outlined, '${job.cpus} CPU${job.cpus != "1" ? "s" : ""}'),
                  _buildDetailItem(Icons.storage_outlined, job.memory),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
} 