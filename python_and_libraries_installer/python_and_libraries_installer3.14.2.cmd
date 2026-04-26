@echo off
title System Monitor - Installer
echo ============================================
echo    SYSTEM MONITOR - INSTALLER
echo ============================================
echo.

:: ====== PYTHON 3.14.2 ======
echo [1/2] Checking Python...
where python >nul 2>nul
if %errorlevel% neq 0 (
    echo Python not found. Downloading 3.14.2...
    powershell -Command "Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.14.2/python-3.14.2-amd64.exe' -OutFile 'python.exe'"
    echo Installing Python 3.14.2...
    python.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
    del python.exe
    echo Python 3.14.2 installed!
) else (
    echo Python OK
)

:: ====== PSUTIL ======
echo.
echo [2/2] Installing psutil...
pip install --quiet psutil
echo Done!

echo.
echo ============================================
echo    Starting System Monitor...
echo ============================================
start python system_monitor.py
exit
