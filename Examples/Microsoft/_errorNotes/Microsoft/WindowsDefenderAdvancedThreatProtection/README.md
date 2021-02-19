# Windows Defender Advanced Threat Protection connectivity tests

## Documentation

The [Get-WDATPConnectivity](./../../../docs/Get-WDATPConnectivity.md) command supports additional parameters (e.g. UrlType, WorkspaceId) other than what is implemented by the [Get-HttpConnectivity](./../../../docs/Get-HttpConnectivity.md) command. See the [Get-WDATPConnectivity](./../../../docs/Get-WDATPConnectivity.md) documentation for more information.

## Usage

1. Import this file: `Import-Module .\WDATPConnectivity.psm1`
1. Run one of the following (replace example WorkspaceId values with the value for your WDATP instance):
    * `$connectivity = Get-WDATPConnectivity`
    * `$connectivity = Get-WDATPConnectivity -Verbose`
    * `$connectivity = Get-WDATPConnectivity -WorkspaceId 'a1a1a1a1-b2b2-c3c3-d4d4-e5e5e5e5e5e5' -Verbose`
    * `$connectivity = Get-WDATPConnectivity -UrlType 'Endpoint' -Verbose`
    * `$connectivity = Get-WDATPConnectivity -UrlType 'SecurityCenter' -Verbose`
    * `$connectivity = Get-WDATPConnectivity -UrlType 'All' -Verbose`
    * `$connectivity = Get-WDATPConnectivity -Verbose -PerformBlueCoatLookup`
    * `$connectivity = Get-WDATPConnectivity -UrlType 'Endpoint' -PerformBlueCoatLookup -Verbose`
    * `$connectivity = Get-WDATPConnectivity -UrlType 'SecurityCenter' -PerformBlueCoatLookup -Verbose`
    * `$connectivity = Get-WDATPConnectivity -UrlType 'All' -PerformBlueCoatLookup -Verbose`
    * `$connectivity = Get-WDATPConnectivity -WorkspaceId '12345678-90AB-CDEF-GHIJ-1234567890AB' -Verbose`
1. Filter results: `$connectivity | Format-List -Property Blocked,TestUrl,UnblockUrl,DnsAliases,IpAddresses,Description,Resolved,ActualStatusCode,ExpectedStatusCode,UnexpectedStatus`
1. Save results to a file: `Save-HttpConnectivity -Objects $connectivity -FileName ('WDATPConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))`

## Tested URLs

### URLs for the built-in Sense Service

URLs for WDATP built-in support (Windows 10 1607+, Windows Server 1803, and Windows Server 2019+) that uses the Sense service. These URLs must be unblocked and functional from endpoints that are going to be onboarded to WDATP.

| Test URL | URL to Unblock | Description |
| -- | -- | -- |
| <https://onboardingpackagescusprd.blob.core.windows.net> | <https://*.blob.core.windows.net> | Azure Blob storage. Eastern US data center. |
| <https://onboardingpackageseusprd.blob.core.windows.net> | <https://*.blob.core.windows.net> | Azure Blob storage. Central US data center. |
| <http://crl.microsoft.com> | <http://crl.microsoft.com> | Microsoft Certificate Revocation List responder URL. |
| <http://ctldl.windowsupdate.com> | <http://ctldl.windowsupdate.com> | Microsoft Certificate Trust List download URL. |
| <https://events.data.microsoft.com> | <https://events.data.microsoft.com> | WDATP event channel. |
| <https://us.vortex-win.data.microsoft.com/collect/v1> | <https://us.vortex-win.data.microsoft.com> | WDATP data channel. |
| <https://us-v20.events.data.microsoft.com> | <https://us-v20.events.data.microsoft.com> | WDATP event channel for 1803+. |
| <https://winatp-gw-eus.microsoft.com/test> | <https://winatp-gw-eus.microsoft.com> | WDATP heartbeat/C&C channel. Eastern US data center. |
| <https://winatp-gw-cus.microsoft.com/test> | <https://winatp-gw-cus.microsoft.com> | WDATP heartbeat/C&C channel. Central US data center. |

### Add-on Microsoft Management Agent

