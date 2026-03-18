$pidToKill = 23332

try {
    Stop-Process -Id $pidToKill -Force -ErrorAction Stop
    Write-Output "Process $pidToKill terminated successfully."
}
catch {
    Write-Output "Failed to terminate process $pidToKill. Error: $_"
}
