# Transparent Lockscreen uninstaller
# Usage (PowerShell):  irm https://naeembolchhi.github.io/transparent-lockscreen/uninstall.ps1 | iex

# --- Settings -------------------------------------------------------------
$BaseUrl  = 'https://naeembolchhi.github.io/transparent-lockscreen'
$AppName  = 'Transparent Lockscreen'
$TaskName = 'ShowTaskbarOnUnlock'

# Enable TLSv1.2 for compatibility with older clients
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

# --- Elevation (the shortcut and folder live in ProgramData) ---------------
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$isAdmin  = ([Security.Principal.WindowsPrincipal]$identity).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host 'Administrator rights are required. Requesting elevation...' -ForegroundColor Yellow
    $cmd = "irm '$BaseUrl/uninstall.ps1' | iex"
    try {
        Start-Process powershell.exe -Verb RunAs -ArgumentList '-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', $cmd
    } catch {
        Write-Error 'Elevation was cancelled. Nothing was removed.'
    }
    return
}

$Root    = Join-Path $env:ProgramData $AppName
$Thide   = Join-Path $Root 'thide\thide.exe'
$LnkPath = Join-Path $env:ProgramData 'Microsoft\Windows\Start Menu\Programs\Lock Desktop.lnk'

# 1. Start Menu shortcut
if (Test-Path $LnkPath) {
    Remove-Item -Path $LnkPath -Force -ErrorAction SilentlyContinue
    Write-Host 'Removed Start Menu shortcut.'
}

# 2. Scheduled task
if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
    Write-Host "Removed scheduled task '$TaskName'."
}

# 3. Stop thide (also restores the taskbar)
if (Test-Path $Thide) {
    try { & $Thide stop *> $null } catch {}
    Start-Sleep -Seconds 1
    Write-Host 'Stopped thide.'
}

# 4. Delete the whole folder
if (Test-Path $Root) {
    try {
        for ($i = 0; $i -lt 5; $i++) {
            try { Remove-Item -Path $Root -Recurse -Force -ErrorAction Stop; break }
            catch { if ($i -eq 4) { throw }; Start-Sleep -Seconds 1 }
        }
        Write-Host "Deleted $Root"
    } catch {
        Write-Error "Could not delete $Root : $_"
        return
    }
}

Write-Host "$AppName has been uninstalled." -ForegroundColor Green
