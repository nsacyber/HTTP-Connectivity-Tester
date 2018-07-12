Set-StrictMode -Version 4

#Import-Module -Name .\ConnectivityTester.psm1 -Force

Import-Module -Name ConnectivityTester -Force

# dot source this file 
# . .\WindowsAnalyticsUpgradeReadinessConnectivity.ps1

# then run one of the following:
# Get-WindowsAnalyticsUpgradeReadinessConnectivity
# Get-WindowsAnalyticsUpgradeReadinessConnectivity -Verbose
# Get-WindowsAnalyticsUpgradeReadinessConnectivity -Verbose -PerformBlueCoatLookup

# to filter results or save them to a file:
# $connectivity = Get-WindowsAnalyticsUpgradeReadinessConnectivity -Verbose -PerformBlueCoatLookup
# $connectivity | Format-List -Property IsBlocked,TestUrl,Description,Resolved,ActualStatusCode,ExpectedStatusCode
# Save-Connectivity -Results $connectivity -OutputPath "$env:userprofile\Desktop" -FileName ('WindowsAnalyticsUpgradeReadinessConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))

Function Get-WindowsAnalyticsUpgradeReadinessConnectivity() {
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[pscustomobject]])]
    Param(
        [Parameter(Mandatory=$false, HelpMessage='Whether to perform a BlueCoat Site Review lookup on the URL. Warning: The BlueCoat Site Review REST API is rate limited.')]
        [switch]$PerformBluecoatLookup
    )

    $isVerbose = $verbosePreference -eq 'Continue'    

    $data = New-Object System.Collections.Generic.List[pscustomobject]
       
    # https://docs.microsoft.com/en-us/windows/deployment/update/windows-analytics-get-started#enable-data-sharing

    $data.Add([pscustomobject]@{ TestUrl = 'https://v10.events.data.microsoft.com'; StatusCode = 404; Description = 'Connected User Experience and Diagnostic component endpoint for use with Windows 10 1803 and later'; IgnoreCertificateValidationErrors=$false })
    $data.Add([pscustomobject]@{ TestUrl = 'https://v10.vortex-win.data.microsoft.com'; StatusCode = 404; Description = 'Connected User Experience and Diagnostic component endpoint for Windows 10 1709 and earlier'; IgnoreCertificateValidationErrors=$false })
    $data.Add([pscustomobject]@{ TestUrl = 'https://vortex.data.microsoft.com'; StatusCode = 404; Description = 'Connected User Experience and Diagnostic component endpoint for operating systems older than Windows 10'; IgnoreCertificateValidationErrors=$false })
    $data.Add([pscustomobject]@{ TestUrl = 'https://settings-win.data.microsoft.com'; StatusCode = 404; Description = 'Enables the compatibility update to send data to Microsoft.'; IgnoreCertificateValidationErrors=$false })
    $data.Add([pscustomobject]@{ TestUrl = 'https://adl.windows.com'; StatusCode = 404; Description = 'Allows the compatibility update to receive the latest compatibility data from Microsoft.'; IgnoreCertificateValidationErrors=$true })
    #$data.Add([pscustomobject]@{ TestUrl = 'https://watson.telemetry.microsoft.com'; StatusCode = 404; Description = 'Windows Error Reporting (WER); required for Device Health and Update Compliance AV reports. Not used by Upgrade Readiness.'; IgnoreCertificateValidationErrors=$false })
    #$data.Add([pscustomobject]@{ TestUrl = 'https://oca.telemetry.microsoft.com'; StatusCode = 404; Description = 'Online Crash Analysis; required for Device Health and Update Compliance AV reports. Not used by Upgrade Readiness.'; IgnoreCertificateValidationErrors=$false })
   
    # https://docs.microsoft.com/en-us/windows/deployment/upgrade/upgrade-readiness-data-sharing   
    
    #$data.Add([pscustomobject]@{ TestUrl = 'https://v10.vortex-win.data.microsoft.com/collect/v1'; StatusCode = 400; IgnoreCertificateValidationErrors=$ignore }) # same base URL as a link above, but full URL returns 400 rather than 404 
    #$data.Add([pscustomobject]@{ TestUrl = 'https://vortex-win.data.microsoft.com/health/keepalive'; StatusCode = 200; IgnoreCertificateValidationErrors=$ignore }) # same base URL as a link above, but full URL returns 200 rather than 404
    #$data.Add([pscustomobject]@{ TestUrl = 'https://settings.data.microsoft.com/qos'; StatusCode = 200; IgnoreCertificateValidationErrors=$ignore })
    #$data.Add([pscustomobject]@{ TestUrl = 'https://settings-win.data.microsoft.com/qos'; StatusCode = 200; IgnoreCertificateValidationErrors=$ignore }) # same base URL as a link above
    #$data.Add([pscustomobject]@{ TestUrl = 'https://go.microsoft.com/fwlink/?LinkID=544713'; StatusCode = 400; IgnoreCertificateValidationErrors=$ignore }) # goes to https://compatexchange1.trafficmanager.net/CompatibilityExchangeService.svc/extended
    #$data.Add([pscustomobject]@{ TestUrl = 'https://compatexchange1.trafficmanager.net/CompatibilityExchangeService.svc'; StatusCode = 200; IgnoreCertificateValidationErrors=$ignore })

    # https://blogs.technet.microsoft.com/upgradeanalytics/2017/03/10/understanding-connectivity-scenarios-and-the-deployment-script/
    # https://blogs.technet.microsoft.com/ukplatforms/2017/03/13/upgrade-readiness-client-configuration/
    
    $results = New-Object System.Collections.Generic.List[pscustomobject]

    $data | ForEach-Object {
        $connectivity = Get-Connectivity -TestUrl $_.TestUrl -ExpectedStatusCode $_.StatusCode -Description $_.Description -IgnoreCertificateValidationErrors:($_.IgnoreCertificateValidationErrors) -PerformBluecoatLookup:$PerformBluecoatLookup -Verbose:$isVerbose
        $results.Add($connectivity)
    }  

    return $results
}