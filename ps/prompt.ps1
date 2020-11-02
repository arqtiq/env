$_pr_time = 1
$_pr_host = 2
$_pr_cwd = 2
$_pr_git = 2

function prompt {
	$cwd = [string](Get-Location) -replace [Regex]::Escape($HOME), "~"
	$p = $cwd.Split("\\").Where({ "" -ne $_ })
	$hs = $p[0] -eq "~"

	# time
	if ($_pr_time) {
		$h = [string](Get-Date -Format "HH:mm")
		Write-Host "$h" -NoNewLine -Fore $CO_PR_HOUR_FORE -Back $CO_PR_HOUR_BACK
		Write-Host $IC_TRIANGLE_TL -NoNewLine -Fore $CO_PR_HOUR_BACK
	}

	# host
	if ($_pr_host) {
		Write-Host "$IC_TRIANGLE_BR " -NoNewLine -Fore $CO_PR_HOST_BACK
		Write-Host "$env:USERNAME $IC_WIN_LOGO $env:COMPUTERNAME" -NoNewline -Fore $CO_PR_HOST_FORE -Back $CO_PR_HOST_BACK

		if ($_pr_host -eq 2) {
			Write-Host $IC_ARROW_FILL_RIGHT -NoNewline -Fore $CO_PR_HOST_BACK -Back $CO_PR_HOST2_BACK
			$psv = $ExecutionContext.Host.Version
			Write-Host "PS$($psv.Major).$($psv.Minor)" -NoNewline -Fore $CO_PR_HOST_FORE -Back $CO_PR_HOST2_BACK
			Write-Host $IC_TRIANGLE_TL -NoNewLine -Fore $CO_PR_HOST2_BACK
		}
		else {
			Write-Host $IC_TRIANGLE_TL -NoNewLine -Fore $CO_PR_HOST_BACK
		}
	}

	$dc = if($hs) {"White"} else {"Green"}
	Write-Host "$IC_TRIANGLE_BR " -NoNewLine -Fore $dc

	# cwd
	$dropbox = $p.Contains("Dropbox")
	
	Write-Host $p[0] -NoNewline -Fore Black -Back $dc

	if($p.Count -eq 1) {
		Write-Host $IC_ARROW_FILL_RIGHT -NoNewline -Fore $dc -Back Yellow
	}
	elseif($p.Count -eq 2) {
		Write-Host $IC_ARROW_FILL_RIGHT -NoNewline -Fore $dc -Back Red
		Write-Host $p[1] -NoNewline -Fore Black -Back Red
	}
	else {
		Write-Host $IC_ARROW_FILL_RIGHT -NoNewline -Fore $dc -Back White
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
		Write-Host $IC_ARROW_FILL_RIGHT -NoNewline -Fore White -Back Red
		Write-Host $p[$p.Count-1] -NoNewline -Fore White -Back Red

		if ($env:VIRTUAL_ENV) {
			Write-Host "$IC_PY_LOGO " -NoNewline -Fore White -Back Red
		}
		if ((Test-Path ./.vs/) -or (Test-Path ./.vscode/)) {
			Write-Host " $IC_VS_LOGO " -NoNewline -Fore White -Back Red
		}
	}
	if($p.Count -gt 1) {
		Write-Host $IC_ARROW_FILL_RIGHT -NoNewline -Fore Red -Back Yellow
	}

	# dirs / file
	$dc = (Get-ChildItem -Directory).Length
	$fc = (Get-ChildItem -File).Length
	$dir = if($dropbox) { $IC_DROPBOX_LOGO } else { $IC_DIR_LOGO }
	Write-Host "$dir " -NoNewline -Fore Black -Back Yellow
	Write-Host "$dc" -NoNewline -Fore Black -Back Yellow
	Write-Host $IC_ARROW_RIGHT -NoNewline -Fore Black -Back Yellow
	Write-Host "$fc" -NoNewline -Fore Black -Back Yellow

	# git
	if($git_installed) {
		if(in_git_repo) {
            Write-Host $IC_ARROW_FILL_RIGHT -NoNewline -Fore Yellow -Back Blue
            write_git_status $_pr_git
            Write-Host "$IC_ARROW_FILL_RIGHT$IC_ARROW_RIGHT" -NoNewline -Fore $CO_PR_GIT_BACK
		}
		else {
			Write-Host $IC_ARROW_FILL_RIGHT -NoNewline -Fore Yellow
			Write-Host $IC_ARROW_RIGHT -NoNewline -Fore Yellow
		}
	}

	# rez
	if($env:REZ_USED_REQUEST) {
		Write-Host -NoNewline " [ $env:REZ_USED_REQUEST ]"
	}

	# prompt line
	Write-Host ""
	Write-Host "$IC_TERMINAL_LOGO " -NoNewline -Fore White
  	return " "
}

function Set-Prompt-Time {
    param ([int]$level)
    $global:_pr_time = $level
}

function Set-Prompt-Host {
    param ([int]$level)
    $global:_pr_host = $level
}

function Set-Prompt-Cwd {
    param ([int]$level)
    $global:_pr_cwd = $level
}

function Set-Prompt-Git {
    param ([int]$level)
    $global:_pr_git = $level
}