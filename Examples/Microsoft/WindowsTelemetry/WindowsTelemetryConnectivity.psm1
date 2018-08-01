Set-StrictMode -Version 4

Import-Module -Name HttpConnectivityTester -Force

# 1. import this file 
# Import-Module .\WindowsTelemetryConnectivity.psm1

# 2. run one of the following:
# $connectivity = Get-WindowsTelemetryConnectivity
# $connectivity = Get-WindowsTelemetryConnectivity -Verbose
# $connectivity = Get-WindowsTelemetryConnectivity -PerformBlueCoatLookup
# $connectivity = Get-WindowsTelemetryConnectivity -Verbose -PerformBlueCoatLookup

# 3. filter results:
# $connectivity | Format-List -Property Blocked,TestUrl,UnblockUrl,DnsAliases,IpAddresses,Description,Resolved,ActualStatusCode,ExpectedStatusCode

# 4. save results to a file:
# Save-HttpConnectivity -Results $connectivity -OutputPath "$env:userprofile\Desktop" -FileName ('WindowsTelemetryConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))

Function Get-WindowsTelemetryConnectivity() {
    <#
    .SYNOPSIS 
    Gets connectivity information for Windows Telemetry.

    .DESCRIPTION  
    Gets connectivity information for Windows Telemetry.
     
    .PARAMETER PerformBlueCoatLookup   
    Use Symantec BlueCoat SiteReview to lookup what SiteReview category the URL is in.

    .EXAMPLE   
    Get-WindowsTelemetryConnectivity

    .EXAMPLE  
    Get-WindowsTelemetryConnectivity -Verbose
    
    .EXAMPLE   
    Get-WindowsTelemetryConnectivity -PerformBlueCoatLookup

    .EXAMPLE  
    Get-WindowsTelemetryConnectivity -Verbose -PerformBlueCoatLookup
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[pscustomobject]])]
    Param(     
        [Parameter(Mandatory=$false, HelpMessage='Whether to perform a BlueCoat Site Review lookup on the URL. Warning: The BlueCoat Site Review REST API is rate limited.')]
        [switch]$PerformBluecoatLookup
    )

    $isVerbose = $verbosePreference -eq 'Continue'    

    $data = New-Object System.Collections.Generic.List[pscustomobject]
    
    # https://docs.microsoft.com/en-us/windows/privacy/configure-windows-diagnostic-data-in-your-organization#endpoints

    $data.Add([pscustomobject]@{ TestUrl = 'https://v10.vortex-win.data.microsoft.com/collect/v1'; UnblockUrl = 'https://v10.vortex-win.data.microsoft.com'; StatusCode = 400; Description = 'Diagnostic/telemetry data for Windows 10 1607 and later.' })
    $data.Add([pscustomobject]@{ TestUrl = 'https://v20.vortex-win.data.microsoft.com/collect/v1'; UnblockUrl = 'https://v20.vortex-win.data.microsoft.com'; StatusCode = 400; Description = 'Diagnostic/telemetry data for Windows 10 1703 and later.' })
    $data.Add([pscustomobject]@{ TestUrl = 'https://settings-win.data.microsoft.com'; UnblockUrl = 'https://settings-win.data.microsoft.com'; StatusCode = 404; Description = 'Used by applications, such as Windows Connected User Experiences and Telemetry component and Windows Insider Program, to dynamically update their configuration.' })
    $data.Add([pscustomobject]@{ TestUrl = 'https://watson.telemetry.microsoft.com'; UnblockUrl = 'https://watson.telemetry.microsoft.com'; StatusCode = 404; Description = 'Windows Error Reporting.' })
    $data.Add([pscustomobject]@{ TestUrl = 'https://oca.telemetry.microsoft.com'; UnblockUrl = 'https://oca.telemetry.microsoft.com'; StatusCode = 404; Description = 'Online Crash Analysis.' })
    $data.Add([pscustomobject]@{ TestUrl = 'https://vortex.data.microsoft.com/collect/v1'; UnblockUrl = 'https://vortex.data.microsoft.com'; StatusCode = 400; Description = 'OneDrive app for Windows 10.' }) 
    
    $results = New-Object System.Collections.Generic.List[pscustomobject]

    $data | ForEach-Object {
        $connectivity = Get-HttpConnectivity -TestUrl $_.TestUrl -UnblockUrl $_.UnblockUrl -ExpectedStatusCode $_.StatusCode -Description $_.Description -PerformBluecoatLookup:$PerformBluecoatLookup -Verbose:$isVerbose
        $results.Add($connectivity)
    }  

    return $results
}