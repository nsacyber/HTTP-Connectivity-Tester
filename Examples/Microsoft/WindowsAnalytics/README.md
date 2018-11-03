# Windows Analytics connectivity tests

## Usage

Windows Analytics Update Compliance

1. Import this file: `Import-Module .\WindowsAnalyticsUpdateComplianceConnectivity.psm1`
1. Run one of the following:
    * `$connectivity = Get-WindowsAnalyticsUpdateComplianceConnectivity`
    * `$connectivity = Get-WindowsAnalyticsUpdateComplianceConnectivity -Verbose`
    * `$connectivity = Get-WindowsAnalyticsUpdateComplianceConnectivity -PerformBlueCoatLookup`
    * `$connectivity = Get-WindowsAnalyticsUpdateComplianceConnectivity -Verbose -PerformBlueCoatLookup`
1. Filter results: `$connectivity | Format-List -Property Blocked,TestUrl,UnblockUrl,DnsAliases,IpAddresses,Description,Resolved,ActualStatusCode,ExpectedStatusCode,UnexpectedStatus`
1. Save results to a file: `Save-HttpConnectivity -Results $connectivity -FileName ('WindowsAnalyticsUpdateComplianceConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))`

Windows Analytics Upgrade Readiness

1. Import this file: `Import-Module .\WindowsAnalyticsUpgradeReadinessConnectivity.psm1`
1. Run one of the following:
    * `$connectivity = Get-WindowsAnalyticsUpgradeReadinessConnectivity`
    * `$connectivity = Get-WindowsAnalyticsUpgradeReadinessConnectivity -Verbose`
    * `$connectivity = Get-WindowsAnalyticsUpgradeReadinessConnectivity -PerformBlueCoatLookup`
    * `$connectivity = Get-WindowsAnalyticsUpgradeReadinessConnectivity -Verbose -PerformBlueCoatLookup`
1. Filter results: `$connectivity | Format-List -Property Blocked,TestUrl,UnblockUrl,DnsAliases,IpAddresses,Description,Resolved,ActualStatusCode,ExpectedStatusCode,UnexpectedStatus`
1. Save results to a file: `Save-HttpConnectivity -Objects $connectivity -FileName ('WindowsAnalyticsUpgradeReadinessConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))`

## Tested URLs

Windows Analytics Update Compliance

| Test URL | URL to Unblock | Description |
| -- | -- | -- |
| <https://v10.events.data.microsoft.com> | <https://v10.events.data.microsoft.com> | Connected User Experience and Diagnostic component endpoint for use with Windows 10 1803 and later. |
| <https://v10.vortex-win.data.microsoft.com> | <https://v10.vortex-win.data.microsoft.com> | Connected User Experience and Diagnostic component endpoint for Windows 10 1709 and earlier. |
| <https://vortex.data.microsoft.com> | <https://vortex.data.microsoft.com> | Connected User Experience and Diagnostic component endpoint for operating systems older than Windows 10. |
| <https://v10c.events.data.microsoft.com> | <https://v10c.events.data.microsoft.com> | Connected User Experience and Diagnostic component endpoint for use with Windows 10 releases that have the September 2018, or later, Cumulative Update installed: KB4457127 (1607), KB4457141 (1703), KB4457136 (1709), KB4458469 (1803). |
| <https://settings-win.data.microsoft.com> | <https://settings-win.data.microsoft.com> | Enables the compatibility update to send data to Microsoft. |
| <https://adl.windows.com> | <https://adl.windows.com> | Allows the compatibility update to receive the latest compatibility data from Microsoft. |
| <https://watson.telemetry.microsoft.com> | <https://watson.telemetry.microsoft.com> | Windows Error Reporting (WER); required for Device Health and Update Compliance AV reports. Not used by Upgrade Readiness. |
| <https://oca.telemetry.microsoft.com> | <https://oca.telemetry.microsoft.com> | Online Crash Analysis; required for Device Health and Update Compliance AV reports. Not used by Upgrade Readiness. |
| <https://ceuswatcab01.blob.core.windows.net> | <https://ceuswatcab01.blob.core.windows.net> | Windows Error Reporting (WER) required for Device Health and Update Compliance AV reports in Windows 10 1809 and later. Not used by Upgrade Readiness. Central US data center #1. |
| <https://ceuswatcab02.blob.core.windows.net> | <https://ceuswatcab02.blob.core.windows.net> | Windows Error Reporting (WER) required for Device Health and Update Compliance AV reports in Windows 10 1809 and later. Not used by Upgrade Readiness. Central US data center #2. |
| <https://eaus2watcab01.blob.core.windows.net> | <https://eaus2watcab01.blob.core.windows.net> | Windows Error Reporting (WER) required for Device Health and Update Compliance AV reports in Windows 10 1809 and later. Not used by Upgrade Readiness. Eastern US data center #1. |
| <https://eaus2watcab02.blob.core.windows.net> | <https://eaus2watcab02.blob.core.windows.net> | Windows Error Reporting (WER) required for Device Health and Update Compliance AV reports in Windows 10 1809 and later. Not used by Upgrade Readiness. Eastern US data center #2. |
| <https://weus2watcab01.blob.core.windows.net> | <https://weus2watcab01.blob.core.windows.net> | Windows Error Reporting (WER) required for Device Health and Update Compliance AV reports in Windows 10 1809 and later. Not used by Upgrade Readiness. Western US data center #1. |
| <https://weus2watcab02.blob.core.windows.net> | <https://weus2watcab02.blob.core.windows.net> | Windows Error Reporting (WER) required for Device Health and Update Compliance AV reports in Windows 10 1809 and later. Not used by Upgrade Readiness. Western US data center #2. |

Windows Analytics Upgrade Readiness

| Test URL | URL to Unblock | Description |
| -- | -- | -- |
| <https://v10.events.data.microsoft.com> | <https://v10.events.data.microsoft.com> | Connected User Experience and Diagnostic component endpoint for use with Windows 10 1803 and later. |
| <https://v10.vortex-win.data.microsoft.com> | <https://v10.vortex-win.data.microsoft.com> | Connected User Experience and Diagnostic component endpoint for Windows 10 1709 and earlier. |
| <https://vortex.data.microsoft.com> | <https://v10.vortex-win.data.microsoft.com> | Connected User Experience and Diagnostic component endpoint for operating systems older than Windows 10. |
| <https://settings-win.data.microsoft.com> | <https://settings-win.data.microsoft.com> | Enables the compatibility update to send data to Microsoft. |
| <https://adl.windows.com> | <https://adl.windows.com> | Allows the compatibility update to receive the latest compatibility data from Microsoft. |

## References

* [Enrolling devices in Windows Analytics - Enable data sharing](https://docs.microsoft.com/en-us/windows/deployment/update/windows-analytics-get-started#enable-data-sharing)
* [Upgrade Readiness data sharing](https://docs.microsoft.com/en-us/windows/deployment/upgrade/upgrade-readiness-data-sharing)
* [Configure Windows diagnostic data in your organization - Endpoints](https://docs.microsoft.com/en-us/windows/privacy/configure-windows-diagnostic-data-in-your-organization#endpoints)
* [Understanding connectivity scenarios and the deployment script](https://blogs.technet.microsoft.com/upgradeanalytics/2017/03/10/understanding-connectivity-scenarios-and-the-deployment-script)
* [Upgrade Readiness Client Configuration](https://blogs.technet.microsoft.com/ukplatforms/2017/03/13/upgrade-readiness-client-configuration)
