# Get env paths
@($env:Path -split ';')
@(($env:Path).Split(';'))


# Validate paths
$Paths = @(($env:Path).Split([System.IO.Path]::PathSeparator)) | 
    Where-Object { $_ -ne "" }

foreach ($Path in $Paths) {
    if (Test-Path -Path $Path -PathType Container -ErrorAction SilentlyContinue) {
        Write-Host $Path -BackgroundColor DarkGreen
    } else {
        Write-Host $Path -BackgroundColor DarkRed
    }
}

# NET Path
[System.Environment]::GetEnvironmentVariable("PATH") -split ";" | 
    Where-Object { $_ -ne "" }

# Thinking Objects
[System.IO.Path]::PathSeparator


# ShouldProcess
# https://blogs.technet.microsoft.com/poshchap/2014/10/24/scripting-tips-and-tricks-cmdletbinding/
function Test-ShouldProcess {
    [CmdletBinding(
       # ConfirmImpact=
        SupportsShouldProcess=$true)]
    Param ( )

    Begin { }

    Process {
        
        if ($pscmdlet.ShouldProcess("TEST", "ACTION")) {
            Write-Host "REAL ACTION"
        }
    }

    End { }
}

# Paging

function Get-Numbers {
    [CmdletBinding(SupportsPaging = $true)]
    param()

    $FirstNumber = [Math]::Min($PSCmdlet.PagingParameters.Skip, 100)
    $LastNumber = [Math]::Min($PSCmdlet.PagingParameters.First + $FirstNumber - 1, 100)

    if ($PSCmdlet.PagingParameters.IncludeTotalCount) {
        $TotalCountAccuracy = 1.0
        $TotalCount = $PSCmdlet.PagingParameters.NewTotalCount(100,
          $TotalCountAccuracy)
        Write-Output $TotalCount
    }
    $FirstNumber .. $LastNumber | Write-Output
}


Get-Numbers -First 50 -skip 20