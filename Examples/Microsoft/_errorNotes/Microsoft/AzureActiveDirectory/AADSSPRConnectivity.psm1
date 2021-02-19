Set-StrictMode -Version 4

Import-Module -Name HttpConnectivityTester -Force

# 1. import this file:
# Import-Module .\AADSSPRConnectivity.psm1

# 2. run one of the following:
# $connectivity = Get-AADSSPRConnectivity
# $connectivity = Get-AADSSPRConnectivity -Verbose
# $connectivity = Get-AADSSPRConnectivity -PerformBlueCoatLookup
# $connectivity = Get-AADSSPRConnectivity -Verbose -PerformBlueCoatLookup

# 3. filter results:
# $connectivity | Format-List -Property Blocked,TestUrl,UnblockUrl,DnsAliases,IpAddresses,Description,Resolved,ActualStatusCode,ExpectedStatusCode,UnexpectedStatus

# 4. save results to a file:
# Save-HttpConnectivity -Objects $connectivity -FileName ('AzADSSPRConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))

Function Get-AADSSPRConnectivity() {
    <#
    .SYNOPSIS
    Gets connectivity information for Azure Active Directory Self Service Password Reset.

    .DESCRIPTION
    Gets connectivity information for Azure Active Directory Self Service Password Reset.

    When enabling the Self-Service Password Reset button on the Windows logon screen, for Windows 10 clients
    that are behind a proxy server or firewall, HTTPS traffice (443) to passwordreset.microsoftonline.com
    and ajax.aspnetcdn.com should be allowed.


    .PARAMETER PerformBlueCoatLookup
    Use Symantec BlueCoat SiteReview to lookup what SiteReview category the URL is in.

    .EXAMPLE
    Get-AADSSPRConnectivity

    .EXAMPLE
    Get-AADSSPRConnectivity -Verbose

    .EXAMPLE
    Get-AADSSPRConnectivity -PerformBlueCoatLookup

    .EXAMPLE
    Get-AADSSPRConnectivity -Verbose -PerformBlueCoatLookup
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[pscustomobject]])]
    Param(
        [Parameter(Mandatory=$false, HelpMessage='Whether to perform a BlueCoat Site Review lookup on the URL. Warning: The BlueCoat Site Review REST API is rate limited.')]
        [switch]$PerformBluecoatLookup
    )

    $isVerbose = $VerbosePreference -eq 'Continue'

    $data = New-Object System.Collections.Generic.List[System.Collections.Hashtable]

    # https://docs.microsoft.com/en-us/azure/active-directory/authentication/tutorial-sspr-windows#limitations

    # passwordreset.microsoftonline.com
    # ajax.aspnetcdn.com

    ###200/200#$data.Add(@{ TestUrl = 'https://passwordreset.microsoftonline.com'; ExpectedStatusCode = 200; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose})
    #
    #0/200#$data.Add(@{ TestUrl = 'https://ajax.aspnetcdn.com'; ExpectedStatusCode = 200; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose})
    $data.Add(@{ TestUrl = 'https://ajax.aspnetcdn.com'; ExpectedStatusCode = 200; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose})

    #
    $results = New-Object System.Collections.Generic.List[pscustomobject]

    $data | ForEach-Object {
        $connectivity = Get-HttpConnectivity @_
        $results.Add($connectivity)
    }

    return $results
}
