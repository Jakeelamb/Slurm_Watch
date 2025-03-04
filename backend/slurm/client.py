import paramiko
import re
import random
from dataclasses import dataclass
from typing import List, Optional, Dict
from datetime import datetime, timedelta
import time

@dataclass
class JobInfo:
    job_id: str
    name: str
    status: str
    time: str
    nodes: str
    cpus: str
    memory: str
    
    @property
    def tag(self) -> str:
        """Return the appropriate tag for the job's status"""
        if self.status == "RUNNING":
            return 'running'
        elif self.status == "PENDING":
            return 'pending'
        elif self.status in ["COMPLETED", "COMPLETING"]:
            return 'completed'
        elif self.status in ["FAILED", "TIMEOUT", "CANCELLED"]:
            return 'failed'
        return 'pending'  # Default case
    
    @staticmethod
    def format_memory(memory: str) -> str:
        # Format memory to appropriate units
        pass
        # ... existing code ...

class SlurmClient:
    def __init__(self, hostname: str, username: str, password: str):
        self.hostname = hostname
        self.username = username
        self.password = password
        self.ssh_client = None
        
    def connect(self) -> bool:
        """Establish SSH connection to Slurm cluster"""
        try:
            print(f"Attempting to connect to {self.hostname} as {self.username}")
            
            # Create SSH client
            self.ssh_client = paramiko.SSHClient()
            self.ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            
            # Connect with timeout
            self.ssh_client.connect(
                hostname=self.hostname,
                username=self.username,
                password=self.password,
                timeout=10
            )
            
            # Test connection by running a simple command
            _, stdout, _ = self.ssh_client.exec_command('hostname')
            result = stdout.read().decode('utf-8').strip()
            print(f"Connected to {result}")
            
            return True
        except Exception as e:
            print(f"Connection error: {type(e).__name__}: {str(e)}")
            import traceback
            traceback.print_exc()
            if self.ssh_client:
                self.ssh_client.close()
                self.ssh_client = None
            return False
        
    def get_jobs(self) -> List[JobInfo]:
        """Get job information from Slurm using squeue command"""
        if not self.ssh_client:
            if not self.connect():
                raise Exception("Not connected to SSH server")
        
        try:
            # Run squeue command to get job information
            # Format: JobID, Name, State, TimeLimit, Nodes, CPUs, Memory
            cmd = 'squeue -u $USER -o "%.18i %.30j %.8T %.10l %.5D %.5C %.8m" --noheader'
            _, stdout, stderr = self.ssh_client.exec_command(cmd)
            
            error = stderr.read().decode('utf-8').strip()
            if error:
                print(f"Error running squeue: {error}")
                return []
                
            output = stdout.read().decode('utf-8').strip()
            
            # Parse squeue output
            jobs = []
            for line in output.split('\n'):
                if not line.strip():
                    continue
                    
                parts = line.split()
                if len(parts) >= 7:
                    job_id = parts[0]
                    name = parts[1]
                    status = parts[2]
                    time = parts[3]
                    nodes = parts[4]
                    cpus = parts[5]
                    memory = parts[6]
                    
                    jobs.append(JobInfo(
                        job_id=job_id,
                        name=name,
                        status=status,
                        time=time,
                        nodes=nodes,
                        cpus=cpus,
                        memory=memory
                    ))
            
            return jobs
        except Exception as e:
            print(f"Error getting jobs: {str(e)}")
            # Try to reconnect once if the connection was lost
            if "SSH session not active" in str(e):
                self.ssh_client = None
                if self.connect():
                    return self.get_jobs()  # Try again
            raise
        
    def disconnect(self):
        """Close SSH connection"""
        if self.ssh_client:
            self.ssh_client.close()
            self.ssh_client = None

    def get_job_dependencies(self, job_id: str) -> List[str]:
        """Fetch job dependencies using scontrol."""
        if not self.ssh_client:
            if not self.connect():
                raise Exception("Not connected to SSH server")
        
        cmd = f"scontrol show job {job_id}"
        _, stdout, stderr = self.ssh_client.exec_command(cmd)
        
        error = stderr.read().decode('utf-8').strip()
        if error:
            print(f"Error running scontrol: {error}")
            return []
        
        output = stdout.read().decode('utf-8')
        dependencies = []
        for line in output.split("\n"):
            if line.strip().startswith("Dependency="):
                dep_str = line.split("=")[1]
                if dep_str and "afterok" in dep_str:
                    # Extract job IDs, e.g., "afterok:12345"
                    dep_type, dep_job_id = dep_str.split(":")
                    if dep_type == "afterok":
                        dependencies.append(dep_job_id)
        return dependencies

    def get_completed_jobs(self, time_range: str) -> List[JobInfo]:
        """Fetch completed jobs using sacct for a given time range."""
        if not self.ssh_client:
            if not self.connect():
                raise Exception("Not connected to SSH server")
        
        # Map time_range to sacct-compatible start time
        time_map = {
            "1h": "now-1hour",
            "6h": "now-6hours",
            "12h": "now-12hours",
            "24h": "now-1day",
            "156h": "now-6.5days"  # 156 hours ≈ 6.5 days
        }
        start_time = time_map.get(time_range, "now-1day")  # Default to 24h
        
        cmd = f"sacct -S {start_time} -E now -o JobID,JobName,State,Time,Nodes,CPUs,Memory --noheader"
        _, stdout, stderr = self.ssh_client.exec_command(cmd)
        
        error = stderr.read().decode('utf-8').strip()
        if error:
            print(f"Error running sacct: {error}")
            return []
        
        output = stdout.read().decode('utf-8')
        jobs = []
        for line in output.split("\n"):
            if not line.strip():
                continue
            parts = line.split()
            if len(parts) >= 7:
                jobs.append(JobInfo(
                    job_id=parts[0],
                    name=parts[1],
                    status=parts[2],
                    time=parts[3],
                    nodes=parts[4],
                    cpus=parts[5],
                    memory=parts[6]
                ))
        return jobs

class MockClient:
    """A client that returns mock data for testing"""
    def __init__(self):
        pass
        
    def get_jobs(self) -> List[JobInfo]:
        """Return mock job data for active jobs"""
        return [
            JobInfo(
                job_id="1001",
                name="test_job_running",
                status="RUNNING",
                time="1:30:00",
                nodes="2",
                cpus="8",
                memory="16G"
            ),
            JobInfo(
                job_id="1002",
                name="test_job_pending",
                status="PENDING",
                time="2:00:00",
                nodes="1",
                cpus="4",
                memory="8G"
            ),
        ]
    
    def get_completed_jobs(self, time_range: str) -> List[JobInfo]:
        """Return mock data for completed jobs"""
        return [
            JobInfo(
                job_id="1000",
                name="test_job_completed",
                status="COMPLETED",
                time="0:45:00",
                nodes="1",
                cpus="2",
                memory="4G"
            ),
            JobInfo(
                job_id="1003",
                name="test_job_failed",
                status="FAILED",
                time="0:30:00",
                nodes="1",
                cpus="1",
                memory="2G"
            ),
        ]
    
    def get_job_dependencies(self, job_id: str) -> List[str]:
        """Return mock dependency data"""
        dependencies = {
            "1001": ["1000"],
            "1002": ["1001"],
            "1000": [],
            "1003": ["1000"]
        }
        return dependencies.get(job_id, []) 