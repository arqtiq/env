New-Alias grep finstr

function LastError {
	$error[0].Exception.ToString()
}

function prompt {
	$arr = $([char]57520)
	$p = ([string](Get-Location)).Split("\\").Where({ "" -ne $_ })
	
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
			$s = $p[$i][0]
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
	}
	if($p.Count -gt 1) {
		Write-Host $arr -NoNewline -Fore Red -Back Yellow
	}

	$dc = (Get-ChildItem -Directory).Length
	$fc = (Get-ChildItem -File).Length
	Write-Host "$dc" -NoNewline -Fore Black -Back Yellow
	Write-Host $([char]57521) -NoNewline -Fore Black -Back Yellow
	Write-Host "$fc" -NoNewline -Fore Black -Back Yellow

	if(Test-Path .git/index) {
		Write-Host $arr -NoNewline -Fore Yellow -Back Blue
		Write-Host $([char]57504) -NoNewline -Fore Black -Back Blue
		$b = (git branch --show-current)
		Write-Host " $b" -NoNewline -Fore Black -Back Blue
		Write-Host $arr -NoNewline -Fore Blue
		Write-Host $([char]57521) -NoNewline -Fore Blue
	}
	else {
		Write-Host $arr -NoNewline -Fore Yellow
		Write-Host $([char]57521) -NoNewline -Fore Yellow
	}

  	return " "
}
