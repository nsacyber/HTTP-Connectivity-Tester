Set-StrictMode -Version 4

#Import-Module -Name .\ConnectivityTester.psm1 -Force

Import-Module -Name ConnectivityTester -Force

# dot source this file 
# . .\WDATPConnectivity.ps1

# then run one of the following:
# Get-WDATPConnectivity
# Get-WDATPConnectivity -Verbose
# Get-WDATPConnectivity -Verbose -PerformBlueCoatLookup

# to filter results or save them to a file:
# $connectivity = Get-WDATPConnectivity -Verbose -PerformBlueCoatLookup
# $connectivity | Format-List -Property IsBlocked,ActualStatusCode,ExpectedStatusCode,TestUrl
# Save-Connectivity -Results $connectivity -OutputPath "$env:userprofile\Desktop" -FileName ('WDATPConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))

Function Get-WDATPConnectivity() {
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[pscustomobject]])]
    Param(       
        [Parameter(Mandatory=$false, HelpMessage='Whether to perform a BlueCoat Site Review lookup on the URL. Warning: The BlueCoat Site Review REST API is rate limited.')]
        [switch]$PerformBluecoatLookup
    )

    $parameters = $PSBoundParameters

    $isVerbose = $verbosePreference -eq 'Continue'

    $data = New-Object System.Collections.Generic.List[pscustomobject]

    # https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-atp/configure-proxy-internet-windows-defender-advanced-threat-protection#enable-access-to-windows-defender-atp-service-urls-in-the-proxy-server

    $data.Add([pscustomobject]@{ TestUrl = 'https://onboardingpackagescusprd.blob.core.windows.net/'; StatusCode = 400; })
    $data.Add([pscustomobject]@{ TestUrl = 'https://onboardingpackageseusprd.blob.core.windows.net/'; StatusCode = 400; })
    $data.Add([pscustomobject]@{ TestUrl = 'http://crl.microsoft.com'; StatusCode = 400; })
    $data.Add([pscustomobject]@{ TestUrl = 'http://ctldl.windowsupdate.com'; StatusCode = 200; })
    $data.Add([pscustomobject]@{ TestUrl = 'https://us.vortex-win.data.microsoft.com/collect/v1'; StatusCode = 400; }) # might correspond to https://us.vortex-win.data.microsoft.com/health/keepalive so might be able to remove
    $data.Add([pscustomobject]@{ TestUrl = 'https://winatp-gw-cus.microsoft.com/test'; StatusCode = 200; })
    $data.Add([pscustomobject]@{ TestUrl = 'https://winatp-gw-eus.microsoft.com/test'; StatusCode = 200; })

    # WDATPConnectivityAnalyzer https://go.microsoft.com/fwlink/p/?linkid=823683 endpoints.txt file as of 02/14/2018:

    #$data.Add([pscustomobject]@{ TestUrl = 'https://winatp-gw-cus.microsoft.com/test'; StatusCode = 200; }) # repeat from above
    #$data.Add([pscustomobject]@{ TestUrl = 'https://winatp-gw-eus.microsoft.com/test'; StatusCode = 200; }) # repeat from above
    #$data.Add([pscustomobject]@{ TestUrl = 'https://winatp-gw-weu.microsoft.com/test'; StatusCode = 200; }) # europe
    #$data.Add([pscustomobject]@{ TestUrl = 'https://winatp-gw-neu.microsoft.com/test'; StatusCode = 200; }) # europe
    #$data.Add([pscustomobject]@{ TestUrl = 'https://eu.vortex-win.data.microsoft.com/health/keepalive'; StatusCode = 400; }) # europe
    $data.Add([pscustomobject]@{ TestUrl = 'https://us.vortex-win.data.microsoft.com/health/keepalive'; StatusCode = 200; }) # might be the status for https://us.vortex-win.data.microsoft.com/collect/v1

    $results = New-Object System.Collections.Generic.List[pscustomobject]

    $data | ForEach-Object {
          $connectivity = Get-Connectivity -TestUrl $_.TestUrl -ExpectedStatusCode $_.StatusCode -PerformBluecoatLookup:$PerformBluecoatLookup -Verbose:$isVerbose
        $results.Add($connectivity)
    }  

    return $results
}