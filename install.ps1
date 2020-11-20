## ARG
$step = $args[0].Trim("-")
if ($step -eq "help") {
	Write-Host "profile > PowerShell Profile"
	Write-Host "wts > WT Settings"
	Write-Host "font > FiraCode NF Font"
	Write-Host "ext > PowerShell Extensions"
	exit
}
elseif ($null -eq $step) {
	$step = "all"
}

## DEPLOY
# set working dir
$cwd = Split-Path $MyInvocation.MyCommand.Path -Parent
Set-Location $cwd

# make sur /tmp doesnt exists
$tmp = $cwd + "/tmp/"
ri ./tmp -Force -Recurse -ErrorAction SilentlyContinue 
# create /tmp
md $tmp | Out-Null

# install PS profile
if ($step -eq "all" -or $step -eq "profile") {
	$target = "~/Documents/WindowsPowerShell/"
	md $target -ErrorAction SilentlyContinue

	$core = $cwd + "\ps\core.ps1"
	(". " + $core) >> ($target + "Microsoft.PowerShell_profile.ps1")
	# add vscode profile
	('. $' + "PSScriptRoot\Microsoft.PowerShell_profile.ps1") >> ($target + "Microsoft.VSCode_profile.ps1")
}

# install font
if ($step -eq "all" -or $step -eq "font") {
	& '.\Fira Code NF.otf'
}

# install extensions
if ($step -eq "all" -or $step -eq "ext") {
	if (-not(Get-InstalledModule PSBookmark -ErrorAction silentlycontinue)) {
		Install-Module PSBookmark -Confirm:$False -Force
	}
}

# install WT settings
if ($step -eq "all" -or $step -eq "wts") {
	. ($cwd + "\ps\utils.ps1")
	if (-not (Is-Defined WT-GetSettingsPath)) {
		. ($cwd + "\ps\wt.ps1")
	}
	$target = WT-GetSettingsPath
	$source = $cwd + "\settings.json"
	Copy-Item -Path $source -Destination $target
}

# clean /tmp
#ri -Force -Recurse ./tmp
