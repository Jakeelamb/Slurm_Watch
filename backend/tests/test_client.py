import pytest
import sys
import os

# Add the project root to the path to resolve imports
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../..')))

from backend.slurm.client import JobInfo, MockClient, SlurmClient

def test_job_info_tag():
    """Test that JobInfo.tag returns the correct status tag"""
    # Test different status tags
    assert JobInfo(job_id="1", name="test", status="RUNNING", time="1:00", nodes="1", cpus="1", memory="1G").tag == "running"
    assert JobInfo(job_id="2", name="test", status="PENDING", time="1:00", nodes="1", cpus="1", memory="1G").tag == "pending"
    assert JobInfo(job_id="3", name="test", status="COMPLETED", time="1:00", nodes="1", cpus="1", memory="1G").tag == "completed"
    assert JobInfo(job_id="4", name="test", status="COMPLETING", time="1:00", nodes="1", cpus="1", memory="1G").tag == "completed"
    assert JobInfo(job_id="5", name="test", status="FAILED", time="1:00", nodes="1", cpus="1", memory="1G").tag == "failed"
    assert JobInfo(job_id="6", name="test", status="TIMEOUT", time="1:00", nodes="1", cpus="1", memory="1G").tag == "failed"
    assert JobInfo(job_id="7", name="test", status="CANCELLED", time="1:00", nodes="1", cpus="1", memory="1G").tag == "failed"
    assert JobInfo(job_id="8", name="test", status="UNKNOWN", time="1:00", nodes="1", cpus="1", memory="1G").tag == "pending"

def test_mock_client_provides_jobs():
    """Test that MockClient returns a list of jobs"""
    client = MockClient()
    jobs = client.get_jobs()
    assert isinstance(jobs, list)
    assert len(jobs) > 0
    assert isinstance(jobs[0], JobInfo)

def test_mock_client():
    """Test that mock client returns sample data"""
    client = MockClient()
    jobs = client.get_jobs()
    assert len(jobs) == 3
    assert jobs[0].status == "RUNNING"
    assert jobs[1].status == "PENDING"
    assert jobs[2].status == "COMPLETED"

# Uncomment and modify this to test with real credentials
# def test_real_client():
#     """Test real client with actual credentials (only run manually)"""
#     client = SlurmClient(
#         hostname="your.hostname.edu",
#         username="your_username",
#         password="your_password"
#     )
#     assert client.connect()
#     jobs = client.get_jobs()
#     print(f"Retrieved {len(jobs)} jobs")
#     for job in jobs:
#         print(f"Job {job.job_id}: {job.name} - {job.status}")
#     client.disconnect() 