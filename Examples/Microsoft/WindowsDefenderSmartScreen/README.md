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
| <https://ars.smartscreen.microsoft.com> | <https://*.smartscreen.microsoft.com> | SmartScreen URL used by Windows Defender SmartScreen (smartscreen.exe) |
| <https://c.urs.microsoft.com> | <https://*.urs.microsoft.com> | SmartScreen URL used by Internet Explorer (iexplore.exe), Edge (MicrosoftEdge.exe) |
| <https://feedback.smartscreen.microsoft.com> | <https://*.smartscreen.microsoft.com> | SmartScreen URL used by users to report feedback on SmartScreen accuracy for a URL |
| <https://nav.smartscreen.microsoft.com> | <https://*.smartscreen.microsoft.com> | SmartScreen URL used by Windows Defender SmartScreen (smartscreen.exe) |
| <https://nf.smartscreen.microsoft.com> | <https://*.smartscreen.microsoft.com> | SmartScreen URL used by Windows Defender Antivirus Network Inspection Service (NisSrv.exe) |
| <https://ping.nav.smartscreen.microsoft.com> | <https://*.smartscreen.microsoft.com> | SmartScreen URL used by Windows Defender SmartScreen (smartscreen.exe) |
| <https://ping.nf.smartscreen.microsoft.com> | <https://*.smartscreen.microsoft.com> | SmartScreen URL used by Windows Defender Antivirus Network Inspection Service (NisSrv.exe), Windows Defender SmartScreen (smartscreen.exe) |
| <https://t.nav.smartscreen.microsoft.com> | <https://*.smartscreen.microsoft.com> | SmartScreen URL used by Windows Defender SmartScreen (smartscreen.exe) |
| <https://t.nf.smartscreen.microsoft.com> | <https://*.smartscreen.microsoft.com> | SmartScreen URL used by Windows Defender Antivirus Network Inspection Service (NisSrv.exe) |
| <https://t.urs.microsoft.com> | <https://*.urs.microsoft.com> | SmartScreen URL used by Internet Explorer (iexplore.exe), Edge (MicrosoftEdge.exe) |
| <https://unitedstates.smartscreen.microsoft.com> | <https://unitedstates.smartscreen.microsoft.com> | SmartScreen URL used by Windows Defender Antivirus Network Inspection Service (NisSrv.exe) and Windows Defender SmartScreen (smartscreen.exe) |
| <https://urs.microsoft.com> | <https://urs.microsoft.com> | SmartScreen URL used by Internet Explorer (iexplore.exe) |
| <https://urs.smartscreen.microsoft.com> | <https://*.smartscreen.microsoft.com> | SmartScreen URL used by Windows Defender Antivirus Network Inspection Service (NisSrv.exe), Windows Defender SmartScreen (smartscreen.exe), Windows Defender Exploit Guard Network Protection (wdnsfltr.exe) |

## Notes

* <https://urs.microsoft.com> and <https://*.urs.microsoft.com> URLs are used by Internet Explorer (iexplore.exe) and Edge (MicrosoftEdge.exe) browsers.
* <https://*.smartscreen.microsoft.com> URLs are used by Windows Defender Antivirus Network Inspection Service (NisSrv.exe), Windows Defender SmartScreen (smartscreen.exe), and Windows Defender Exploit Guard Network Protection (wdnsfltr.exe).

## WDATP query
```kusto
NetworkCommunicationEvents
| where RemoteUrl matches regex @'.*urs\.microsoft\.com.*|.*smartscreen\.microsoft\.com.*'
| where InitiatingProcessFileName != "powershell.exe" 
| summarize count() by RemoteUrl,RemotePort
| order by count_ desc 
```

## References

* [Windows Defender SmartScreen](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-smartscreen/windows-defender-smartscreen-overview)
* [SmartScreen Filter and Resulting Internet Communication in Windows 7 and Windows Server 2008 R2](https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2008-R2-and-2008/ee126149(v=ws.10))
