## Windows Update connectivity tests

### Usage
1. Import this file: `Import-Module .\WindowsUpdateConnectivity.psm1`
1. Run one of the following:
    * `$connectivity = Get-WindowsUpdateConnectivity`
    * `$connectivity = Get-WindowsUpdateConnectivity -Verbose`
    * `$connectivity = Get-WindowsUpdateConnectivity -PerformBlueCoatLookup`
    * `$connectivity = Get-WindowsUpdateConnectivity -Verbose -PerformBlueCoatLookup`
1. Filter results: `$connectivity | Format-List -Property IsBlocked,TestUrl,UnblockUrl,Description,Resolved,ActualStatusCode,ExpectedStatusCode`
1. Save results to a file: `Save-HttpConnectivity -Results $connectivity -OutputPath "$env:userprofile\Desktop" -FileName ('WindowsUpdateConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))`

### Tested URLs

| Test URL | URL to Unblock | Description |
| -- | -- | -- |
| | | |
| | | |
| | | |
| | | |
| | | |
| | | |

### References
* [Manage Windows 10 connection endpoints - Windows Update](https://docs.microsoft.com/en-us/windows/privacy/manage-windows-endpoints#windows-update)
* [Can't download updates from Windows Update from behind a firewall or proxy server](https://support.microsoft.com/en-us/help/3084568/can-t-download-updates-from-windows-update-from-behind-a-firewall-or-p)
* [How to Configure a Firewall for Software Updates](https://technet.microsoft.com/en-us/library/bb693717.aspx)