Set-StrictMode -Version 4

Import-Module -Name HttpConnectivityTester -Force

# 1. import this file:
# Import-Module .\WDATPConnectivity.psm1

# 2. run one of the following:
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
        # https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-atp/configure-proxy-internet-windows-defender-advanced-threat-protection#enable-access-to-windows-defender-atp-service-urls-in-the-proxy-server

        $data.Add(@{ TestUrl = 'https://onboardingpackagescusprd.blob.core.windows.net/'; UrlPattern = 'https://*.blob.core.windows.net'; ExpectedStatusCode = 400; Description='Azure Blob storage. Eastern US data center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # onboarding package download URL, there are other sub domains for other resources
        $data.Add(@{ TestUrl = 'https://onboardingpackageseusprd.blob.core.windows.net/'; UrlPattern = 'https://*.blob.core.windows.net'; ExpectedStatusCode = 400; Description='Azure Blob storage. Central US data center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # onboarding package download URL, there are other sub domains for other resources
        $data.Add(@{ TestUrl = 'http://crl.microsoft.com'; ExpectedStatusCode = 400; Description='Microsoft Certificate Revocation List responder URL'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        $data.Add(@{ TestUrl = 'http://ctldl.windowsupdate.com'; Description='Microsoft Certificate Trust List download URL'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        $data.Add(@{ TestUrl = 'https://events.data.microsoft.com'; ExpectedStatusCode = 404; Description='WDATP event channel'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        $data.Add(@{ TestUrl = 'https://us.vortex-win.data.microsoft.com/collect/v1'; ExpectedStatusCode = 400; Description='WDATP data channel'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # might correspond to https://us.vortex-win.data.microsoft.com/health/keepalive so might be able to remove
        $data.Add(@{ TestUrl = 'https://us-v20.events.data.microsoft.com'; ExpectedStatusCode = 404; Description='WDATP event channel for 1803+'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # 1803+
        $data.Add(@{ TestUrl = 'https://winatp-gw-eus.microsoft.com/test'; Description='WDATP heartbeat/C&C channel. Eastern US data center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        $data.Add(@{ TestUrl = 'https://winatp-gw-cus.microsoft.com/test'; Description='WDATP heartbeat/C&C channel. Central US data center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })

        $data.Add(@{ TestUrl = 'https://us.vortex-win.data.microsoft.com/health/keepalive'; Description='WDATP data channel.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # might be repeat status for https://us.vortex-win.data.microsoft.com/collect/v1

        # WDATPConnectivityAnalyzer https://go.microsoft.com/fwlink/p/?linkid=823683 endpoints.txt file as of 07/05/2018:
        # https://winatp-gw-cus.microsoft.com/test
        # https://winatp-gw-eus.microsoft.com/test
        # https://winatp-gw-weu.microsoft.com/test
        # https://winatp-gw-neu.microsoft.com/test
        # https://winatp-gw-uks.microsoft.com/test
        # https://winatp-gw-ukw.microsoft.com/test
        # https://eu.vortex-win.data.microsoft.com/health/keepalive
        # https://us.vortex-win.data.microsoft.com/health/keepalive
        # https://uk.vortex-win.data.microsoft.com/health/keepalive
        # https://events.data.microsoft.com
        # https://us-v20.events.data.microsoft.com
        # https://eu-v20.events.data.microsoft.com
        # https://uk-v20.events.data.microsoft.com
        # http://ctldl.windowsupdate.com/msdownload/update/v3/static/trustedr/en/disallowedcertstl.cab    NoPinning
    }

    if ($UrlType.ToLower() -in @('all','securitycenter')) {
        $data.Add(@{ TestUrl = 'https://onboardingpackagescusprd.blob.core.windows.net/'; UrlPattern = 'https://*.blob.core.windows.net'; ExpectedStatusCode = 400; Description='Azure Blob storage. Eastern US data center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # onboarding package download URL, there are other sub domains for other resources
        $data.Add(@{ TestUrl = 'https://onboardingpackageseusprd.blob.core.windows.net/'; UrlPattern = 'https://*.blob.core.windows.net'; ExpectedStatusCode = 400; Description='Azure Blob storage. Central US data center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # onboarding package download URL, there are other sub domains for other resources
        $data.Add(@{ TestUrl = 'https://securitycenter.windows.com'; Description='Windows Defeder Security Center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        $data.Add(@{ TestUrl = 'https://login.windows.net/'; Description='Azure AD authentication'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        $data.Add(@{ TestUrl = 'https://secure.aadcdn.microsoftonline-p.com'; UrlPattern = 'https://*.microsoftonline-p.com'; ExpectedStatusCode = 400; Description='Azure AD Connect / Azure MFA / Azure ADFS'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        $data.Add(@{ TestUrl = 'https://login.microsoftonline.com'; Description='Azure AD authentication'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        $data.Add(@{ TestUrl = 'https://winatpmanagement-us.securitycenter.windows.com'; UrlPattern = 'https://*.securitycenter.windows.com'; ExpectedStatusCode = 404; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        $data.Add(@{ TestUrl = 'https://threatintel-eus.securitycenter.windows.com'; UrlPattern = 'https://*.securitycenter.windows.com'; ExpectedStatusCode = 404; Description='Threat Intel. Eastern US data center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        $data.Add(@{ TestUrl = 'https://threatintel-cus.securitycenter.windows.com'; UrlPattern = 'https://*.securitycenter.windows.com'; ExpectedStatusCode = 404; Description='Threat Intel. Central US data center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        $data.Add(@{ TestUrl = 'https://automatediracs-eus-prd.securitycenter.windows.com'; UrlPattern = 'https://*.securitycenter.windows.com'; ExpectedStatusCode = 500; Description='Automated IR. Eastern US data center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        $data.Add(@{ TestUrl = 'https://automatediracs-cus-prd.securitycenter.windows.com'; UrlPattern = 'https://*.securitycenter.windows.com'; ExpectedStatusCode = 500; Description='Automated IR. Central US data center'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        $data.Add(@{ TestUrl = 'https://winatpservicehealth.securitycenter.windows.com'; UrlPattern = 'https://*.securitycenter.windows.com'; ExpectedStatusCode = 404; Description='Service health status'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        #$data.Add(@{ TestUrl = 'https://dc.services.visualstudio.com'; ExpectedStatusCode = 404; Description='Azure Application Insights'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # https://dc.services.visualstudio.com/v2/track
        $data.Add(@{ TestUrl = 'https://userrequests-us.securitycenter.windows.com'; UrlPattern = 'https://*.securitycenter.windows.com'; ExpectedStatusCode = 404; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
        $data.Add(@{ TestUrl = 'https://winatpsecurityanalyticsapi-us.securitycenter.windows.com'; UrlPattern = 'https://*.securitycenter.windows.com'; ExpectedStatusCode = 403; Description='Secure Score security analytics'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    }

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
