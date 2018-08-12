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
# Save-HttpConnectivity -Objects $connectivity -FileName ('ChromeUpdateConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))

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

    $isVerbose = $VerbosePreference -eq 'Continue'

    $data = New-Object System.Collections.Generic.List[System.Collections.Hashtable]

    $data.Add(@{ TestUrl = 'http://redirector.gvt1.com'; UrlPattern = 'http://*.gvt1.com'; ExpectedStatusCode = 404; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://redirector.gvt1.com'; UrlPattern = 'https://*.gvt1.com'; ExpectedStatusCode = 404; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'http://update.googleapis.com/service/update2'; ExpectedStatusCode = 404; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://update.googleapis.com/service/update2'; ExpectedStatusCode = 404; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://clients2.google.com'; ExpectedStatusCode = 404; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://clients5.google.com'; ExpectedStatusCode = 404; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://tools.google.com'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'http://dl.google.com'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })

    $results = New-Object System.Collections.Generic.List[pscustomobject]

    $data | ForEach-Object {
        $connectivity = Get-HttpConnectivity @_
        $results.Add($connectivity)
    }

    return $results
}
