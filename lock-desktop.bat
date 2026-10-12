@echo off
set "dir=%ProgramData%\Transparent Lockscreen"
set "di=%dir%\desktopicons\DesktopIcons.ps1"

:: Resolve the Documents folder (handles OneDrive/redirected folders)
for /f "delims=" %%D in ('powershell -NoProfile -Command "[Environment]::GetFolderPath('MyDocuments')"') do set "docs=%%D"
set "marker=%docs%\transparent-lockscreen-desktop-icons"

:: Desktop icons: exit code 0 = visible, 1 = already hidden, 2 = not found
powershell -NoProfile -ExecutionPolicy Bypass -File "%di%" status >nul 2>&1
if errorlevel 2 goto ICONS_DONE
if errorlevel 1 goto ICONS_ALREADY_HIDDEN

:: Icons are visible: discard any stale marker (as if it never existed), then hide them
if exist "%marker%" del /f /q /a "%marker%"
powershell -NoProfile -ExecutionPolicy Bypass -File "%di%" hide >nul 2>&1
goto ICONS_DONE

:ICONS_ALREADY_HIDDEN
:: Icons were hidden before locking: leave a hidden marker so unlock keeps them hidden
if exist "%marker%" del /f /q /a "%marker%"
<nul set /p "=transparent-lockscreen-desktop-icons" > "%marker%"
attrib +h "%marker%"

:ICONS_DONE
"%dir%\nircmd\nircmd.exe" sendkeypress rwin+m

"%dir%\thide\thide.exe" start

"%dir%\thide\thide.exe" hide

timeout 1

"%dir%\lockscreen\Invisble.Lock.Screen.scr" /s
