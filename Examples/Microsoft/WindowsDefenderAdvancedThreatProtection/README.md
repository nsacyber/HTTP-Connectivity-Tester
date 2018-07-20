## Windows Defender Advanced Threat Protection connectivity tests

### Usage 
1. Import this file: `Import-Module .\WDATPConnectivity.psm1`
1. Run one of the following:
    * `$connectivity = Get-WDATPConnectivity`
    * `$connectivity = Get-WDATPConnectivity -Verbose`
    * `$connectivity = Get-WDATPConnectivity -UrlType 'Endpoint' -Verbose`
    * `$connectivity = Get-WDATPConnectivity -UrlType 'SecurityCenter' -Verbose`
    * `$connectivity = Get-WDATPConnectivity -UrlType 'All' -Verbose`
    * `$connectivity = Get-WDATPConnectivity -Verbose -PerformBlueCoatLookup`
    * `$connectivity = Get-WDATPConnectivity -UrlType 'Endpoint' -PerformBlueCoatLookup -Verbose`
    * `$connectivity = Get-WDATPConnectivity -UrlType 'SecurityCenter' -PerformBlueCoatLookup -Verbose`
    * `$connectivity = Get-WDATPConnectivity -UrlType 'All' -PerformBlueCoatLookup -Verbose`
1. Filter results: `$connectivity | Format-List -Property IsBlocked,TestUrl,UnblockUrl,Description,Resolved,ActualStatusCode,ExpectedStatusCode`
1. Save results to a file: `Save-HttpConnectivity -Results $connectivity -OutputPath "$env:userprofile\Desktop" -FileName ('WDATPConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))`

### Tested URLs

Endpoint URLs for WDATP built-in support (Windows 10 1607+, Windows Server 1803, and Windows Server 2019+)

| Test URL | URL to Unblock | Description |
| -- | -- | -- |
| https://onboardingpackagescusprd.blob.core.windows.net | https://*.blob.core.windows.net | Azure Blob storage. Eastern US data center. |
| https://onboardingpackageseusprd.blob.core.windows.net | https://*.blob.core.windows.net | Azure Blob storage. Central US data center. |
| http://crl.microsoft.com | http://crl.microsoft.com | Microsoft Certificate Revocation List responder URL. |
| http://ctldl.windowsupdate.com | http://ctldl.windowsupdate.com | Microsoft Certificate Trust List download URL. |
| https://events.data.microsoft.com | https://events.data.microsoft.com | WDATP event channel. | 
| https://us.vortex-win.data.microsoft.com/collect/v1 | https://us.vortex-win.data.microsoft.com | WDATP data channel. | 
| https://us-v20.events.data.microsoft.com | https://us-v20.events.data.microsoft.com | WDATP event channel for 1803+. |
| https://winatp-gw-eus.microsoft.com/test | https://winatp-gw-eus.microsoft.com | WDATP heartbeat/C&C channel. Eastern US data center. |
| https://winatp-gw-cus.microsoft.com/test | https://winatp-gw-cus.microsoft.com | WDATP heartbeat/C&C channel. Central US data center. | 
  
  
Endpoint URLs for WDATP downlevel Microsoft Management Agent support (Windows 7, Windows 8.1, Windows Server 2012, Windows Server 2012 R2, Windows Server 2016)

| Test URL | URL to Unblock | Description |
| -- | -- | -- |
| https://_workspaceid_.oms.opinsights.azure.com  | https://*.oms.opinsights.azure.com | Microsoft Management Agent communication. |
| https://_workspaceid_.opinsights.azure.com | https://*.ods.opinsights.azure.com | Azure OMS data collection. |
| | https://*.azure-automation.net| Azure Automation. Process and workflow automation. |
 
 
Windows Defender Security Center URLs.

| Test URL | Representative URL | Description |
| -- | -- | -- |
| https://onboardingpackagescusprd.blob.core.windows.net | https://*.blob.core.windows.net | Azure Blob storage. Eastern US data center. |
| https://onboardingpackageseusprd.blob.core.windows.net | https://*.blob.core.windows.net | Azure Blob storage. Central US data center. |
| https://securitycenter.windows.com | https://securitycenter.windows.com | Windows Defender Security Center. |
| https://login.windows.net | https://login.windows.net | Azure AD authentication. |
| https://secure.aadcdn.microsoftonline-p.com | https://*.microsoftonline-p.com | Azure AD Connect / Azure MFA / Azure ADFS. | 
| https://login.microsoftonline.com | https://login.microsoftonline.com | Azure AD authentication |
| https://winatpmanagement-us.securitycenter.windows.com | https://*.securitycenter.windows.com | |
| https://threatintel-eus.securitycenter.windows.com | https://*.securitycenter.windows.com | Threat Intel. Eastern US data center. |
| https://threatintel-cus.securitycenter.windows.com | https://*.securitycenter.windows.com | Threat Intel. Central US data center. |
| https://automatediracs-eus-prd.securitycenter.windows.com | https://*.securitycenter.windows.com | Automated IR. Eastern US data center. |
| https://automatediracs-cus-prd.securitycenter.windows.com | https://*.securitycenter.windows.com | Automated IR. Central US data center. |
| https://winatpservicehealth.securitycenter.windows.com | https://*.securitycenter.windows.com | Service health status. | 
| https://userrequests-us.securitycenter.windows.com | https://*.securitycenter.windows.com | |
| https://winatpsecurityanalyticsapi-us.securitycenter.windows.com | https://*.securitycenter.windows.com | Secure Score security analytics. |

### References
* [Configure machine proxy and Internet connectivity settings - Enable access to Windows Defender ATP service URLs in the proxy server](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-atp/configure-proxy-internet-windows-defender-advanced-threat-protection#enable-access-to-windows-defender-atp-service-urls-in-the-proxy-server)
* [Onboard previous versions of Windows - Configure proxy and Internet connectivity settings](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-atp/onboard-downlevel-windows-defender-advanced-threat-protection#configure-proxy-and-internet-connectivity-settings)
* [WDATPConnectivityAnalyzer](https://go.microsoft.com/fwlink/p/?linkid=823683)