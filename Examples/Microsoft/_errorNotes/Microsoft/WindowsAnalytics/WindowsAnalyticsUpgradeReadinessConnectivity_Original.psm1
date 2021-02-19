Set-StrictMode -Version 4

Import-Module -Name HttpConnectivityTester -Force

# 1. import this file:
# Import-Module .\WindowsAnalyticsUpgradeReadinessConnectivity.psm1

# 2. run one of the following:
# $connectivity = Get-WindowsAnalyticsUpgradeReadinessConnectivity
# $connectivity = Get-WindowsAnalyticsUpgradeReadinessConnectivity -Verbose
# $connectivity = Get-WindowsAnalyticsUpgradeReadinessConnectivity -PerformBlueCoatLookup
# $connectivity = Get-WindowsAnalyticsUpgradeReadinessConnectivity -Verbose -PerformBlueCoatLookup

# 3. filter results:
# $connectivity | Format-List -Property Blocked,TestUrl,UnblockUrl,DnsAliases,IpAddresses,Description,Resolved,ActualStatusCode,ExpectedStatusCode,UnexpectedStatus

# 4. save results to a file:
# Save-HttpConnectivity -Objects $connectivity -FileName ('WindowsAnalyticsUpgradeReadinessConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))

Function Get-WindowsAnalyticsUpgradeReadinessConnectivity() {
    <#
    .SYNOPSIS
    Gets connectivity information for Windows Analytics Upgrade Readiness.

    .DESCRIPTION
    Gets connectivity information for Windows Analytics Upgrade Readiness.

    .PARAMETER PerformBlueCoatLookup
    Use Symantec BlueCoat SiteReview to lookup what SiteReview category the URL is in.

    .EXAMPLE
    Get-WindowsAnalyticsUpgradeReadinessConnectivity

    .EXAMPLE
    Get-WindowsAnalyticsUpgradeReadinessConnectivity -Verbose

    .EXAMPLE
    Get-WindowsAnalyticsUpgradeReadinessConnectivity -PerformBlueCoatLookup

    .EXAMPLE
    Get-WindowsAnalyticsUpgradeReadinessConnectivity -Verbose -PerformBlueCoatLookup
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[pscustomobject]])]
    Param(
        [Parameter(Mandatory=$false, HelpMessage='Whether to perform a BlueCoat Site Review lookup on the URL. Warning: The BlueCoat Site Review REST API is rate limited.')]
        [switch]$PerformBluecoatLookup
    )

    $isVerbose = $VerbosePreference -eq 'Continue'

    $data = New-Object System.Collections.Generic.List[System.Collections.Hashtable]

    # https://docs.microsoft.com/en-us/windows/deployment/update/windows-analytics-get-started#enable-data-sharing

    $data.Add(@{ TestUrl = 'https://v10.events.data.microsoft.com'; ExpectedStatusCode = 404; Description = 'Connected User Experience and Diagnostic component endpoint for use with Windows 10 1803 and later'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://v10.vortex-win.data.microsoft.com'; ExpectedStatusCode = 404; Description = 'Connected User Experience and Diagnostic component endpoint for Windows 10 1709 and earlier'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://vortex.data.microsoft.com'; ExpectedStatusCode = 404; Description = 'Connected User Experience and Diagnostic component endpoint for operating systems older than Windows 10'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://v10c.events.data.microsoft.com'; ExpectedStatusCode = 404; Description = 'Connected User Experience and Diagnostic component endpoint for use with Windows 10 releases that have the September 2018, or later, Cumulative Update installed: KB4457127 (1607), KB4457141 (1703), KB4457136 (1709), KB4458469 (1803).'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://settings-win.data.microsoft.com'; ExpectedStatusCode = 404; Description = 'Enables the compatibility update to send data to Microsoft.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://adl.windows.com'; ExpectedStatusCode = 404; Description = 'Allows the compatibility update to receive the latest compatibility data from Microsoft.'; IgnoreCertificateValidationErrors=$true; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    #$data.Add(@{ TestUrl = 'https://watson.telemetry.microsoft.com'; ExpectedStatusCode = 404; Description = 'Windows Error Reporting (WER); required for Device Health and Update Compliance AV reports. Not used by Upgrade Readiness.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    #$data.Add(@{ TestUrl = 'https://oca.telemetry.microsoft.com'; ExpectedStatusCode = 404; Description = 'Online Crash Analysis; required for Device Health and Update Compliance AV reports. Not used by Upgrade Readiness.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })

    # https://docs.microsoft.com/en-us/windows/deployment/upgrade/upgrade-readiness-data-sharing

    #$data.Add(@{ TestUrl = 'https://v10.vortex-win.data.microsoft.com/collect/v1'; ExpectedStatusCode = 400; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # same base URL as a link above, but full URL returns 400 rather than 404
    #$data.Add(@{ TestUrl = 'https://vortex-win.data.microsoft.com/health/keepalive'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # same base URL as a link above, but full URL returns 200 rather than 404
    #$data.Add(@{ TestUrl = 'https://settings.data.microsoft.com/qos'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    #$data.Add(@{ TestUrl = 'https://settings-win.data.microsoft.com/qos'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # same base URL as a link above
    #$data.Add(@{ TestUrl = 'https://go.microsoft.com/fwlink/?LinkID=544713'; ExpectedStatusCode = 400; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # goes to https://compatexchange1.trafficmanager.net/CompatibilityExchangeService.svc/extended
    #$data.Add(@{ TestUrl = 'https://compatexchange1.trafficmanager.net/CompatibilityExchangeService.svc'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })

    # https://blogs.technet.microsoft.com/upgradeanalytics/2017/03/10/understanding-connectivity-scenarios-and-the-deployment-script/
    # https://blogs.technet.microsoft.com/ukplatforms/2017/03/13/upgrade-readiness-client-configuration/

    $results = New-Object System.Collections.Generic.List[pscustomobject]

    $data | ForEach-Object {
        $connectivity = Get-HttpConnectivity @_
        $results.Add($connectivity)
    }

    return $results
}
