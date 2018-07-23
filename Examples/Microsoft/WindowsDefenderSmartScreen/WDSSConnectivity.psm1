Set-StrictMode -Version 4

Import-Module -Name HttpConnectivityTester -Force

# 1. import this file:
# Import-Module .\WDSSConnectivity.psm1

# 2. run one of the following:
# $connectivity = Get-WDSSConnectivity
# $connectivity = Get-WDSSConnectivity -Verbose
# $connectivity = Get-WDSSConnectivity -PerformBlueCoatLooku
# $connectivity = Get-WDSSConnectivity -Verbose -PerformBlueCoatLookup

# 3. filter results:
# $connectivity | Format-List -Property IsBlocked,TestUrl,UnblockUrl,Aliases,Addresses,Description,Resolved,ActualStatusCode,ExpectedStatusCode

# 4. save results to a file:
# Save-HttpConnectivity -Results $connectivity -OutputPath "$env:userprofile\Desktop" -FileName ('WDSSConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))

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

    $isVerbose = $verbosePreference -eq 'Continue'

    $data = New-Object System.Collections.Generic.List[pscustomobject]

    # https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-smartscreen/windows-defender-smartscreen-overview
	# https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2008-R2-and-2008/ee126149(v=ws.10)

    $data.Add([pscustomobject]@{ TestUrl = 'https://apprep.smartscreen.microsoft.com'; UnblockUrl='https://*.smartscreen.microsoft.com'; StatusCode = 404; Description = ''; })
    $data.Add([pscustomobject]@{ TestUrl = 'https://ars.smartscreen.microsoft.com'; UnblockUrl='https://*.smartscreen.microsoft.com'; StatusCode = 404; Description = ''; })
    $data.Add([pscustomobject]@{ TestUrl = 'https://c.urs.microsoft.com'; UnblockUrl='https://*.urs.microsoft.com'; StatusCode = 403; Description = ''; })
    $data.Add([pscustomobject]@{ TestUrl = 'https://feedback.smartscreen.microsoft.com'; UnblockUrl='https://*.smartscreen.microsoft.com'; StatusCode = 403; Description = ''; })    
    $data.Add([pscustomobject]@{ TestUrl = 'https://nav.smartscreen.microsoft.com'; UnblockUrl='https://*.smartscreen.microsoft.com'; StatusCode = 404; Description = ''; })
    $data.Add([pscustomobject]@{ TestUrl = 'https://nf.smartscreen.microsoft.com'; UnblockUrl='https://*.smartscreen.microsoft.com'; StatusCode = 404; Description = ''; })
    $data.Add([pscustomobject]@{ TestUrl = 'https://ping.nav.smartscreen.microsoft.com'; UnblockUrl='https://*.smartscreen.microsoft.com'; StatusCode = 404; Description = ''; })
    $data.Add([pscustomobject]@{ TestUrl = 'https://ping.nf.smartscreen.microsoft.com'; UnblockUrl='https://*.smartscreen.microsoft.com'; StatusCode = 404; Description = ''; })   
    $data.Add([pscustomobject]@{ TestUrl = 'https://t.nf.smartscreen.microsoft.com'; UnblockUrl='https://*.smartscreen.microsoft.com'; StatusCode = 404; Description = ''; })   
    $data.Add([pscustomobject]@{ TestUrl = 'https://t.urs.microsoft.com'; UnblockUrl='https://*.urs.microsoft.com'; StatusCode = 403; Description = ''; })
    $data.Add([pscustomobject]@{ TestUrl = 'https://urs.microsoft.com' ; UnblockUrl='https://urs.microsoft.com'; StatusCode = 403; Description = ''; })
    $data.Add([pscustomobject]@{ TestUrl = 'https://urs.smartscreen.microsoft.com'; UnblockUrl='https://*.smartscreen.microsoft.com'; StatusCode = 404; Description = ''; })


    $results = New-Object System.Collections.Generic.List[pscustomobject]

    $data | ForEach-Object {
        $connectivity = Get-HttpConnectivity -TestUrl $_.TestUrl -UnblockUrl $_.UnblockUrl -ExpectedStatusCode $_.StatusCode -Description $_.Description -PerformBluecoatLookup:$PerformBluecoatLookup -Verbose:$isVerbose
        $results.Add($connectivity)
    }  

    return $results
}