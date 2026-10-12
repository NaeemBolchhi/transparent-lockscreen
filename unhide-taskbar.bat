@echo off
set "dir=%ProgramData%\Transparent Lockscreen"
set "di=%dir%\desktopicons\DesktopIcons.ps1"

:: Resolve the Documents folder (handles OneDrive/redirected folders)
for /f "delims=" %%D in ('powershell -NoProfile -Command "[Environment]::GetFolderPath('MyDocuments')"') do set "docs=%%D"
set "marker=%docs%\transparent-lockscreen-desktop-icons"

:: Marker present = icons were already hidden before locking, so keep them hidden.
:: Marker absent  = we hid them, so show them again.
if exist "%marker%" (
    del /f /q /a "%marker%"
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%di%" show >nul 2>&1
)

"%dir%\thide\thide.exe" show
