from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional, Dict
import uuid
import time
from .slurm.client import SlurmClient, JobInfo, MockClient
from datetime import datetime
import asyncio

app = FastAPI(title="SWATCH API", description="API for Slurm job monitoring")

# Configure CORS for Flutter web client
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, limit this to your app's domains
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Store active sessions (in a real app, use a more robust solution)
active_sessions = {}

class LoginRequest(BaseModel):
    hostname: str
    username: str
    password: str
    save_credentials: bool = False

class LoginResponse(BaseModel):
    session_id: str
    username: str
    hostname: str

class JobResponse(BaseModel):
    jobs: List[JobInfo]
    last_updated: str

class JobNode(BaseModel):
    job: JobInfo
    dependencies: List[str]

@app.post("/login")
async def login(request_data: dict):
    # Test mode login
    if request_data.get("test_mode", False):
        return {
            "session_id": "test_session_123",
            "username": request_data.get("username", "test_user"),
            "hostname": request_data.get("hostname", "localhost")
        }
    else:
        # Real authentication
        try:
            # Create client and test connection
            hostname = request_data.get("hostname", "")
            username = request_data.get("username", "")
            password = request_data.get("password", "")
            
            print(f"Attempting real login to {hostname} as {username}")
            
            client = SlurmClient(hostname, username, password)
            if not client.connect():
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Authentication failed"
                )
                
            # Create session
            session_id = str(uuid.uuid4())
            active_sessions[session_id] = {
                "client": client,
                "username": username,
                "hostname": hostname,
                "created_at": time.time()
            }
            
            return {
                "session_id": session_id,
                "username": username,
                "hostname": hostname
            }
        except Exception as e:
            print(f"Login error: {type(e).__name__}: {str(e)}")
            import traceback
            traceback.print_exc()
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Login failed: {str(e)}"
            )

@app.get("/jobs", response_model=JobResponse)
async def get_jobs(session_id: str, time_range: str = "24h", test_mode: bool = False):
    if test_mode:
        client = MockClient()
        jobs = client.get_jobs() + client.get_completed_jobs(time_range)
    else:
        if session_id not in active_sessions:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid or expired session"
            )
            
        session = active_sessions[session_id]
        client = session["client"]
        
        try:
            active_jobs = client.get_jobs()
            completed_jobs = client.get_completed_jobs(time_range)
            jobs = active_jobs + completed_jobs
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, 
                detail=f"Failed to retrieve jobs: {str(e)}"
            )
    
    return {
        "jobs": jobs,
        "last_updated": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    }

@app.get("/job_graph")
async def get_job_graph(session_id: str, time_range: str = "24h", test_mode: bool = False):
    if test_mode:
        client = MockClient()
        jobs = client.get_jobs() + client.get_completed_jobs(time_range)
    else:
        if session_id not in active_sessions:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid session"
            )
        client = active_sessions[session_id]["client"]
        jobs = client.get_jobs() + client.get_completed_jobs(time_range)
    
    job_graph = {}
    for job in jobs:
        dependencies = client.get_job_dependencies(job.job_id)
        job_graph[job.job_id] = {"job": job, "dependencies": dependencies}
    
    return job_graph

@app.post("/logout")
async def logout(session_id: str):
    if session_id in active_sessions:
        # Close client connection
        client = active_sessions[session_id]["client"]
        if hasattr(client, "disconnect"):
            client.disconnect()
        
        # Remove session
        del active_sessions[session_id]
    
    return {"detail": "Logged out successfully"}

@app.on_event("startup")
async def startup_event():
    # Start a background task to clean up expired sessions
    asyncio.create_task(cleanup_sessions())

async def cleanup_sessions():
    """Periodically clean up expired sessions"""
    while True:
        await asyncio.sleep(300)  # Check every 5 minutes
        current_time = time.time()
        expired_sessions = []
        
        for session_id, session in active_sessions.items():
            # Sessions expire after 1 hour of inactivity
            if current_time - session["created_at"] > 3600:
                expired_sessions.append(session_id)
        
        for session_id in expired_sessions:
            session = active_sessions[session_id]
            client = session.get("client")
            if client:
                client.disconnect()
            del active_sessions[session_id]
            print(f"Cleaned up expired session: {session_id}") 