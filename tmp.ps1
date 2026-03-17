# Target URL
$url = "https://wispy-sunset-a7c0.anox.workers.dev/test"

Write-Host "[*] Checking endpoint..." -ForegroundColor Cyan

try {
    $response = Invoke-WebRequest -Uri $url -Method GET -TimeoutSec 10
    $status = "UP"
    $statusCode = $response.StatusCode
    Write-Host "[+] Server reachable (Status: $statusCode)" -ForegroundColor Green
}
catch {
    $status = "DOWN"
    $statusCode = "N/A"
    Write-Host "[-] Server not reachable" -ForegroundColor Red
}

# Prepare JSON body
$body = @{
    status     = $status
    statusCode = $statusCode
    timestamp  = (Get-Date).ToString("o")
} | ConvertTo-Json -Depth 3

Write-Host "[*] Sending POST request..." -ForegroundColor Cyan

try {
    $postResponse = Invoke-RestMethod -Uri $url `
        -Method POST `
        -Body $body `
        -ContentType "application/json" `
        -Headers @{
            "User-Agent" = "Mozilla/5.0"
        }

    Write-Host "[+] POST Success:" -ForegroundColor Green
    $postResponse | ConvertTo-Json -Depth 5
}
catch {
    Write-Host "[-] POST failed (detailed):" -ForegroundColor Red
    $_ | Format-List * -Force
}
