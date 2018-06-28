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
# $connectivity | Format-List -Property IsBlocked,ActualStatusCode,ExpectedStatusCode,TestUrl
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
	
    $ignore=$false	

    # https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-antivirus/configure-network-connections-windows-defender-antivirus

    $data.Add([pscustomobject]@{ TestUrl = 'https://unitedstates.cp.wd.microsoft.com'; StatusCode = 503; IgnoreCertificateValidationErrors=$ignore }) # appears to be the replacement for wdcp.microsoft.com and wdcpalt.microsoft.com as of 06/26/2018 with WDAV 4.18.1806.18062. Seems related to HKLM\SOFTWARE\Microsoft\Windows Defender\Features\    GeoPreferenceId = 'US'
    $data.Add([pscustomobject]@{ TestUrl = 'https://wdcp.microsoft.com'; StatusCode = 503; IgnoreCertificateValidationErrors=$ignore }) # cloud-delivered protection service aka MAPS https://cloudblogs.microsoft.com/enterprisemobility/2016/05/31/important-changes-to-microsoft-active-protection-service-maps-endpoint/
    $data.Add([pscustomobject]@{ TestUrl = 'https://wdcpalt.microsoft.com'; StatusCode = 503; IgnoreCertificateValidationErrors=$ignore}) # cloud-delivered protection service aka MAPS https://cloudblogs.microsoft.com/enterprisemobility/2016/05/31/important-changes-to-microsoft-active-protection-service-maps-endpoint/
    $data.Add([pscustomobject]@{ TestUrl = 'https://update.microsoft.com'; StatusCode = 200; IgnoreCertificateValidationErrors=$true }) # changed to "update" from "updates due to possible typo of "updates" on Microsoft's page
    $data.Add([pscustomobject]@{ TestUrl = 'https://download.microsoft.com'; StatusCode = 200; IgnoreCertificateValidationErrors=$ignore })
    $data.Add([pscustomobject]@{ TestUrl = 'https://onboardingpackageseusprd.blob.core.windows.net' ; StatusCode = 400; IgnoreCertificateValidationErrors=$ignore }) # need to change to different URL to represent upload location for https://www.microsoft.com/en-us/wdsi/filesubmission
    $data.Add([pscustomobject]@{ TestUrl = 'http://www.microsoft.com/pkiops/crl'; StatusCode = 404; IgnoreCertificateValidationErrors=$ignore })
    $data.Add([pscustomobject]@{ TestUrl = 'http://www.microsoft.com/pkiops/certs'; StatusCode = 404; IgnoreCertificateValidationErrors=$ignore })
    $data.Add([pscustomobject]@{ TestUrl = 'http://crl.microsoft.com/pki/crl/products'; StatusCode = 404; IgnoreCertificateValidationErrors=$ignore })
    $data.Add([pscustomobject]@{ TestUrl = 'http://www.microsoft.com/pki/certs'; StatusCode = 404; IgnoreCertificateValidationErrors=$ignore })
    $data.Add([pscustomobject]@{ TestUrl = 'https://msdl.microsoft.com/download/symbols'; StatusCode = 200; IgnoreCertificateValidationErrors=$ignore })
    $data.Add([pscustomobject]@{ TestUrl = 'https://vortex-win.data.microsoft.com'; StatusCode = 404; IgnoreCertificateValidationErrors=$ignore })
    $data.Add([pscustomobject]@{ TestUrl = 'https://settings-win.data.microsoft.com'; StatusCode = 400; IgnoreCertificateValidationErrors=$ignore })

    $results = New-Object System.Collections.Generic.List[pscustomobject]

    $data | ForEach-Object {
        $connectivity = Get-Connectivity -TestUrl $_.TestUrl -ExpectedStatusCode $_.StatusCode -IgnoreCertificateValidationErrors:($_.IgnoreCertificateValidationErrors) -PerformBluecoatLookup:$PerformBluecoatLookup -Verbose:$isVerbose
        $results.Add($connectivity)
    }  

    return $results
}