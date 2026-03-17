# --- Configuration ---
$BaseUrl    = "http://192.168.29.20"
$UserAgent  = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
$Cookie     = "lock=; path=/schoolexpert,lastFY=2025; path=/schoolexpert,fy=2025; path=/schoolexpert,userno=1; path=/schoolexpert"
$Timeout    = 120 # <--- THIS WAS MISSING
$OutputFile = Join-Path $env:TEMP "Protocol_Analysis_$(Get-Date -Format 'yyyyMMdd_HHmm').json"

$Paths = @(
    "/schoolexpertnew/logout.asp",
    "/schoolExpert/default.asp",
    "/schoolexpertnew/modules.asp",
    "/schoolExpertnew/logout.php",
    "/schoolexpertnew/modules.php",
    "/schoolExpertnew/dashboard.asp",
    "/schoolexpertnew/dashboard.php",
    "/schoolexpertnew/top.asp",
    "/schoolexpertnew/top.php",
    "/schoolexpert/logout.asp"
    
)

$RequestHeaders = @{
    "User-Agent"      = $UserAgent
    "Cookie"          = $Cookie
    "Referer"         = "$BaseUrl/schoolexpert"
    "Accept"          = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
    "Accept-Language" = "en-US,en;q=0.5"
}

$AllTransactionLogs = @()

Write-Host "--- ADVANCED PROTOCOL EXTRACTION STARTING ---" -ForegroundColor Cyan

foreach ($Path in $Paths) {
    $FullUrl = "$BaseUrl$Path"
    $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    
    $LogEntry = [ordered]@{
        metadata = @{
            url          = $FullUrl
            timestamp    = (Get-Date).ToString("o")
            method       = "GET"
        }
        request = @{
            headers      = $RequestHeaders
        }
        response = @{
            status_code  = 0
            status_desc  = ""
            latency_ms   = 0
            headers      = @{}
            set_cookie   = @()
            body_base64  = ""
            size_bytes   = 0
        }
        error = $null
    }

    try {
        # Execute Request
        $Resp = Invoke-WebRequest -Uri $FullUrl -Headers $RequestHeaders -Method Get -UseBasicParsing -TimeoutSec $Timeout -ErrorAction Stop
        $Stopwatch.Stop()

        # Capture Response Details
        $LogEntry.response.status_code =[int]$Resp.StatusCode
        $LogEntry.response.status_desc = $Resp.StatusDescription
        $LogEntry.response.latency_ms  = $Stopwatch.ElapsedMilliseconds
        
        # Capture ALL Response Headers
        foreach ($h in $Resp.Headers.GetEnumerator()) {
            $LogEntry.response.headers.Add($h.Key, $h.Value)
            # Specifically track cookie changes
            if ($h.Key -eq "Set-Cookie") { $LogEntry.response.set_cookie += $h.Value }
        }

        # Encode Body
        $ContentBytes = $Resp.Content
        if ($ContentBytes -is [string]) { $ContentBytes = [System.Text.Encoding]::UTF8.GetBytes($ContentBytes) }
        $LogEntry.response.body_base64 = [Convert]::ToBase64String($ContentBytes)
        $LogEntry.response.size_bytes  = $ContentBytes.Length

        Write-Host "[$($LogEntry.response.status_code)] $($LogEntry.response.latency_ms)ms - $Path" -ForegroundColor Green

    } catch {
        $Stopwatch.Stop()
        $LogEntry.error = $_.Exception.Message
        if ($_.Exception.Response) {
            $LogEntry.response.status_code = [int]$_.Exception.Response.StatusCode
        }
        Write-Host "[ERR] $Path - $($LogEntry.error)" -ForegroundColor Red
    }

    $AllTransactionLogs += $LogEntry
}

# Final Save
try {
    $FinalJson = $AllTransactionLogs | ConvertTo-Json -Depth 20
    $FinalJson | Set-Content -Path $OutputFile -Encoding UTF8
    
    Write-Host "`nAnalysis Finished Successfully." -ForegroundColor Cyan
    Write-Host "Full Protocol Log: " -NoNewline
    Write-Host $OutputFile -ForegroundColor Yellow
} catch {
    Write-Host "Critical Save Failure: $($_.Exception.Message)" -ForegroundColor Red
}
