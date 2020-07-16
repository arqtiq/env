## consts

$fluent_terminal = "https://github.com/felixse/FluentTerminal/releases/download/0.7.1.0/FluentTerminal.Package_0.7.1.0.zip"

## deploy

# force working dir
$cwd = Split-Path $MyInvocation.MyCommand.Path -Parent
Set-Location $cwd

# make sur /tmp doesnt exists
$tmp = $cwd + "/tmp/"
ri ./tmp -Force -Recurse -ErrorAction SilentlyContinue 

# create /tmp
md $tmp | Out-Null
cd tmp

# download + install FluentTerminal
$zip = $tmp + "ft.zip"
(New-Object System.Net.WebClient).DownloadFile($fluent_terminal, $zip)
Expand-Archive $zip -Force
& "$tmp/ft/Install"

# install PS profile
md ~/Documents/WindowsPowerShell -ErrorAction SilentlyContinue
Copy-Item profile.ps1 ~/Documents/WindowsPowerShell/Microsoft.PowerShell_profile.ps1

# install font
& '.\Fira Code NF.otf'

# clean /tmp
#ri -Force -Recurse ./tmp

# back to working dir
Set-Location $cwd