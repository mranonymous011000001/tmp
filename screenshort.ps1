# Load required .NET assemblies for screen capture
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create a unique file name using the current date and time
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$filePath = Join-Path -Path $env:TEMP -ChildPath "Screenshot_$timestamp.png"

# Get the screen resolution of the primary monitor
$bounds =[System.Windows.Forms.Screen]::PrimaryScreen.Bounds

# Create bitmap and graphics objects
$bitmap = New-Object System.Drawing.Bitmap $bounds.Width, $bounds.Height
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)

# Capture the screen
$graphics.CopyFromScreen($bounds.Location,[System.Drawing.Point]::Empty, $bounds.Size)

# Save the screenshot to the file
$bitmap.Save($filePath, [System.Drawing.Imaging.ImageFormat]::Png)

# Clean up memory
$graphics.Dispose()
$bitmap.Dispose()

# Print the file path
Write-Host "Screenshot successfully saved to:" -ForegroundColor Green
Write-Host $filePath -ForegroundColor Cyan
