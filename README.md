# env

## todo

PS Object Manager \
WT-* functions with dedicated ps1 file for windows terminal (set font ...) \
Handle prompt parts removal \
Use consts for all colors \
Multiline prompt option \
Copy WT settings file

## notes

dev mode \
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1"

wsl2 \
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart \
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

install chocolatey \
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072 \
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

get os/system/disk info \
Get-CimInstance Win32_OperatingSystem \
Get-CimInstance Win32_ComputerSystem \
Get-CimInstance Win32_LogicalDisk