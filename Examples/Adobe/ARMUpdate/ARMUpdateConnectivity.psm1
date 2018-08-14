Set-StrictMode -Version 4

Import-Module -Name HttpConnectivityTester -Force

# 1. import this file:
# Import-Module .\ARMUpdateConnectivity.psm1

# 2. run one of the following:
# $connectivity = Get-ARMUpdateConnectivity
# $connectivity = Get-ARMUpdateConnectivity -Verbose
# $connectivity = Get-ARMUpdateConnectivity -PerformBlueCoatLookup
# $connectivity = Get-ARMUpdateConnectivity -Verbose -PerformBlueCoatLookup

# 3. filter results:
# $connectivity | Format-List -Property Blocked,TestUrl,UnblockUrl,DnsAliases,IpAddresses,Description,Resolved,ActualStatusCode,ExpectedStatusCode,UnexpectedStatus

# 4. save results:
# Save-HttpConnectivity -Objects $connectivity -FileName ('ARMUpdateConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))

Function Get-ARMUpdateConnectivity() {
    <#
    .SYNOPSIS
    Gets connectivity information for Adobe Reader updates.

    .DESCRIPTION
    Gets connectivity information for Adobe Reader updates.

    .PARAMETER PerformBlueCoatLookup
    Use Symantec BlueCoat SiteReview to lookup what SiteReview category the URL is in.

    .EXAMPLE
    Get-ARMUpdateConnectivity

    .EXAMPLE
    Get-ARMUpdateConnectivity -Verbose

    .EXAMPLE
    Get-ARMUpdateConnectivity -PerformBlueCoatLookup

    .EXAMPLE
    Get-ARMUpdateConnectivity -Verbose -PerformBlueCoatLookup
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[pscustomobject]])]
    Param(
        [Parameter(Mandatory=$false, HelpMessage='Whether to perform a BlueCoat Site Review lookup on the URL. Warning: The BlueCoat Site Review REST API is rate limited.')]
        [switch]$PerformBluecoatLookup
    )

    $isVerbose = $VerbosePreference -eq 'Continue'

    $data = New-Object System.Collections.Generic.List[System.Collections.Hashtable]

    $data.Add(@{ TestUrl = 'http://armmf.adobe.com'; ExpectedStatusCode = 404; Description = 'Adobe update metadata download'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://armmf.adobe.com'; ExpectedStatusCode = 404; Description = 'Adobe update metadata download'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })

    $data.Add(@{ TestUrl = 'http://ardownload.adobe.com'; ExpectedStatusCode = 404; Description = 'Adobe updates download'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://ardownload.adobe.com'; ExpectedStatusCode = 404; Description = 'Adobe updates download'; IgnoreCertificateValidationErrors=$true; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })

    $data.Add(@{ TestUrl = 'http://ardownload2.adobe.com'; ExpectedStatusCode = 404; Description = 'Adobe incremental updates download'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://ardownload2.adobe.com'; ExpectedStatusCode = 404; Description = 'Adobe incremental updates download'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })

    $data.Add(@{ TestUrl = 'http://crl.adobe.com'; ExpectedStatusCode = 404; Description = 'Adobe Certificate Revocation List'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })

    $results = New-Object System.Collections.Generic.List[pscustomobject]

    $data | ForEach-Object {
        $connectivity = Get-HttpConnectivity @_
        $results.Add($connectivity)
    }

    return $results
}
