Set-StrictMode -Version 4

Import-Module -Name HttpConnectivityTester -Force

# 1. import this file
# Import-Module .\WindowsUpdateConnectivity.psm1

# 2. run one of the following:
# $connectivity = Get-WindowsUpdateConnectivity
# $connectivity = Get-WindowsUpdateConnectivity -Verbose
# $connectivity = Get-WindowsUpdateConnectivity -PerformBlueCoatLookup
# $connectivity = Get-WindowsUpdateConnectivity -Verbose -PerformBlueCoatLookup

# 3. filter results:
# $connectivity | Format-List -Property Blocked,TestUrl,UnblockUrl,DnsAliases,IpAddresses,Description,Resolved,ActualStatusCode,ExpectedStatusCode

# 4. save results to a file:
# Save-HttpConnectivity -Objects $connectivity -FileName ('WindowsUpdateConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))

Function Get-WindowsUpdateConnectivity() {
    <#
    .SYNOPSIS
    Gets connectivity information for Windows Update.

    .DESCRIPTION
    Gets connectivity information for Windows Update.

    .PARAMETER PerformBlueCoatLookup
    Use Symantec BlueCoat SiteReview to lookup what SiteReview category the URL is in.

    .EXAMPLE
    Get-WindowsUpdateConnectivity

    .EXAMPLE
    Get-WindowsUpdateConnectivity -Verbose

    .EXAMPLE
    Get-WindowsUpdateConnectivity -PerformBlueCoatLookup

    .EXAMPLE
    Get-WindowsUpdateConnectivity -Verbose -PerformBlueCoatLookup
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[pscustomobject]])]
    Param(
        [Parameter(Mandatory=$false, HelpMessage='Whether to perform a BlueCoat Site Review lookup on the URL. Warning: The BlueCoat Site Review REST API is rate limited.')]
        [switch]$PerformBluecoatLookup
    )

    $isVerbose = $verbosePreference -eq 'Continue'

    $data = New-Object System.Collections.Generic.List[pscustomobject]

    # https://docs.microsoft.com/en-us/windows/privacy/manage-windows-endpoints#windows-update

    $data.Add([pscustomobject]@{ TestUrl = 'http://windowsupdate.microsoft.com'; StatusCode = 200; Description = ''; IgnoreCertificateValidationErrors=$false })
    $data.Add([pscustomobject]@{ TestUrl = 'https://windowsupdate.microsoft.com'; StatusCode = 200; Description = ''; IgnoreCertificateValidationErrors=$false })
    #$data.Add([pscustomobject]@{ TestUrl = 'https://windowsupdate.microsoft.com'; UrlPattern = 'http://*.windowsupdate.microsoft.com'; StatusCode = 200; Description = ''; IgnoreCertificateValidationErrors=$false })
    $data.Add([pscustomobject]@{ TestUrl = 'https://geo-prod.do.dsp.mp.microsoft.com'; UrlPattern = 'https://*.do.dsp.mp.microsoft.com'; StatusCode = 403; Description = 'Updates for applications and the OS on Windows 10 1709 and later. Windows Update Delivery Optimization metadata, resiliency, and anti-corruption.'; IgnoreCertificateValidationErrors=$false }) # many different *-prod.do.dsp.mp.microsoft.com, but geo-prod.do.dsp.mp.microsoft.com is the most common one
    $data.Add([pscustomobject]@{ TestUrl = 'http://download.windowsupdate.com'; StatusCode = 200; Description = 'Download operating system patches and updates'; IgnoreCertificateValidationErrors=$true})
    $data.Add([pscustomobject]@{ TestUrl = 'http://au.download.windowsupdate.com'; UrlPattern = 'http://*.au.download.windowsupdate.com'; StatusCode = 200; Description = ''; IgnoreCertificateValidationErrors=$true }) # many different *.download.windowsupdate.com, au.download.windowsupdate.com is most common. *.au.download.windowsupdate.com, *.l.windowsupdate.com
    $data.Add([pscustomobject]@{ TestUrl = 'https://cds.d2s7q6s2.hwcdn.net'; UrlPattern = 'https://cds.*.hwcdn.net'; StatusCode = 504; Description = 'Highwinds Content Delivery Network used for Windows Update on Windows 10 1709 and later'; IgnoreCertificateValidationErrors=$true })
    $data.Add([pscustomobject]@{ TestUrl = 'http://cs9.wac.phicdn.net'; UrlPattern = 'http://*.wac.phicdn.net'; StatusCode = 200; Description = 'Verizon Content Delivery Network used for Windows Update on Windows 10 1709 and later'; IgnoreCertificateValidationErrors=$true })
    $data.Add([pscustomobject]@{ TestUrl = 'https://cs491.wac.edgecastcdn.net'; UrlPattern = 'https://*.wac.edgecastcdn.net'; StatusCode = 404; Description = 'Verizon Content Delivery Network used for Windows Update on Windows 10 1709 and later'; IgnoreCertificateValidationErrors=$true })
    $data.Add([pscustomobject]@{ TestUrl = 'http://dl.delivery.mp.microsoft.com'; UrlPattern = 'http://*.dl.delivery.mp.microsoft.com'; StatusCode = 403; Description = ''; IgnoreCertificateValidationErrors=$true })
    $data.Add([pscustomobject]@{ TestUrl = 'http://tlu.dl.delivery.mp.microsoft.com'; UrlPattern = 'http://*.tlu.dl.delivery.mp.microsoft.com'; StatusCode = 403; Description = ''; IgnoreCertificateValidationErrors=$true })
    $data.Add([pscustomobject]@{ TestUrl = 'https://emdl.ws.microsoft.com'; StatusCode = 503; Description = 'Update applications from the Microsoft Store'; IgnoreCertificateValidationErrors=$true })
    $data.Add([pscustomobject]@{ TestUrl = 'https://fe2.update.microsoft.com'; UrlPattern = 'https://*.update.microsoft.com'; StatusCode = 200; Description = ''; IgnoreCertificateValidationErrors=$false })
    $data.Add([pscustomobject]@{ TestUrl = 'https://sls.update.microsoft.com'; UrlPattern = 'https://*.update.microsoft.com'; StatusCode = 403; Description = ''; IgnoreCertificateValidationErrors=$false })
    $data.Add([pscustomobject]@{ TestUrl = 'https://fe3.delivery.mp.microsoft.com'; UrlPattern = 'https://*.delivery.mp.microsoft.com'; StatusCode = 403; Description = ''; IgnoreCertificateValidationErrors=$false })
    $data.Add([pscustomobject]@{ TestUrl = 'https://tsfe.trafficshaping.dsp.mp.microsoft.com'; UrlPattern = 'https://*.dsp.mp.microsoft.com'; StatusCode = 403; Description = ''; IgnoreCertificateValidationErrors=$false })

    $results = New-Object System.Collections.Generic.List[pscustomobject]

    $data | ForEach-Object {
        if ('UrlPattern' -in $_.PSObject.Properties.Name) {
            $connectivity = Get-HttpConnectivity -TestUrl $_.TestUrl -UrlPattern $_.UrlPattern -ExpectedStatusCode $_.StatusCode -Description $_.Description -IgnoreCertificateValidationErrors:($_.IgnoreCertificateValidationErrors) -PerformBluecoatLookup:$PerformBluecoatLookup -Verbose:$isVerbose
        } else {
            $connectivity = Get-HttpConnectivity -TestUrl $_.TestUrl -ExpectedStatusCode $_.StatusCode -Description $_.Description -IgnoreCertificateValidationErrors:($_.IgnoreCertificateValidationErrors) -PerformBluecoatLookup:$PerformBluecoatLookup -Verbose:$isVerbose
        }
        $results.Add($connectivity)
    }

    return $results
}
