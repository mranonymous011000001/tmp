# Ensure OpenCV is installed quietly
python -m pip install opencv-python --quiet

# Define the paths in the TEMP directory
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$imagePath = Join-Path -Path $env:TEMP -ChildPath "Webcam_Single_$timestamp.png"
$pythonScriptPath = Join-Path -Path $env:TEMP -ChildPath "webcam_capture_$timestamp.py"

# --- EMBEDDED PYTHON SCRIPT ---
$pythonCode = @"
import cv2
import sys
import time
import os

save_path = sys.argv[1]

print("Initializing webcam...")
cap = cv2.VideoCapture(0)

if not cap.isOpened():
    print("Error: Could not open the webcam.")
    sys.exit(1)

# Warm up the camera sensor (prevents the image from being completely black/dark)
for _ in range(10):
    cap.read()
    time.sleep(0.1)

# Capture the final frame
ret, frame = cap.read()
if ret:
    cv2.imwrite(save_path, frame)
    print("Capture successful!")
else:
    print("Error: Failed to capture the image.")

# Turn off the webcam
cap.release()
"@

# Write the Python script to the Temp folder
$pythonCode | Set-Content -Path $pythonScriptPath -Encoding UTF8

Write-Host "Running Python to capture the webcam image..." -ForegroundColor Cyan
# Execute the Python script, passing the image save path as an argument
python $pythonScriptPath $imagePath

Write-Host "Cleaning up the Python script..." -ForegroundColor Cyan
Remove-Item -Path $pythonScriptPath -Force

Write-Host "`nAll done!" -ForegroundColor Green
Write-Host "Your webcam image is saved here:" -ForegroundColor Yellow
Write-Host $imagePath -ForegroundColor White
