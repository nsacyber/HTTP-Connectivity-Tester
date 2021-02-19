Set-StrictMode -Version 4

Import-Module -Name HttpConnectivityTester -Force

# 1. import this file
# Import-Module .\WindowsTelemetryConnectivity.psm1

# 2. run one of the following:
# $connectivity = Get-WindowsTelemetryConnectivity
# $connectivity = Get-WindowsTelemetryConnectivity -Verbose
# $connectivity = Get-WindowsTelemetryConnectivity -PerformBlueCoatLookup
# $connectivity = Get-WindowsTelemetryConnectivity -Verbose -PerformBlueCoatLookup

# 3. filter results:
# $connectivity | Format-List -Property Blocked,TestUrl,UnblockUrl,DnsAliases,IpAddresses,Description,Resolved,ActualStatusCode,ExpectedStatusCode,UnexpectedStatus

# 4. save results to a file:
# Save-HttpConnectivity -Objects $connectivity -FileName ('WindowsTelemetryConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))

Function Get-WindowsTelemetryConnectivity() {
    <#
    .SYNOPSIS
    Gets connectivity information for Windows Telemetry.

    .DESCRIPTION
    Gets connectivity information for Windows Telemetry.

    .PARAMETER PerformBlueCoatLookup
    Use Symantec BlueCoat SiteReview to lookup what SiteReview category the URL is in.

    .EXAMPLE
    Get-WindowsTelemetryConnectivity

    .EXAMPLE
    Get-WindowsTelemetryConnectivity -Verbose

    .EXAMPLE
    Get-WindowsTelemetryConnectivity -PerformBlueCoatLookup

    .EXAMPLE
    Get-WindowsTelemetryConnectivity -Verbose -PerformBlueCoatLookup
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[pscustomobject]])]
    Param(
        [Parameter(Mandatory=$false, HelpMessage='Whether to perform a BlueCoat Site Review lookup on the URL. Warning: The BlueCoat Site Review REST API is rate limited.')]
        [switch]$PerformBluecoatLookup
    )

    $isVerbose = $VerbosePreference -eq 'Continue'

    $data = New-Object System.Collections.Generic.List[System.Collections.Hashtable]

    # https://docs.microsoft.com/en-us/windows/privacy/configure-windows-diagnostic-data-in-your-organization#endpoints

    $data.Add(@{ TestUrl = 'https://v10.vortex-win.data.microsoft.com/collect/v1'; ExpectedStatusCode = 400; Description = 'Diagnostic/telemetry data for Windows 10 1607 and later.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://v20.vortex-win.data.microsoft.com/collect/v1'; ExpectedStatusCode = 400; Description = 'Diagnostic/telemetry data for Windows 10 1703 and later.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://settings-win.data.microsoft.com'; ExpectedStatusCode = 404; Description = 'Used by applications, such as Windows Connected User Experiences and Telemetry component and Windows Insider Program, to dynamically update their configuration.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://watson.telemetry.microsoft.com'; ExpectedStatusCode = 404; Description = 'Windows Error Reporting.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://ceuswatcab01.blob.core.windows.net'; ExpectedStatusCode = 404; Description = 'Windows Error Reporting Central US 1.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://ceuswatcab02.blob.core.windows.net'; ExpectedStatusCode = 404; Description = 'Windows Error Reporting Central US 2.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://eaus2watcab01.blob.core.windows.net'; ExpectedStatusCode = 404; Description = 'Windows Error Reporting East US 1.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://eaus2watcab02.blob.core.windows.net'; ExpectedStatusCode = 404; Description = 'Windows Error Reporting East US 2.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://weus2watcab01.blob.core.windows.net'; ExpectedStatusCode = 404; Description = 'Windows Error Reporting West US 1.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://weus2watcab02.blob.core.windows.net'; ExpectedStatusCode = 404; Description = 'Windows Error Reporting West US 2.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })    
    $data.Add(@{ TestUrl = 'https://oca.telemetry.microsoft.com'; ExpectedStatusCode = 404; Description = 'Online Crash Analysis.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })
    $data.Add(@{ TestUrl = 'https://vortex.data.microsoft.com/collect/v1'; ExpectedStatusCode = 400; Description = 'OneDrive app for Windows 10.'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose })

    $results = New-Object System.Collections.Generic.List[pscustomobject]

    $data | ForEach-Object {
        $connectivity = Get-HttpConnectivity @_
        $results.Add($connectivity)
    }

    return $results
}
