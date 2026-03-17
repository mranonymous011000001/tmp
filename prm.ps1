# Load required .NET assemblies for screen capture
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Set up paths in the TEMP directory for the folder and the final zip file
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$saveFolder = Join-Path -Path $env:TEMP -ChildPath "Screenshots_$timestamp"
$zipPath = Join-Path -Path $env:TEMP -ChildPath "Screenshots_$timestamp.zip"

# Create the temporary folder
New-Item -ItemType Directory -Force -Path $saveFolder | Out-Null

# Function to take a single screenshot
function Take-Screenshot {
    param ([string]$FileName)
    
    # Get the screen resolution
    $bounds =[System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    
    # Create a bitmap object to hold the image
    $bitmap = New-Object System.Drawing.Bitmap $bounds.Width, $bounds.Height
    $graphics =[System.Drawing.Graphics]::FromImage($bitmap)
    
    # Capture the screen
    $graphics.CopyFromScreen($bounds.Location, [System.Drawing.Point]::Empty, $bounds.Size)
    
    # Save the image as PNG
    $filePath = Join-Path -Path $saveFolder -ChildPath $FileName
    $bitmap.Save($filePath, [System.Drawing.Imaging.ImageFormat]::Png)
    
    # Clean up memory
    $graphics.Dispose()
    $bitmap.Dispose()
    
    Write-Host "Saved: $FileName"
}

Write-Host "Taking the first 5 pre-Chrome screenshots..." -ForegroundColor Cyan
for ($i = 1; $i -le 5; $i++) {
    Take-Screenshot -FileName "01_Pre_Chrome_$i.png"
    Start-Sleep -Seconds 1
}

Write-Host "Opening Google Chrome in new window and fullscreen..." -ForegroundColor Cyan
# We use Start-Process here so the script continues running in the background. 
# Using '&' directly would freeze the script until you closed Chrome.
Start-Process -FilePath "C:\Program Files\Google\Chrome\Application\chrome.exe" -ArgumentList "--new-window", "https://www.xvideos.com/", "--start-fullscreen"

# Give Chrome a few seconds to fully open and render
Start-Sleep -Seconds 3

Write-Host "Taking 20 screenshots of Chrome with a 1-second delay..." -ForegroundColor Cyan
for ($i = 1; $i -le 20; $i++) {
    $num = "{0:D2}" -f $i 
    Take-Screenshot -FileName "02_Chrome_Fullscreen_$num.png"
    Start-Sleep -Seconds 1
}

Write-Host "`nZipping the screenshots folder..." -ForegroundColor Cyan
# Compress the folder into a .zip file
Compress-Archive -Path "$saveFolder\*" -DestinationPath $zipPath -Force

Write-Host "Cleaning up the temporary screenshots folder..." -ForegroundColor Cyan
# Delete the original unzipped folder to clear the temp directory
Remove-Item -Path $saveFolder -Recurse -Force

Write-Host "`nAll done! The folder was zipped and the raw files were deleted." -ForegroundColor Green
Write-Host "Your zip file is saved at the following path:" -ForegroundColor Yellow
Write-Host $zipPath -ForegroundColor White
