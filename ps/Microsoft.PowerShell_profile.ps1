. $PSScriptRoot/consts.ps1
. $PSScriptRoot/utils.ps1
. $PSScriptRoot/git.ps1
. $PSScriptRoot/prompt.ps1
. $PSScriptRoot/user.ps1

Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

New-Alias grep findstr

function Last-Error { $error[0].Exception.ToString() }
function List-Env {	gci env:* }

function Unicode-Char {
	param ([string] $id)
	$i = [convert]::toint32($id, 16)
	Write-Host "$([char]$i) - $i"
}

function forest {
	param ([int] $c=20)
	for($i=0; $i -lt $c; $i+=1) {
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
	if ($global:_cpy -eq $null) {
		Write-Host "No file to paste" -Fore Red
		return
	}
	$dest = [string](Get-Location)
	if (!($n -eq $null)) {
		$dest += "\" + $n
	}

	Copy-Item -Path $global:_cpy -Destination $dest
}

function Add-To-Path {
	param ([string]$addPath)
    if (Test-Path $addPath) {
        $regexAddPath = [regex]::Escape($addPath)
        $arrPath = $env:Path -split ';' | Where-Object {$_ -notMatch "^$regexAddPath\\?"}
        $env:Path = ($arrPath + $addPath) -join ';'
    }
    else {
        Throw "'$addPath' is not a valid path."
    }
}