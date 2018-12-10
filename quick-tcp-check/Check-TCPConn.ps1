
# Input Information
$Computers = "srv1", "www.google.com"
$Ports     = 80, 443

# Color Scheme
$ServerColor  = @{ BackgroundColor = "DarkMagenta"; ForegroundColor = "White" }
$LineColor    = @{ BackgroundColor = "Yellow";      ForegroundColor = "Black" }
$GoodColor    = @{ BackgroundColor = "DarkGreen";   ForegroundColor = "White" }
$BadColor     = @{ BackgroundColor = "DarkRed";   ForegroundColor = "White"}

$LineLength   = 3

$Result = @()

#region Help Functions
function Write-Line {
  param (
    [ValidateSet("regular", "simple")]
    [string] $Type = 'regular'
  )

  switch ($Type) {
    'simple' {
      1..30 | ForEach-Object { Write-Host "++" -NoNewline -ForegroundColor (Get-Random -Minimum 1 -Maximum 15) }
      Write-Host ""
    }
    Default {
      1..40 | ForEach-Object { Write-Host "##" -NoNewline -ForegroundColor (Get-Random -Minimum 1 -Maximum 15) } 
      Write-Host ""
    }
  }
}
#endregion

Write-Line

# Processing
foreach ($Computer in $Computers) {

  $TestResult = New-Object psobject
  Add-Member -InputObject $TestResult -MemberType NoteProperty -Name "Source" -Value $env:COMPUTERNAME
  Add-Member -InputObject $TestResult -MemberType NoteProperty -Name "Destination" -Value $Computer

  $OpenedPorts = @()
  $ClosedPorts = @()
  
  foreach ($Port in $Ports) {
    Write-Host ("[ {0} ]" -f $env:COMPUTERNAME) @ServerColor -NoNewline
    Write-Host " " -NoNewline

    $isAccesible = Test-NetConnection `
      -ComputerName $Computer -Port $Port `
      -InformationLevel Quiet `
      -ErrorAction SilentlyContinue `
      -WarningAction SilentlyContinue

    if ($isAccesible) { 
      Write-Host ("{0} tcp/{1} {2}> [V]" -f ''.PadLeft($LineLength, '-'), $Port, ''.PadLeft(5, '-')) @GoodColor -NoNewline
      $OpenedPorts += $Port
    } else { 
      Write-Host ("{0} tcp/{1} {2}> [X]" -f ''.PadLeft($LineLength, '-'), $Port, ''.PadLeft($LineLength + 5 - $Port.ToString().Length, '-')) @BadColor -NoNewline
      $ClosedPorts += $Port
    }

    Write-Host " " -NoNewline
    Write-Host ("[ {0} ]" -f $Computer) @ServerColor
  }

  Add-Member -InputObject $TestResult -MemberType NoteProperty -Name "OpenedPorts" -Value $OpenedPorts
  Add-Member -InputObject $TestResult -MemberType NoteProperty -Name "ClosedPorts" -Value $ClosedPorts

  if (($Computers[-1] -ne $Computer) -and 
      ($Computers -ne $Computer)) {
    Write-Line -Type 'simple'
  }

  $Result += $TestResult
}

Write-Line

$Result