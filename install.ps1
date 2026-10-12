# Transparent Lockscreen installer
# Usage (PowerShell):  irm https://naeembolchhi.github.io/transparent-lockscreen/install.ps1 | iex

# --- Settings -------------------------------------------------------------
$BaseUrl  = 'https://naeembolchhi.github.io/transparent-lockscreen'
$AppName  = 'Transparent Lockscreen'
$TaskName = 'ShowTaskbarOnUnlock'

$Files = @(
    'lock-desktop.vbs',
    'lock-desktop.bat',
    'hide-taskbar.vbs',
    'hide-taskbar.bat',
    'unhide-taskbar.vbs',
    'unhide-taskbar.bat',
    'icon/lock.ico',
    'lockscreen/Invisble.Lock.Screen.scr',
    'desktopicons/DesktopIcons.ps1',
    'nircmd/nircmd.exe',
    'thide/thide.exe',
    'thide/LICENSE.txt',
    'thide/README-PORTABLE.txt'
)

# Enable TLSv1.2 for compatibility with older clients
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12
$ProgressPreference = 'SilentlyContinue'

# --- Elevation (needed for ProgramData and the all-users Start Menu) -------
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$isAdmin  = ([Security.Principal.WindowsPrincipal]$identity).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host 'Administrator rights are required. Requesting elevation...' -ForegroundColor Yellow
    $cmd = "irm '$BaseUrl/install.ps1' | iex"
    try {
        Start-Process powershell.exe -Verb RunAs -ArgumentList '-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', $cmd
    } catch {
        Write-Error 'Elevation was cancelled. Nothing was installed.'
    }
    return
}

$ErrorActionPreference = 'Stop'
$Root      = Join-Path $env:ProgramData $AppName
$Thide     = Join-Path $Root 'thide\thide.exe'
$LockVbs   = Join-Path $Root 'lock-desktop.vbs'
$LockIcon  = Join-Path $Root 'icon\lock.ico'
$UnhideVbs = Join-Path $Root 'unhide-taskbar.vbs'

try {
    # --- Remove any previous install ----------------------------------------
    if (Test-Path $Thide) {
        try { & $Thide stop *> $null } catch {}   # also restores the taskbar
        Start-Sleep -Seconds 1
    }
    if (Test-Path $Root) {
        for ($i = 0; $i -lt 5; $i++) {
            try { Remove-Item -Path $Root -Recurse -Force -ErrorAction Stop; break }
            catch { if ($i -eq 4) { throw }; Start-Sleep -Seconds 1 }
        }
    }

    # --- Download files -----------------------------------------------------
    New-Item -Path $Root -ItemType Directory -Force | Out-Null
    foreach ($rel in $Files) {
        $dest = Join-Path $Root ($rel -replace '/', '\')
        New-Item -Path (Split-Path $dest) -ItemType Directory -Force | Out-Null
        Write-Host "Downloading $rel"
        Invoke-WebRequest -Uri "$BaseUrl/$rel" -UseBasicParsing -OutFile $dest
    }

    # --- Start Menu shortcut (All Programs) ---------------------------------
    $lnkPath = Join-Path $env:ProgramData 'Microsoft\Windows\Start Menu\Programs\Lock Desktop.lnk'
    $shell = New-Object -ComObject WScript.Shell
    $lnk = $shell.CreateShortcut($lnkPath)
    $lnk.TargetPath       = $LockVbs
    $lnk.WorkingDirectory = $Root
    $lnk.IconLocation     = "$LockIcon,0"
    $lnk.Description      = 'Lock the PC while keeping the desktop visible'
    $lnk.Save()
    [void][Runtime.InteropServices.Marshal]::ReleaseComObject($shell)

    # --- Scheduled task: restore the taskbar when the workstation unlocks ---
    $trigger = Get-CimClass -ClassName MSFT_TaskSessionStateChangeTrigger -Namespace Root/Microsoft/Windows/TaskScheduler |
               New-CimInstance -ClientOnly
    $trigger.StateChange = 8   # 8 = Workstation Unlock

    $action   = New-ScheduledTaskAction -Execute 'wscript.exe' -Argument "`"$UnhideVbs`"" -WorkingDirectory $Root
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

    Register-ScheduledTask -TaskName $TaskName `
                           -Trigger $trigger `
                           -Action $action `
                           -Settings $settings `
                           -User $identity.Name `
                           -Force | Out-Null

    Write-Host ''
    Write-Host "$AppName installed to: $Root" -ForegroundColor Green
    Write-Host "Start Menu shortcut:   Lock Desktop" -ForegroundColor Green
    Write-Host "Scheduled task:        $TaskName (runs on unlock)" -ForegroundColor Green
} catch {
    Write-Error "Installation failed: $_"
}
