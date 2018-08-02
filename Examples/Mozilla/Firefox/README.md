## Firefox update connectivity tests

### Usage

1. Import this file: `Import-Module .\FirefoxUpdateConnectivity.psm1`
1. Run one of the following:
    * `$connectivity = Get-FirefoxUpdateConnectivity`
    * `$connectivity = Get-FirefoxUpdateConnectivity -Verbose`
    * `$connectivity = Get-FirefoxUpdateConnectivity -PerformBlueCoatLookup`
    * `$connectivity = Get-FirefoxUpdateConnectivity -Verbose -PerformBlueCoatLookup`
1. Filter results: `$connectivity | Format-List -Property Blocked,TestUrl,UnblockUrl,DnsAliases,IpAddresses,Description,Resolved,ActualStatusCode,ExpectedStatusCode`
1. Save results to a file: `Save-HttpConnectivity -Results $connectivity -OutputPath "$env:userprofile\Desktop" -FileName ('FirefoxUpdateConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))`

### Tested URLs
| Test URL | URL to Unblock | Description |
| -- | -- | -- |
| https://aus3.mozilla.org | https://aus3.mozilla.org | Firefox update check |
| https://aus4.mozilla.org | https://aus4.mozilla.org| Firefox update check |
| https://aus5.mozilla.org | https://aus5.mozilla.org | Firefox update check |
| https://download.cdn.mozilla.net | https://download.cdn.mozilla.net | Firefox update download |
| https://archive.mozilla.org | https://archive.mozilla.org | Firefox update download |
| https://ftp.mozilla.org | https://ftp.mozilla.org | Firefox update download |
| https://versioncheck.addons.mozilla.org | https://versioncheck.addons.mozilla.org | Firefox add-on/extension update check |
| https://versioncheck-bg.addons.mozilla.org | https://swdist.apple.com | Firefox add-on/extension update check |
  
### References
* [Balrog - Environments](https://wiki.mozilla.org/Balrog#Environments)
* [Balrog Client Domains - SSL Certificates](https://wiki.mozilla.org/Balrog/Client_Domains#SSL_Certificates)
* [Eligible Websites and Services - Firefox Updates (AUS/Balrug)](https://www.mozilla.org/en-US/security/bug-bounty/web-eligible-sites/)