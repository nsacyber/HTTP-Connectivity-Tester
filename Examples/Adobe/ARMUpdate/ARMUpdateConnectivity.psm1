Set-StrictMode -Version 4

Import-Module -Name HttpConnectivityTester -Force

# 1. import this file:
# Import-Module .\ARMUpdateConnectivity.psm1

# 2. run one of the following:
# $connectivity = Get-ARMUpdateConnectivity 
# $connectivity = Get-ARMUpdateConnectivity -Verbose
# $connectivity = Get-ARMUpdateConnectivity -PerformBlueCoatLookup 
# $connectivity = Get-ARMUpdateConnectivity -Verbose -PerformBlueCoatLookup

# 3. filter results:
# $connectivity | Format-List -Property Blocked,TestUrl,UnblockUrl,DnsAliases,IpAddresses,Description,Resolved,ActualStatusCode,ExpectedStatusCode

# 4. save results:
# Save-HttpConnectivity -Results $connectivity -OutputPath "$env:userprofile\Desktop" -FileName ('ARMUpdateConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))

Function Get-ARMUpdateConnectivity() {
    <#
    .SYNOPSIS 
    Gets connectivity information for Adobe Reader updates.
    
    .DESCRIPTION  
    Gets connectivity information for Adobe Reader updates.
     
    .PARAMETER PerformBlueCoatLookup   
    Use Symantec BlueCoat SiteReview to lookup what SiteReview category the URL is in.
    
    .EXAMPLE   
    Get-ARMUpdateConnectivity
    
    .EXAMPLE  
    Get-ARMUpdateConnectivity -Verbose
    
    .EXAMPLE   
    Get-ARMUpdateConnectivity -PerformBlueCoatLookup
    
    .EXAMPLE  
    Get-ARMUpdateConnectivity -Verbose -PerformBlueCoatLookup
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
   
    $data.Add([pscustomobject]@{ TestUrl = 'http://armmf.adobe.com'; UnblockUrl = 'http://armmf.adobe.com'; StatusCode = 404; Description = 'Adobe update metadata download'; IgnoreCertificateValidationErrors=$false })
    $data.Add([pscustomobject]@{ TestUrl = 'https://armmf.adobe.com'; UnblockUrl = 'https://armmf.adobe.com'; StatusCode = 404; Description = 'Adobe update metadata download'; IgnoreCertificateValidationErrors=$false })

    $data.Add([pscustomobject]@{ TestUrl = 'http://ardownload.adobe.com'; UnblockUrl = 'http://ardownload.adobe.com'; StatusCode = 404; Description = 'Adobe updates download'; IgnoreCertificateValidationErrors=$false })
    $data.Add([pscustomobject]@{ TestUrl = 'https://ardownload.adobe.com'; UnblockUrl = 'https://ardownload.adobe.com'; StatusCode = 404; Description = 'Adobe updates download'; IgnoreCertificateValidationErrors=$true })

    $data.Add([pscustomobject]@{ TestUrl = 'http://ardownload2.adobe.com'; UnblockUrl = 'http://ardownload2.adobe.com'; StatusCode = 404; Description = 'Adobe incremental updates download'; IgnoreCertificateValidationErrors=$false })
    $data.Add([pscustomobject]@{ TestUrl = 'https://ardownload2.adobe.com'; UnblockUrl = 'https://ardownload2.adobe.com'; StatusCode = 404; Description = 'Adobe incremental updates download'; IgnoreCertificateValidationErrors=$false })

    $data.Add([pscustomobject]@{ TestUrl = 'http://crl.adobe.com'; UnblockUrl = 'http://crl.adobe.com'; StatusCode = 404; Description = 'Adobe Certificate Revocation List'; IgnoreCertificateValidationErrors=$false })
    
    $results = New-Object System.Collections.Generic.List[pscustomobject]

    $data | ForEach-Object {
        $connectivity = Get-HttpConnectivity -TestUrl $_.TestUrl -UnblockUrl $_.UnblockUrl -ExpectedStatusCode $_.StatusCode -Description $_.Description -IgnoreCertificateValidationErrors:($_.IgnoreCertificateValidationErrors) -PerformBluecoatLookup:$PerformBluecoatLookup -Verbose:$isVerbose
        $results.Add($connectivity)
    }  

    return $results
}