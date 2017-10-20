Set-StrictMode -Version 4

#Import-Module -Name .\DebugConnectivity.psm1 -Force

Import-Module -Name DebugConnectivity -Force

# dot source this file and then run:
# Debug-WDATPConnectivity

Function Debug-WDATPConnectivity() {
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[pscustomobject]])]
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
	
	$list.Add([pscustomobject]@{ Url = [Uri]'https://winatp-gw-cus.microsoft.com/test'; ExpectedStatus = 200; ConnectivityParameters = @{}; })
	$list.Add([pscustomobject]@{ Url = [Uri]'https://winatp-gw-eus.microsoft.com/test'; ExpectedStatus = 200; ConnectivityParameters = @{}; })
	$list.Add([pscustomobject]@{ Url = [Uri]'https://us.vortex-win.data.microsoft.com/collect/v1'; ExpectedStatus = 400; ConnectivityParameters = @{}; })
	$list.Add([pscustomobject]@{ Url = [Uri]'https://onboardingpackagescusprd.blob.core.windows.net/'; ExpectedStatus = 400; ConnectivityParameters = @{}; })
	$list.Add([pscustomobject]@{ Url = [Uri]'https://onboardingpackageseusprd.blob.core.windows.net/'; ExpectedStatus = 400; ConnectivityParameters = @{}; })
	$list.Add([pscustomobject]@{ Url = [Uri]'http://crl.microsoft.com'; ExpectedStatus = 400; ConnectivityParameters = @{}; })
	$list.Add([pscustomobject]@{ Url = [Uri]'http://ctldl.windowsupdate.com'; ExpectedStatus = 200; ConnectivityParameters = @{}; })
	
	Debug-Connectivity -List $list @PSBoundParameters
}