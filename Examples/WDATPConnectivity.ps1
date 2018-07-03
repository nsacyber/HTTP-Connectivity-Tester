Set-StrictMode -Version 4

#Import-Module -Name .\ConnectivityTester.psm1 -Force

Import-Module -Name ConnectivityTester -Force

# dot source this file 
# . .\WDATPConnectivity.ps1

# then run one of the following:
# Get-WDATPConnectivity
# Get-WDATPConnectivity -Verbose
# Get-WDATPConnectivity -Verbose -PerformBlueCoatLookup

# to filter results or save them to a file:
# $connectivity = Get-WDATPConnectivity -Verbose -PerformBlueCoatLookup
# $connectivity | Format-List -Property IsBlocked,ActualStatusCode,ExpectedStatusCode,TestUrl
# Save-Connectivity -Results $connectivity -OutputPath "$env:userprofile\Desktop" -FileName ('WDATPConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))


Function Get-OperatingSystemReleaseId() {
    <#
    .SYNOPSIS
    Gets the operating system release identifier.

    .DESCRIPTION
    Gets the Windows 10 operating system release identifier (e.g. 1507, 1511, 1607).

    .EXAMPLE
    Get-OperatingSystemReleaseId
    #>
    [CmdletBinding()]
    [OutputType([UInt32])]
    Param()

    $release = [UInt32](Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'ReleaseId' -ErrorAction SilentlyContinue)

    return $release
}

