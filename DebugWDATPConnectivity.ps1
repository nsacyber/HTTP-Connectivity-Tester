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
    $data.Add([pscustomobject]@{ Url = 'https://us.vortex-win.data.microsoft.com/collect/v1'; StatusCode = 400; })
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

Function Save-WDATPConnectivity() {
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[pscustomobject]])]
    Param(
        [Parameter(Mandatory=$false, HelpMessage='Path to save the output to')]
        [System.Collections.Generic.List[pscustomobject]]$Results,

        [Parameter(Mandatory=$false, HelpMessage='Path to save the output to')]
        [string]$OutputPath,

        [Parameter(Mandatory=$false, HelpMessage='Compress JSON output')]
        [switch]$Compress
    )

    $parameters = $PSBoundParameters

    $isVerbose = $verbosePreference -eq 'Continue'

    if (-not($parameters.ContainsKey('OutputPath'))) {
        $OutputPath = $env:USERPROFILE,'Desktop' -join [System.IO.Path]::DirectorySeparatorChar
    }

    $OutputPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputPath)

    if (-not(Test-Path -Path $OutputPath)) {
        New-Item -Path $OutputPath -ItemType Directory
    }

    #$fileName = ($targetUrl.OriginalString.Split([string[]][IO.Path]::GetInvalidFileNameChars(),[StringSplitOptions]::RemoveEmptyEntries)) -join '-'
    $fileName = 'ATPConnectivity'
    $json = $Results | ConvertTo-Json -Depth 3 -Compress:$Compress
    $json | Out-File -FilePath "$OutputPath\$fileName.json" -NoNewline -Force
}