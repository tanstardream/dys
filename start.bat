@echo off
chcp 65001 >nul
echo ================================
echo Recruitment System - Quick Start
echo ================================
echo.

echo Checking Python environment...
python --version
if errorlevel 1 (
    echo Error: Python not found, please install Python 3.7+
    pause
    exit /b 1
)

echo.
echo Checking dependencies...
cd backend

if not exist "venv" (
    echo Creating virtual environment...
    python -m venv venv
)

echo Activating virtual environment...
call venv\Scripts\activate.bat

echo Installing dependencies...
pip install -r requirements.txt

echo.
echo ================================
echo Starting backend service...
echo Access URL: http://localhost:5000
echo ================================
echo.
echo Frontend pages:
echo - Public page: frontend/index.html
echo - Admin panel: frontend/admin.html
echo.
echo Default admin account:
echo Username: admin
echo Password: admin123
echo.
echo Press Ctrl+C to stop the service
echo ================================
echo.

python app.py

pause
