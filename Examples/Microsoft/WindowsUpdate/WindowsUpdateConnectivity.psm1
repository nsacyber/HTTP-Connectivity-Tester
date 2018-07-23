Set-StrictMode -Version 4

Import-Module -Name HttpConnectivityTester -Force

# 1. import this file 
# Import-Module .\WindowsUpdateConnectivity.psm1

# 2. run one of the following:
# $connectivity = Get-WindowsUpdateConnectivity
# $connectivity = Get-WindowsUpdateConnectivity -Verbose
# $connectivity = Get-WindowsUpdateConnectivity -PerformBlueCoatLookup
# $connectivity = Get-WindowsUpdateConnectivity -Verbose -PerformBlueCoatLookup

# 3. filter results:
# $connectivity | Format-List -Property IsBlocked,TestUrl,UnblockUrl,Aliases,Addresses,Description,Resolved,ActualStatusCode,ExpectedStatusCode

# 4. save results to a file:
# Save-HttpConnectivity -Results $connectivity -OutputPath "$env:userprofile\Desktop" -FileName ('WindowsUpdateConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))

Function Get-WindowsUpdateConnectivity() {
    <#
    .SYNOPSIS 
    Gets connectivity information for Windows Update.

    .DESCRIPTION  
    Gets connectivity information for Windows Update.
     
    .PARAMETER PerformBlueCoatLookup   
    Use Symantec BlueCoat SiteReview to lookup what SiteReview category the URL is in.

    .EXAMPLE   
    Get-WindowsUpdateConnectivity

    .EXAMPLE  
    Get-WindowsUpdateConnectivity -Verbose
    
    .EXAMPLE   
    Get-WindowsUpdateConnectivity -PerformBlueCoatLookup

    .EXAMPLE  
    Get-WindowsUpdateConnectivity -Verbose -PerformBlueCoatLookup
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[pscustomobject]])]
    Param(     
        [Parameter(Mandatory=$false, HelpMessage='Whether to perform a BlueCoat Site Review lookup on the URL. Warning: The BlueCoat Site Review REST API is rate limited.')]
        [switch]$PerformBluecoatLookup
    )

    $isVerbose = $verbosePreference -eq 'Continue'    

    $data = New-Object System.Collections.Generic.List[pscustomobject]
    
    # 

    $data.Add([pscustomobject]@{ TestUrl = 'http://windowsupdate.microsoft.com'; UnblockUrl = 'http://windowsupdate.microsoft.com'; StatusCode = 200; Description = ''; IgnoreCertificateValidationErrors=$false })
    $data.Add([pscustomobject]@{ TestUrl = 'https://windowsupdate.microsoft.com'; UnblockUrl = 'https://windowsupdate.microsoft.com'; StatusCode = 200; Description = ''; IgnoreCertificateValidationErrors=$false })
    #$data.Add([pscustomobject]@{ TestUrl = 'https://windowsupdate.microsoft.com'; UnblockUrl = 'http://*.windowsupdate.microsoft.com'; StatusCode = 200; Description = ''; IgnoreCertificateValidationErrors=$false })
    $data.Add([pscustomobject]@{ TestUrl = 'https://geo-prod.do.dsp.mp.microsoft.com'; UnblockUrl = 'https://*.do.dsp.mp.microsoft.com'; StatusCode = 403; Description = ''; IgnoreCertificateValidationErrors=$false }) # many different *-prod.do.dsp.mp.microsoft.com, but geo-prod.do.dsp.mp.microsoft.com is the most common one
    $data.Add([pscustomobject]@{ TestUrl = 'https://download.windowsupdate.com'; UnblockUrl = 'https://download.windowsupdate.com'; StatusCode = 504; Description = ''; IgnoreCertificateValidationErrors=$true})
    $data.Add([pscustomobject]@{ TestUrl = 'https://au.download.windowsupdate.com'; UnblockUrl = 'https://*.download.windowsupdate.com'; StatusCode = 400; Description = ''; IgnoreCertificateValidationErrors=$true }) # many different *.download.windowsupdate.com, au.download.windowsupdate.com is most common. *.au.download.windowsupdate.com, *.l.windowsupdate.com
    
    $results = New-Object System.Collections.Generic.List[pscustomobject]

    $data | ForEach-Object {
        $connectivity = Get-HttpConnectivity -TestUrl $_.TestUrl -UnblockUrl $_.UnblockUrl -ExpectedStatusCode $_.StatusCode -Description $_.Description -IgnoreCertificateValidationErrors:($_.IgnoreCertificateValidationErrors) -PerformBluecoatLookup:$PerformBluecoatLookup -Verbose:$isVerbose
        $results.Add($connectivity)
    }  

    return $results
}