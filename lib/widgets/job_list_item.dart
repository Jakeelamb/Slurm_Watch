import 'package:flutter/material.dart';
import '../models/job.dart';

class JobListItem extends StatelessWidget {
  final Job job;
  
  const JobListItem({Key? key, required this.job}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: _buildStatusIcon(),
        title: Text(job.name),
        subtitle: Text('Job ID: ${job.jobId}'),
        trailing: _buildDetails(),
        onTap: () {
          // Show detailed job information
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(job.name),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDetailRow('Status', job.status),
                    _buildDetailRow('Job ID', job.jobId),
                    _buildDetailRow('Time', job.time),
                    _buildDetailRow('Nodes', job.nodes),
                    _buildDetailRow('CPUs', job.cpus),
                    _buildDetailRow('Memory', job.memory),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildStatusIcon() {
    Color color;
    IconData icon;
    
    switch (job.statusTag) {
      case 'running':
        color = Colors.green;
        icon = Icons.play_arrow;
        break;
      case 'pending':
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        break;
      case 'completed':
        color = Colors.blue;
        icon = Icons.check_circle;
        break;
      case 'failed':
        color = Colors.red;
        icon = Icons.error;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }
    
    return CircleAvatar(
      backgroundColor: color,
      radius: 16,
      child: Icon(icon, color: Colors.white, size: 16),
    );
  }
  
  Widget _buildDetails() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(job.status, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text('${job.cpus} CPUs, ${job.memory}'),
      ],
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
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