$git_installed = (Get-Command -ErrorAction SilentlyContinue git) -ne $null

New-Alias grep findstr

function LastError {
	$error[0].Exception.ToString()
}

function List-Env {
	gci env:*
}

function Unicode-Char {
	param ([string] $id)
	$i = [convert]::toint32($id, 16)
	Write-Host "$([char]$i) - $i"
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

	Write-Host "$env:USERNAME $([char]61818) $env:COMPUTERNAME" -NoNewline -Fore White -Back DarkBlue
	Write-Host $arr -NoNewline -Fore DarkBlue -Back DarkGray

	Write-Host "PS$($psv.Major).$($psv.Minor)" -NoNewline -Fore Gray -Back DarkGray

	Write-Host $arr -NoNewline -Fore DarkGray -Back Green

	$p = ([string](Get-Location)).Split("\\").Where({ "" -ne $_ })
	$dropbox = $p.Contains("Dropbox")
	
	Write-Host $p[0] -NoNewline -Fore Black -Back Green

	if($p.Count -eq 1) {
		Write-Host $arr -NoNewline -Fore Green -Back Yellow
	}
	elseif($p.Count -eq 2) {
		Write-Host $arr -NoNewline -Fore Green -Back Red
		Write-Host $p[1] -NoNewline -Fore Black -Back Red
	}
	else {
		Write-Host $arr -NoNewline -Fore Green -Back White
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
			Write-Host "$([char]59148) " -NoNewline -Fore Black -Back Red
		}	
	}
	if($p.Count -gt 1) {
		Write-Host $arr -NoNewline -Fore Red -Back Yellow
	}

	$dc = (Get-ChildItem -Directory).Length
	$fc = (Get-ChildItem -File).Length
	$dir = if($dropbox) { 61803 } else { 61564 }
	Write-Host "$([char]$dir) " -NoNewline -Fore Black -Back Yellow
	Write-Host "$dc" -NoNewline -Fore Black -Back Yellow
	Write-Host $([char]57521) -NoNewline -Fore Black -Back Yellow
	Write-Host "$fc" -NoNewline -Fore Black -Back Yellow

	if($git_installed) {
		$in_git = (git rev-parse --is-inside-work-tree 2> $null) -eq "true"
		if($in_git) {
			Write-Host $arr -NoNewline -Fore Yellow -Back Blue
			$b = (git branch --show-current)
			$o = (git config --get remote.origin.url)
			$or = 61907
			if ($o.Contains("github")) {
				$or = 63395
			}
			Write-Host "$([char]$or) " -NoNewline -Fore Black -Back Blue	
			$br = if($b -eq "master") {62489} else {62488}
			Write-Host $([char]$br) -NoNewline -Fore Black -Back Blue		
			Write-Host " $b" -NoNewline -Fore Black -Back Blue
			Write-Host $arr -NoNewline -Fore Blue
			Write-Host $([char]57521) -NoNewline -Fore Blue
		}
		else {
			Write-Host $arr -NoNewline -Fore Yellow
			Write-Host $([char]57521) -NoNewline -Fore Yellow
		}
	}

	Write-Host ""
	Write-Host "$([char]62601) " -NoNewline -Back DarkBlue -Fore White
	Write-Host $arr -NoNewline -Fore DarkBlue

  	return " "
}
