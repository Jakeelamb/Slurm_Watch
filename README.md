# Slurm Watch (SWATCH)

SWATCH is a modern, cross-platform application built with Flutter for monitoring and managing Slurm jobs. It provides an intuitive interface for tracking job statuses, visualizing job dependencies, and filtering jobs based on time ranges.

## Features

- 📊 Real-time monitoring of Slurm jobs
- 🔄 Interactive job dependency visualization
- ⏱️ Time-based filtering (1h, 6h, 12h, 24h, 156h)
- 📋 Detailed job information
- 💻 Responsive design that works on desktop, web, and mobile
- 🧪 Test mode for trying the app without a Slurm cluster

## Installation

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (latest stable version recommended)
- [Python 3.7+](https://www.python.org/downloads/)
- [Git](https://git-scm.com/downloads)

### Clone the Repository

```bash
# Using HTTPS
git clone https://github.com/Jakeelamb/Slurm_Watch.git

# Or using SSH
git clone git@github.com:Jakeelamb/Slurm_Watch.git

# Navigate to the project directory
cd Slurm_Watch
```

### Backend Setup

```bash
# Create and activate a virtual environment (recommended)
python -m venv venv

# On Unix/macOS
source venv/bin/activate

# On Windows
venv\Scripts\activate

# Install required Python packages
pip install -r requirements.txt

# Start the backend server
cd backend
uvicorn main:app --reload --host 0.0.0.0 --port 8080
```

### Frontend Setup

```bash
# Install Flutter dependencies
flutter pub get

# Run Flutter app in debug mode
flutter run
```

## Running on Different Platforms

### Web
```bash
# Run on Chrome
flutter run -d chrome

# Build for web deployment
flutter build web
```

### Desktop
```bash
# Run on Windows
flutter run -d windows

# Run on macOS
flutter run -d macos

# Run on Linux
flutter run -d linux
```

### Mobile
```bash
# Run on connected Android device
flutter run -d android

# Run on connected iOS device (requires macOS)
flutter run -d ios

# Or use a specific device
flutter devices  # List available devices
flutter run -d <device_id>
```

### Test Mode
```bash
# Run with test mode enabled
flutter run --dart-define=TEST_MODE=true
```

> **Note**: In the login screen, check the "Test Mode" option to use simulated data.

## Project Structure

```
SWATCH/
├── lib/          # Flutter application code
├── backend/      # Python FastAPI backend server
├── test/         # Test files
└── scripts/      # Utility scripts
```

## Troubleshooting

🔍 Common issues and solutions:

- If the app doesn't connect to the backend:
  - Verify that the backend server is running on port 8080
  - Check if the backend URL is correctly configured
  - Ensure your firewall allows connections to the backend server

- For connection issues with a real Slurm cluster:
  - Verify SSH permissions
  - Check network access to the cluster
  - Ensure the Slurm commands are available in the PATH

## Contributing

Contributions are welcome! Here's how you can help:

- 🐛 Report bugs by opening issues
- 💡 Suggest new features
- 🔧 Submit pull requests
- 📚 Improve documentation

---

<div align="center">
Made with ❤️ for the HPC community
</div>