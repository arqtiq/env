function Get-Encoding {
  param
  (
    [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
    [Alias('FullName')]
    [string]
    $Path
  )

  process {
    $bom = New-Object -TypeName System.Byte[](4)
        
    $file = New-Object System.IO.FileStream((Resolve-Path $Path), 'Open', 'Read')
    
    $null = $file.Read($bom, 0, 4)
    $file.Close()
    $file.Dispose()
    
    $enc = [Text.Encoding]::ASCII
    if ($bom[0] -eq 0x2b -and $bom[1] -eq 0x2f -and $bom[2] -eq 0x76) 
    { $enc = [Text.Encoding]::UTF7 }
    if ($bom[0] -eq 0xff -and $bom[1] -eq 0xfe) 
    { $enc = [Text.Encoding]::Unicode }
    if ($bom[0] -eq 0xfe -and $bom[1] -eq 0xff) 
    { $enc = [Text.Encoding]::BigEndianUnicode }
    if ($bom[0] -eq 0x00 -and $bom[1] -eq 0x00 -and $bom[2] -eq 0xfe -and $bom[3] -eq 0xff) 
    { $enc = [Text.Encoding]::UTF32 }
    if ($bom[0] -eq 0xef -and $bom[1] -eq 0xbb -and $bom[2] -eq 0xbf) 
    { $enc = [Text.Encoding]::UTF8 }
        
    [PSCustomObject]@{
      Encoding = $enc
      Path     = $Path
    }
  }
}

function Watch-Path {
  param (
    [string] $path = "./",
    [switch] $recurse,
    [string] $filter = "*.*"
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
    
  while ($true) { sleep 5 }
}

function Random-Color {
  param([int] $seed = 0)
  $hx = Get-Random -Maximum 0xFFFFFF -SetSeed $seed
  return "#{0:X6}" -f $hx
}

function Unicode-Char {
  param ([string] $id)
  $i = [convert]::toint32($id, 16)
  Write-Host "$([char]$i) - $i"
}

function Is-Defined {
  param([string] $name)
  $func = Get-Command -Name $name -ErrorAction SilentlyContinue
  $var = Get-Variable -Name $name -ErrorAction SilentlyContinue

  if ($null -eq $func -and $null -eq $var) {
    Write-Host "'$name' is not defined" -Fore Red
    return $false
  }
  elseif ($null -ne $func) {
    Write-Host "'$name' [ Function ]" -Fore Green
    return $true
  }
  elseif ($null -ne $var) {
    Write-Host "'$name' [ Variable ]" -Fore Green
    return $true
  }
}