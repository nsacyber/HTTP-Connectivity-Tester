Set-StrictMode -Version 4

#Import-Module -Name .\ConnectivityTester.psm1 -Force

Import-Module -Name ConnectivityTester -Force

# dot source this file and then run:
# Get-TelemetryConnectivity

Function Get-TelemetryConnectivity() {
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[pscustomobject]])]
    Param(
        [Parameter(Mandatory=$false, HelpMessage='Path to save the output to')]
        [string]$OutputPath,
        
        [Parameter(Mandatory=$false, HelpMessage='Whether to perform a BlueCoat Site Review lookup on the URL. Warning: The BlueCoat Site Review REST API is rate limited.')]
        [switch]$PerformBluecoatLookup,
        
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

    $targetUrl = [Uri]'https://v10.vortex-win.data.microsoft.com'
    $connectivity = Get-Connectivity -Url 'https://v10.vortex-win.data.microsoft.com' -ExpectedStatus 404 -PerformBluecoatLookup:$PerformBluecoatLookup -Verbose:$isVerbose
    
    $fileName = ($targetUrl.OriginalString.Split([string[]][IO.Path]::GetInvalidFileNameChars(),[StringSplitOptions]::RemoveEmptyEntries)) -join '-'
    $json = $connectivity | ConvertTo-Json -Depth 5 -Compress:$Compress
    $json | Out-File -FilePath "$OutputPath\$fileName.json" -NoNewline -Force
    
    $connectivity = Get-Connectivity -Url 'https://settings-win.data.microsoft.com' -ExpectedStatus 200 -PerformBluecoatLookup:$PerformBluecoatLookup -Verbose:$isVerbose
    $connectivity = Get-Connectivity -Url 'https://watson.telemetry.microsoft.com' -ExpectedStatus 200 -PerformBluecoatLookup:$PerformBluecoatLookup -Verbose:$isVerbose
    $connectivity = Get-Connectivity -Url 'https://oca.telemetry.microsoft.com' -ExpectedStatus 200 -PerformBluecoatLookup:$PerformBluecoatLookup -Verbose:$isVerbose
    $connectivity = Get-Connectivity -Url 'https://vortex.data.microsoft.com/collect/v1' -ExpectedStatus 404 -PerformBluecoatLookup:$PerformBluecoatLookup -Verbose:$isVerbose
}