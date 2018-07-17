Set-StrictMode -Version 4

Import-Module -Name HttpConnectivityTester -Force

# 1. import this file 
# Import-Module .\MacOSUpdateConnectivity.psm1

# 2. run one of the following:
# Get-MacOSUpdateConnectivity 
# Get-MacOSUpdateConnectivity -Verbose
# Get-MacOSUpdateConnectivity -PerformBlueCoatLookup 
# Get-MacOSUpdateConnectivity -Verbose -PerformBlueCoatLookup

# 3. filter results:
# $connectivity | Format-List -Property IsBlocked,TestUrl,Description,Resolved,ActualStatusCode,ExpectedStatusCode

# 4. save results
# Save-Connectivity -Results $connectivity -OutputPath "$env:userprofile\Desktop" -FileName ('MacOSUpdateConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))

Function Get-MacOSUpdateConnectivity() {
    <#
    .SYNOPSIS 
    Gets connectivity information for macOS updates.
    
    .DESCRIPTION  
    Gets connectivity information for macOS updates.
     
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

    $parameters = $PSBoundParameters

    $isVerbose = $verbosePreference -eq 'Continue'    

    $data = New-Object System.Collections.Generic.List[pscustomobject]
   
    $data.Add([pscustomobject]@{ TestUrl = 'https://swscan.apple.com'; StatusCode = 403; Description = ''; IgnoreCertificateValidationErrors=$false })
    $data.Add([pscustomobject]@{ TestUrl = 'https://swcdnlocator.apple.com'; StatusCode = 403; Description = ''; IgnoreCertificateValidationErrors=$false })

    # $data.Add([pscustomobject]@{ TestUrl = 'https://swquery.apple.com'; StatusCode = 403; Description = ''; IgnoreCertificateValidationErrors=$false }) # DNS failure    
    $data.Add([pscustomobject]@{ TestUrl = 'https://swdownload.apple.com'; StatusCode = 403; Description = ''; IgnoreCertificateValidationErrors=$true })
    $data.Add([pscustomobject]@{ TestUrl = 'https://swcdn.apple.com'; StatusCode = 404; Description = ''; IgnoreCertificateValidationErrors=$true })
    $data.Add([pscustomobject]@{ TestUrl = 'https://swdist.apple.com'; StatusCode = 403; Description = ''; IgnoreCertificateValidationErrors=$false })

    $results = New-Object System.Collections.Generic.List[pscustomobject]

    $data | ForEach-Object {
        $connectivity = Get-Connectivity -TestUrl $_.TestUrl -ExpectedStatusCode $_.StatusCode -IgnoreCertificateValidationErrors:($_.IgnoreCertificateValidationErrors) -PerformBluecoatLookup:$PerformBluecoatLookup -Verbose:$isVerbose
        $results.Add($connectivity)
    }  

    return $results
}