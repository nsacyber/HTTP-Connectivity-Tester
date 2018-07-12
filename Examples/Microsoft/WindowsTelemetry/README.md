## Windows Telemetry connectivity tests

### Usage
1. Import this file: `Import-Module .\WindowsTelemetryConnectivity.psm1`
1. Run one of the following:
    * `$connectivity = Get-WindowsTelemetryConnectivity`
    * `$connectivity = Get-WindowsTelemetryConnectivity -Verbose`
    * `$connectivity = Get-WindowsTelemetryConnectivity -PerformBlueCoatLookup`
    * `$connectivity = Get-WindowsTelemetryConnectivity -Verbose -PerformBlueCoatLookup`
1. Filter results: `$connectivity | Format-List -Property IsBlocked,TestUrl,Description,Resolved,ActualStatusCode,ExpectedStatusCode`
1. Save results to a file: `Save-Connectivity -Results $connectivity -OutputPath "$env:userprofile\Desktop" -FileName ('WindowsTelemetryConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))`

### Tested URLs

| Test URL | Representative URL | Description |
| -- | -- | -- |
| https://v10.vortex-win.data.microsoft.com/collect/v1 | https://v10.vortex-win.data.microsoft.com | Diagnostic/telemetry data for Windows 10 1607 and later. |
| https://v20.vortex-win.data.microsoft.com/collect/v1 | https://v20.vortex-win.data.microsoft.com | Diagnostic/telemetry data for Windows 10 1703 and later. |
| https://settings-win.data.microsoft.com | https://settings-win.data.microsoft.com | Used by applications, such as Windows Connected User Experiences and Telemetry component and Windows Insider Program, to dynamically update their configuration. |
| https://watson.telemetry.microsoft.com | https://watson.telemetry.microsoft.com | Windows Error Reporting (WER) data. |
| https://oca.telemetry.microsoft.com | https://oca.telemetry.microsoft.com | Online Crash Analysis (OCA) data. |
| https://vortex.data.microsoft.com/collect/v1 | https://vortex.data.microsoft.com | OneDrive application for Windows 10 data. |

### References 
* https://docs.microsoft.com/en-us/windows/privacy/configure-windows-diagnostic-data-in-your-organization#endpoints
* https://docs.microsoft.com/en-us/windows/desktop/wer/windows-error-reporting 
* https://docs.microsoft.com/en-us/windows/desktop/DxTechArts/crash-dump-analysis