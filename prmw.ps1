# Ensure Python is accessible
if (-not (Get-Command "python" -ErrorAction SilentlyContinue)) {
    Write-Error "Python is not detected. Please ensure Python is installed and added to your PATH environment variable."
    exit
}

Write-Host "Installing/Verifying Python dependencies (opencv-python, pillow)..." -ForegroundColor Yellow
# Install required dependencies quietly so it doesn't clutter the console
python -m pip install opencv-python pillow --quiet

# Setup paths in the TEMP directory
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$saveFolder = Join-Path -Path $env:TEMP -ChildPath "Screenshots_$timestamp"
$zipPath = Join-Path -Path $env:TEMP -ChildPath "Screenshots_$timestamp.zip"
$pythonScriptPath = Join-Path -Path $env:TEMP -ChildPath "capture_script_$timestamp.py"

# Create the temporary directory for images
New-Item -ItemType Directory -Force -Path $saveFolder | Out-Null

# --- EMBEDDED PYTHON SCRIPT ---
# We use Python's "threading" module to ensure screenshots and webcam captures happen in exact parallel
$pythonCode = @"
import cv2
import os
import sys
import time
import threading
import subprocess
from PIL import ImageGrab

save_dir = sys.argv[1]

def take_screenshot(name):
    try:
        # all_screens=True captures the FULL virtual screen (including multiple monitors)
        img = ImageGrab.grab(all_screens=True)
        img.save(os.path.join(save_dir, name))
        print(f"Saved Screen: {name}")
    except Exception as e:
        print(f"Failed to save screen {name}: {e}")

print("Taking the first 5 pre-Chrome screenshots...")
for i in range(1, 6):
    take_screenshot(f"01_Pre_Chrome_{i:02d}.png")
    time.sleep(1)

print("\nOpening Google Chrome in a new fullscreen window...")
subprocess.Popen([r"C:\Program Files\Google\Chrome\Application\chrome.exe", "--new-window", "https://www.google.com", "--start-fullscreen"])

# Wait for Chrome to fully open and load
time.sleep(3)

print("Initializing Webcam (warming up sensor)...")
cap = cv2.VideoCapture(0)
# Read a few frames to let the camera adjust to the lighting, preventing black frames
for _ in range(10):
    cap.read()
    time.sleep(0.1)

print("\nTaking 30 screenshots (1s delay) and webcam captures (2s delay) strictly in parallel...")

def capture_webcam():
    # Runs in the background: captures every 2 seconds, effectively matching even numbers of the screenshot loop
    for i in range(2, 31, 2):
        start_time = time.time()
        
        ret, frame = cap.read()
        if ret:
            name = f"03_Webcam_{i:02d}.png"
            cv2.imwrite(os.path.join(save_dir, name), frame)
            print(f"Triggered Webcam: {name}")
        
        # Calculate exactly how much time is left in the 2-second interval to prevent timing drift
        elapsed = time.time() - start_time
        time.sleep(max(0, 2.0 - elapsed))

# Start the webcam capture in a parallel background thread
webcam_thread = threading.Thread(target=capture_webcam)
webcam_thread.start()

# Main thread handles the 1-second screenshot loop
for i in range(1, 31):
    start_time = time.time()
    
    take_screenshot(f"02_Chrome_Fullscreen_{i:02d}.png")
    
    # Calculate exactly how much time is left in the 1-second interval
    elapsed = time.time() - start_time
    time.sleep(max(0, 1.0 - elapsed))

# Wait for the webcam background process to completely finish, then close the camera
webcam_thread.join()
cap.release()
print("\nAll Python captures finished successfully.")
"@

# Write the Python script to the Temp folder
$pythonCode | Set-Content -Path $pythonScriptPath -Encoding UTF8

Write-Host "`nRunning the Python Capture Engine..." -ForegroundColor Cyan
# Execute the Python script, passing the dynamically created TEMP save folder as an argument
python $pythonScriptPath $saveFolder

Write-Host "`nZipping the screenshots folder..." -ForegroundColor Cyan
# Compress the folder into a .zip file
Compress-Archive -Path "$saveFolder\*" -DestinationPath $zipPath -Force

Write-Host "Cleaning up the temporary folder and Python script..." -ForegroundColor Cyan
# Delete the unzipped original folder and the python script to keep the machine clean
Remove-Item -Path $saveFolder -Recurse -Force
Remove-Item -Path $pythonScriptPath -Force

Write-Host "`nAll done! Images were safely zipped and raw files were deleted." -ForegroundColor Green
Write-Host "Your zip file containing both screenshots and webcam images is located here:" -ForegroundColor Yellow
Write-Host $zipPath -ForegroundColor White
