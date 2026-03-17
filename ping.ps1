$endTime = (Get-Date).AddMinutes(4)

while ((Get-Date) -lt $endTime) {
    if (Test-Connection 192.168.29.20 -Count 1 -Quiet) {
        Write-Host "UP"
    } else {
        Write-Host "DOWN"
    }
    Start-Sleep -Seconds 1
}
