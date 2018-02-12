Set-StrictMode -Version 4

#Import-Module -Name .\ConnectivityTester.psm1 -Force

Import-Module -Name ConnectivityTester -Force

# dot source this file and then run:
# Get-WDATPConnectivity

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

    $data.Add([pscustomobject]@{ Url = 'https://winatp-gw-cus.microsoft.com/test'; StatusCode = 200; })
    $data.Add([pscustomobject]@{ Url = 'https://winatp-gw-eus.microsoft.com/test'; StatusCode = 200; })
    $data.Add([pscustomobject]@{ Url = 'https://us.vortex-win.data.microsoft.com/collect/v1'; StatusCode = 400; }) #https://us.vortex-win.data.microsoft.com/health/keepalive
    $data.Add([pscustomobject]@{ Url = 'https://onboardingpackagescusprd.blob.core.windows.net/'; StatusCode = 400; })
    $data.Add([pscustomobject]@{ Url = 'https://onboardingpackageseusprd.blob.core.windows.net/'; StatusCode = 400; })
    $data.Add([pscustomobject]@{ Url = 'http://crl.microsoft.com'; StatusCode = 400; })
    $data.Add([pscustomobject]@{ Url = 'http://ctldl.windowsupdate.com'; StatusCode = 200; })

    $results = New-Object System.Collections.Generic.List[pscustomobject]

    $data | ForEach-Object {
        $targetUrl = $_.Url
        $statusCode = $_.StatusCode

        $connectivity = Get-Connectivity -Url $_.Url -ExpectedStatusCode $_.StatusCode -PerformBluecoatLookup:$PerformBluecoatLookup -Verbose:$isVerbose
        $results.Add($connectivity)
    }  

    return $results
}