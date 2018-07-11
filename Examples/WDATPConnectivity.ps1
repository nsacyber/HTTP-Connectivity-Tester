Set-StrictMode -Version 4

#Import-Module -Name .\ConnectivityTester.psm1 -Force

Import-Module -Name ConnectivityTester -Force

# dot source this file 
# . .\WDATPConnectivity.ps1

# then run one of the following:
# Get-WDATPConnectivity
# Get-WDATPConnectivity -Verbose
# Get-WDATPConnectivity -UrlType 'Endpoint' -Verbose
# Get-WDATPConnectivity -UrlType 'SecurityCenter' -Verbose
# Get-WDATPConnectivity -UrlType 'All' -Verbose
# Get-WDATPConnectivity -Verbose -PerformBlueCoatLookup
# Get-WDATPConnectivity -UrlType 'Endpoint' -PerformBlueCoatLookup -Verbose 
# Get-WDATPConnectivity -UrlType 'SecurityCenter' -PerformBlueCoatLookup -Verbose
# Get-WDATPConnectivity -UrlType 'All' -PerformBlueCoatLookup -Verbose

# to filter results or save them to a file:
# $connectivity = Get-WDATPConnectivity -Verbose -PerformBlueCoatLookup
# $connectivity | Format-List -Property IsBlocked,TestUrl,Description,Resolved,ActualStatusCode,ExpectedStatusCode
# Save-Connectivity -Results $connectivity -OutputPath "$env:userprofile\Desktop" -FileName ('WDATPConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))

