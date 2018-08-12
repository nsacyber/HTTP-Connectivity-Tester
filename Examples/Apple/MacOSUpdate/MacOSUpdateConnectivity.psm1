Set-StrictMode -Version 4

Import-Module -Name HttpConnectivityTester -Force

# 1. import this file:
# Import-Module .\MacOSUpdateConnectivity.psm1

# 2. run one of the following:
# $connectivity = Get-MacOSUpdateConnectivity
# $connectivity = Get-MacOSUpdateConnectivity -Verbose
# $connectivity = Get-MacOSUpdateConnectivity -PerformBlueCoatLookup
# $connectivity = Get-MacOSUpdateConnectivity -Verbose -PerformBlueCoatLookup

# 3. filter results:
# $connectivity | Format-List -Property Blocked,TestUrl,UnblockUrl,DnsAliases,IpAddresses,Description,Resolved,ActualStatusCode,ExpectedStatusCode

# 4. save results:
# Save-HttpConnectivity -Objects $connectivity -FileName ('MacOSUpdateConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))

Function Get-MacOSUpdateConnectivity() {
    <#
    .SYNOPSIS
    Gets connectivity information for macOS updates.

    .DESCRIPTION
    Gets connectivity information for macOS updates.

    .PARAMETER PerformBlueCoatLookup
    Use Symantec BlueCoat SiteReview to lookup what SiteReview category the URL is in.

    .EXAMPLE
    Get-MacOSUpdateConnectivity

    .EXAMPLE
    Get-MacOSUpdateConnectivity -Verbose

    .EXAMPLE
    Get-MacOSUpdateConnectivity -PerformBlueCoatLookup

    .EXAMPLE
    Get-MacOSUpdateConnectivity -Verbose -PerformBlueCoatLookup
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[pscustomobject]])]
    Param(
        [Parameter(Mandatory=$false, HelpMessage='Whether to perform a BlueCoat Site Review lookup on the URL. Warning: The BlueCoat Site Review REST API is rate limited.')]
        [switch]$PerformBluecoatLookup
    )

    $isVerbose = $VerbosePreference -eq 'Continue'

    $data = New-Object System.Collections.Generic.List[System.Collections.Hashtable]

    $data.Add(@{ TestUrl = 'https://swscan.apple.com'; ExpectedStatusCode = 403; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://swcdnlocator.apple.com'; ExpectedStatusCode = 501; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://swdownload.apple.com'; ExpectedStatusCode = 403; IgnoreCertificateValidationErrors=$true; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://swcdn.apple.com'; ExpectedStatusCode = 404; IgnoreCertificateValidationErrors=$true; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://swdist.apple.com'; ExpectedStatusCode = 403; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })

    $results = New-Object System.Collections.Generic.List[pscustomobject]

    $data | ForEach-Object {
        $connectivity = Get-HttpConnectivity @_
        $results.Add($connectivity)
    }

    return $results
}