Function Get-OperatingSystemVersion() {
    <#
    .SYNOPSIS
    Gets the operating system version.

    .DESCRIPTION
    Gets the operating system version.

    .EXAMPLE
    Get-OperatingSystemVersion
    #>
    [CmdletBinding()]
    [OutputType([System.Version])]
    Param()

    $major = 0
    $minor = 0
    $build = 0
    $revision = 0

    $currentVersionPath = 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion'

    $isWindows10orLater = $null -ne (Get-ItemProperty -Path $currentVersionPath -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'CurrentMajorVersionNumber' -ErrorAction SilentlyContinue)

    if($isWindows10orLater) {
        $major = [Uint32](Get-ItemProperty -Path $currentVersionPath -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'CurrentMajorVersionNumber' -ErrorAction SilentlyContinue)
        $minor = [UInt32](Get-ItemProperty -Path $currentVersionPath -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'CurrentMinorVersionNumber' -ErrorAction SilentlyContinue)
        $build = [UInt32](Get-ItemProperty -Path $currentVersionPath -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'CurrentBuildNumber' -ErrorAction SilentlyContinue)
        $revision = [UInt32](Get-ItemProperty -Path $currentVersionPath -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'UBR' -ErrorAction SilentlyContinue)

        if ($revision -eq 0) {
            $revision = 1507
        }
    } else {
        $major = [Uint32]((Get-ItemProperty -Path $currentVersionPath -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'CurrentVersion' -ErrorAction SilentlyContinue) -split '\.')[0]
        $minor = [UInt32]((Get-ItemProperty -Path $currentVersionPath -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'CurrentVersion' -ErrorAction SilentlyContinue) -split '\.')[1]
        $build = [UInt32](Get-ItemProperty -Path $currentVersionPath -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'CurrentBuild' -ErrorAction SilentlyContinue)      
        $revision = [UInt32](Get-ItemProperty -Path $currentVersionPath -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'UBR' -ErrorAction SilentlyContinue) # might exist on fully patched 8.1

        # get service pack version number for downlevel OSes. no SP installed, then registry value doesn't exist. Otherwise the value is 0x100, 0x200, etc
        if ($revision -eq 0) {
            $revision = ([UInt32](Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Windows' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty 'CSDVersion' -ErrorAction SilentlyContinue)) -shr 2
        }
    }

    return [System.Version]('{0}.{1}.{2}.{3}' -f $major,$minor,$build,$revision)
}

Function Get-WDATPConnectivity() {
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[pscustomobject]])]
    Param(       
        [Parameter(Mandatory=$false, HelpMessage='Whether to perform a BlueCoat Site Review lookup on the URL. Warning: The BlueCoat Site Review REST API is rate limited.')]
        [switch]$PerformBluecoatLookup
    )

    $parameters = $PSBoundParameters

    $isVerbose = $verbosePreference -eq 'Continue'

    $data = New-Object System.Collections.Generic.List[pscustomobject]

    # https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-atp/configure-proxy-internet-windows-defender-advanced-threat-protection#enable-access-to-windows-defender-atp-service-urls-in-the-proxy-server

    $data.Add([pscustomobject]@{ TestUrl = 'https://onboardingpackagescusprd.blob.core.windows.net/'; StatusCode = 400; Description=''; }) # dashboard
    $data.Add([pscustomobject]@{ TestUrl = 'https://onboardingpackageseusprd.blob.core.windows.net/'; StatusCode = 400; Description=''; }) # dashboard
    $data.Add([pscustomobject]@{ TestUrl = 'http://crl.microsoft.com'; StatusCode = 400; })
    $data.Add([pscustomobject]@{ TestUrl = 'http://ctldl.windowsupdate.com'; StatusCode = 200; })
    $data.Add([pscustomobject]@{ TestUrl = 'https://us.vortex-win.data.microsoft.com/collect/v1'; StatusCode = 400; Description=''; }) # might correspond to https://us.vortex-win.data.microsoft.com/health/keepalive so might be able to remove
    $data.Add([pscustomobject]@{ TestUrl = 'https://winatp-gw-cus.microsoft.com/test'; StatusCode = 200; Description=''; })
    $data.Add([pscustomobject]@{ TestUrl = 'https://winatp-gw-eus.microsoft.com/test'; StatusCode = 200; Description=''; })

    # WDATPConnectivityAnalyzer https://go.microsoft.com/fwlink/p/?linkid=823683 endpoints.txt file as of 05/03/2018:

    #$data.Add([pscustomobject]@{ TestUrl = 'https://winatp-gw-cus.microsoft.com/test'; StatusCode = 200; }) # repeat from above
    #$data.Add([pscustomobject]@{ TestUrl = 'https://winatp-gw-eus.microsoft.com/test'; StatusCode = 200; }) # repeat from above
    #$data.Add([pscustomobject]@{ TestUrl = 'https://winatp-gw-weu.microsoft.com/test'; StatusCode = 200; }) # europe
    #$data.Add([pscustomobject]@{ TestUrl = 'https://winatp-gw-neu.microsoft.com/test'; StatusCode = 200; }) # europe
    #$data.Add([pscustomobject]@{ TestUrl = 'https://eu.vortex-win.data.microsoft.com/health/keepalive'; StatusCode = 400; }) # europe
    $data.Add([pscustomobject]@{ TestUrl = 'https://us.vortex-win.data.microsoft.com/health/keepalive'; StatusCode = 200; Description=''; }) # might be repeat status for https://us.vortex-win.data.microsoft.com/collect/v1
    # http://ctldl.windowsupdate.com/msdownload/update/v3/static/trustedr/en/disallowedcertstl.cab # repeat from above

    $data.Add([pscustomobject]@{ TestUrl = 'https://events.data.microsoft.com'; StatusCode = 404; Description=''; }) # 1803 only?
    $data.Add([pscustomobject]@{ TestUrl = 'https://us-v20.events.data.microsoft.com'; StatusCode = 200; Description=''; }) # 1803 only

    $results = New-Object System.Collections.Generic.List[pscustomobject]

    $data | ForEach-Object {
        $connectivity = Get-Connectivity -TestUrl $_.TestUrl -ExpectedStatusCode $_.StatusCode -PerformBluecoatLookup:$PerformBluecoatLookup -Verbose:$isVerbose
        $results.Add($connectivity)
    }

    $authenticatedProxyValue = Get-ItemProperty 'HKLM:\Software\Policies\Microsoft\Windows\DataCollection' | Select-Object -Property DisableEnterpriseAuthProxy -ExpandProperty DisableEnterpriseAuthProxy -ErrorAction SilentlyContinue

    $useAuthenticatedProxy = $authenticatedProxyValue -eq $null -or $authenticatedProxyValue -eq 0

    $isRunningAsSystem = [bool](&"$env:systemroot\system32\whoami.exe" | Select-String -Pattern '^nt authority\\system$' -Quiet) #$env:username -eq "$env:computername$"

    if ($useAuthenticatedProxy -and $isRunningAsSystem) {
        Write-Warning -Message 'This script must be run as a user to ensure accurate results since the diagnostic tracking service is configured to use a user authenticating proxy'
    }

    if (!$useAuthenticatedProxy -and !$isRunningAsSystem) {
        Write-Warning -Message 'This script must be run as SYSTEM to ensure accurate results since the diagnostic tracking service is not configured to use a user authenticating proxy'
    }

    return $results
}