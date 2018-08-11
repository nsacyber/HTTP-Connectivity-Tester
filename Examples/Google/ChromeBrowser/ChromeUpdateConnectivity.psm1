Set-StrictMode -Version 4

Import-Module -Name HttpConnectivityTester -Force

# 1. import this file:
# Import-Module .\ChromeUpdateConnectivity.psm1

# 2. run one of the following:
# $connectivity = Get-ChromeUpdateConnectivity
# $connectivity = Get-ChromeUpdateConnectivity -Verbose
# $connectivity = Get-ChromeUpdateConnectivity -PerformBlueCoatLookup
# $connectivity = Get-ChromeUpdateConnectivity -Verbose -PerformBlueCoatLookup

# 3. filter results:
# $connectivity | Format-List -Property Blocked,TestUrl,UnblockUrl,DnsAliases,IpAddresses,Description,Resolved,ActualStatusCode,ExpectedStatusCode

# 4. save results:
# Save-HttpConnectivity -Results $connectivity -OutputPath "$env:userprofile\Desktop" -FileName ('ChromeUpdateConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))

Function Get-ChromeUpdateConnectivity() {
    <#
    .SYNOPSIS
    Gets connectivity information for Chrome updates.

    .DESCRIPTION
    Gets connectivity information for Chrome updates.

    .PARAMETER PerformBlueCoatLookup
    Use Symantec BlueCoat SiteReview to lookup what SiteReview category the URL is in.

    .EXAMPLE
    Get-ChromeUpdateConnectivity

    .EXAMPLE
    Get-ChromeUpdateConnectivity -Verbose

    .EXAMPLE
    Get-ChromeUpdateConnectivity -PerformBlueCoatLookup

    .EXAMPLE
    Get-ChromeUpdateConnectivity -Verbose -PerformBlueCoatLookup
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

    $data.Add([pscustomobject]@{ TestUrl = 'http://redirector.gvt1.com'; UrlPattern = 'http://*.gvt1.com'; StatusCode = 404; Description = '' })
    $data.Add([pscustomobject]@{ TestUrl = 'https://redirector.gvt1.com'; UrlPattern = 'https://*.gvt1.com'; StatusCode = 404; Description = '' })
    $data.Add([pscustomobject]@{ TestUrl = 'http://update.googleapis.com/service/update2'; StatusCode = 404; Description = '' })
    $data.Add([pscustomobject]@{ TestUrl = 'https://update.googleapis.com/service/update2'; StatusCode = 404; Description = '' })
    $data.Add([pscustomobject]@{ TestUrl = 'https://clients2.google.com'; StatusCode = 404; Description = '' })
    $data.Add([pscustomobject]@{ TestUrl = 'https://clients5.google.com'; StatusCode = 404; Description = '' })
    $data.Add([pscustomobject]@{ TestUrl = 'https://tools.google.com'; StatusCode = 200; Description = '' })
    $data.Add([pscustomobject]@{ TestUrl = 'http://dl.google.com'; StatusCode = 200; Description = '' })

    $results = New-Object System.Collections.Generic.List[pscustomobject]

    $data | ForEach-Object {
        if ('UrlPattern' -in $_.PSObject.Properties.Name) {
            $connectivity = Get-HttpConnectivity -TestUrl $_.TestUrl -UrlPattern $_.UrlPattern -ExpectedStatusCode $_.StatusCode -Description $_.Description -PerformBluecoatLookup:$PerformBluecoatLookup -Verbose:$isVerbose
        } else {
            $connectivity = Get-HttpConnectivity -TestUrl $_.TestUrl -ExpectedStatusCode $_.StatusCode -Description $_.Description -PerformBluecoatLookup:$PerformBluecoatLookup -Verbose:$isVerbose
        }
        $results.Add($connectivity)
    }

    return $results
}