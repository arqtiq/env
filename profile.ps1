$git_installed = (Get-Command -ErrorAction SilentlyContinue git) -ne $null

New-Alias grep findstr

function gs { git status -sb }
function gb { git branch $args }
function gco { git checkout $args }
Remove-Item Alias:gc -Force
function gc {
	git checkout $args
	git fetch > $null
}
Remove-Item Alias:gcm -Force
function gcm { gc master }

function Last-Error { $error[0].Exception.ToString() }
function List-Env {	gci env:* }

function Unicode-Char {
	param ([string] $id)
	$i = [convert]::toint32($id, 16)
	Write-Host "$([char]$i) - $i"
}

$_cpy = $null
function copyfile {
	param([string] $path)
	$_cpy = Resolve-Path $path

}
function pastefile {
	param(
		[switch] $f,
		[string] $n = $null
	)
	if ($_cpy -eq $null) {
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

function prompt {
	$arr = $([char]57520)
	$psv = $ExecutionContext.Host.Version

	$cwd = [string](Get-Location) -replace [Regex]::Escape($HOME), "~"
	$p = $cwd.Split("\\").Where({ "" -ne $_ })
	$hs = $p[0] -eq "~"

	# time
	$h = [string](Get-Date -Format "HH:mm")
	Write-Host "$h" -NoNewLine -Fore Black -Back White
	Write-Host $([char]57532) -NoNewLine -Fore White
	Write-Host $([char]57530) -NoNewLine -Fore DarkBlue

	# host
	Write-Host " " -NoNewLine
	Write-Host "$env:USERNAME $([char]61818) $env:COMPUTERNAME" -NoNewline -Fore White -Back DarkBlue
	Write-Host $arr -NoNewline -Fore DarkBlue -Back Blue

	Write-Host "PS$($psv.Major).$($psv.Minor)" -NoNewline -Fore White -Back Blue

	$dc = if($hs) {"White"} else {"Green"}
	Write-Host $arr -NoNewline -Fore Blue -Back $dc

	# cwd
	$dropbox = $p.Contains("Dropbox")
	
	Write-Host $p[0] -NoNewline -Fore Black -Back $dc

	if($p.Count -eq 1) {
		Write-Host $arr -NoNewline -Fore $dc -Back Yellow
	}
	elseif($p.Count -eq 2) {
		Write-Host $arr -NoNewline -Fore $dc -Back Red
		Write-Host $p[1] -NoNewline -Fore Black -Back Red
	}
	else {
		Write-Host $arr -NoNewline -Fore $dc -Back White
		For($i=1; $i -lt $p.Count - 1; $i++) {
			$s = $p[$i].SubString(0, [math]::min(2, $p[$i].Length))
			if($s -eq ".") {
				$s += $p[$i][1]
			}
			if($i -gt 1) {
				$s = "/" + $s
			}
			Write-Host $s -NoNewline -Fore Black -Back White
		}
		Write-Host $arr -NoNewline -Fore White -Back Red
		Write-Host $p[$p.Count-1] -NoNewline -Fore Black -Back Red

		if ($env:VIRTUAL_ENV) {
			Write-Host "$([char]57909) " -NoNewline -Fore Black -Back Red
		}
		if ((Test-Path ./.vs/) -or (Test-Path ./.vscode/)) {
			Write-Host " $([char]59148) " -NoNewline -Fore Black -Back Red
		}	
	}
	if($p.Count -gt 1) {
		Write-Host $arr -NoNewline -Fore Red -Back Yellow
	}

	# dirs / file
	$dc = (Get-ChildItem -Directory).Length
	$fc = (Get-ChildItem -File).Length
	$dir = if($dropbox) { 61803 } else { 61564 }
	Write-Host "$([char]$dir) " -NoNewline -Fore Black -Back Yellow
	Write-Host "$dc" -NoNewline -Fore Black -Back Yellow
	Write-Host $([char]57521) -NoNewline -Fore Black -Back Yellow
	Write-Host "$fc" -NoNewline -Fore Black -Back Yellow

	# git
	if($git_installed) {
		$in_git = (git rev-parse --is-inside-work-tree 2> $null) -eq "true"
		if($in_git) {
			Write-Host $arr -NoNewline -Fore Yellow -Back Blue
			# git type
			$o = (git config --get remote.origin.url)
			$or = if($o.Contains("github")) { 63395 } else { 61907 }
			Write-Host "$([char]$or) " -NoNewline -Fore Black -Back Blue
			# state
			$sta = (git status --porcelain -b)
			$changes = $sta -is [array]
			$header = if($changes) {$sta[0]} else {$sta}
			$rgx = "(?<branch>\w+)\.\.\.(?<remote>[\/\w]+)(?: \[(?:ahead (?<ahead>[0-9]+))?(?:, )?(?:behind (?<behind>[0-9]+))?)?"
			$match = [Regex]::Match($header, $rgx)
			$b = $match.groups['branch'].Value
			$sl = $($match.groups['ahead'].success.tostring()[0] + $match.groups['behind'].success.tostring()[0])
			$s = switch ($sl) {
				"FF" { $([char]8801) }
				"TT" { $match.groups['ahead'].value + $([char]8597) + $match.groups['behind'].value }
				"TF" { $([char]8593) + $match.groups['ahead'].value }
				"FT" { $([char]8595) + $match.groups['behind'].value }
			}
			$br = if($b -eq "master") {62489} else {62488}
			Write-Host $([char]$br) -NoNewline -Fore Black -Back Blue		
			Write-Host " $b $s" -NoNewline -Fore Black -Back Blue

			Write-Host $arr -NoNewline -Fore Blue
			Write-Host $([char]57521) -NoNewline -Fore Blue
		}
		else {
			Write-Host $arr -NoNewline -Fore Yellow
			Write-Host $([char]57521) -NoNewline -Fore Yellow
		}
	}

	# prompt line
	Write-Host ""
	Write-Host "$([char]62601) " -NoNewline -Fore White
  	return " "
}
