$themes_url = "https://iterm2colorschemes.com/"

$tagsMap = @{
    "Ansi 0 Color" = "black";
    "Ansi 1 Color" = "red";
    "Ansi 2 Color" = "green";
    "Ansi 3 Color" = "yellow";
    "Ansi 4 Color" = "blue";
    "Ansi 5 Color" = "purple";
    "Ansi 6 Color" = "cyan";
    "Ansi 7 Color" = "white";
    "Ansi 8 Color" = "brightBlack";
    "Ansi 9 Color" = "brightRed";
    "Ansi 10 Color" = "brightGreen";
    "Ansi 11 Color" = "brightYellow";
    "Ansi 12 Color" = "brightBlue";
    "Ansi 13 Color" = "brightPurple";
    "Ansi 14 Color" = "brightCyan";
    "Ansi 15 Color" = "brightWhite";
    "Background Color" = "background";
    "Foreground Color" = "foreground";
    "Selection Color" = "selectionBackground";
    "Cursor Color" = "cursorColor";
}

function Use-Theme {
    param (
        [string] $theme,
        [switch] $d,
        [switch] $p
    )
    
    # load C# xml lib
    Add-Type -AssemblyName "System.Xml.Linq"

    # find terminal package
    $term = Resolve-Path ($env:LOCALAPPDATA + "/Packages/Microsoft.WindowsTerminal*")
    if ($term -eq $null) {
        Write-Host "Can't locate WinsowsTerminal package" -Fore Red
        return
    }
    $settings = $term.ToString() + "/LocalState/settings.json"
    if (!(Test-Path $settings)) {
        Write-Host "Can't locate settings file from package" -Fore Red
        return
    }

    # get requested theme link
    $request = Invoke-WebRequest -Uri $themes_url -UseBasicParsing
    $xmlLink = $null
    foreach ($l in $request.Links) {
        if ($l.outerHTML -match "<strong>(.*?)<\/strong>") {
            $n = $Matches.1
            if ($n -eq $theme) {
                $xmlLink = $l.Href
            }
        }
    }
    if ($xmlLink -eq $null) {
        Write-Host "Can't find requested theme" -Fore Red
        return
    }

    # get theme xml
    $request = Invoke-WebRequest -Uri $xmlLink -UseBasicParsing
    $xml = [System.Xml.Linq.XDocument]::Parse($request.content)

    # parse xml & convert to json
    $themeObj = @{ name = $theme }
    $currentColor = $null
    $color = @{}
    [array]$colors = $xml.Root.Element("dict").Elements()

    for($i = 0; $i -lt $colors.Length; $i++) {
        $k = $colors[$i]
        $tag = $k.name
        if($tag -eq "key") {
            if($currentColor -ne $null) {
                $themeObj[$tagsMap[$currentColor]] =
                "#" + $color.Red.ToString() + $color.Green.ToString() + $color.Blue.ToString()
            }
            # skip color if not used
            if (!$tagsMap.ContainsKey($k.Value)) {
                $i++
                continue
            }
            $currentColor = $k.Value
        }
        else {
            [array]$vals = $k.Elements()
            for($j = 0; $j -lt $vals.Length; $j+=2) {
                $_k = $vals[$j]
                if (($_k.Value.Contains("Alpha")) -or ($_k.Value.Contains("Space"))) {
                    continue
                }
                $comp = $_k.Value.Replace("Component", "").Trim()
                $cval = (($vals[$j+1].Value -as [float]) * 255) -as [int]
                $color[$comp] = "{0:X2}" -f $cval
            }
        }
    }
    
    $themeJson = ($themeObj | ConvertTo-Json)

    # patch settings
    # strip comments
    $settingsJson = @()
    foreach($l in Get-Content -Path $settings) {
        if (!($l.Trim().StartsWith("//"))) {
            $settingsJson += $l
        }
    }
    $settingsJson = ($settingsJson -join "`n") | ConvertFrom-Json

    $existing = -1
    for ($k = 0; $k -lt $settingsJson.schemes.Count; $k++) {
        if ($settingsJson.schemes[$k].name -eq $theme) {
            $existing = $k
        }
    }
    if ($existing -lt 0) {
        $settingsJson.schemes += $themeObj
    }

    if ($d) {
        if ($settingsJson.profiles.defaults.PSObject.Properties.Match("colorScheme").Count) {
            $settingsJson.profiles.defaults.colorScheme = $theme
        }
        else {
            $settingsJson.profiles.defaults | Add-Member -Name "colorScheme" -Value $theme -Type NoteProperty
        }
    }

    $settingsJson | ConvertTo-Json | Out-File $settings -Encoding ASCII

    #$settingsJson.profiles.list

    #if ($p) {
      #  $currentProfile = $host.UI.RawUI.WindowTitle
    #}
}