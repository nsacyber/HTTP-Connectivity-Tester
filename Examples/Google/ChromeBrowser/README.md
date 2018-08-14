# Chrome update connectivity tests

## Usage

1. Import this file: `Import-Module .\ChromeUpdateConnectivity.psm1`
1. Run one of the following:
    * `$connectivity = Get-ChromeUpdateConnectivity`
    * `$connectivity = Get-ChromeUpdateConnectivity -Verbose`
    * `$connectivity = Get-ChromeUpdateConnectivity -PerformBlueCoatLookup`
    * `$connectivity = Get-ChromeUpdateConnectivity -Verbose -PerformBlueCoatLookup`
1. Filter results: `$connectivity | Format-List -Property Blocked,TestUrl,UnblockUrl,DnsAliases,IpAddresses,Description,Resolved,ActualStatusCode,ExpectedStatusCode,UnexpectedStatus`
1. Save results to a file: `Save-HttpConnectivity "$env:userprofile\Desktop" -FileName ('ChromeUpdateConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))`

## Tested URLs

| Test URL | URL to Unblock | Description |
| -- | -- | -- |
| <http://redirector.gvt1.com> | <http://*.gvt1.com> | |
| <https://redirector.gvt1.com> | <https://*.gvt1.com> | |
| <http://update.googleapis.com/service/update2> | <http://update.googleapis.com> | |
| <https://update.googleapis.com/service/update2> |<https://update.googleapis.com> | |
| <https://clients2.google.com> | <https://clients2.google.com> | |
| <https://clients5.google.com> | <https://clients5.google.com> | |
| <https://tools.google.com> | <https://tools.google.com> | |
| <http://dl.google.com> | <http://dl.google.com> | |

## References

* [Manage Chrome updates (Windows) - Questions - What URLs are used for Chrome Browser updates?](https://support.google.com/chrome/a/answer/6350036?hl=en)