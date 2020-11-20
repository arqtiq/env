
function WT-GetPackageRoot {
    $term = Resolve-Path ($env:LOCALAPPDATA + "/Packages/Microsoft.WindowsTerminal*")
    if ($term -is [array]) {
        $term = $term[0]
    }
    elseif ($null -eq $term) {
        Write-Host "Can't locate WinsowsTerminal package" -Fore Red
        return $null
    }
    return $term
}

function WT-GetSettingsPath {
    $root = WT-GetPackageRoot
    $settings = $root.ToString() + "/LocalState/settings.json"
    return $settings
}

function WT-LoadSettings {
    $settings = WT-GetSettingsPath
    if (!(Test-Path $settings)) {
        Write-Host "Can't locate settings file from package" -Fore Red
        return $null
    }
    $settingsJson = @()
    # remove comment lines
    foreach ($l in Get-Content -Path $settings) {
        if (!($l.Trim().StartsWith("//"))) {
            $settingsJson += $l
        }
    }
    $settingsJson = ($settingsJson -join "`n") | ConvertFrom-Json
    return $settingsJson
}

function WT-SaveSettings {
    param([object] $json)
    $settings = WT-GetSettingsPath
    $json | ConvertTo-Json -Depth 10 | Out-File $settings -Encoding ASCII
}