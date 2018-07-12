Set-StrictMode -Version 4

Import-Module -Name ConnectivityTester -Force

# 1. import this file:
# Import-Module .\WindowsAnalyticsUpdateComplianceConnectivity.psm1

# 2. run one of the following:
# $connectivity = Get-WindowsAnalyticsUpdateComplianceConnectivity
# $connectivity = Get-WindowsAnalyticsUpdateComplianceConnectivity -Verbose
# $connectivity = Get-WindowsAnalyticsUpdateComplianceConnectivity -PerformBlueCoatLookup
# $connectivity = Get-WindowsAnalyticsUpdateComplianceConnectivity -Verbose -PerformBlueCoatLookup

# 3. filter results:
# $connectivity | Format-List -Property IsBlocked,TestUrl,Description,Resolved,ActualStatusCode,ExpectedStatusCode

# 4. save results to a file:
# Save-Connectivity -Results $connectivity -OutputPath "$env:userprofile\Desktop" -FileName ('WindowsAnalyticsUpdateComplianceConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))

Function Get-WindowsAnalyticsUpdateComplianceConnectivity() {
    <#
    .SYNOPSIS 
    Gets connectivity information for Windows Analytics Update Compliance.

    .DESCRIPTION  
    Gets connectivity information for Windows Analytics Update Compliance.
     
    .PARAMETER PerformBlueCoatLookup   
    Use Symantec BlueCoat SiteReview to lookup what SiteReview category the URL is in.

    .EXAMPLE   
    Get-WindowsAnalyticsUpdateComplianceConnectivity

    .EXAMPLE  
    Get-WindowsAnalyticsUpdateComplianceConnectivity -Verbose
    
    .EXAMPLE   
    Get-WindowsAnalyticsUpdateComplianceConnectivity -PerformBlueCoatLookup

    .EXAMPLE  
    Get-WindowsAnalyticsUpdateComplianceConnectivity -Verbose -PerformBlueCoatLookup
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[pscustomobject]])]
    Param(
        [Parameter(Mandatory=$false, HelpMessage='Whether to perform a BlueCoat Site Review lookup on the URL. Warning: The BlueCoat Site Review REST API is rate limited.')]
        [switch]$PerformBluecoatLookup
    )

    $isVerbose = $verbosePreference -eq 'Continue'    

    $data = New-Object System.Collections.Generic.List[pscustomobject]
    
    # the same URLs as found in WindowsTelemetryConnectivity.ps1
    
    # https://docs.microsoft.com/en-us/windows/deployment/update/windows-analytics-get-started#enable-data-sharing
    
    $data.Add([pscustomobject]@{ TestUrl = 'https://v10.events.data.microsoft.com'; StatusCode = 404; Description = 'Connected User Experience and Diagnostic component endpoint for use with Windows 10 1803 and later'; IgnoreCertificateValidationErrors=$false })
    $data.Add([pscustomobject]@{ TestUrl = 'https://v10.vortex-win.data.microsoft.com'; StatusCode = 404; Description = 'Connected User Experience and Diagnostic component endpoint for Windows 10 1709 and earlier'; IgnoreCertificateValidationErrors=$false })
    $data.Add([pscustomobject]@{ TestUrl = 'https://vortex.data.microsoft.com'; StatusCode = 404; Description = 'Connected User Experience and Diagnostic component endpoint for operating systems older than Windows 10'; IgnoreCertificateValidationErrors=$false })
    $data.Add([pscustomobject]@{ TestUrl = 'https://settings-win.data.microsoft.com'; StatusCode = 404; Description = 'Enables the compatibility update to send data to Microsoft.'; IgnoreCertificateValidationErrors=$false })
    $data.Add([pscustomobject]@{ TestUrl = 'https://adl.windows.com'; StatusCode = 404; Description = 'Allows the compatibility update to receive the latest compatibility data from Microsoft.'; IgnoreCertificateValidationErrors=$true })
    $data.Add([pscustomobject]@{ TestUrl = 'https://watson.telemetry.microsoft.com'; StatusCode = 404; Description = 'Windows Error Reporting (WER); required for Device Health and Update Compliance AV reports. Not used by Upgrade Readiness.'; IgnoreCertificateValidationErrors=$false })
    $data.Add([pscustomobject]@{ TestUrl = 'https://oca.telemetry.microsoft.com'; StatusCode = 404; Description = 'Online Crash Analysis; required for Device Health and Update Compliance AV reports. Not used by Upgrade Readiness.'; IgnoreCertificateValidationErrors=$false })
    
    # https://docs.microsoft.com/en-us/windows/privacy/configure-windows-diagnostic-data-in-your-organization#endpoints
    
    $results = New-Object System.Collections.Generic.List[pscustomobject]

    $data | ForEach-Object {
        $connectivity = Get-Connectivity -TestUrl $_.TestUrl -ExpectedStatusCode $_.StatusCode -Description $_.Description -IgnoreCertificateValidationErrors:($_.IgnoreCertificateValidationErrors) -PerformBluecoatLookup:$PerformBluecoatLookup -Verbose:$isVerbose
        $results.Add($connectivity)
    }  

    return $results
}