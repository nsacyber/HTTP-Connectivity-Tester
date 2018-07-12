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
# $connectivity | Format-List -Property IsBlocked,TestUrl,Description,Resolved,ActualStatusCode,ExpectedStatusCode
# Save-Connectivity -Results $connectivity -OutputPath "$env:userprofile\Desktop" -FileName ('WindowsTelemetryConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))

Function Get-WindowsTelemetryConnectivity() {
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[pscustomobject]])]
    Param(     
        [Parameter(Mandatory=$false, HelpMessage='Whether to perform a BlueCoat Site Review lookup on the URL. Warning: The BlueCoat Site Review REST API is rate limited.')]
        [switch]$PerformBluecoatLookup
    )

    $isVerbose = $verbosePreference -eq 'Continue'    

    $data = New-Object System.Collections.Generic.List[pscustomobject]
    
    # https://docs.microsoft.com/en-us/windows/privacy/configure-windows-diagnostic-data-in-your-organization#endpoints

    $data.Add([pscustomobject]@{ TestUrl = 'https://v10.vortex-win.data.microsoft.com/collect/v1'; StatusCode = 400; Description = 'Diagnostic data.' })
    $data.Add([pscustomobject]@{ TestUrl = 'https://v20.vortex-win.data.microsoft.com/collect/v1'; StatusCode = 400; Description = 'Functional data.' })
    $data.Add([pscustomobject]@{ TestUrl = 'https://settings-win.data.microsoft.com'; StatusCode = 404; Description = '' })
    $data.Add([pscustomobject]@{ TestUrl = 'https://watson.telemetry.microsoft.com'; StatusCode = 404; Description = 'Windows Error Reporting.' })
    $data.Add([pscustomobject]@{ TestUrl = 'https://oca.telemetry.microsoft.com'; StatusCode = 404; Description = 'Online Crash Analysis.' })
    $data.Add([pscustomobject]@{ TestUrl = 'https://vortex.data.microsoft.com/collect/v1'; StatusCode = 400; Description = 'OneDrive app for Windows 10.' }) 
    
    $results = New-Object System.Collections.Generic.List[pscustomobject]

    $data | ForEach-Object {
        $connectivity = Get-Connectivity -TestUrl $_.TestUrl -ExpectedStatusCode $_.StatusCode -Description $_.Description -PerformBluecoatLookup:$PerformBluecoatLookup -Verbose:$isVerbose
        $results.Add($connectivity)
    }  

    return $results
}