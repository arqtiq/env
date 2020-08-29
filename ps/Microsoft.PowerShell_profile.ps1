. $PSScriptRoot/consts.ps1
. $PSScriptRoot/git.ps1
. $PSScriptRoot/prompt.ps1
. $PSScriptRoot/custom.ps1

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
		Write-Host "$([char]61883) " -NoNewLine -Fore Green
	}
}

$global:_cpy = $null
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

function Watch-Path {
	param (
		[string] $path="./",
	    [switch] $recurse,
	    [string] $filter="*.*"
    )

	$filewatcher = New-Object System.IO.FileSystemWatcher
    $filewatcher.Path = $path
    $filewatcher.Filter = $filter
    $filewatcher.IncludeSubdirectories = $recurse.IsPresent
    $filewatcher.EnableRaisingEvents = $true

	$writeaction = {
		$path = $Event.SourceEventArgs.FullPath
	    $changeType = $Event.SourceEventArgs.ChangeType
	    $logline = "$(Get-Date), $changeType, $path"
	    Write-Host $logline
	}

	Register-ObjectEvent $filewatcher "Created" -Action $writeaction | Out-Null
    Register-ObjectEvent $filewatcher "Changed" -Action $writeaction | Out-Null
    Register-ObjectEvent $filewatcher "Deleted" -Action $writeaction | Out-Null
    Register-ObjectEvent $filewatcher "Renamed" -Action $writeaction | Out-Null
    
    while ($true) {sleep 5}
}
