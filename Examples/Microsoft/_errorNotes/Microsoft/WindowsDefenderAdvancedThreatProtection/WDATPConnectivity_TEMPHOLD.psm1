Set-StrictMode -Version 4

Import-Module -Name HttpConnectivityTester -Force

# 1. import this file:
# Import-Module .\WDATPConnectivity.psm1

# 2. run one of the following (replace example WorkspaceId values with the value for your WDATP instance):
# $connectivity = Get-WDATPConnectivity
# $connectivity = Get-WDATPConnectivity -Verbose
# $connectivity = Get-WDATPConnectivity -Verbose -WorkspaceId 'a1a1a1a1-b2b2-c3c3-d4d4-e5e5e5e5e5e5'`
# $connectivity = Get-WDATPConnectivity -UrlType 'Endpoint' -Verbose
# $connectivity = Get-WDATPConnectivity -UrlType 'SecurityCenter' -Verbose
# $connectivity = Get-WDATPConnectivity -UrlType 'All' -Verbose
# $connectivity = Get-WDATPConnectivity -Verbose -PerformBlueCoatLookup
# $connectivity = Get-WDATPConnectivity -UrlType 'Endpoint' -PerformBlueCoatLookup -Verbose
# $connectivity = Get-WDATPConnectivity -UrlType 'SecurityCenter' -PerformBlueCoatLookup -Verbose
# $connectivity = Get-WDATPConnectivity -UrlType 'All' -PerformBlueCoatLookup -Verbose
# $connectivity = Get-WDATPConnectivity -Verbose -WorkspaceId '12345678-90AB-CDEF-GHIJ-1234567890AB'

# 3. filter results:
# $connectivity | Format-List -Property Blocked,TestUrl,UnblockUrl,DnsAliases,IpAddresses,Description,Resolved,ActualStatusCode,ExpectedStatusCode,UnexpectedStatus

# 4. save results to a file:
# Save-HttpConnectivity -Objects $connectivity -FileName ('WDATPConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))

