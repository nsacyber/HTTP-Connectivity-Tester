## Windows Analytics connectivity tests

### Usage
Windows Analytics Update Compliance
1. Import this file: `Import-Module .\WindowsAnalyticsUpdateComplianceConnectivity.psm1`
1. Run one of the following:
    * `$connectivity = Get-WindowsAnalyticsUpdateComplianceConnectivity`
    * `$connectivity = Get-WindowsAnalyticsUpdateComplianceConnectivity -Verbose`
    * `$connectivity = Get-WindowsAnalyticsUpdateComplianceConnectivity -PerformBlueCoatLookup`
    * `$connectivity = Get-WindowsAnalyticsUpdateComplianceConnectivity -Verbose -PerformBlueCoatLookup`
1. Filter results: `$connectivity | Format-List -Property IsBlocked,TestUrl,Description,Resolved,ActualStatusCode,ExpectedStatusCode`
1. Save results to a file: `Save-Connectivity -Results $connectivity -OutputPath "$env:userprofile\Desktop" -FileName ('WindowsAnalyticsUpdateComplianceConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))`

Windows Analytics Upgrade Readiness
1. Import this file: `Import-Module .\WindowsAnalyticsUpgradeReadinessConnectivity.psm1`
1. Run one of the following:
    * `$connectivity = Get-WindowsAnalyticsUpgradeReadinessConnectivity`
    * `$connectivity = Get-WindowsAnalyticsUpgradeReadinessConnectivity -Verbose`
    * `$connectivity = Get-WindowsAnalyticsUpgradeReadinessConnectivity -PerformBlueCoatLookup`
    * `$connectivity = Get-WindowsAnalyticsUpgradeReadinessConnectivity -Verbose -PerformBlueCoatLookup`
1. Filter results: `$connectivity | Format-List -Property IsBlocked,TestUrl,Description,Resolved,ActualStatusCode,ExpectedStatusCode`
1. Save results to a file: `Save-Connectivity -Results $connectivity -OutputPath "$env:userprofile\Desktop" -FileName ('WindowsAnalyticsUpgradeReadinessConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))`

### Tested URLs
Windows Analytics Update Compliance
| Test URL | Representative URL | Description |
| -- | -- | -- |
| https://v10.events.data.microsoft.com | https://v10.events.data.microsoft.com | Connected User Experience and Diagnostic component endpoint for use with Windows 10 1803 and later. |
| https://v10.vortex-win.data.microsoft.com | https://v10.vortex-win.data.microsoft.com | Connected User Experience and Diagnostic component endpoint for Windows 10 1709 and earlier. |
| https://vortex.data.microsoft.com | https://vortex.data.microsoft.com | Connected User Experience and Diagnostic component endpoint for operating systems older than Windows 10. |
| https://settings-win.data.microsoft.com | https://settings-win.data.microsoft.com | Enables the compatibility update to send data to Microsoft. |
| https://adl.windows.com | https://adl.windows.com | Allows the compatibility update to receive the latest compatibility data from Microsoft. |
| https://watson.telemetry.microsoft.com | https://watson.telemetry.microsoft.com | Windows Error Reporting (WER); required for Device Health and Update Compliance AV reports. Not used by Upgrade Readiness. |
| https://oca.telemetry.microsoft.com | https://oca.telemetry.microsoft.com | Online Crash Analysis; required for Device Health and Update Compliance AV reports. Not used by Upgrade Readiness. |
    

Windows Analytics Upgrade Readiness
| Test URL | Representative URL | Description |
| -- | -- | -- |
| https://v10.events.data.microsoft.com | https://v10.events.data.microsoft.com | Connected User Experience and Diagnostic component endpoint for use with Windows 10 1803 and later. |
| https://v10.vortex-win.data.microsoft.com | https://v10.vortex-win.data.microsoft.com | Connected User Experience and Diagnostic component endpoint for Windows 10 1709 and earlier. |
| https://vortex.data.microsoft.com | https://v10.vortex-win.data.microsoft.com | Connected User Experience and Diagnostic component endpoint for operating systems older than Windows 10. |
| https://settings-win.data.microsoft.com | https://settings-win.data.microsoft.com | Enables the compatibility update to send data to Microsoft. | 
| https://adl.windows.com | https://adl.windows.com | Allows the compatibility update to receive the latest compatibility data from Microsoft. |

### References
* https://docs.microsoft.com/en-us/windows/deployment/update/windows-analytics-get-started#enable-data-sharing
* https://docs.microsoft.com/en-us/windows/deployment/upgrade/upgrade-readiness-data-sharing
* https://docs.microsoft.com/en-us/windows/privacy/configure-windows-diagnostic-data-in-your-organization#endpoints
* https://blogs.technet.microsoft.com/upgradeanalytics/2017/03/10/understanding-connectivity-scenarios-and-the-deployment-script/
* https://blogs.technet.microsoft.com/ukplatforms/2017/03/13/upgrade-readiness-client-configuration/