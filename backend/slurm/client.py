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
    hours_ago: float = 0.0  # Add this field with a default value
    
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
        """Return mock dependency data with a logical dependency graph"""
        # Fix the dependency logic to make sense:
        # 1. Failed jobs can depend on completed jobs
        # 2. Running jobs must depend on completed or running jobs
        # 3. Pending jobs can depend on anything
        # 4. Completed jobs should only depend on other completed jobs
        
        # First determine job status
        job_status = {}
        for job in self.get_jobs() + self.get_completed_jobs("156h"):  # All jobs
            job_status[job.job_id] = job.status
        
        # Define logical dependencies
        dependencies = {
            # Main workflow (logical flow)
            "1004": ["1002"],          # final_analysis (PENDING) depends on data_processing (RUNNING)
            "1003": ["1002"],          # visualization_prep (PENDING) depends on data_processing (RUNNING)
            "1002": ["1001", "1000"],  # data_processing (RUNNING) depends on main_simulation (RUNNING) and data_preparation (COMPLETED)
            "1001": ["1000"],          # main_simulation (RUNNING) depends on data_preparation (COMPLETED)
            
            # Completed chain
            "1000": ["995"],           # data_preparation (COMPLETED) depends on model_training_small (COMPLETED)
            "995": ["990"],            # model_training_small (COMPLETED) depends on preprocessing_batch1 (COMPLETED)
            "990": [],                 # preprocessing_batch1 (COMPLETED) has no dependencies
            
            # Failed chain
            "985": ["990"],            # model_validation (FAILED) depends on preprocessing_batch1 (COMPLETED)
            
            # Older completed chain
            "980": ["975"],            # large_simulation (COMPLETED) depends on data_collection (COMPLETED)
            "975": ["970"],            # data_collection (COMPLETED) depends on initial_setup (COMPLETED)
            "970": [],                 # initial_setup (COMPLETED) has no dependencies
        }
        
        return dependencies.get(job_id, [])

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
    """A client that returns mock data for testing with enhanced test data"""
    def __init__(self):
        # Store current time for relative time calculations
        self.now = datetime.now()
        
    def get_jobs(self) -> List[JobInfo]:
        """Return mock data for active jobs - these are always shown"""
        return [
            # Currently running jobs
            JobInfo(
                job_id="1001",
                name="main_simulation",
                status="RUNNING",
                time="12:30:00",
                nodes="4",
                cpus="32",
                memory="64G"
            ),
            JobInfo(
                job_id="1002",
                name="data_processing",
                status="RUNNING",
                time="2:45:00",
                nodes="2",
                cpus="16",
                memory="32G"
            ),
            # Pending jobs
            JobInfo(
                job_id="1003",
                name="visualization_prep",
                status="PENDING",
                time="1:00:00",
                nodes="1",
                cpus="8",
                memory="16G"
            ),
            JobInfo(
                job_id="1004",
                name="final_analysis",
                status="PENDING",
                time="3:00:00",
                nodes="2",
                cpus="16",
                memory="24G"
            ),
        ]
    
    def get_completed_jobs(self, time_range: str) -> List[JobInfo]:
        """Return mock data for completed jobs based on time range"""
        print(f"MockClient.get_completed_jobs called with time_range={time_range}")
        
        # Map time_range to hours
        hours_map = {
            "1h": 1,
            "6h": 6,
            "12h": 12,
            "24h": 24,
            "156h": 156  # ~6.5 days
        }
        
        hours = hours_map.get(time_range, 24)  # Default to 24h
        print(f"Filtering for {hours} hours")
        
        # Create all jobs with their relative timestamps
        all_completed_jobs = [
            # Within 1 hour
            self._create_job_with_timestamp("1000", "data_preparation", "COMPLETED", 0.5),
            
            # Within 4 hours
            self._create_job_with_timestamp("995", "model_training_small", "COMPLETED", 3),
            
            # Within 8 hours
            self._create_job_with_timestamp("990", "preprocessing_batch1", "COMPLETED", 7),
            
            # Within 18 hours
            self._create_job_with_timestamp("985", "model_validation", "FAILED", 16),
            
            # Within 2 days
            self._create_job_with_timestamp("980", "large_simulation", "COMPLETED", 40),
            
            # Within 4 days
            self._create_job_with_timestamp("975", "data_collection", "COMPLETED", 85),
            
            # Within 6 days
            self._create_job_with_timestamp("970", "initial_setup", "COMPLETED", 140),
        ]
        
        # Filter based on time range
        filtered_jobs = [job for job in all_completed_jobs if job.hours_ago <= hours]
        
        print(f"Returning {len(filtered_jobs)} completed jobs for time range {time_range}")
        return filtered_jobs
        
    def _create_job_with_timestamp(self, job_id, name, status, hours_ago):
        """Create a job with timestamp information"""
        job = JobInfo(
            job_id=job_id,
            name=name,
            status=status,
            time=f"{int(hours_ago)}:00:00" if hours_ago >= 1 else f"0:{int(hours_ago*60)}:00",
            nodes="1",
            cpus="4",
            memory="8G"
        )
        # Add hours_ago as an attribute for filtering
        job.hours_ago = hours_ago
        return job
    
    def get_job_dependencies(self, job_id: str) -> List[str]:
        """Return mock dependency data with a logical dependency graph that respects time ranges"""
        # Define dependencies that make sense with our time-based jobs
        dependencies = {
            # Active jobs
            "1004": ["1002"],          # final_analysis (PENDING) depends on data_processing (RUNNING)
            "1003": ["1002"],          # visualization_prep (PENDING) depends on data_processing (RUNNING)
            "1002": ["1001", "1000"],  # data_processing (RUNNING) depends on main_simulation (RUNNING) and data_preparation (COMPLETED)
            "1001": ["1000"],          # main_simulation (RUNNING) depends on data_preparation (COMPLETED)
            
            # Completed jobs with timestamps
            "1000": ["995"],           # data_preparation (0.5h ago) depends on model_training_small (3h ago)
            "995": ["990"],            # model_training_small (3h ago) depends on preprocessing_batch1 (7h ago)
            "990": [],                 # preprocessing_batch1 (7h ago) has no dependencies
            
            # Failed job
            "985": ["990"],            # model_validation (16h ago) depends on preprocessing_batch1 (7h ago)
            
            # Older completed jobs
            "980": ["975"],            # large_simulation (40h ago) depends on data_collection (85h ago)
            "975": ["970"],            # data_collection (85h ago) depends on initial_setup (140h ago)
            "970": [],                 # initial_setup (140h ago) has no dependencies
        }
        
        # Return only dependencies that exist (this allows time filtering to work)
        deps = dependencies.get(job_id, [])
        return deps 