import sys
import os

# Add the project root to the path to resolve imports
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../..')))

from fastapi.testclient import TestClient
from backend.main import app

client = TestClient(app)

def test_jobs_endpoint_with_test_mode():
    """Test the /jobs endpoint with test_mode=True"""
    response = client.get("/jobs?session_id=test&test_mode=True")
    assert response.status_code == 200
    data = response.json()
    assert "jobs" in data
    assert "last_updated" in data 