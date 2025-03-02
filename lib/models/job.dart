class Job {
  final String jobId;
  final String name;
  final String status;
  final String time;
  final String nodes;
  final String cpus;
  final String memory;

  Job({
    required this.jobId,
    required this.name,
    required this.status,
    required this.time,
    required this.nodes,
    required this.cpus,
    required this.memory,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      jobId: json['job_id'],
      name: json['name'],
      status: json['status'],
      time: json['time'],
      nodes: json['nodes'],
      cpus: json['cpus'],
      memory: json['memory'],
    );
  }

  String get statusTag {
    if (status == "RUNNING") {
      return 'running';
    } else if (status == "PENDING") {
      return 'pending';
    } else if (["COMPLETED", "COMPLETING"].contains(status)) {
      return 'completed';
    } else if (["FAILED", "TIMEOUT", "CANCELLED"].contains(status)) {
      return 'failed';
    }
    return 'pending';
  }
} 