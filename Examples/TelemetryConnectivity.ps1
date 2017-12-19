Set-StrictMode -Version 4

#Import-Module -Name .\ConnectivityTester.psm1 -Force

Import-Module -Name ConnectivityTester -Force

# dot source this file and then run:
# Get-TelemetryConnectivity

Function Get-TelemetryConnectivity() {
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[pscustomobject]])]
    Param(
       
        [Parameter(Mandatory=$false, HelpMessage='Whether to perform a BlueCoat Site Review lookup on the URL. Warning: The BlueCoat Site Review REST API is rate limited.')]
        [switch]$PerformBluecoatLookup
    )

    $parameters = $PSBoundParameters

    $isVerbose = $verbosePreference -eq 'Continue'    

    $data = New-Object System.Collections.Generic.List[pscustomobject]

    $data.Add([pscustomobject]@{ Url = 'https://settings-win.data.microsoft.com'; StatusCode = 200; })
    $data.Add([pscustomobject]@{ Url = 'https://watson.telemetry.microsoft.com'; StatusCode = 200; })
    $data.Add([pscustomobject]@{ Url = 'https://oca.telemetry.microsoft.com'; StatusCode = 200; })
    $data.Add([pscustomobject]@{ Url = 'https://vortex.data.microsoft.com/collect/v1'; StatusCode = 404; })

    $results = New-Object System.Collections.Generic.List[pscustomobject]

    $data | ForEach-Object {
        $targetUrl = $_.Url
        $statusCode = $_.StatusCode

        $connectivity = Get-Connectivity -Url $_.Url -ExpectedStatusCode $_.StatusCode -PerformBluecoatLookup:$PerformBluecoatLookup -Verbose:$isVerbose
        $results.Add($connectivity)
    }  

    return $results
}

Function Save-TelemetryPConnectivity() {
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
    $fileName = 'TelemetryConnectivity'
    $json = $Results | ConvertTo-Json -Depth 3 -Compress:$Compress
    $json | Out-File -FilePath "$OutputPath\$fileName.json" -NoNewline -Force
}