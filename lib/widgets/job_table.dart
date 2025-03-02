import 'package:flutter/material.dart';
import '../models/job.dart';

class JobTable extends StatelessWidget {
  final List<Job> jobs;
  
  const JobTable({Key? key, required this.jobs}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Job ID')),
            DataColumn(label: Text('Time')),
            DataColumn(label: Text('Nodes')),
            DataColumn(label: Text('CPUs')),
            DataColumn(label: Text('Memory')),
          ],
          rows: jobs.map((job) => _buildJobRow(job, context)).toList(),
        ),
      ),
    );
  }
  
  DataRow _buildJobRow(Job job, BuildContext context) {
    return DataRow(
      cells: [
        DataCell(_buildStatusCell(job)),
        DataCell(Text(job.name)),
        DataCell(Text(job.jobId)),
        DataCell(Text(job.time)),
        DataCell(Text(job.nodes)),
        DataCell(Text(job.cpus)),
        DataCell(Text(job.memory)),
      ],
    );
  }
  
  Widget _buildStatusCell(Job job) {
    Color color;
    String text = job.status;
    
    switch (job.statusTag) {
      case 'running':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'completed':
        color = Colors.blue;
        break;
      case 'failed':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
} 