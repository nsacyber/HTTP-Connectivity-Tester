Set-StrictMode -Version 4

Import-Module -Name HttpConnectivityTester -Force

# 1. import this file:
# Import-Module .\MacOSUpdateConnectivity.psm1

# 2. run one of the following:
# $connectivity = Get-MacOSUpdateConnectivity 
# $connectivity = Get-MacOSUpdateConnectivity -Verbose
# $connectivity = Get-MacOSUpdateConnectivity -PerformBlueCoatLookup 
# $connectivity = Get-MacOSUpdateConnectivity -Verbose -PerformBlueCoatLookup

# 3. filter results:
# $connectivity | Format-List -Property Blocked,TestUrl,UnblockUrl,DnsAliases,IpAddresses,Description,Resolved,ActualStatusCode,ExpectedStatusCode

# 4. save results:
# Save-HttpConnectivity -Results $connectivity -OutputPath "$env:userprofile\Desktop" -FileName ('MacOSUpdateConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))

Function Get-MacOSUpdateConnectivity() {
    <#
    .SYNOPSIS 
    Gets connectivity information for macOS updates.
    
    .DESCRIPTION  
    Gets connectivity information for macOS updates.
     
    .PARAMETER PerformBlueCoatLookup   
    Use Symantec BlueCoat SiteReview to lookup what SiteReview category the URL is in.
    
    .EXAMPLE   
    Get-MacOSUpdateConnectivity
    
    .EXAMPLE  
    Get-MacOSUpdateConnectivity -Verbose
    
    .EXAMPLE   
    Get-MacOSUpdateConnectivity -PerformBlueCoatLookup
    
    .EXAMPLE  
    Get-MacOSUpdateConnectivity -Verbose -PerformBlueCoatLookup
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
   
    $data.Add([pscustomobject]@{ TestUrl = 'https://swscan.apple.com'; UnblockUrl = 'https://swscan.apple.com'; StatusCode = 403; Description = ''; IgnoreCertificateValidationErrors=$false })
    $data.Add([pscustomobject]@{ TestUrl = 'https://swcdnlocator.apple.com'; UnblockUrl = 'https://swcdnlocator.apple.com'; StatusCode = 501; Description = ''; IgnoreCertificateValidationErrors=$false })

    # $data.Add([pscustomobject]@{ TestUrl = 'https://swquery.apple.com'; UnblockUrl = 'https://swquery.apple.com'; StatusCode = 403; Description = ''; IgnoreCertificateValidationErrors=$false }) # DNS failure    
    $data.Add([pscustomobject]@{ TestUrl = 'https://swdownload.apple.com'; UnblockUrl = 'https://swdownload.apple.com'; StatusCode = 403; Description = ''; IgnoreCertificateValidationErrors=$true })
    $data.Add([pscustomobject]@{ TestUrl = 'https://swcdn.apple.com'; UnblockUrl = 'https://swcdn.apple.com'; StatusCode = 404; Description = ''; IgnoreCertificateValidationErrors=$true })
    $data.Add([pscustomobject]@{ TestUrl = 'https://swdist.apple.com'; UnblockUrl = 'https://swdist.apple.com'; StatusCode = 403; Description = ''; IgnoreCertificateValidationErrors=$false })

    $results = New-Object System.Collections.Generic.List[pscustomobject]

    $data | ForEach-Object {
        $connectivity = Get-HttpConnectivity -TestUrl $_.TestUrl -UnblockUrl $_.UnblockUrl -ExpectedStatusCode $_.StatusCode -Description $_.Description -IgnoreCertificateValidationErrors:($_.IgnoreCertificateValidationErrors) -PerformBluecoatLookup:$PerformBluecoatLookup -Verbose:$isVerbose
        $results.Add($connectivity)
    }  

    return $results
}