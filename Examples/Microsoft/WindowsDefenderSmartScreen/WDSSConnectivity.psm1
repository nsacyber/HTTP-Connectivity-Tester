Set-StrictMode -Version 4

Import-Module -Name HttpConnectivityTester -Force

# 1. import this file:
# Import-Module .\WDSSConnectivity.psm1

# 2. run one of the following:
# $connectivity = Get-WDSSConnectivity
# $connectivity = Get-WDSSConnectivity -Verbose
# $connectivity = Get-WDSSConnectivity -PerformBlueCoatLookup
# $connectivity = Get-WDSSConnectivity -Verbose -PerformBlueCoatLookup

# 3. filter results:
# $connectivity | Format-List -Property Blocked,TestUrl,UnblockUrl,DnsAliases,IpAddresses,Description,Resolved,ActualStatusCode,ExpectedStatusCode,UnexpectedStatus

# 4. save results to a file:
# Save-HttpConnectivity -Objects $connectivity -FileName ('WDSSConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))

Function Get-WDSSConnectivity() {
    <#
    .SYNOPSIS
    Gets connectivity information for Windows Defender SmartScreen.

    .DESCRIPTION
    Gets connectivity information for Windows Defender SmartScreen.

    .PARAMETER PerformBlueCoatLookup
    Use Symantec BlueCoat SiteReview to lookup what SiteReview category the URL is in.

    .EXAMPLE
    Get-WDSSConnectivity

    .EXAMPLE
    Get-WDSSConnectivity -Verbose

    .EXAMPLE
    Get-WDSSConnectivity -PerformBlueCoatLookup

    .EXAMPLE
    Get-WDSSConnectivity -Verbose -PerformBlueCoatLookup
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[pscustomobject]])]
    Param(
        [Parameter(Mandatory=$false, HelpMessage='Whether to perform a BlueCoat Site Review lookup on the URL. Warning: The BlueCoat Site Review REST API is rate limited.')]
        [switch]$PerformBluecoatLookup
    )

    $isVerbose = $VerbosePreference -eq 'Continue'

    $data = New-Object System.Collections.Generic.List[System.Collections.Hashtable]

    # https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-smartscreen/windows-defender-smartscreen-overview
	# https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2008-R2-and-2008/ee126149(v=ws.10)

    $data.Add(@{ TestUrl = 'https://apprep.smartscreen.microsoft.com'; UrlPattern='https://*.smartscreen.microsoft.com'; ExpectedStatusCode = 404; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose})
    $data.Add(@{ TestUrl = 'https://ars.smartscreen.microsoft.com'; UrlPattern='https://*.smartscreen.microsoft.com'; ExpectedStatusCode = 404; Description = 'SmartScreen URL used by smartscreen.exe'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://c.urs.microsoft.com'; UrlPattern='https://*.urs.microsoft.com'; ExpectedStatusCode = 404; Description = 'SmartScreen URL used by iexplore.exe, MicrosoftEdge.exe'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://feedback.smartscreen.microsoft.com'; UrlPattern='https://*.smartscreen.microsoft.com'; ExpectedStatusCode = 403; Description = 'SmartScreen URL used by browsers and users to report feedback on SmartScreen accuracy for a site'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://nav.smartscreen.microsoft.com'; UrlPattern='https://*.smartscreen.microsoft.com'; ExpectedStatusCode = 404; Description = 'SmartScreen URL used by smartscreen.exe'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://nf.smartscreen.microsoft.com'; UrlPattern='https://*.smartscreen.microsoft.com'; ExpectedStatusCode = 404; Description = 'SmartScreen URL used by NisSrv.exe'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://ping.nav.smartscreen.microsoft.com'; UrlPattern='https://*.smartscreen.microsoft.com'; ExpectedStatusCode = 404; Description = 'SmartScreen URL used by smartscreen.exe'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://ping.nf.smartscreen.microsoft.com'; UrlPattern='https://*.smartscreen.microsoft.com'; ExpectedStatusCode = 404; Description = 'SmartScreen URL used by NisSrv.exe, smartscreen.exe'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://t.nav.smartscreen.microsoft.com'; UrlPattern='https://*.smartscreen.microsoft.com'; ExpectedStatusCode = 404; Description = 'SmartScreen URL used by smartscreen.exe'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://t.nf.smartscreen.microsoft.com'; UrlPattern='https://*.smartscreen.microsoft.com'; ExpectedStatusCode = 404; Description = 'SmartScreen URL used by NisSrv.exe'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://t.urs.microsoft.com'; UrlPattern='https://*.urs.microsoft.com'; ExpectedStatusCode = 404; Description = 'SmartScreen URL used by iexplore.exe, MicrosoftEdge.exe'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://urs.microsoft.com' ; UrlPattern='https://urs.microsoft.com'; ExpectedStatusCode = 404; Description = 'SmartScreen URL used by iexplore.exe'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://urs.smartscreen.microsoft.com'; UrlPattern='https://*.smartscreen.microsoft.com'; ExpectedStatusCode = 404; Description = ' SmartScreen URL used by NisSrv.exe, smartscreen.exe, wdnsfltr.exe (Windows Defender Exploit Guard Network Protection)'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })

    $results = New-Object System.Collections.Generic.List[pscustomobject]

    $data | ForEach-Object {
        $connectivity = Get-HttpConnectivity @_
        $results.Add($connectivity)
    }

    return $results
}
