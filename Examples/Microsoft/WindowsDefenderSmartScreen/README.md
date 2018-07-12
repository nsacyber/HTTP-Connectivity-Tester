## Windows Defender SmartScreen connectivity tests

### Usage 
1. Import this file: `Import-Module .\WDSSConnectivity.psm1`
1. Run one of the following:
    * `$connectivity = Get-WDSSConnectivity`
    * `$connectivity = Get-WDSSConnectivity -Verbose`
    * `$connectivity = Get-WDSSConnectivity -PerformBlueCoatLookup`
    * `$connectivity = Get-WDSSConnectivity -Verbose -PerformBlueCoatLookup`
1. Filter results: `$connectivity | Format-List -Property IsBlocked,TestUrl,Description,Resolved,ActualStatusCode,ExpectedStatusCode`
1. Save results to a file: `Save-Connectivity -Results $connectivity -OutputPath "$env:userprofile\Desktop" -FileName ('WDSSConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))`

### Tested URLs

| Test URL | Representative URL | Description |
| -- | -- | -- |
| https://apprep.smartscreen.microsoft.com | https://*.smartscreen.microsoft.com | | 
| https://ars.smartscreen.microsoft.com | https://*.smartscreen.microsoft.com | | 
| https://c.urs.microsoft.com | https://*.urs.microsoft.com | | 
| https://feedback.smartscreen.microsoft.com | https://*.smartscreen.microsoft.com | |   
| https://nav.smartscreen.microsoft.com | https://*.smartscreen.microsoft.com | | 
| https://nf.smartscreen.microsoft.com | https://*.smartscreen.microsoft.com | | 
| https://ping.nav.smartscreen.microsoft.com | https://*.smartscreen.microsoft.com | | 
| https://ping.nf.smartscreen.microsoft.com | https://*.smartscreen.microsoft.com | | 
| https://t.nf.smartscreen.microsoft.com | https://*.smartscreen.microsoft.com | |   
| https://t.urs.microsoft.com | https://*.urs.microsoft.com | | 
| https://urs.microsoft.com | https://urs.microsoft.com | | 
| https://urs.smartscreen.microsoft.com | https://*.smartscreen.microsoft.com | | 

### References
* https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-smartscreen/windows-defender-smartscreen-overview
* https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2008-R2-and-2008/ee126149(v=ws.10)