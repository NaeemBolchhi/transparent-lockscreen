# Transparent Lockscreen
A transparent lockscreen for Windows so your live wallpaper keeps running.

This tool can lock Windows while keeping the desktop visible: minimizes windows, hides the taskbar, and starts an invisible lock screen. The taskbar returns automatically when you unlock.

## Install
Open PowerShell and run:
```
irm https://naeembolchhi.github.io/transparent-lockscreen/install.ps1 | iex
```
It installs to `%ProgramData%\Transparent Lockscreen`, adds a **Lock Desktop** shortcut to the Start Menu, and registers a scheduled task (`ShowTaskbarOnUnlock`) that restores the taskbar on unlock.

## Uninstall
```
irm https://naeembolchhi.github.io/transparent-lockscreen/uninstall.ps1 | iex
```
Removes the Start Menu shortcut and scheduled task, stops thide (restoring the taskbar), and deletes `%ProgramData%\Transparent Lockscreen`.

## Credits
- [Invisible Lock Screen](https://github.com/billiegoose/lock-screen) by billiegoose
- [thide](https://github.com/amnweb/thide) by amnweb
- [NirCmd](https://www.nirsoft.net/utils/nircmd.html) by NirSoft
- [Padlock Icon](https://www.flaticon.com/free-icon/padlocks_1102092) by Flaticon

## License
The scripts in this project are licensed AGPL-3.0. However, this does not apply to the resources mentioned in **Credits**. Licenses for those projects can be found in their respective sources.