#!/bin/bash

echo "========================================"
echo "Recruitment System - Production Start"
echo "========================================"
echo

# Check Python
if ! command -v python3 &> /dev/null; then
    echo "Error: Python3 not found"
    exit 1
fi

# Navigate to backend directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/backend"

# Install dependencies
echo "Installing dependencies..."
pip3 install -r requirements.txt

# Initialize database
echo "Initializing database..."
python3 init_demo_data.py

echo
echo "========================================"
echo "Starting Production Server with Gunicorn"
echo "========================================"
echo
echo "Access URLs:"
echo "- Public Page: http://localhost:5000/"
echo "- Admin Panel: http://localhost:5000/admin"
echo
echo "For cloud server, replace localhost with your IP"
echo
echo "Press Ctrl+C to stop"
echo "========================================"
echo

# Start with Gunicorn (production server)
gunicorn -w 4 -b 0.0.0.0:5000 --access-logfile - --error-logfile - app:app