Function Get-WDATPConnectivity() {
    <#
    .SYNOPSIS
    Gets connectivity information for Windows Defender Advanced Threat Protection.

    .DESCRIPTION
    Gets connectivity information for Windows Defender Advanced Threat Protection.

    .PARAMETER UrlType
    Selects the type of URLs to test. 'All', 'Endpoint', and 'SecurityCenter' are accepted values. 'All' is the default behavior.

    .PARAMETER WorkspaceId
    The workspace identifier used for down level operating system support for WDATP.

    .PARAMETER PerformBlueCoatLookup
    Use Symantec BlueCoat SiteReview to lookup what SiteReview category the URL is in.

    .PARAMETER WorkspaceId
    The workspace identifier used for down level operating system support for WDATP.

    .EXAMPLE
    Get-WDATPConnectivity

    .EXAMPLE
    Get-WDATPConnectivity -Verbose

    .EXAMPLE
    Get-WDATPConnectivity -Verbose -WorkspaceId 'a1a1a1a1-b2b2-c3c3-d4d4-e5e5e5e5e5e5'

    .EXAMPLE
    Get-WDATPConnectivity -Verbose -UrlType 'Endpoint'

    .EXAMPLE
    Get-WDATPConnectivity -Verbose -UrlType 'SecurityCenter'

    .EXAMPLE
    Get-WDATPConnectivity -Verbose -WorkspaceId '12345678-90AB-CDEF-GHIJ-1234567890AB'

    .EXAMPLE
    Get-WDATPConnectivity -PerformBlueCoatLookup

    .EXAMPLE
    Get-WDATPConnectivity -Verbose -PerformBlueCoatLookup
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[pscustomobject]])]
    Param(
        [Parameter(Mandatory=$false, HelpMessage='Whether to perform a BlueCoat Site Review lookup on the URL. Warning: The BlueCoat Site Review REST API is rate limited.')]
        [switch]$PerformBluecoatLookup,

        [Parameter(Mandatory=$false, HelpMessage="The type of URLs to test. 'All', 'Endpoint', or 'SecurityCenter'.")]
        [ValidateSet('All','Endpoint','SecurityCenter',IgnoreCase=$true)]
        [string]$UrlType = 'All',

        [Parameter(Mandatory=$false, HelpMessage='The workspace identifier used for down level operating system support for WDATP.')]
        [string]$WorkspaceId
    )

    $isVerbose = $VerbosePreference -eq 'Continue'

    $parameters = $PSBoundParameters

    $data = New-Object System.Collections.Generic.List[System.Collections.Hashtable]

    if ($UrlType.ToLower() -in @('all','endpoint')) {
    #=========NATE WORKED ON START==============
    # ALL ARE COMMENTED OUT - THERE ARE ONLY 2 FAULTY URLS BELOW THAT HAVE NOT BEEN SOLVED 1/20/2021  
    # Still need's Clint's confirmation regardless 
    # https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-atp/configure-proxy-internet-windows-defender-advanced-threat-protection#enable-access-to-windows-defender-atp-service-urls-in-the-proxy-server
    
        #-----------------------------------------------------------------------------------------------------------    
        ###400/400###01/25/2021###_$data.Add(@{ TestUrl = 'https://onboardingpackagescusprd.blob.core.windows.net/'; UrlPattern = 'https://*.blob.core.windows.net'; ExpectedStatusCode = 400; Description='Azure Blob storage. Eastern US data center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # onboarding package download URL, there are other sub domains for other resources
        ###400/400###01/25/2021###_$data.Add(@{ TestUrl = 'https://onboardingpackageseusprd.blob.core.windows.net/'; UrlPattern = 'https://*.blob.core.windows.net'; ExpectedStatusCode = 400; Description='Azure Blob storage. Central US data center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # onboarding package download URL, there are other sub domains for other resources
        ###400/400###01/25/2021###_$data.Add(@{ TestUrl = 'http://crl.microsoft.com'; ExpectedStatusCode = 400; Description='Microsoft Certificate Revocation List responder URL'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        ###200/200###01/25/2021###_$data.Add(@{ TestUrl = 'http://ctldl.windowsupdate.com'; Description='Microsoft Certificate Trust List download URL'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        ###404/404###01/25/2021###_$data.Add(@{ TestUrl = 'https://events.data.microsoft.com'; ExpectedStatusCode = 404; Description='WDATP event channel'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        #
        #405/400###01/25/2021###_$data.Add(@{ TestUrl = 'https://us.vortex-win.data.microsoft.com/collect/v1'; ExpectedStatusCode = 400; Description='WDATP data channel'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # might correspond to https://us.vortex-win.data.microsoft.com/health/keepalive so might be able to remove
        #404/400###01/25/2021###_$data.Add(@{ TestUrl = 'https://us.vortex-win.data.microsoft.com'; ExpectedStatusCode = 400; Description='WDATP data channel'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # might correspond to https://us.vortex-win.data.microsoft.com/health/keepalive so might be able to remove    
        #404/400###01/25/2021###_$data.Add(@{ TestUrl = 'https://v10.vortex-win.data.microsoft.com'; ExpectedStatusCode = 400; Description='WDATP data channel'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # might correspond to https://us.vortex-win.data.microsoft.com/health/keepalive so might be able to remove    
        #400/400###01/25/2021###_$data.Add(@{ TestUrl = 'https://v10.vortex-win.data.microsoft.com/collect/v1'; ExpectedStatusCode = 400; Description='WDATP data channel'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # might correspond to https://us.vortex-win.data.microsoft.com/health/keepalive so might be able to remove    
        ###200/400###01/25/2021###_$data.Add(@{ TestUrl = 'https://us.vortex-win.data.microsoft.com/ping'; ExpectedStatusCode = 400; Description='WDATP data channel'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # might correspond to https://us.vortex-win.data.microsoft.com/health/keepalive so might be able to remove    
        #
        ###404/404###01/25/2021###_$data.Add(@{ TestUrl = 'https://us-v20.events.data.microsoft.com'; ExpectedStatusCode = 404; Description='WDATP event channel for 1803+'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # 1803+
        ###200/404###01/25/2021###_$data.Add(@{ TestUrl = 'https://us-v20.events.data.microsoft.com/ping'; ExpectedStatusCode = 404; Description='WDATP event channel for 1803+'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # 1803+
        #
        ###200/200###01/25/2021###_$data.Add(@{ TestUrl = 'https://winatp-gw-eus.microsoft.com/test'; Description='WDATP heartbeat/C&C channel. Eastern US data center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        ###200/200###01/25/2021###_$data.Add(@{ TestUrl = 'https://winatp-gw-cus.microsoft.com/test'; Description='WDATP heartbeat/C&C channel. Central US data center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        #
        #404/200###01/25/2021###_$data.Add(@{ TestUrl = 'https://us.vortex-win.data.microsoft.com/health/keepalive'; Description='WDATP data channel.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # might be repeat status for https://us.vortex-win.data.microsoft.com/collect/v1
        #404/200###01/25/2021###_$data.Add(@{ TestUrl = 'https://us.vortex-win.data.microsoft.com/health/'; Description='WDATP data channel.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # might be repeat status for https://us.vortex-win.data.microsoft.com/collect/v1
        #404/200$##01/25/2021###_#data.Add(@{ TestUrl = 'https://v10c.events.data.microsoft.com/health/keepalive'; Description='WDATP data channel.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # might be repeat status for https://us.vortex-win.data.microsoft.com/collect/v1
        #404/200###01/25/2021###_$data.Add(@{ TestUrl = 'https://v10c.events.data.microsoft.com/health/'; Description='WDATP data channel.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # might be repeat status for https://us.vortex-win.data.microsoft.com/collect/v1
        #404/200###01/25/2021###_$data.Add(@{ TestUrl = 'https://v10c.events.data.microsoft.com/'; Description='WDATP data channel.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # might be repeat status for https://us.vortex-win.data.microsoft.com/collect/v1
        #404/200###01/25/2021###_$data.Add(@{ TestUrl = 'https://v10.events.data.microsoft.com/'; Description='WDATP data channel.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # might be repeat status for https://us.vortex-win.data.microsoft.com/collect/v1
        #404/200###01/25/2021###_$data.Add(@{ TestUrl = 'https://v10.vortex-win.data.microsoft.com/'; Description='WDATP data channel.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # might be repeat status for https://us.vortex-win.data.microsoft.com/collect/v1
        #404/200###01/25/2021###_$data.Add(@{ TestUrl = 'https://us.vortex-win.data.microsoft.com/'; Description='WDATP data channel.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # might be repeat status for https://us.vortex-win.data.microsoft.com/collect/v1
        #404/200###01/25/2021###_$data.Add(@{ TestUrl = 'https://us.vortex-win.data.microsoft.com/collect/'; Description='WDATP data channel.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # might be repeat status for https://us.vortex-win.data.microsoft.com/collect/v1
        #405/200###01/25/2021###_$data.Add(@{ TestUrl = 'https://us.vortex-win.data.microsoft.com/collect/v1'; Description='WDATP data channel.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # might be repeat status for https://us.vortex-win.data.microsoft.com/collect/v1
        #400/400#>>>#400/200###01/25/2021###_$data.Add(@{ TestUrl = 'https://v10.vortex-win.data.microsoft.com/collect/v1'; Description='WDATP data channel.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # might be repeat status for https://us.vortex-win.data.microsoft.com/collect/v1
        ###200/200###01/25/2021###_$data.Add(@{ TestUrl = 'https://us.vortex-win.data.microsoft.com/ping'; Description='WDATP data channel.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # might be repeat status for https://us.vortex-win.data.microsoft.com/collect/v1
        #
        #-------- Commented Out START------------------------------------------------------------------------------------------------------------
        # WDATPConnectivityAnalyzer https://go.microsoft.com/fwlink/p/?linkid=823683 endpoints.txt file as of 01/25/2021:
        # https://winatp-gw-cus.microsoft.com/test
        # https://winatp-gw-eus.microsoft.com/test
        # https://winatp-gw-weu.microsoft.com/test
        # https://winatp-gw-neu.microsoft.com/test
        # https://winatp-gw-uks.microsoft.com/test
        # https://winatp-gw-ukw.microsoft.com/test
        # https://winatp-gw-usgv.microsoft.com/test
        # https://winatp-gw-usgt.microsoft.com/test
        # https://eu.vortex-win.data.microsoft.com/ping
        # https://us.vortex-win.data.microsoft.com/ping
        # https://uk.vortex-win.data.microsoft.com/ping
        # https://events.data.microsoft.com/ping
        # https://settings-win.data.microsoft.com/qos
        # https://eu-v20.events.data.microsoft.com/ping
        # https://uk-v20.events.data.microsoft.com/ping
        # https://us-v20.events.data.microsoft.com/ping
        # https://us4-v20.events.data.microsoft.com/ping
        # https://us5-v20.events.data.microsoft.com/ping
        # http://ctldl.windowsupdate.com/msdownload/update/v3/static/trustedr/en/disallowedcertstl.cab	NoPinning
    }####

    if ($UrlType.ToLower() -in @('all','securitycenter')) {
        ###400/400###01/25/2021###_$data.Add(@{ TestUrl = 'https://onboardingpackagescusprd.blob.core.windows.net/'; UrlPattern = 'https://*.blob.core.windows.net'; ExpectedStatusCode = 400; Description='Azure Blob storage. Eastern US data center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # onboarding package download URL, there are other sub domains for other resources
        ###400/400###01/25/2021###_$data.Add(@{ TestUrl = 'https://onboardingpackageseusprd.blob.core.windows.net/'; UrlPattern = 'https://*.blob.core.windows.net'; ExpectedStatusCode = 400; Description='Azure Blob storage. Central US data center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # onboarding package download URL, there are other sub domains for other resources
        ###200/200###01/25/2021###_$data.Add(@{ TestUrl = 'https://securitycenter.windows.com'; Description='Windows Defender Security Center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        #
        #000/200###01/25/2021###_$data.Add(@{ TestUrl = 'https://login.windows.net/'; Description='Azure AD authentication'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        #404/200###01/25/2021###_$data.Add(@{ TestUrl = 'https://login.windows.net/test'; Description='Azure AD authentication'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        #404/200###01/25/2021###_$data.Add(@{ TestUrl = 'https://login.windows.net/ping'; Description='Azure AD authentication'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        #404/200###01/25/2021###_$data.Add(@{ TestUrl = 'https://login.windows.net/qos'; Description='Azure AD authentication'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        #-->https://login.windows.net --> redirects to login.microsoftonline.com....
        #000/200###01/25/2021###_$data.Add(@{ TestUrl = 'https://login.microsoftonline.com/'; Description='Azure AD authentication'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        #404/200###01/25/2021###_$data.Add(@{ TestUrl = 'https://login.microsoftonline.com/test'; Description='Azure AD authentication'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        #404/200###01/25/2021###_$data.Add(@{ TestUrl = 'https://login.microsoftonline.com/ping'; Description='Azure AD authentication'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        ###200/200###01/25/2021###_$data.Add(@{ TestUrl = 'https://login.microsoftonline.com/common/oauth2/'; Description='Azure AD authentication'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        #000/200###01/25/2021###_$data.Add(@{ TestUrl = 'https://login.windows.us/'; Description='Azure AD authentication'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        #404/200###01/25/2021###_$data.Add(@{ TestUrl = 'https://login.windows.net/common'; Description='Azure AD authentication'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        # N/A $data.Add(@{ TestUrl = 'https://login.windows.net*'; Description='Azure AD authentication'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        #404/200###01/25/2021###_$data.Add(@{ TestUrl = 'https://login.windows.net/*'; Description='Azure AD authentication'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        # N/A $data.Add(@{ TestUrl = 'https://login.windows.net.*'; Description='Azure AD authentication'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        ###200/200###01/25/2021###_$data.Add(@{ TestUrl = 'https://login.windows.net/common/oauth2/'; Description='Azure AD authentication'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        #
        ###400/400###01/25/2021###_$data.Add(@{ TestUrl = 'https://secure.aadcdn.microsoftonline-p.com'; UrlPattern = 'https://*.microsoftonline-p.com'; ExpectedStatusCode = 400; Description='Azure AD Connect / Azure MFA / Azure ADFS'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        #
        #000/200###01/25/2021###_$data.Add(@{ TestUrl = 'https://login.microsoftonline.com'; Description='Azure AD authentication'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        ###200/200###01/25/2021###_$data.Add(@{ TestUrl = 'https://login.microsoftonline.com/common/oauth2/'; Description='Azure AD authentication'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        ###200/200###01/25/2021###_$data.Add(@{ TestUrl = 'https://login.microsoftonline.us'; Description='Azure AD authentication'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        #
        ###404/404###01/25/2021###_$data.Add(@{ TestUrl = 'https://winatpmanagement-us.securitycenter.windows.com'; UrlPattern = 'https://*.securitycenter.windows.com'; ExpectedStatusCode = 404; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        ###404/404###01/25/2021###_$data.Add(@{ TestUrl = 'https://threatintel-eus.securitycenter.windows.com'; UrlPattern = 'https://*.securitycenter.windows.com'; ExpectedStatusCode = 404; Description='Threat Intel. Eastern US data center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        ###404/404###01/25/2021###_$data.Add(@{ TestUrl = 'https://threatintel-cus.securitycenter.windows.com'; UrlPattern = 'https://*.securitycenter.windows.com'; ExpectedStatusCode = 404; Description='Threat Intel. Central US data center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        #
        #000/500###01/25/2021###_$data.Add(@{ TestUrl = 'https://automatediracs-eus-prd.securitycenter.windows.com'; UrlPattern = 'https://*.securitycenter.windows.com'; ExpectedStatusCode = 500; Description='Automated IR. Eastern US data center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        #-->https://automatediracs-eus-prd.securitycenter.windows.com --> This URL is active on newest Microsoft mdatp-url spreadsheet, BUT - my machine-internet is 'Missing required root certificate for Symantec Blue Coat
        #-->Cant do anything with URL on the unsecured Remote testing machine. Donot get the same Symantec error on RDP as we did in Empire.
        #-->https://securitycenter.windows.com --> redirects to https://login.microsoftonline.com/common/oauth2/
        #200/500###01/25/2021###_$data.Add(@{ TestUrl = 'https://securitycenter.windows.com'; UrlPattern = 'https://*.securitycenter.windows.com'; ExpectedStatusCode = 500; Description='Automated IR. Eastern US data center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        #-->https://securitycenter.windows.com is expected to be 200, so that works, but I can't tell if it works for the ...automatediracs....
        #000/500###01/25/2021###_$data.Add(@{ TestUrl = 'https://*.securitycenter.windows.com'; ExpectedStatusCode = 500; Description='Automated IR. Eastern US data center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        #000/500###01/25/2021###_$data.Add(@{ TestUrl = 'https://*prd.securitycenter.windows.com'; ExpectedStatusCode = 500; Description='Automated IR. Eastern US data center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        #000/500###01/25/2021###_$data.Add(@{ TestUrl = 'https://*eus-prd.securitycenter.windows.com'; ExpectedStatusCode = 500; Description='Automated IR. Eastern US data center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        #000/500###01/25/2021###_$data.Add(@{ TestUrl = 'https://*automatediracs-eus-prd.securitycenter.windows.com'; ExpectedStatusCode = 500; Description='Automated IR. Eastern US data center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        #000/500###01/25/2021###_$data.Add(@{ TestUrl = 'https://automatediracs-eus-prd.securitycenter.windows.com'; UrlPattern = 'https://*.securitycenter.windows.com'; ExpectedStatusCode = 500; Description='Automated IR. Eastern US data center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        #000/500###01/25/2021###_$data.Add(@{ TestUrl = 'https://automatediracs-eus-prd.securitycenter.windows.com/qos'; UrlPattern = 'https://*.securitycenter.windows.com/qos'; ExpectedStatusCode = 500; Description='Automated IR. Eastern US data center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        # N/A   ###01/25/2021###_$data.Add(@{ TestUrl = 'https://*.securitycenter.windows.com/qos'; UrlPattern = 'https://*.securitycenter.windows.com/qos'; ExpectedStatusCode = 500; Description='Automated IR. Eastern US data center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        #000/500###01/25/2021###_$data.Add(@{ TestUrl = 'https://automatediracs-eus-prd.securitycenter.windows.com/common'; UrlPattern = 'https://*.securitycenter.windows.com'; ExpectedStatusCode = 500; Description='Automated IR. Eastern US data center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        #000/500###01/25/2021###_$data.Add(@{ TestUrl = 'https://automatediracs-eus-prd.securitycenter.windows.com/test'; UrlPattern = 'https://*.securitycenter.windows.com'; ExpectedStatusCode = 500; Description='Automated IR. Eastern US data center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        #000/500###01/25/2021###_$data.Add(@{ TestUrl = 'https://automatediracs-eus-prd.securitycenter.windows.com/ping'; UrlPattern = 'https://*.securitycenter.windows.com'; ExpectedStatusCode = 500; Description='Automated IR. Eastern US data center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })        
        #000/500###01/25/2021###_$data.Add(@{ TestUrl = 'https://automatediracs-eus-prd.securitycenter.windows.com/check'; UrlPattern = 'https://*.securitycenter.windows.com'; ExpectedStatusCode = 500; Description='Automated IR. Eastern US data center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        $data.Add(@{ TestUrl = 'https://automatediracs-eus-prd.securitycenter.windows.com/check'; UrlPattern = 'https://*.securitycenter.windows.com'; ExpectedStatusCode = 500; Description='Automated IR. Eastern US data center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })


        #           ^^^ These two are the only ones that error with the Symantec Blue Coat not being installed properly. vvv
        #
        # --> https://automatediracs-cus-prd.securitycenter.windows.com --> This URL is NOT active on newest Microsoft mdatp-url spreadsheet, BUT - my machine-internet is 'Missing required root certificate for Symantec Blue Coat'
        #000/500###01/25/2021###_$data.Add(@{ TestUrl = 'https://automatediracs-cus-prd.securitycenter.windows.com'; UrlPattern = 'https://*.securitycenter.windows.com'; ExpectedStatusCode = 500; Description='Automated IR. Central US data center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        #404/500###01/25/2021###_$data.Add(@{ TestUrl = 'https://api.securitycenter.microsoft.com/'; UrlPattern = 'https://*.securitycenter.windows.com'; ExpectedStatusCode = 500; Description='Automated IR. Central US data center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        $data.Add(@{ TestUrl = 'https://api.securitycenter.microsoft.com/'; UrlPattern = 'https://*.securitycenter.windows.com'; ExpectedStatusCode = 500; Description='Automated IR. Central US data center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        
        #
        ###404/404###01/25/2021###_$data.Add(@{ TestUrl = 'https://winatpservicehealth.securitycenter.windows.com'; UrlPattern = 'https://*.securitycenter.windows.com'; ExpectedStatusCode = 404; Description='Service health status'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        ###404/404###01/25/2021###_$data.Add(@{ TestUrl = 'https://dc.services.visualstudio.com'; ExpectedStatusCode = 404; Description='Azure Application Insights'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # https://dc.services.visualstudio.com/v2/track
        ###404/404###01/25/2021###_$data.Add(@{ TestUrl = 'https://userrequests-us.securitycenter.windows.com'; UrlPattern = 'https://*.securitycenter.windows.com'; ExpectedStatusCode = 404; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        ###403/403###01/25/2021###_$data.Add(@{ TestUrl = 'https://winatpsecurityanalyticsapi-us.securitycenter.windows.com'; UrlPattern = 'https://*.securitycenter.windows.com'; ExpectedStatusCode = 403; Description='Secure Score security analytics'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        ###400/400###01/25/2021###_$data.Add(@{ TestUrl = 'https://static2.sharepointonline.com'; UrlPattern = 'https://static2.sharepointonline.com'; ExpectedStatusCode = 400; Description='Host for Microsoft Fabric Assets containing fonts, icons, and stylesheets used by Microsoft cloud service user interfaces'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    }
    #=========NATE WORKED ON END==============

    # downlevel URL tests
    if ($parameters.ContainsKey('WorkspaceId')) {
        $data.Add(@{ TestUrl = "https://$WorkspaceId.oms.opinsights.azure.com"; UrlPattern = 'https://*.oms.opinsights.azure.com'; ExpectedStatusCode = 403; Description='Microsoft Management Agent communication'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        $data.Add(@{ TestUrl = "https://$WorkspaceId.ods.opinsights.azure.com"; UrlPattern = 'https://*.ods.opinsights.azure.com'; ExpectedStatusCode = 403; Description='Azure OMS data collection'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })

        # ncus and eus2 are other options https://docs.microsoft.com/en-us/azure/log-analytics/log-analytics-oms-gateway#agent-service-urls
        $data.Add(@{ TestUrl = 'https://scus-agentservice-prod-1.azure-automation.net'; UrlPattern = 'https://*.azure-automation.net'; ExpectedStatusCode = 400; Description='Azure Automation. Process and workflow automation'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })

        # eusaaomssa.blob.core.windows.net is another option
        $data.Add(@{ TestUrl = 'https://scadvisorcontent.blob.core.windows.net'; UrlPattern = 'https://*.blob.core.windows.net'; ExpectedStatusCode = 400; Description='System Center Advisor content'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    }

    $uniqueUrls = @($data | ForEach-Object { [pscustomobject]$_ } | Select-Object -Property TestUrl -ExpandProperty TestUrl -Unique)

    $results = New-Object System.Collections.Generic.List[pscustomobject]

    $data | Where-Object { ([pscustomobject]$_).TestUrl -in $uniqueUrls } | ForEach-Object {
        $connectivity = Get-HttpConnectivity @_
        $results.Add($connectivity)
    }

    $authenticatedProxyValue = Get-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\DataCollection' | Select-Object -Property DisableEnterpriseAuthProxy -ExpandProperty DisableEnterpriseAuthProxy -ErrorAction SilentlyContinue

    $useAuthenticatedProxy = $null -eq $authenticatedProxyValue -or $authenticatedProxyValue -eq 0

    $isRunningAsSystem = [bool](&"$env:systemroot\system32\whoami.exe" | Select-String -Pattern '^nt authority\\system$' -Quiet) #$env:username -eq "$env:computername$"

    if ($useAuthenticatedProxy -and $isRunningAsSystem) {
        Write-Warning -Message 'This script must be run as a user to ensure accurate results since the diagnostic tracking service is configured to use a user authenticating proxy'
    }

    if (!$useAuthenticatedProxy -and !$isRunningAsSystem) {
        Write-Warning -Message 'This script must be run as SYSTEM to ensure accurate results since the diagnostic tracking service is not configured to use a user authenticating proxy'
    }

    return $results
}
