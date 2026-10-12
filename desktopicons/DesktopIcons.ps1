<#
  DesktopIcons.ps1 - decisively hide / show / query desktop icons.
  Usage:  powershell -NoProfile -ExecutionPolicy Bypass -File DesktopIcons.ps1 hide|show|toggle|status
  Exit code for "status": 0 = icons visible, 1 = icons hidden, 2 = desktop list view not found.
#>
param([Parameter(Mandatory)][ValidateSet('hide','show','toggle','status')][string]$Action)

Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class DI {
  delegate bool EnumProc(IntPtr h, IntPtr l);
  [DllImport("user32.dll")] static extern bool EnumWindows(EnumProc p, IntPtr l);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] static extern IntPtr FindWindow(string c, string t);
  [DllImport("user32.dll", CharSet=CharSet.Unicode)] static extern IntPtr FindWindowEx(IntPtr p, IntPtr a, string c, string t);
  [DllImport("user32.dll")] static extern bool IsWindowVisible(IntPtr h);
  [DllImport("user32.dll")] static extern bool ShowWindow(IntPtr h, int cmd);

  // Desktop icons live in SysListView32 ("FolderView") inside SHELLDLL_DefView.
  // DefView is a child of Progman normally, or of a WorkerW window when a
  // wallpaper slideshow / Win7+ desktop composition is active.
  public static IntPtr GetListView() {
    IntPtr view = FindWindowEx(FindWindow("Progman", "Program Manager"), IntPtr.Zero, "SHELLDLL_DefView", null);
    if (view == IntPtr.Zero) {
      EnumWindows((h, l) => {
        IntPtr v = FindWindowEx(h, IntPtr.Zero, "SHELLDLL_DefView", null);
        if (v != IntPtr.Zero) { view = v; return false; }
        return true;
      }, IntPtr.Zero);
    }
    return view == IntPtr.Zero ? IntPtr.Zero : FindWindowEx(view, IntPtr.Zero, "SysListView32", null);
  }
  public static bool Visible(IntPtr lv) { return IsWindowVisible(lv); }
  public static void Set(IntPtr lv, bool show) { ShowWindow(lv, show ? 4 : 0); } // SW_SHOWNOACTIVATE / SW_HIDE
}
'@

$lv = [DI]::GetListView()
if ($lv -eq [IntPtr]::Zero) { Write-Error 'Desktop icon list view not found'; exit 2 }
$visible = [DI]::Visible($lv)

switch ($Action) {
  'hide'   { if ($visible)  { [DI]::Set($lv, $false) } }
  'show'   { if (-not $visible) { [DI]::Set($lv, $true) } }
  'toggle' { [DI]::Set($lv, -not $visible) }
  'status' { }
}
$now = [DI]::Visible($lv)
Write-Output ($(if ($now) { 'visible' } else { 'hidden' }))
exit ($(if ($now) { 0 } else { 1 }))
