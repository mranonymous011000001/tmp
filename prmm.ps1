# We use C# to access the native Windows API (user32.dll) to force-minimize windows
$Win32API = @"
using System;
using System.Runtime.InteropServices;
public class WindowHelper {
    [DllImport("user32.dll")]
    public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
    
    [DllImport("user32.dll")]
    public static extern IntPtr GetForegroundWindow();
}
"@

# Only add the type if it hasn't been added yet (prevents errors if you run the script twice)
if (-not ([System.Management.Automation.PSTypeName]'WindowHelper').Type) {
    Add-Type -TypeDefinition $Win32API
}

# Define the path to Chrome
$chromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
if (-not (Test-Path $chromePath)) {
    $chromePath = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
}

# List of websites you want to open in the new window
$websites = @(
"https://spankbang.com/a46ck/video/pure+taboo+religious+conservative+virgin+lexi+lore+succumbs+to+anal+while+waiting+for+marriage",
"https://www.spankbang.com",
"https://www.xvideos9.com/gozando-na-esposa/",
"https://www.pornhat.com"
)

# Join the URLs into a single space-separated string
$urlArguments = $websites -join " "

Write-Host "Opening a new Chrome window with $($websites.Count) tabs..." -ForegroundColor Cyan

# Launch Chrome
Start-Process -FilePath $chromePath -ArgumentList "--new-window $urlArguments"

Write-Host "Waiting for Chrome to load, then forcing minimize..." -ForegroundColor Yellow
# Give Chrome just enough time to open and become the active window (Adjust to 2 seconds if your PC is slower)
Start-Sleep -Seconds 1.5

# Get the handle of the currently active window (which is the Chrome window that just popped up)
$hwnd = [WindowHelper]::GetForegroundWindow()

# 2 = SW_SHOWMINIMIZED in the Windows API. This forces the window down to the taskbar.
[WindowHelper]::ShowWindowAsync($hwnd, 2) | Out-Null

Write-Host "Chrome launched and successfully minimized!" -ForegroundColor Green
