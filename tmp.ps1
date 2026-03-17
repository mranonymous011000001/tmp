# Target URL
$url = "https://wispy-sunset-a7c0.anox.workers.dev/"

Write-Host "[*] Checking endpoint..." -ForegroundColor Cyan

try {
    # Step 1: GET request (like ping)
    $response = Invoke-WebRequest -Uri $url -Method GET -UseBasicParsing -TimeoutSec 10

    $status = "UP"
    $statusCode = $response.StatusCode

    Write-Host "[+] Server is reachable (Status: $statusCode)" -ForegroundColor Green
}
catch {
    $status = "DOWN"
    $statusCode = $_.Exception.Response.StatusCode.value__ 2>$null

    Write-Host "[-] Server is not reachable" -ForegroundColor Red
}

# Step 2: Prepare POST data
$body = @{
    status     = $status
    statusCode = $statusCode
    timestamp  = (Get-Date).ToString("o")
} | ConvertTo-Json

Write-Host "[*] Sending POST request..." -ForegroundColor Cyan

try {
    $postResponse = Invoke-WebRequest -Uri $url -Method POST -Body $body -ContentType "application/json"

    Write-Host "[+] POST Response:" -ForegroundColor Green
    Write-Output $postResponse.Content
}
catch {
    Write-Host "[-] POST request failed" -ForegroundColor Red
    Write-Output $_
}
