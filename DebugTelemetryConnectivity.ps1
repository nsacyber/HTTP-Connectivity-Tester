Set-StrictMode -Version 4

#Import-Module -Name .\DebugConnectivity.psm1 -Force

Import-Module -Name DebugConnectivity -Force

# dot source this file and then run:
# Debug-WDATPConnectivity

Function Debug-TelemetryConnectivity() {
    [CmdletBinding()]
    [OutputType([void])]
    Param(
		[Parameter(Mandatory=$false, HelpMessage='Path to save the output to')]
		[string]$OutputPath,
		
        [Parameter(Mandatory=$false, HelpMessage='Whether to perform a BlueCoat Site Review lookup on the URL. Warning: The BlueCoat Site Review REST API is rate limited.')]
        [switch]$PerformBluecoatLookup,
		
		[Parameter(Mandatory=$false, HelpMessage='Compress JSON output')]
		[switch]$Compress,

		[Parameter(Mandatory=$false, HelpMessage='Returns an object representing the connectivity information')]	
		[switch]$PassThru
    )

	$list = New-Object System.Collections.Generic.List[pscustomobject]	

	# ConnectivityParameters are the parameters to pass into the Get-Connectivity cmdlet, if the defaults are not acceptable, in the DebugConnectivity module
	$list.Add([pscustomobject]@{ Url = [Uri]'https://v10.vortex-win.data.microsoft.com'; ExpectedStatus = 404; ConnectivityParameters = @{}; })
	$list.Add([pscustomobject]@{ Url = [Uri]'https://settings-win.data.microsoft.com'; ExpectedStatus = 200; ConnectivityParameters = @{ }; })
	$list.Add([pscustomobject]@{ Url = [Uri]'https://watson.telemetry.microsoft.com'; ExpectedStatus = 200; ConnectivityParameters = @{ }; })
	$list.Add([pscustomobject]@{ Url = [Uri]'https://oca.telemetry.microsoft.com'; ExpectedStatus = 200; ConnectivityParameters = @{ }; })
	$list.Add([pscustomobject]@{ Url = [Uri]'https://vortex.data.microsoft.com/collect/v1'; ExpectedStatus = 404; ConnectivityParameters = @{ }; })
	
	Debug-Connectivity -List $list @PSBoundParameters
}