URLs for WDATP down level support (Windows 7, Windows 8.1, Windows Server 2012, Windows Server 2012 R2, Windows Server 2016) that uses the Microsoft Management Agent. These URLs must be unblocked and functional from endpoints that are going to be onboarded to WDATP.

The Workspace ID of the WDATP tenant is needed to test connectivity for down level support. The Workspace ID can be found in the WDATP Security Center under **Settings** > **Machine management** > **Onboarding** by selecting the **Windows 7 SP1 and 8.1** or **Windows Server 2012 R2 and 2016** option.

| Test URL | URL to Unblock | Description |
| -- | -- | -- |
| <https://_workspaceid_.oms.opinsights.azure.com>  | <https://*.oms.opinsights.azure.com> | Microsoft Management Agent communication. |
| <https://_workspaceid_.ods.opinsights.azure.com> | <https://*.ods.opinsights.azure.com> | Azure OMS data collection. |
| <https://scus-agentservice-prod-1.azure-automation.net> | <https://*.azure-automation.net> | Azure Automation. Process and workflow automation. |
| <https://scadvisorcontent.windows.blob.core.net> | <https://*.blob.core.windows.net> | System Center Advisor content. |

### Windows Defender Security Center

URLs for accessing the WDATP dashboard called the Windows Defender Security Center. These URLs must be unblocked and functional from endpoints used to perform analysis of endpoints onboarded to WDATP.

| Test URL | URL to Unblock | Description |
| -- | -- | -- |
| <https://onboardingpackagescusprd.blob.core.windows.net> | <https://*.blob.core.windows.net> | Azure Blob storage. Eastern US data center. |
| <https://onboardingpackageseusprd.blob.core.windows.net> | <https://*.blob.core.windows.net> | Azure Blob storage. Central US data center. |
| <https://securitycenter.windows.com> | <https://securitycenter.windows.com> | Windows Defender Security Center. |
| <https://login.windows.net> | <https://login.windows.net> | Azure AD authentication. |
| <https://secure.aadcdn.microsoftonline-p.com> | <https://*.microsoftonline-p.com> | Azure AD Connect / Azure MFA / Azure ADFS. |
| <https://login.microsoftonline.com> | <https://login.microsoftonline.com> | Azure AD authentication |
| <https://winatpmanagement-us.securitycenter.windows.com> | <https://*.securitycenter.windows.com> | |
| <https://threatintel-eus.securitycenter.windows.com> | <https://*.securitycenter.windows.com> | Threat Intel. Eastern US data center. |
| <https://threatintel-cus.securitycenter.windows.com> | <https://*.securitycenter.windows.com> | Threat Intel. Central US data center. |
| <https://automatediracs-eus-prd.securitycenter.windows.com> | <https://*.securitycenter.windows.com> | Automated IR. Eastern US data center. |
| <https://automatediracs-cus-prd.securitycenter.windows.com> | <https://*.securitycenter.windows.com> | Automated IR. Central US data center. |
| <https://winatpservicehealth.securitycenter.windows.com> | <https://*.securitycenter.windows.com> | Service health status. |
| <https://userrequests-us.securitycenter.windows.com> | <https://*.securitycenter.windows.com> | |
| <https://winatpsecurityanalyticsapi-us.securitycenter.windows.com> | <https://*.securitycenter.windows.com> | Secure Score security analytics. |
| <https://static2.sharepointonline.com> | <https://static2.sharepointonline.com> | Host for Microsoft Fabric Assets containing fonts, icons, and stylesheets used by Microsoft cloud service user interfaces. |

## References

* [Configure machine proxy and Internet connectivity settings - Enable access to Windows Defender ATP service URLs in the proxy server](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-atp/configure-proxy-internet-windows-defender-advanced-threat-protection#enable-access-to-windows-defender-atp-service-urls-in-the-proxy-server)
* [Onboard previous versions of Windows - Configure proxy and Internet connectivity settings](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-atp/onboard-downlevel-windows-defender-advanced-threat-protection#configure-proxy-and-internet-connectivity-settings)
* [Troubleshoot subscription and portal access issues - Portal communication issues](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-atp/troubleshoot-onboarding-error-messages-windows-defender-advanced-threat-protection#portal-communication-issues)
* [WDATPConnectivityAnalyzer](https://go.microsoft.com/fwlink/p/?linkid=823683)
