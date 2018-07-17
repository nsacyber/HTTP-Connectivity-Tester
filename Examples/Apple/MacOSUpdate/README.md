## macOS update connectivity tests

### Usage

1. Import this file: `Import-Module .\MacOSUpdateConnectivity.psm1`
1. Run one of the following:
    * `$connectivity = Get-MacOSUpdateConnectivity`
    * `$connectivity = Get-MacOSUpdateConnectivity -Verbose`
    * `$connectivity = Get-MacOSUpdateConnectivity -PerformBlueCoatLookup`
    * `$connectivity = Get-MacOSUpdateConnectivity -Verbose -PerformBlueCoatLookup`
1. Filter results: `$connectivity | Format-List -Property IsBlocked,TestUrl,UnblockUrl,Description,Resolved,ActualStatusCode,ExpectedStatusCode`
1. Save results to a file: `Save-HttpConnectivity -Results $connectivity -OutputPath "$env:userprofile\Desktop" -FileName ('MacOSUpdateConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))`

### Tested URLs
| Test URL | URL to Unblock | Description |
| -- | -- | -- |
| https://swscan.apple.com | https://swscan.apple.com | |
| https://swcdnlocator.apple.com | https://swcdnlocator.apple.com |
| https://swdownload.apple.com | https://swdownload.apple.com | |
| https://swcdn.apple.com | https://swcdn.apple.com | |
| https://swdist.apple.com | https://swdist.apple.com | |
  
### References
* https://support.apple.com/en-us/HT200149
* https://support.apple.com/en-us/HT202943
* https://github.com/bntjah/lancache/issues/36
* https://www.richard-purves.com/2016/09/10/apple-services/
* https://support.apple.com/en-us/HT203609