Function Get-WDATPConnectivity() {
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[pscustomobject]])]
    Param(       
        [Parameter(Mandatory=$false, HelpMessage='Whether to perform a BlueCoat Site Review lookup on the URL. Warning: The BlueCoat Site Review REST API is rate limited.')]
        [switch]$PerformBluecoatLookup,
        
        [Parameter(Mandatory=$false, HelpMessage="The type of URLs to test. 'All', 'Endpoint', or 'SecurityCenter'")]
        [ValidateSet('All','Endpoint','SecurityCenter',IgnoreCase=$true)]
        [string]$UrlType = 'All'
    )

    $parameters = $PSBoundParameters

    $isVerbose = $verbosePreference -eq 'Continue'

    $data = New-Object System.Collections.Generic.List[pscustomobject]

    if ($UrlType.ToLower() -in @('all','endpoint')) {
        # https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-atp/configure-proxy-internet-windows-defender-advanced-threat-protection#enable-access-to-windows-defender-atp-service-urls-in-the-proxy-server

        $data.Add([pscustomobject]@{ TestUrl = 'https://onboardingpackagescusprd.blob.core.windows.net/'; StatusCode = 400; Description='https://*.blob.core.windows.net - Azure Blob storage. Eastern US data center'; }) # onboarding package download URL, there are other sub domains for other resources
        $data.Add([pscustomobject]@{ TestUrl = 'https://onboardingpackageseusprd.blob.core.windows.net/'; StatusCode = 400; Description='https://*.blob.core.windows.net - Azure Blob storage. Central US data center'; }) # onboarding package download URL, there are other sub domains for other resources
        $data.Add([pscustomobject]@{ TestUrl = 'http://crl.microsoft.com'; StatusCode = 400; Description='Microsoft Certificate Revocation List responder URL'; })
        $data.Add([pscustomobject]@{ TestUrl = 'http://ctldl.windowsupdate.com'; StatusCode = 200; Description='Microsoft Certificate Trust List download URL'; })
        $data.Add([pscustomobject]@{ TestUrl = 'https://events.data.microsoft.com'; StatusCode = 404; Description=''; })
        $data.Add([pscustomobject]@{ TestUrl = 'https://us.vortex-win.data.microsoft.com/collect/v1'; StatusCode = 400; Description='WDATP data channel'; }) # might correspond to https://us.vortex-win.data.microsoft.com/health/keepalive so might be able to remove
        #$data.Add([pscustomobject]@{ TestUrl = 'https://v20.events.data.microsoft.com'; StatusCode = 200; Description=''; }) # 1803+ might be a Windows Analytics URL
        $data.Add([pscustomobject]@{ TestUrl = 'https://us-v20.events.data.microsoft.com'; StatusCode = 404; Description=''; }) # 1803+ 
        $data.Add([pscustomobject]@{ TestUrl = 'https://winatp-gw-eus.microsoft.com/test'; StatusCode = 200; Description='WDATP heartbeat/C&C channel - Eastern US data center'; })
        $data.Add([pscustomobject]@{ TestUrl = 'https://winatp-gw-cus.microsoft.com/test'; StatusCode = 200; Description='WDATP heartbeat/C&C channel - Central US data center'; })

        $data.Add([pscustomobject]@{ TestUrl = 'https://us.vortex-win.data.microsoft.com/health/keepalive'; StatusCode = 200; Description=''; }) # might be repeat status for https://us.vortex-win.data.microsoft.com/collect/v1
    
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
        # http://ctldl.windowsupdate.com/msdownload/update/v3/static/trustedr/en/disallowedcertstl.cab	NoPinning
    }
    
    if ($UrlType.ToLower() -in @('all','securitycenter')) {
        $data.Add([pscustomobject]@{ TestUrl = 'https://onboardingpackagescusprd.blob.core.windows.net/'; StatusCode = 400; Description='https://*.blob.core.windows.net - Azure Blob storage. Eastern US data center'; }) # onboarding package download URL, there are other sub domains for other resources
        $data.Add([pscustomobject]@{ TestUrl = 'https://onboardingpackageseusprd.blob.core.windows.net/'; StatusCode = 400; Description='https://*.blob.core.windows.net - Azure Blob storage. Central US data center'; }) # onboarding package download URL, there are other sub domains for other resources
        $data.Add([pscustomobject]@{ TestUrl = 'https://securitycenter.windows.com'; StatusCode = 200; Description='Windows Defender Security Center'; })
        $data.Add([pscustomobject]@{ TestUrl = 'https://login.windows.net/'; StatusCode = 200; Description='Azure AD authentication'; })
        #$data.Add([pscustomobject]@{ TestUrl = 'https://securitycenter.onmicrosoft.com'; StatusCode = 400; Description='Windows Defender Security Center instance'; }) # DNS failure
        $data.Add([pscustomobject]@{ TestUrl = 'https://secure.aadcdn.microsoftonline-p.com'; StatusCode = 400; Description='https://*.microsoftonline-p.com - Azure AD Connect / Azure MFA / Azure ADFS'; })
        $data.Add([pscustomobject]@{ TestUrl = 'https://login.microsoftonline.com'; StatusCode = 200; Description='Azure AD authentication'; })
        $data.Add([pscustomobject]@{ TestUrl = 'https://winatpmanagement-us.securitycenter.windows.com'; StatusCode = 404; Description='https://*.securitycenter.windows.com'; })
        $data.Add([pscustomobject]@{ TestUrl = 'https://threatintel-eus.securitycenter.windows.com'; StatusCode = 404; Description='https://*.securitycenter.windows.com - Threat Intel Eastern US data center'; })
        $data.Add([pscustomobject]@{ TestUrl = 'https://threatintel-cus.securitycenter.windows.com'; StatusCode = 404; Description='https://*.securitycenter.windows.com - Threat Intel Central US data center'; })
        $data.Add([pscustomobject]@{ TestUrl = 'https://automatediracs-eus-prd.securitycenter.windows.com'; StatusCode = 500; Description='https://*.securitycenter.windows.com - Automated IR Eastern US data center'; })
        $data.Add([pscustomobject]@{ TestUrl = 'https://automatediracs-cus-prd.securitycenter.windows.com'; StatusCode = 500; Description='https://*.securitycenter.windows.com - Automated IR Central US data center'; })
        $data.Add([pscustomobject]@{ TestUrl = 'https://winatpservicehealth.securitycenter.windows.com'; StatusCode = 404; Description='https://*.securitycenter.windows.com'; })
        # $data.Add([pscustomobject]@{ TestUrl = 'https://dc.services.visualstudio.com'; StatusCode = 404; Description='Azure Application Insights'; }) # https://dc.services.visualstudio.com/v2/track
        $data.Add([pscustomobject]@{ TestUrl = 'https://userrequests-us.securitycenter.windows.com'; StatusCode = 404; Description='https://*.securitycenter.windows.com'; })
        $data.Add([pscustomobject]@{ TestUrl = 'https://winatpsecurityanalyticsapi-us.securitycenter.windows.com'; StatusCode = 403; Description='https://*.securitycenter.windows.com'; })
    }
    
    $uniqueUrls = @($data | Select-Object -Property TestUrl -ExpandProperty TestUrl -Unique)   

    $results = New-Object System.Collections.Generic.List[pscustomobject]

    $data | Where-Object {$_.TestUrl -in $uniqueUrls } | ForEach-Object {
        $connectivity = Get-Connectivity -TestUrl $_.TestUrl -ExpectedStatusCode $_.StatusCode -Description $_.Description -PerformBluecoatLookup:$PerformBluecoatLookup -Verbose:$isVerbose
        $results.Add($connectivity)
    }

    $authenticatedProxyValue = Get-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\DataCollection' | Select-Object -Property DisableEnterpriseAuthProxy -ExpandProperty DisableEnterpriseAuthProxy -ErrorAction SilentlyContinue

    $useAuthenticatedProxy = $authenticatedProxyValue -eq $null -or $authenticatedProxyValue -eq 0

    $isRunningAsSystem = [bool](&"$env:systemroot\system32\whoami.exe" | Select-String -Pattern '^nt authority\\system$' -Quiet) #$env:username -eq "$env:computername$"

    if ($useAuthenticatedProxy -and $isRunningAsSystem) {
        Write-Warning -Message 'This script must be run as a user to ensure accurate results since the diagnostic tracking service is configured to use a user authenticating proxy'
    }

    if (!$useAuthenticatedProxy -and !$isRunningAsSystem) {
        Write-Warning -Message 'This script must be run as SYSTEM to ensure accurate results since the diagnostic tracking service is not configured to use a user authenticating proxy'
    }

    return $results
}