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
# $connectivity | Format-List -Property IsBlocked,TestUrl,UnblockUrl,Description,Resolved,ActualStatusCode,ExpectedStatusCode

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

    $data.Add([pscustomobject]@{ TestUrl = 'http://windowsupdate.microsoft.com'; UnblockUrl = 'http://windowsupdate.microsoft.com'; StatusCode = 200; Description = '' })
    $data.Add([pscustomobject]@{ TestUrl = 'https://windowsupdate.microsoft.com'; UnblockUrl = 'http://windowsupdate.microsoft.com'; StatusCode = 200; Description = '' })   
    
    $results = New-Object System.Collections.Generic.List[pscustomobject]

    $data | ForEach-Object {
        $connectivity = Get-HttpConnectivity -TestUrl $_.TestUrl -UnblockUrl $_.UnblockUrl -ExpectedStatusCode $_.StatusCode -Description $_.Description -PerformBluecoatLookup:$PerformBluecoatLookup -Verbose:$isVerbose
        $results.Add($connectivity)
    }  

    return $results
}