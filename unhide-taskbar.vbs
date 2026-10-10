Set sh = CreateObject("WScript.Shell")
root = sh.ExpandEnvironmentStrings("%ProgramData%") & "\Transparent Lockscreen"
sh.Run """" & root & "\unhide-taskbar.bat""", 0, False
