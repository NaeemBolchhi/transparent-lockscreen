@echo off
set "dir=%ProgramData%\Transparent Lockscreen"

"%dir%\nircmd\nircmd.exe" sendkeypress rwin+m

"%dir%\thide\thide.exe" start

"%dir%\thide\thide.exe" hide

timeout 1

"%dir%\lockscreen\Invisble.Lock.Screen.scr" /s
