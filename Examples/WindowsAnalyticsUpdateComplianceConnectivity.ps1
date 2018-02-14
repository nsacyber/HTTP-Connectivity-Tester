Set-StrictMode -Version 4

#Import-Module -Name .\ConnectivityTester.psm1 -Force

Import-Module -Name ConnectivityTester -Force

# dot source this file 
# . .\WindowsAnalyticsUpdateComplianceConnectivity.ps1

# then run one of the following:
# Get-WindowsAnalyticsUpdateComplianceConnectivity
# Get-WindowsAnalyticsUpdateComplianceConnectivity -Verbose
# Get-WindowsAnalyticsUpdateComplianceConnectivity -Verbose -PerformBlueCoatLookup

# to filter results or save them to a file:
# $connectivity = Get-WindowsAnalyticsUpdateComplianceConnectivity -Verbose -PerformBlueCoatLookup
# $connectivity | Format-List -Property IsBlocked,ActualStatusCode,ExpectedStatusCode,Url
# Save-Connectivity -Results $connectivity -OutputPath "$env:userprofile\Desktop" -FileName ('WindowsAnalyticsUpdateComplianceConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))

Function Get-WindowsAnalyticsUpdateComplianceConnectivity() {
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[pscustomobject]])]
    Param(
        [Parameter(Mandatory=$false, HelpMessage='Whether to perform a BlueCoat Site Review lookup on the URL. Warning: The BlueCoat Site Review REST API is rate limited.')]
        [switch]$PerformBluecoatLookup
    )

    $parameters = $PSBoundParameters

    $isVerbose = $verbosePreference -eq 'Continue'    

    $data = New-Object System.Collections.Generic.List[pscustomobject]
    
    # the same URLs as found in WindowsTelemetryConnectivity.ps1
    
    # https://docs.microsoft.com/en-us/windows/deployment/update/update-compliance-get-started#update-compliance-prerequisites

    $data.Add([pscustomobject]@{ Url = 'https://v10.vortex-win.data.microsoft.com'; StatusCode = 404; })
    $data.Add([pscustomobject]@{ Url = 'https://settings-win.data.microsoft.com'; StatusCode = 200; })
    $data.Add([pscustomobject]@{ Url = 'https://watson.telemetry.microsoft.com'; StatusCode = 200; })
    $data.Add([pscustomobject]@{ Url = 'https://oca.telemetry.microsoft.com'; StatusCode = 200; })
    
    # https://docs.microsoft.com/en-us/windows/configuration/configure-windows-diagnostic-data-in-your-organization#endpoints
    
    #$data.Add([pscustomobject]@{ Url = 'https://v10.vortex-win.data.microsoft.com'; StatusCode = 200; }) # repeat from above
    #$data.Add([pscustomobject]@{ Url = 'https://settings-win.data.microsoft.com'; StatusCode = 200; }) # repeat from above
    #$data.Add([pscustomobject]@{ Url = 'https://watson.telemetry.microsoft.com'; StatusCode = 200; }) # repeat from above
    #$data.Add([pscustomobject]@{ Url = 'https://oca.telemetry.microsoft.com'; StatusCode = 200; }) # repeat from above
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