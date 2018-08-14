# Windows Defender SmartScreen connectivity tests

## Usage

1. Import this file: `Import-Module .\WDSSConnectivity.psm1`
1. Run one of the following:
    * `$connectivity = Get-WDSSConnectivity`
    * `$connectivity = Get-WDSSConnectivity -Verbose`
    * `$connectivity = Get-WDSSConnectivity -PerformBlueCoatLookup`
    * `$connectivity = Get-WDSSConnectivity -Verbose -PerformBlueCoatLookup`
1. Filter results: `$connectivity | Format-List -Property Blocked,TestUrl,UnblockUrl,DnsAliases,IpAddresses,Description,Resolved,ActualStatusCode,ExpectedStatusCode,UnexpectedStatus`
1. Save results to a file: `Save-HttpConnectivity -Objects $connectivity -FileName ('WDSSConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))`

## Tested URLs

| Test URL | URL to Unblock | Description |
| -- | -- | -- |
| <https://apprep.smartscreen.microsoft.com> | <https://*.smartscreen.microsoft.com> | |
| <https://ars.smartscreen.microsoft.com> | <https://*.smartscreen.microsoft.com> | SmartScreen URL used by smartscreen.exe |
| <https://c.urs.microsoft.com> | <https://*.urs.microsoft.com> | SmartScreen URL used by iexplore.exe, MicrosoftEdge.exe |
| <https://feedback.smartscreen.microsoft.com> | <https://*.smartscreen.microsoft.com> | SmartScreen URL used by browsers and users to report feedback on SmartScreen accuracy for a site |
| <https://nav.smartscreen.microsoft.com> | <https://*.smartscreen.microsoft.com> | SmartScreen URL used by smartscreen.exe |
| <https://nf.smartscreen.microsoft.com> | <https://*.smartscreen.microsoft.com> | SmartScreen URL used by NisSrv.exe |
| <https://ping.nav.smartscreen.microsoft.com> | <https://*.smartscreen.microsoft.com> | SmartScreen URL used by smartscreen.exe |
| <https://ping.nf.smartscreen.microsoft.com> | <https://*.smartscreen.microsoft.com> | SmartScreen URL used by NisSrv.exe, smartscreen.exe |
| <https://t.nav.smartscreen.microsoft.com | <https://*.smartscreen.microsoft.com> | SmartScreen URL used by smartscreen.exe |
| <https://t.nf.smartscreen.microsoft.com> | <https://*.smartscreen.microsoft.com> | SmartScreen URL used by NisSrv.exe |
| <https://t.urs.microsoft.com> | <https://*.urs.microsoft.com> | SmartScreen URL used by iexplore.exe, MicrosoftEdge.exe |
| <https://urs.microsoft.com> | <https://urs.microsoft.com> | SmartScreen URL used by iexplore.exe |
| <https://urs.smartscreen.microsoft.com> | <https://*.smartscreen.microsoft.com> | SmartScreen URL used by NisSrv.exe, smartscreen.exe, wdnsfltr.exe (Windows Defender Exploit Guard Network Protection) |

## References

* [Windows Defender SmartScreen](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-smartscreen/windows-defender-smartscreen-overview)
* [SmartScreen Filter and Resulting Internet Communication in Windows 7 and Windows Server 2008 R2](https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2008-R2-and-2008/ee126149(v=ws.10))
