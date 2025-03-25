. $PSScriptRoot/consts.ps1
. $PSScriptRoot/utils.ps1
. $PSScriptRoot/git.ps1
. $PSScriptRoot/prompt.ps1
. $PSScriptRoot/wt.ps1
. $PSScriptRoot/themes.ps1

Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

New-Alias grep findstr

$shell = [PSCustomObject] @{
	Git             = [PSCustomObject] @{
		Enabled      = $true
		BranchInfo   = $true
		TrackingInfo = $true
	}
	Time            = [PSCustomObject] @{
		Enabled  = $true
		Format24 = $true
	}
	Host            = [PSCustomObject] @{
		Enabled     = $true
		UserName    = $true
		MachineName = $true
		PSVersion   = $true
	}
	Path            = [PSCustomObject] @{
		Enabled = $true
	}
	Dir             = [PSCustomObject] @{
		Enabled = $true
		Count   = $true
		Flags   = $true
	}
	MultilinePrompt = $false
}

function forest {
	param ([int] $c = 20)
	for ($i = 0; $i -lt $c; $i += 1) {
		Write-Host "$([char]61883) " -NoNewLine -Fore DarkGreen
	}
}

$_cpy = $null
function copyfile {
	param([string] $path)
	$global:_cpy = Resolve-Path $path

}
function pastefile {
	param(
		[switch] $f,
		[string] $n = $null
	)
	if ($null -eq $global:_cpy) {
		Write-Host "No file to paste" -Fore Red
		return
	}
	$dest = [string](Get-Location)
	if (!($n -eq $null)) {
		$dest += "\" + $n
	}

	Copy-Item -Path $global:_cpy -Destination $dest
}
