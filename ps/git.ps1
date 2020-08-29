$git_installed = (Get-Command -ErrorAction SilentlyContinue git) -ne $null
$git_status_regex = "(?:#+) (?<branch>\w+)(?:\.{3})?(?<remote>[\/\w]+)(?: \[(?:ahead (?<ahead>[0-9]+))?(?:, )?(?:behind (?<behind>[0-9]+))?)?"

function in_git_repo {
    return  (git rev-parse --is-inside-work-tree 2> $null) -eq "true"
}

function write_git_status {
    $o = (git config --get remote.origin.url)
    $or = if($o.Contains("github")) { $IC_GIT_HUB_LOGO } else { $IC_GIT_LOGO }
    $sta = (git status --porcelain -b)
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
    if ($changes) {
        
    }

    Write-Host "$or $bri $br $s" -NoNewline -Fore $CO_PR_GIT_FORE -Back $CO_PR_GIT_BACK
}

function gs { git status -sb }
function gb { git branch $args }
function gco { git checkout $args }
Remove-Item Alias:gc -Force
function gc {
	git checkout $args
	git fetch > $null
}
Remove-Item Alias:gcb -Force
function gcb {
	git checkout -b $args
    git push --set-upstream origin $args
}
Remove-Item Alias:gcm -Force
function gcm { gc master }