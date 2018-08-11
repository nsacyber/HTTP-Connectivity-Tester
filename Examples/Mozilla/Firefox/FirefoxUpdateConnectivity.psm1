Set-StrictMode -Version 4

Import-Module -Name HttpConnectivityTester -Force

# 1. import this file:
# Import-Module .\FirefoxUpdateConnectivity.psm1

# 2. run one of the following:
# $connectivity = Get-FirefoxUpdateConnectivity
# $connectivity = Get-FirefoxUpdateConnectivity -Verbose
# $connectivity = Get-FirefoxUpdateConnectivity -PerformBlueCoatLookup
# $connectivity = Get-FirefoxUpdateConnectivity -Verbose -PerformBlueCoatLookup

# 3. filter results:
# $connectivity | Format-List -Property Blocked,TestUrl,UnblockUrl,DnsAliases,IpAddresses,Description,Resolved,ActualStatusCode,ExpectedStatusCode

# 4. save results:
# Save-HttpConnectivity -Objects $connectivity -FileName ('FirefoxUpdateConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))

Function Get-FirefoxUpdateConnectivity() {
    <#
    .SYNOPSIS
    Gets connectivity information for Firefox updates.

    .DESCRIPTION
    Gets connectivity information for Firefox updates.

    .PARAMETER PerformBlueCoatLookup
    Use Symantec BlueCoat SiteReview to lookup what SiteReview category the URL is in.

    .EXAMPLE
    Get-FirefoxUpdateConnectivity

    .EXAMPLE
    Get-FirefoxUpdateConnectivity -Verbose

    .EXAMPLE
    Get-FirefoxUpdateConnectivity -PerformBlueCoatLookup

    .EXAMPLE
    Get-FirefoxUpdateConnectivity -Verbose -PerformBlueCoatLookup
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[pscustomobject]])]
    Param(
        [Parameter(Mandatory=$false, HelpMessage='Whether to perform a BlueCoat Site Review lookup on the URL. Warning: The BlueCoat Site Review REST API is rate limited.')]
        [switch]$PerformBluecoatLookup
    )

    $parameters = $PSBoundParameters

    $isVerbose = $verbosePreference -eq 'Continue'

    $data = New-Object System.Collections.Generic.List[pscustomobject]

    $data.Add([pscustomobject]@{ TestUrl = 'https://aus3.mozilla.org'; UnblockUrl = 'https://aus3.mozilla.org'; StatusCode = 404; Description = 'Firefox update check' })
    $data.Add([pscustomobject]@{ TestUrl = 'https://aus4.mozilla.org'; UnblockUrl = 'https://aus4.mozilla.org'; StatusCode = 404; Description = 'Firefox update check' })
    $data.Add([pscustomobject]@{ TestUrl = 'https://aus5.mozilla.org'; UnblockUrl = 'https://aus5.mozilla.org'; StatusCode = 404; Description = 'Firefox update check'})
    $data.Add([pscustomobject]@{ TestUrl = 'https://download.cdn.mozilla.net'; UnblockUrl = 'https://download.cdn.mozilla.net'; StatusCode = 200; Description = 'Firefox update download' })
    $data.Add([pscustomobject]@{ TestUrl = 'https://archive.mozilla.org'; UnblockUrl = 'https://archive.mozilla.org'; StatusCode = 200; Description = 'Firefox update download' })
    $data.Add([pscustomobject]@{ TestUrl = 'https://ftp.mozilla.org'; UnblockUrl = 'https://ftp.mozilla.org'; StatusCode = 200; Description = 'Firefox update download'})
    $data.Add([pscustomobject]@{ TestUrl = 'https://versioncheck.addons.mozilla.org'; UnblockUrl = 'https://versioncheck.addons.mozilla.org'; StatusCode = 403; Description = 'Firefox add-on/extension update check' })
    $data.Add([pscustomobject]@{ TestUrl = 'https://versioncheck-bg.addons.mozilla.org'; UnblockUrl = 'https://versioncheck-bg.addons.mozilla.org'; StatusCode = 403; Description = 'Firefox add-on/extension update check' })

    $results = New-Object System.Collections.Generic.List[pscustomobject]

    $data | ForEach-Object {
        $connectivity = Get-HttpConnectivity -TestUrl $_.TestUrl -UnblockUrl $_.UnblockUrl -ExpectedStatusCode $_.StatusCode -Description $_.Description -PerformBluecoatLookup:$PerformBluecoatLookup -Verbose:$isVerbose
        $results.Add($connectivity)
    }

    return $results
}
