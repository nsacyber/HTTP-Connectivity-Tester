## Windows Defender Antivirus connectivity tests

### Usage 
1. Import this file: `Import-Module .\WDAVConnectivity.psm1`
1. Run one of the following:
    * `$connectivity = Get-WDAVConnectivity`
    * `$connectivity = Get-WDAVConnectivity -Verbose`
    * `$connectivity = Get-WDAVConnectivity -PerformBlueCoatLookup`
    * `$connectivity = Get-WDAVConnectivity -Verbose -PerformBlueCoatLookup`
1. Filter results: `$connectivity | Format-List -Property IsBlocked,TestUrl,UnblockUrl,Description,Resolved,ActualStatusCode,ExpectedStatusCode`
1. Save results to a file: `Save-HttpConnectivity -Results $connectivity -OutputPath "$env:userprofile\Desktop" -FileName ('WDAVConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))`

### Tested URLs

| Test URL | URL to Unblock | Description |
| -- | -- | -- |
| https://wdcp.microsoft.com | https://wdcp.microsoft.com | Windows Defender Antivirus cloud-delivered protection service, also referred to as Microsoft Active Protection Service (MAPS). Used by Windows Defender Antivirus to provide cloud-delivered protection. |
| https://wdcpalt.microsoft.com | https://wdcpalt.microsoft.com | Windows Defender Antivirus cloud-delivered protection service, also referred to as Microsoft Active Protection Service (MAPS). Used by Windows Defender Antivirus to provide cloud-delivered protection. |
| https://update.microsoft.com | https://*.update.microsoft.com | Microsoft Update Service (MU). Signature and product updates. |
| https://download.microsoft.com | https://*.download.microsoft.com | Alternate location for Windows Defender Antivirus definition updates if the installed definitions fall out of date (7 or more days behind). |
| https://onboardingpackageseusprd.blob.core.windows.net | https://*.blob.core.windows.net | Malware submission storage. Upload location for files submitted to Microsoft via the Submission form or automatic sample submission. |
| http://www.microsoft.com/pkiops/crl | http://www.microsoft.com/pkiops | Microsoft Certificate Revocation List (CRL). Used by Windows when creating the SSL connection to MAPS for updating the CRL. |
| http://www.microsoft.com/pkiops/certs | http://www.microsoft.com/pkiops | |
| http://crl.microsoft.com/pki/crl/products | http://crl.microsoft.com | Microsoft Certificate Revocation List (CRL). Used by Windows when creating the SSL connection to MAPS for updating the CRL. |
| http://www.microsoft.com/pki/certs | http://www.microsoft.com/pki | | 
| https://msdl.microsoft.com/download/symbols | https://msdl.microsoft.com/download/symbols | Microsoft Symbol Store. Used by Windows Defender Antivirus to restore certain critical files during remediation flows. |
| https://vortex-win.data.microsoft.com | https://vortex-win.data.microsoft.com | Used by Windows to send client diagnostic data, Windows Defender Antivirus uses this for product quality monitoring purposes. |
| https://settings-win.data.microsoft.com | https://settings-win.data.microsoft.com | Used by Windows to send client diagnostic data, Windows Defender Antivirus uses this for product quality monitoring purposes. |
| https://unitedstates.cp.wd.microsoft.com | https://unitedstates.cp.wd.microsoft.com | Geo-affinity URL for wdcp.microsoft.com and wdcpalt.microsoft.com as of 06/26/2018 with WDAV 4.18.1806.18062+. | 

### References
* https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-antivirus/configure-network-connections-windows-defender-antivirus#allow-connections-to-the-windows-defender-antivirus-cloud