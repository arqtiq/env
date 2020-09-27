## ARG
$step = $args[0].Trim("-")
if($step -eq "help") {
	Write-Host "terminal > Fluent Terminal"
	Write-Host "profile > PowerShell Profile"
	Write-Host "font > FiraCode NF Font"
    exit
}
elseif($step -eq $null) {
	$step = "all"
}

## CONSTS
$fluent_terminal = "https://github.com/felixse/FluentTerminal/releases/download/0.7.2.0/FluentTerminal.Package_0.7.2.0_Test.zip"

## DEPLOY
# set working dir
$cwd = Split-Path $MyInvocation.MyCommand.Path -Parent
Set-Location $cwd

# make sur /tmp doesnt exists
$tmp = $cwd + "/tmp/"
ri ./tmp -Force -Recurse -ErrorAction SilentlyContinue 

# create /tmp
md $tmp | Out-Null

# download + install FluentTerminal
if($step -eq "all" -or $step -eq "terminal") {
	$zip = $tmp + "ft.zip"
	(New-Object System.Net.WebClient).DownloadFile($fluent_terminal, $zip)
	Expand-Archive $zip -Force -DestinationPath $tmp
	& "$tmp/Install.ps1"
}

# install PS profile
if($step -eq "all" -or $step -eq "profile") {
	$target = "~/Documents/WindowsPowerShell/"
	md $target -ErrorAction SilentlyContinue

	$core = $cwd + "/ps/core.ps1"
	(". " + $core) >> ($target + "Microsoft.PowerShell_profile.ps1")
	# add vscode profile
	('. $' + "PSScriptRoot/Microsoft.PowerShell_profile.ps1") >> ($target + "Microsoft.PowerShell_VSCode_profile.ps1")
}

# install font
if($step -eq "all" -or $step -eq "font") {
	& '.\Fira Code NF.otf'
}

# clean /tmp
#ri -Force -Recurse ./tmp
