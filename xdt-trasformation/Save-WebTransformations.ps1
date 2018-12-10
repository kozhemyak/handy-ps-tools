param(
  [string] $ProjectPath = '',
  [string] $Output = "${PSScriptRoot}\.deployment"
)

# Get list of transformations
function Get-WebTransforms {
  param(
    [string] $Path
  )

  if (Test-Path -Path $Path -PathType Container) {
    Write-Host "$Path is valid"
    $Configs = Get-ChildItem -Path $Path -File -Filter 'web.*.config'
    if (@($Configs).Count -gt 0) {
      Write-Host "Transformations:"
      foreach ($Config in $Configs) {
        Write-Host ("`t{0}" -f $Config.Name)
        if ($Config.Name -match '^web\.(.+)\.config$') {
          $obj = New-Object psobject
          $obj | Add-Member -MemberType NoteProperty -Name 'Name' -Value $Matches[1]
          $obj | Add-Member -MemberType NoteProperty -Name 'FullName' -Value $Config.FullName
          $obj
        } else {
          Write-Error "There is an error in getting name of transform"
        }
      }
    } else {
      Write-Error "$Path does not have web transforms"
    }
  } else {
    Write-Error "$Path does not exist"
  }
}

# Apply a transformation
function Apply-WebTransform {
  param(
    [string] $WebConfig,
    [string] $Transform,
    [string] $SavePath,
    [string] $dll = "${PSScriptRoot}\Microsoft.Web.XmlTransform.dll"
  )

  try {
    if (Test-Path -Path $dll -PathType Leaf) {
      Add-Type -Path $dll
      $xml = New-Object Microsoft.Web.XmlTransform.XmlTransformableDocument
      $xml.PreserveWhitespace = $true
      if (Test-Path -Path $WebConfig -Type Leaf) {
        $xml.Load($WebConfig)
        if (Test-Path -Path $Transform -Type Leaf) {
          $xdt = New-Object Microsoft.Web.XmlTransform.XmlTransformation($Transform)
          if ($xdt.Apply($xml) -eq $false) {
            Write-Error ("{0} <- {1} = failed" -f $WebConfig.Name, $Transform.Name)
          } else {
            Write-Host ("{0} <- {1} = finished" -f $WebConfig.Name, $Transform.Name)
          }
          New-Item -Path $SavePath -Force -Value $null | Out-Null
          $xml.Save($SavePath)
        } else {
          Write-Error "$Transform does not exist"
        }
      } else {
        Write-Error "$WebConfig does not exist"
      }
    } else {
      Write-Error "$dll does not exist"
    }
  } catch {
    Write-Error $Error[0].Exception
  }
}

# Main ####################################################

$WebConfig = Get-Item -Path (Join-Path -Path $ProjectPath -ChildPath 'web.config')
$Transformations = Get-WebTransforms -Path $ProjectPath

foreach ($Transformation in $Transformations) {
  Apply-WebTransform `
    -WebConfig $WebConfig.FullName `
    -Transform $Transformation.FullName `
    -SavePath ("{0}\{1}\Web.config" -f $Output, $Transformation.Name)
}

###########################################################