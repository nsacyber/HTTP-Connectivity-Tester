# Windows Update connectivity tests

## Usage

1. Import this file: `Import-Module .\WindowsUpdateConnectivity.psm1`
1. Run one of the following:
    * `$connectivity = Get-WindowsUpdateConnectivity`
    * `$connectivity = Get-WindowsUpdateConnectivity -Verbose`
    * `$connectivity = Get-WindowsUpdateConnectivity -PerformBlueCoatLookup`
    * `$connectivity = Get-WindowsUpdateConnectivity -Verbose -PerformBlueCoatLookup`
1. Filter results: `$connectivity | Format-List -Property Blocked,TestUrl,UnblockUrl,DnsAliases,IpAddresses,Description,Resolved,ActualStatusCode,ExpectedStatusCode,UnexpectedStatus`
1. Save results to a file: `Save-HttpConnectivity -Objects $connectivity -FileName ('WindowsUpdateConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))`

## Tested URLs

| Test URL | URL to Unblock | Description |
| -- | -- | -- |
| <http://windowsupdate.microsoft.com> | <http://windowsupdate.microsoft.com> | |
| <https://windowsupdate.microsoft.com> | <https://windowsupdate.microsoft.com> | |
| <https://geo-prod.do.dsp.mp.microsoft.com> | <https://*.do.dsp.mp.microsoft.com> | |
| <http://download.windowsupdate.com> | <http://download.windowsupdate.com> | |
| <http://au.download.windowsupdate.com> | <http://*.au.download.windowsupdate.com> | |
| <https://cds.d2s7q6s2.hwcdn.net> | <https://cds.*.hwcdn.net> | |
| <http://cs9.wac.phicdn.net> | <http://*.wac.phicdn.net> | |
| <https://cs491.wac.edgecastcdn.net> | <https://*.wac.edgecastcdn.net> | |
| <http://dl.delivery.mp.microsoft.com> | <http://*.dl.delivery.mp.microsoft.com> | |
| <http://tlu.dl.delivery.mp.microsoft.com> | <http://*.tlu.dl.delivery.mp.microsoft.com> | |
| <https://emdl.ws.microsoft.com> | <https://emdl.ws.microsoft.com> | |
| <https://fe2.update.microsoft.com> | <https://*.update.microsoft.com> | |
| <https://sls.update.microsoft.com> | <https://*.update.microsoft.com> | |
| <https://fe3.delivery.mp.microsoft.com> | <https://*.delivery.mp.microsoft.com> | |
| <https://tsfe.trafficshaping.dsp.mp.microsoft.com> | <https://*.dsp.mp.microsoft.com> | |

## References

* [Manage Windows 10 connection endpoints - Windows Update](https://docs.microsoft.com/en-us/windows/privacy/manage-windows-endpoints#windows-update)
* [Windows Update troubleshooting - Issues related to HTTP/Proxy](https://docs.microsoft.com/en-us/windows/deployment/update/windows-update-troubleshooting#issues-related-to-httpproxy)
* [How to Configure a Firewall for Software Updates](https://docs.microsoft.com/en-us/previous-versions/system-center/configuration-manager-2007/bb693717(v=technet.10))