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
# Save-Connectivity -Results $connectivity -OutputPath "$env:userprofile\Desktop" -FileName ('WDATPConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))

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

    # https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-atp/configure-proxy-internet-windows-defender-advanced-threat-protection#enable-access-to-windows-defender-atp-service-urls-in-the-proxy-server

    $data.Add([pscustomobject]@{ TestUrl = 'https://wdcp.microsoft.com'; StatusCode = 503; }) # cloud-delivered protection service aka MAPS https://cloudblogs.microsoft.com/enterprisemobility/2016/05/31/important-changes-to-microsoft-active-protection-service-maps-endpoint/
    $data.Add([pscustomobject]@{ TestUrl = 'https://wdcpalt.microsoft.com'; StatusCode = 503; }) # cloud-delivered protection service aka MAPS https://cloudblogs.microsoft.com/enterprisemobility/2016/05/31/important-changes-to-microsoft-active-protection-service-maps-endpoint/
    $data.Add([pscustomobject]@{ TestUrl = 'https://updates.microsoft.com'; StatusCode = 400; })
    $data.Add([pscustomobject]@{ TestUrl = 'https://download.microsoft.com'; StatusCode = 200; })
    $data.Add([pscustomobject]@{ TestUrl = 'https://onboardingpackageseusprd.blob.core.windows.net'; StatusCode = 400; }) # need to change to different URL to represent upload location for https://www.microsoft.com/en-us/wdsi/filesubmission
    $data.Add([pscustomobject]@{ TestUrl = 'http://www.microsoft.com/pkiops/crl'; StatusCode = 404; })
    $data.Add([pscustomobject]@{ TestUrl = 'http://www.microsoft.com/pkiops/certs'; StatusCode = 404; })
    $data.Add([pscustomobject]@{ TestUrl = 'http://crl.microsoft.com/pki/crl/products'; StatusCode = 404; })
    $data.Add([pscustomobject]@{ TestUrl = 'http://www.microsoft.com/pki/certs'; StatusCode = 404; })
    $data.Add([pscustomobject]@{ TestUrl = 'https://msdl.microsoft.com/download/symbols'; StatusCode = 200; })
    $data.Add([pscustomobject]@{ TestUrl = 'https://vortex-win.data.microsoft.com'; StatusCode = 404; })
    $data.Add([pscustomobject]@{ TestUrl = 'https://settings-win.data.microsoft.com'; StatusCode = 400; })

    $results = New-Object System.Collections.Generic.List[pscustomobject]

    $data | ForEach-Object {
        $statusCode = $_.StatusCode

        $connectivity = Get-Connectivity -TestUrl $_.TestUrl -ExpectedStatusCode $_.StatusCode -PerformBluecoatLookup:$PerformBluecoatLookup -Verbose:$isVerbose
        $results.Add($connectivity)
    }  

    return $results
}