Set sh = CreateObject("WScript.Shell")
root = sh.ExpandEnvironmentStrings("%ProgramData%") & "\Transparent Lockscreen"
sh.Run """" & root & "\hide-taskbar.bat""", 0, False
