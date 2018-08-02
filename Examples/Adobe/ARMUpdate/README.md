## Adobe Reader Manager update connectivity tests

### Usage

1. Import this file: `Import-Module .\ARMUpdateConnectivity.psm1`
1. Run one of the following:
    * `$connectivity = Get-ARMUpdateConnectivity`
    * `$connectivity = Get-ARMUpdateConnectivity -Verbose`
    * `$connectivity = Get-ARMUpdateConnectivity -PerformBlueCoatLookup`
    * `$connectivity = Get-ARMUpdateConnectivity -Verbose -PerformBlueCoatLookup`
1. Filter results: `$connectivity | Format-List -Property Blocked,TestUrl,UnblockUrl,DnsAliases,IpAddresses,Description,Resolved,ActualStatusCode,ExpectedStatusCode`
1. Save results to a file: `Save-HttpConnectivity -Results $connectivity -OutputPath "$env:userprofile\Desktop" -FileName ('ARMUpdateConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))`

### Tested URLs
| Test URL | URL to Unblock | Description |
| -- | -- | -- |
| http://armmf.adobe.com | http://armmf.adobe.com | Adobe update metadata download |
| https://armmf.adobe.com | https://armmf.adobe.com | Adobe update metadata download |
| http://ardownload.adobe.com | http://ardownload.adobe.com | Adobe updates download |
| https://ardownload.adobe.com | https://ardownload.adobe.com | Adobe updates download |
| http://ardownload2.adobe.com | http://ardownload2.adobe.com | Adobe incremental updates download |
| https://ardownload2.adobe.com| https://ardownload2.adobe.com | Adobe incremental updates download |
| http://crl.adobe.com| http://crl.adobe.com | Adobe Certificate Revocation List |
  
### References
* [Adobe Enterprise Toolkit >> Enterprise Administration Guide >> Service and Online Feature Configuration - Endpoint Configuration](https://www.adobe.com/devnet-docs/acrobatetk/tools/AdminGuide/services.html#endpoint-configuration)