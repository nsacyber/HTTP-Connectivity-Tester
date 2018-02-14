Set-StrictMode -Version 4

#Import-Module -Name .\ConnectivityTester.psm1 -Force

Import-Module -Name ConnectivityTester -Force

# dot source this file 
# . .\WindowsTelemetryConnectivity.ps1

# then run one of the following:
# Get-WindowsTelemetryConnectivity
# Get-WindowsTelemetryConnectivity -Verbose
# Get-WindowsTelemetryConnectivity -Verbose -PerformBlueCoatLookup

# to filter results or save them to a file:
# $connectivity = Get-WindowsTelemetryConnectivity -Verbose -PerformBlueCoatLookup
# $connectivity | Format-List -Property IsBlocked,ActualStatusCode,ExpectedStatusCode,Url
# Save-Connectivity -Results $connectivity -OutputPath "$env:userprofile\Desktop" -FileName ('WindowsTelemetryConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))

Function Get-WindowsTelemetryConnectivity() {
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[pscustomobject]])]
    Param(     
        [Parameter(Mandatory=$false, HelpMessage='Whether to perform a BlueCoat Site Review lookup on the URL. Warning: The BlueCoat Site Review REST API is rate limited.')]
        [switch]$PerformBluecoatLookup
    )

    $parameters = $PSBoundParameters

    $isVerbose = $verbosePreference -eq 'Continue'    

    $data = New-Object System.Collections.Generic.List[pscustomobject]
    
    # https://docs.microsoft.com/en-us/windows/configuration/configure-windows-diagnostic-data-in-your-organization#endpoints

    $data.Add([pscustomobject]@{ Url = 'https://v10.vortex-win.data.microsoft.com'; StatusCode = 404; })
    $data.Add([pscustomobject]@{ Url = 'https://settings-win.data.microsoft.com'; StatusCode = 200; })
    $data.Add([pscustomobject]@{ Url = 'https://watson.telemetry.microsoft.com'; StatusCode = 200; })
    $data.Add([pscustomobject]@{ Url = 'https://oca.telemetry.microsoft.com'; StatusCode = 200; })
    $data.Add([pscustomobject]@{ Url = 'https://vortex.data.microsoft.com/collect/v1'; StatusCode = 400; }) # OneDrive app for Windows 10 so might not really be necessary

    $results = New-Object System.Collections.Generic.List[pscustomobject]

    $data | ForEach-Object {
        $targetUrl = $_.Url
        $statusCode = $_.StatusCode

        $connectivity = Get-Connectivity -Url $_.Url -ExpectedStatusCode $_.StatusCode -PerformBluecoatLookup:$PerformBluecoatLookup -Verbose:$isVerbose
        $results.Add($connectivity)
    }  

    return $results
}