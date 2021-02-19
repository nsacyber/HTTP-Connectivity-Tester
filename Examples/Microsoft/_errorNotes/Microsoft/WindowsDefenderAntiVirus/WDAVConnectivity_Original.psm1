Set-StrictMode -Version 4

Import-Module -Name HttpConnectivityTester -Force

# 1. import this file:
# Import-Module .\WDAVConnectivity.psm1

# 2. run one of the following:
# $connectivity = Get-WDAVConnectivity
# $connectivity = Get-WDAVConnectivity -Verbose
# $connectivity = Get-WDAVConnectivity -PerformBlueCoatLookup
# $connectivity = Get-WDAVConnectivity -Verbose -PerformBlueCoatLookup

# 3. filter results:
# $connectivity | Format-List -Property Blocked,TestUrl,UnblockUrl,DnsAliases,IpAddresses,Description,Resolved,ActualStatusCode,ExpectedStatusCode,UnexpectedStatus

# 4. save results to a file:
# Save-Connectivity -Objects $connectivity -FileName ('WDAVConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))

Function Get-WDAVConnectivity() {
    <#
    .SYNOPSIS
    Gets connectivity information for Windows Defender Antivirus.

    .DESCRIPTION
    Gets connectivity information for Windows Defender Antivirus.

    .Parameter PerformBlueCoatLookup
    Use Symantec BlueCoat SiteReview to lookup what SiteReview category the URL is in.

    .EXAMPLE
    Get-WDAVConnectivity

    .EXAMPLE
    Get-WDAVConnectivity -Verbose

    .EXAMPLE
    Get-WDAVConnectivity -PerformBlueCoatLookup

    .EXAMPLE
    Get-WDAVConnectivity -Verbose -PerformBlueCoatLookup
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[pscustomobject]])]
    Param(
        [Parameter(Mandatory=$false, HelpMessage='Whether to perform a BlueCoat Site Review lookup on the URL. Warning: The BlueCoat Site Review REST API is rate limited.')]
        [switch]$PerformBluecoatLookup
    )

    $isVerbose = $VerbosePreference -eq 'Continue'

    $data = New-Object System.Collections.Generic.List[System.Collections.Hashtable]

    # https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-antivirus/configure-network-connections-windows-defender-antivirus#allow-connections-to-the-windows-defender-antivirus-cloud

    $data.Add(@{ TestUrl = 'https://wdcp.microsoft.com'; ExpectedStatusCode = 503; Description = 'Windows Defender Antivirus cloud-delivered protection service, also referred to as Microsoft Active Protection Service (MAPS). Used by Windows Defender Antivirus to provide cloud-delivered protection.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # cloud-delivered protection service aka MAPS https://cloudblogs.microsoft.com/enterprisemobility/2016/05/31/important-changes-to-microsoft-active-protection-service-maps-endpoint/
    $data.Add(@{ TestUrl = 'https://wdcpalt.microsoft.com'; ExpectedStatusCode = 503; Description = 'Windows Defender Antivirus cloud-delivered protection service, also referred to as Microsoft Active Protection Service (MAPS). Used by Windows Defender Antivirus to provide cloud-delivered protection.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # cloud-delivered protection service aka MAPS https://cloudblogs.microsoft.com/enterprisemobility/2016/05/31/important-changes-to-microsoft-active-protection-service-maps-endpoint/
    $data.Add(@{ TestUrl = 'https://update.microsoft.com'; UrlPattern='https://*.update.microsoft.com'; Description = 'Microsoft Update Service (MU). Signature and product updates.'; IgnoreCertificateValidationErrors=$true; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://download.microsoft.com'; UrlPattern='https://*.download.microsoft.com'; Description = 'Alternate location for Windows Defender Antivirus definition updates if the installed definitions fall out of date (7 or more days behind).'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://onboardingpackageseusprd.blob.core.windows.net'; UrlPattern='https://*.blob.core.windows.net'; Description = 'Malware submission storage. Upload location for files submitted to Microsoft via the Submission form or automatic sample submission.'; ExpectedStatusCode = 400; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # todo need to change to different URL to represent upload location for https://www.microsoft.com/en-us/wdsi/filesubmission
    $data.Add(@{ TestUrl = 'http://www.microsoft.com/pkiops/crl'; ExpectedStatusCode = 404; Description = 'Microsoft Certificate Revocation List (CRL). Used by Windows when creating the SSL connection to MAPS for updating the CRL.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'http://www.microsoft.com/pkiops/certs'; ExpectedStatusCode = 404; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'http://crl.microsoft.com/pki/crl/products'; ExpectedStatusCode = 404; Description = 'Microsoft Certificate Revocation List (CRL). Used by Windows when creating the SSL connection to MAPS for updating the CRL.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'http://www.microsoft.com/pki/certs'; ExpectedStatusCode = 404; Description = 'Microsoft certificates.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://msdl.microsoft.com/download/symbols'; Description = 'Microsoft Symbol Store. Used by Windows Defender Antivirus to restore certain critical files during remediation flows.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://vortex-win.data.microsoft.com'; ExpectedStatusCode = 404; Description = 'Used by Windows to send client diagnostic data, Windows Defender Antivirus uses this for product quality monitoring purposes.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://settings-win.data.microsoft.com'; ExpectedStatusCode = 400; Description = 'Used by Windows to send client diagnostic data, Windows Defender Antivirus uses this for product quality monitoring purposes.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://definitionupdates.microsoft.com'; Description = 'Windows Defender Antivirus definition updates for Windows 10 1709+.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://unitedstates.cp.wd.microsoft.com'; ExpectedStatusCode = 503; Description = 'Geo-affinity URL for wdcp.microsoft.com and wdcpalt.microsoft.com as of 06/26/2018 with WDAV 4.18.1806.18062+'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # appears to be a possible replacement for wdcp.microsoft.com and wdcpalt.microsoft.com as of 06/26/2018 with WDAV 4.18.1806.18062. Seems related to HKLM\SOFTWARE\Microsoft\Windows Defender\Features\    GeoPreferenceId = 'US'
    $data.Add(@{ TestUrl = 'https://adldefinitionupdates-wu.azurewebsites.net'; ExpectedStatusCode = 200; Description = 'Alternative to https://adl.windows.com which allows the compatibility update to receive the latest compatibility data from Microsoft'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'http://ctldl.windowsupdate.com'; Description='Microsoft Certificate Trust List download URL'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })

    $results = New-Object System.Collections.Generic.List[pscustomobject]

    $data | ForEach-Object {
        $connectivity = Get-HttpConnectivity @_
        $results.Add($connectivity)
    }

    return $results
}
