# env
Scripts to deploy my dev env

https://github.com/powerline/fonts \
https://github.com/felixse/FluentTerminal/releases \
https://github.com/ppadial/winfetch \
https://github.com/JanDeDobbeleer/oh-my-posh \

get latest release \
https://gist.github.com/f3l3gy/0e89dde158dde024959e36e915abf6bd

dev mode \
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" /t REG_DWORD /f /v "AllowDevelopmentWithoutDevLicense" /d "1"

wsl2 \
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart \
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

install chocolatey \
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072 \
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

get disk space \
https://stackoverflow.com/questions/12159341/how-to-get-disk-capacity-and-free-space-of-remote-computer

poshgit status \
https://github.com/dahlbyk/posh-git#git-status-summary-information

## master...origin/master \
 M README.md      <- unstaged \
M  profile.ps1    <- staged