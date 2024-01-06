# Zig Win Install

That's a simple powershell script to install / update the zig master version on your windows.

This script download the 'master' version of zig and update the PATH of the current user.
The destination folder is in C:\Users\%username%\AppData\Local\zig\zig-windows-x86_64-%version%

⚠️ Use it at your own risk.

```Powershell
Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/fhusson/zig-win-install/main/zig_install.ps1')
```
