# Connectivity Tester
Aids in discovering HTTP and HTTPS connectivity issues. Includes a PowerShell module named [ConnectivityTester](./ConnectivityTester/) along with [example PowerShell scripts](./Examples/) to use the module.

## Getting started

To get started using the tools:

1. [Download](#downloading-the-repository) the repository as a zip file 
1. [Configure PowerShell](#configuring-the-powershell-environment) 
1. [Load the code](#loading-the-code) 
1. [Running the code](#running-the-code) 

## Downloading the repository

Download the [current code](https://github.com/iadgov/Connectivity-Tester/archive/master.zip) to your **Downloads** folder. It will be saved as **Connectivity-Tester-master.zip** by default.

## Configuring the PowerShell environment
The PowerShell commands are meant to run from a system with at least PowerShell 4.0 and .Net 4.5 installed. PowerShell may need to be configured to run the commands.

### Changing the PowerShell execution policy

Users may need to change the default PowerShell execution policy. This can be achieved in a number of different ways:

* Open a command prompt and run **powershell.exe -ExecutionPolicy Unrestricted** and run scripts from that PowerShell session. 
* Open a PowerShell prompt and run **Set-ExecutionPolicy Unrestricted -Scope Process** and run scripts from the current PowerShell session. 
* Open an administrative PowerShell prompt and run **Set-ExecutionPolicy Unrestricted** and run scripts from any PowerShell session. 

### Unblocking the PowerShell scripts
Users will need to unblock the downloaded zip file since it will be marked as having been downloaded from the Internet which PowerShell will block from executing by default. Open a PowerShell prompt and run the following commands to unblock the PowerShell code in the zip file:

1. `cd $env:USERPROFILE` 
1. `cd Downloads` 
1. `Unblock-File -Path '.\Connectivity-Tester-master.zip'`

Running the PowerShell scripts inside the zip file without unblocking the file will result in the following warning:

*Security warning*
*Run only scripts that you trust. While scripts from the internet can be useful, this script can potentially harm your computer. If you trust this script, use the Unblock-File cmdlet to allow the script to run without this warning message. Do you want to run C:\users\user\Downloads\script.ps1?*
*[D] Do not run [R] Run once [S] Suspend [?] Help (default is "D"):*


If the downloaded zip file is not unblocked before extracting it, then all the individual PowerShell files that were in the zip file will have to be unblocked. You will need to run the following command after Step 5 in the [Loading the code](#loading-the-code) section:

```
Get-ChildItem -Path '.\Connectivity-Tester' -Recurse -Include '*.ps1','*.psm1','*.psd1' | Unblock-File -Verbose
```

See the [Unblock-File command's documentation](https://docs.microsoft.com/en-us/powershell/module/Microsoft.PowerShell.Utility/Unblock-File?view=powershell-5.1) for more information on how to use it.

### Loading the code
Now extract the downloaded zip file and load the PowerShell code used for apply the policies.

1. Right click on the zip file and select **Extract All**
1. At the dialog remove **Connectivity-Tester-master** from the end of the path since it will extract the files to a Connectivity-Tester-master folder by default
1. Click the **Extract** button
1. From the previously opened PowerShell prompt, rename the **Connectivity-Tester-master** folder to **Connectivity-Tester** `mv .\Connectivity-Tester-master\ .\Connectivity-Tester\`
1. `cd Connectivity-Tester`
1. Inside the **Connectivity-Tester** folder is another folder named **ConnectivityTester** which is a PowerShell module. Move this folder to a folder path in your $PSModulePath such as **C:\\users\\*username*\\Documents\\WindowsPowerShell\\Modules**
1. `mv .\ConnectivityTester "$env:USERPROFILE\Documents\WindowsPowerShell\Modules"`
1. Go to the **Examples folder** `cd .\Examples`
1. Dot source one of the example files `. .\WDATPConnectivity.ps1` or `. .\TelemetryConnectivity.ps1`

### Running the code
1. Run `$connectivity = Get-WDATPConnectivity -Verbose` or `$connectivity = Get-TelemetryConnectivity -Verbose`. If using BlueCoat as a proxy, then add the `-PerformBlueCoatLookup` option
1. Run `$connectivity | Format-List -Property Url,IsBlocked` to see if any URLs are blocked

## License
See [LICENSE](./LICENSE.md).

## Contributing
See [CONTRIBUTING](./CONTRIBUTING.md).

## Disclaimer
See [DISCLAIMER](./DISCLAIMER.md).