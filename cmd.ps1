param (
    [Parameter(Mandatory=$true)]
    [string]$Command
)

# Create a hidden process
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = "powershell.exe"
$psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -Command $Command"
$psi.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
$psi.CreateNoWindow = $true
$psi.UseShellExecute = $false
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError = $true

$process = New-Object System.Diagnostics.Process
$process.StartInfo = $psi

$process.Start() | Out-Null

# Capture output (optional)
$output = $process.StandardOutput.ReadToEnd()
$error  = $process.StandardError.ReadToEnd()

$process.WaitForExit()

# Print to current console (if script is run interactively)
if ($output) { Write-Output $output }
if ($error)  { Write-Output $error }
