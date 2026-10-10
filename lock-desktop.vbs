Set sh = CreateObject("WScript.Shell")
root = sh.ExpandEnvironmentStrings("%ProgramData%") & "\Transparent Lockscreen"
sh.Run """" & root & "\lock-desktop.bat""", 0, False
