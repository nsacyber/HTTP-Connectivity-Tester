Set-StrictMode -Version 4

#Import-Module -Name .\ConnectivityTester.psm1 -Force

Import-Module -Name ConnectivityTester -Force

# dot source this file 
# . .\WDSSConnectivity.ps1

# then run one of the following:
# Get-WDSSConnectivity
# Get-WDSSConnectivity -Verbose
# Get-WDSSConnectivity -Verbose -PerformBlueCoatLookup

# to filter results or save them to a file:
# $connectivity = Get-WDSSConnectivity -Verbose -PerformBlueCoatLookup
# $connectivity | Format-List -Property IsBlocked,TestUrl,Description,Resolved,ActualStatusCode,ExpectedStatusCode
# Save-Connectivity -Results $connectivity -OutputPath "$env:userprofile\Desktop" -FileName ('WDSSConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))

Function Get-WDSSConnectivity() {
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[pscustomobject]])]
    Param(       
        [Parameter(Mandatory=$false, HelpMessage='Whether to perform a BlueCoat Site Review lookup on the URL. Warning: The BlueCoat Site Review REST API is rate limited.')]
        [switch]$PerformBluecoatLookup
    )

    $parameters = $PSBoundParameters

    $isVerbose = $verbosePreference -eq 'Continue'

    $data = New-Object System.Collections.Generic.List[pscustomobject]

    # https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-smartscreen/windows-defender-smartscreen-overview
	# https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2008-R2-and-2008/ee126149(v=ws.10)

    $data.Add([pscustomobject]@{ TestUrl = 'https://apprep.smartscreen.microsoft.com'; StatusCode = 404; Description = ''; })
    $data.Add([pscustomobject]@{ TestUrl = 'https://ars.smartscreen.microsoft.com'; StatusCode = 404; Description = ''; })
    $data.Add([pscustomobject]@{ TestUrl = 'https://c.urs.microsoft.com'; StatusCode = 403; Description = ''; })
	$data.Add([pscustomobject]@{ TestUrl = 'https://feedback.smartscreen.microsoft.com'; StatusCode = 403; Description = ''; })    
    $data.Add([pscustomobject]@{ TestUrl = 'https://nav.smartscreen.microsoft.com'; StatusCode = 404; Description = ''; })
    $data.Add([pscustomobject]@{ TestUrl = 'https://nf.smartscreen.microsoft.com'; StatusCode = 404; Description = ''; })
    $data.Add([pscustomobject]@{ TestUrl = 'https://ping.nav.smartscreen.microsoft.com'; StatusCode = 404; Description = ''; })
    $data.Add([pscustomobject]@{ TestUrl = 'https://ping.nf.smartscreen.microsoft.com'; StatusCode = 404; Description = ''; })   
    $data.Add([pscustomobject]@{ TestUrl = 'https://t.nf.smartscreen.microsoft.com'; StatusCode = 404; Description = ''; })   
    $data.Add([pscustomobject]@{ TestUrl = 'https://t.urs.microsoft.com'; StatusCode = 403; Description = ''; })
	$data.Add([pscustomobject]@{ TestUrl = 'https://urs.microsoft.com' ; StatusCode = 403; Description = ''; })
    $data.Add([pscustomobject]@{ TestUrl = 'https://urs.smartscreen.microsoft.com'; StatusCode = 404; Description = ''; })


    $results = New-Object System.Collections.Generic.List[pscustomobject]

    $data | ForEach-Object {
        $connectivity = Get-Connectivity -TestUrl $_.TestUrl -ExpectedStatusCode $_.StatusCode -Description $_.Description -PerformBluecoatLookup:$PerformBluecoatLookup -Verbose:$isVerbose
        $results.Add($connectivity)
    }  

    return $results
}