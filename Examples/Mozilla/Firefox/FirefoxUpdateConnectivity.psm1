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

    $isVerbose = $VerbosePreference -eq 'Continue'

    $data = New-Object System.Collections.Generic.List[System.Collections.Hashtable]

    $data.Add(@{ TestUrl = 'https://aus3.mozilla.org'; ExpectedStatusCode = 404; Description = 'Firefox update check'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://aus4.mozilla.org'; ExpectedStatusCode = 404; Description = 'Firefox update check'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://aus5.mozilla.org'; ExpectedStatusCode = 404; Description = 'Firefox update check'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://download.cdn.mozilla.net'; Description = 'Firefox update download'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://archive.mozilla.org'; Description = 'Firefox update download'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://ftp.mozilla.org'; Description = 'Firefox update download'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://versioncheck.addons.mozilla.org'; ExpectedStatusCode = 403; Description = 'Firefox add-on/extension update check'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://versioncheck-bg.addons.mozilla.org'; ExpectedStatusCode = 403; Description = 'Firefox add-on/extension update check'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })

    $results = New-Object System.Collections.Generic.List[pscustomobject]

    $data | ForEach-Object {
        $connectivity = Get-HttpConnectivity @_
        $results.Add($connectivity)
    }

    return $results
}
