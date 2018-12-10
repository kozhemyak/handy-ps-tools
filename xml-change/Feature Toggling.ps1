function Set-AisGate {
    param (
        [Parameter(Mandatory=$true)]
        [string] $Config,
        
        [Parameter(Mandatory=$true)]
        [string] $AisGate
    )

    if (Test-Path -Path $Config -PathType Leaf) {
        $xml = [xml](Get-Content $Config)
        $endpoint = $xml.configuration."system.serviceModel".client.endpoint | 
            Where-Object {$_.name -eq "BasicHttpBinding_IAisGate" }
        $endpoint.address = $AisGate
        $xml.Save($Config)
    } else {
        Write-Error "${Config} does not exist"
    }
}

function Set-FeatureState {
    param (
        [Parameter(Mandatory=$true)]
        [string] $Config,
        
        [Parameter(Mandatory=$true)]
        [string] $Feature,

        [Parameter(Mandatory=$true)]
        [string] $isEnabled
    )

    if (Test-Path -Path $Config -PathType Leaf) {
        $xml = [xml](Get-Content $Config)
        $feature = $xml.configuration.FeatureStateSettings.feature | 
            Where-Object { $_.const -eq $Feature }
        $feature.isEnabled = $isEnabled
        $xml.Save($Config)
    } else {
        Write-Error "${Config} does not exist"
    }
}