Set-StrictMode -Version 4

#Import-Module -Name .\ConnectivityTester.psm1 -Force

Import-Module -Name ConnectivityTester -Force

# dot source this file 
# . .\WDAVConnectivity.ps1

# then run one of the following:
# Get-WDAVConnectivity
# Get-WDAVConnectivity -Verbose
# Get-WDAVConnectivity -Verbose -PerformBlueCoatLookup

# to filter results or save them to a file:
# $connectivity = Get-WDAVConnectivity -Verbose -PerformBlueCoatLookup
# $connectivity | Format-List -Property IsBlocked,TestUrl,Description,Resolved,ActualStatusCode,ExpectedStatusCode
# Save-Connectivity -Results $connectivity -OutputPath "$env:userprofile\Desktop" -FileName ('WDAVConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))

Function Get-WDAVConnectivity() {
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[pscustomobject]])]
    Param(       
        [Parameter(Mandatory=$false, HelpMessage='Whether to perform a BlueCoat Site Review lookup on the URL. Warning: The BlueCoat Site Review REST API is rate limited.')]
        [switch]$PerformBluecoatLookup
    )

    $parameters = $PSBoundParameters

    $isVerbose = $verbosePreference -eq 'Continue'

    $data = New-Object System.Collections.Generic.List[pscustomobject]

    # https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-antivirus/configure-network-connections-windows-defender-antivirus#allow-connections-to-the-windows-defender-antivirus-cloud

    $data.Add([pscustomobject]@{ TestUrl = 'https://wdcp.microsoft.com'; StatusCode = 503; Description = 'Windows Defender Antivirus cloud-delivered protection service, also referred to as Microsoft Active Protection Service (MAPS). Used by Windows Defender Antivirus to provide cloud-delivered protection.'; IgnoreCertificateValidationErrors=$false }) # cloud-delivered protection service aka MAPS https://cloudblogs.microsoft.com/enterprisemobility/2016/05/31/important-changes-to-microsoft-active-protection-service-maps-endpoint/
    $data.Add([pscustomobject]@{ TestUrl = 'https://wdcpalt.microsoft.com'; StatusCode = 503; Description = 'Windows Defender Antivirus cloud-delivered protection service, also referred to as Microsoft Active Protection Service (MAPS). Used by Windows Defender Antivirus to provide cloud-delivered protection.'; IgnoreCertificateValidationErrors=$false}) # cloud-delivered protection service aka MAPS https://cloudblogs.microsoft.com/enterprisemobility/2016/05/31/important-changes-to-microsoft-active-protection-service-maps-endpoint/
    $data.Add([pscustomobject]@{ TestUrl = 'https://update.microsoft.com'; StatusCode = 200; Description = '*.update.microsoft.com. Microsoft Update Service (MU). Signature and product updates.'; IgnoreCertificateValidationErrors=$true }) # changed to "update" from "updates due to possible typo of "updates" on Microsoft's page
    $data.Add([pscustomobject]@{ TestUrl = 'https://download.microsoft.com'; StatusCode = 200; Description = '*.download.microsoft.com. Alternate location for Windows Defender Antivirus definition updates if the installed definitions fall out of date (7 or more days behind).'; IgnoreCertificateValidationErrors=$false })
    $data.Add([pscustomobject]@{ TestUrl = 'https://onboardingpackageseusprd.blob.core.windows.net'; Description = '*.blob.core.windows.net. Malware submission storage. Upload location for files submitted to Microsoft via the Submission form or automatic sample submission.'; StatusCode = 400; IgnoreCertificateValidationErrors=$false }) # need to change to different URL to represent upload location for https://www.microsoft.com/en-us/wdsi/filesubmission
    $data.Add([pscustomobject]@{ TestUrl = 'http://www.microsoft.com/pkiops/crl'; StatusCode = 404; Description = 'Microsoft Certificate Revocation List (CRL). Used by Windows when creating the SSL connection to MAPS for updating the CRL.'; IgnoreCertificateValidationErrors=$false })
    $data.Add([pscustomobject]@{ TestUrl = 'http://www.microsoft.com/pkiops/certs'; StatusCode = 404; Description = ''; IgnoreCertificateValidationErrors=$false })
    $data.Add([pscustomobject]@{ TestUrl = 'http://crl.microsoft.com/pki/crl/products'; StatusCode = 404; Description = 'Microsoft Certificate Revocation List (CRL). Used by Windows when creating the SSL connection to MAPS for updating the CRL.'; IgnoreCertificateValidationErrors=$false })
    $data.Add([pscustomobject]@{ TestUrl = 'http://www.microsoft.com/pki/certs'; StatusCode = 404; Description = ''; IgnoreCertificateValidationErrors=$false })
    $data.Add([pscustomobject]@{ TestUrl = 'https://msdl.microsoft.com/download/symbols'; StatusCode = 200; Description = 'Microsoft Symbol Store. Used by Windows Defender Antivirus to restore certain critical files during remediation flows.'; IgnoreCertificateValidationErrors=$false })
    $data.Add([pscustomobject]@{ TestUrl = 'https://vortex-win.data.microsoft.com'; StatusCode = 404; Description = 'Used by Windows to send client diagnostic data, Windows Defender Antivirus uses this for product quality monitoring purposes.'; IgnoreCertificateValidationErrors=$false })
    $data.Add([pscustomobject]@{ TestUrl = 'https://settings-win.data.microsoft.com'; StatusCode = 400; Description = 'Used by Windows to send client diagnostic data, Windows Defender Antivirus uses this for product quality monitoring purposes.'; IgnoreCertificateValidationErrors=$false })

    $data.Add([pscustomobject]@{ TestUrl = 'https://unitedstates.cp.wd.microsoft.com'; StatusCode = 503; Description = ''; IgnoreCertificateValidationErrors=$false }) # appears to be a possible replacement for wdcp.microsoft.com and wdcpalt.microsoft.com as of 06/26/2018 with WDAV 4.18.1806.18062. Seems related to HKLM\SOFTWARE\Microsoft\Windows Defender\Features\    GeoPreferenceId = 'US'
    
    $results = New-Object System.Collections.Generic.List[pscustomobject]

    $data | ForEach-Object {
        $connectivity = Get-Connectivity -TestUrl $_.TestUrl -ExpectedStatusCode $_.StatusCode -Description $_.Description -IgnoreCertificateValidationErrors:($_.IgnoreCertificateValidationErrors) -PerformBluecoatLookup:$PerformBluecoatLookup -Verbose:$isVerbose
        $results.Add($connectivity)
    }  

    return $results
}