$git_installed = (Get-Command -ErrorAction SilentlyContinue git) -ne $null
$git_status_regex = "(?:#+) (?<branch>\w+)(?:\.{3})?(?<remote>[\/\w]+)(?: \[(?:ahead (?<ahead>[0-9]+))?(?:, )?(?:behind (?<behind>[0-9]+))?)?"

function in_git_repo {
    return  (git rev-parse --is-inside-work-tree 2> $null) -eq "true"
}

function write_git_status {
    param ([int]$level)
    if ($level -eq 0) {
        return
    }
    $o = (git config --get remote.origin.url)
    $or = if($o.Contains("github")) { $IC_GIT_HUB_LOGO } elseif($o.Contains("bitbucket")) { $IC_GIT_BITBUCKET_LOGO } else { $IC_GIT_LAB_LOGO }
    $sta = (git status --porcelain -b -u)
    $changes = $sta -is [array]
    $header = if($changes) {$sta[0]} else {$sta}
    $match = [Regex]::Match($header, $git_status_regex)
    $br = $match.groups['branch'].Value
    $bri = if($br -eq "master") {$IC_GIT_BRANCH_MAIN} else {$IC_GIT_BRANCHED}
    $sl = $($match.groups['ahead'].success.tostring()[0] + $match.groups['behind'].success.tostring()[0])
    $s = switch ($sl) {
        "FF" { $IC_GIT_STATUS_SYNC }
        "TT" { $match.groups['ahead'].value + $IC_GIT_STATUS_BOTH + $match.groups['behind'].value }
        "TF" { $IC_GIT_STATUS_AHEAD + $match.groups['ahead'].value }
        "FT" { $IC_GIT_STATUS_BEHIND + $match.groups['behind'].value }
    }

    Write-Host "$or $bri $br $s" -NoNewline -Fore $CO_PR_GIT_FORE -Back $CO_PR_GIT_BACK

    if ($changes) {
        $A = $B = $C = $D = $E = $F = $G = $H = 0
        for ($i = 1; $i -lt $sta.Length; $i++) {
            $l = $sta[$i].SubString(0, 2)
            if ($l[0] -eq "M")      { $B++ }
            elseif ($l[0] -eq "R")  { $B++ }
            elseif ($l[0] -eq "A")  { $A++ }
            elseif ($l[0] -eq "D")  { $C++ }
            elseif ($l[0] -eq "U")  { $D++ }
            if ($l[1] -eq "M")      { $F++ }
            elseif ($l[1] -eq "R")  { $F++ }
            elseif ($l[1] -eq "D")  { $G++ }
            elseif ($l[1] -eq "U")  { $H++ }
            if ($l -eq "??")        { $E++ }
        }

        $txt = " +$A ~$B -$C "
        if ($D -gt 0) {
            $txt += "!$D"
        }
        $txt += "| +$E ~$F -$G "
        if ($H -gt 0) {
            $txt += "!$H"
        }
        Write-Host $txt -NoNewline -Fore $CO_PR_GIT_FORE -Back $CO_PR_GIT_BACK
    }
}

function gs { git status -sb }
function gsu { git status -sb -u }
function gf { git fetch }
Remove-Item Alias:gp -Force
function gp { git pull }
function gb { git branch $args }
function gco { git checkout $args }
Remove-Item Alias:gc -Force
function gc {
    git checkout $args
    gf > $null
}
function gcom {
    $msg = $args -join "`n"
    git commit -m $(echo $msg)
}
Remove-Item Alias:gcb -Force
function gcb {
    param([switch] $p,
          [switch] $m)
    if ($m) {
        gcm
    }
    git checkout -b $args
    if ($p) {
        git push --set-upstream origin $args
    }
}
Remove-Item Alias:gcm -Force
function gcm { gc master }
function ga { git add $args }
function gaa { ga -A }
function gr { git reset $args }
function gst { git stash $args }
function gstp { git stash pop }
function gd {
	param([string] $path,
		  [switch] $h)
  	if ($h) {
  		git diff $path
  	}
  	else {
  		git diff HEAD $path
  	}
}
Remove-Item Alias:gl -Force
function gl {
	param([int] $l=1)
	git log ("-"+($l -as [string]))
}
function cdgr { cd (git rev-parse --show-toplevel) }
function gurl { start (git config --get remote.origin.url) }
