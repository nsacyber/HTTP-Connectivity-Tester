# HTTP Connectivity Tester

Aids in discovering HTTP and HTTPS connectivity issues. Includes a PowerShell module named [HttpConnectivityTester](./HttpConnectivityTester/) along with [example PowerShell scripts](./Examples/) to use the module.

## Getting started

To get started using the tools:

1. [Download](#downloading-the-repository) the repository as a zip file
1. [Configure PowerShell](#configuring-the-powershell-environment)
1. [Extract the code](#extracting-the-code)
1. [Load the code](#loading-the-code)
1. [Run the code](#running-the-code)

## Downloading the repository

[Download the current code](https://github.com/nsacyber/HTTP-Connectivity-Tester/archive/master.zip) to your **Downloads** folder. It will be saved as **HTTP-Connectivity-Tester-master.zip** by default.

## Configuring the PowerShell environment

The PowerShell commands are meant to run from a system with at least PowerShell 4.0 and .Net 4.5 installed. PowerShell may need to be configured to run the commands.

### Changing the PowerShell execution policy

Users may need to change the default PowerShell execution policy. This can be achieved in a number of different ways:

* Open a command prompt and run **powershell.exe -ExecutionPolicy Bypass** and run scripts from that PowerShell session.
* Open a command prompt and run **powershell.exe -ExecutionPolicy Unrestricted** and run scripts from that PowerShell session.
* Open a PowerShell prompt and run **Set-ExecutionPolicy Unrestricted -Scope Process** and run scripts from the current PowerShell session.
* Open an administrative PowerShell prompt and run **Set-ExecutionPolicy Unrestricted** and run scripts from any PowerShell session.

### Unblocking the PowerShell scripts

Users will need to unblock the downloaded zip file since it will be marked as having been downloaded from the Internet (Mark of the Web) which PowerShell will block from executing by default. Open a PowerShell prompt and run the following commands to unblock the PowerShell code in the zip file:

1. `cd $env:USERPROFILE`
1. `cd Downloads`
1. `Unblock-File -Path '.\HTTP-Connectivity-Tester-master.zip'`

Running the PowerShell scripts inside the zip file without unblocking the file will result in the following warning:

*Security warning*
*Run only scripts that you trust. While scripts from the internet can be useful, this script can potentially harm your computer. If you trust this script, use the Unblock-File cmdlet to allow the script to run without this warning message. Do you want to run C:\users\user\Downloads\script.ps1?*
*[D] Do not run [R] Run once [S] Suspend [?] Help (default is "D"):*

If the downloaded zip file is not unblocked before extracting it, then all the individual PowerShell files that were in the zip file will have to be unblocked. You will need to run the following command after Step 5 in the [Loading the code](#loading-the-code) section:

```powershell
Get-ChildItem -Path '.\HTTP-Connectivity-Tester' -Recurse -Include '*.ps1','*.psm1','*.psd1' | Unblock-File -Verbose
```

See the [Unblock-File command's documentation](https://docs.microsoft.com/en-us/powershell/module/Microsoft.PowerShell.Utility/Unblock-File?view=powershell-5.1) for more information on how to use it.

### Extracting the code

1. Right click on the zip file and select **Extract All**
1. At the dialog remove **HTTP-Connectivity-Tester-master** from the end of the path since it will extract the files to a HTTP-Connectivity-Tester-master folder by default
1. Click the **Extract** button
1. From the previously opened PowerShell prompt, rename the **HTTP-Connectivity-Tester-master** folder to **HTTP-Connectivity-Tester** `mv .\HTTP-Connectivity-Tester-master\ .\HTTP-Connectivity-Tester\`

or

1. From the previously opened PowerShell prompt, type `Expand-Archive -Path .\HTTP-Connectivity-Tester-master.zip -DestinationPath .\`

The [Expand-Archive command](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.archive/expand-archive) is available starting with PowerShell 5.0.

### Loading the code

Extract the downloaded zip file and install the HttpConnectivityTester PowerShell module.

1. `cd HTTP-Connectivity-Tester`
1. Inside the **HTTP-Connectivity-Tester** folder is another folder named **HttpConnectivityTester** which is the HttpConnectivityTester PowerShell module. Move this folder to one of the PowerShell module directories on the system. Open a PowerShell prompt and type **$env:PSModulePath** to see the locations where PowerShell modules can be installed. PowerShell 4.0 and later allow [modules to be installed](https://msdn.microsoft.com/en-us/library/dd878350(v=vs.85).aspx#Where%20to%20Install%20Modules) at the following paths by default: %ProgramFilesDir%\WindowsPowerShell\Modules\;%SystemRoot%\System32\WindowsPowerShell\v1.0\Modules\;%UserProfile%\Documents\WindowsPowerShell\Modules\
1. `mv .\HttpConnectivityTester "$env:USERPROFILE\Documents\WindowsPowerShell\Modules"`
1. Close the PowerShell prompt and open a new PowerShell prompt
1. Go to the Examples folder `cd .\Examples` from the extracted download
1. Go to the vendor specific folder `cd .\Microsoft`
1. Go to the product/service specific folder `cd .\WindowsTelemetry\`
1. Import the product/service specific connectivity test `Import-Module -Name .\WindowsTelemetryConnectivity.psm1`

### Running the code

Call the main Get- command (e.g. `Get-WindowsTelemetryConnectivity`) after importing the product/service specific connectivity test to execute the test. The main Get- command is named after the file name. For example, **Get-WindowsTelemetryConnectivity** is the main Get- command for the WindowsTelemetryConnectivity.psm1 file. The main Get- command is **Get-WDATPConnectivity** for the WDATPConnectivity.psm1 file. The product/service specific Get- command is a wrapper around the [Get-HttpConnectivity](./docs/Get-HttpConnectivity.md) command provided by the PowerShell moduled.

The main Get- command for each connectivity test supports the same common options:

* **-Verbose** - prints verbose output to the console
* **-PerformBlueCoatLookup** - useful for looking up the rating of a URL when a BlueCoat proxy is being used. A rate limit is enforced for accessing the BlueCoat SiteReview REST API so use this option only when behind a BlueCoat proxy and use it sparingly. The script will automatically rate limit BlueCoat requests after every 10 requests and will then pause for 5 minutes.

Some Get- commands support additional unique options that can be discovered by running the built-in **Get-Help** command on the main Get- command (e.g. `Get-Help Get-WindowsTelemetryConnectivity -Detailed`).

An example for running, viewing, and saving a connectivity test:

```powershell
cd .\Examples\Microsoft\WindowsTelemetry\
Import-Module -Name .\WindowsTelemetryConnectivity.psm1
$connectivity = Get-WindowsTelemetryConnectivity -Verbose
$connectivity | Format-List -Property Blocked,TestUrl,UnblockUrl,DnsAliases,IpAddresses,Description,Resolved,ActualStatusCode,ExpectedStatusCode,UnexpectedStatus
Save-HttpConnectivity -Objects $connectivity -FileName ('WindowsTelemetryConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))
```

### Interpreting results

The main Get- command returns a [Connectivity object](./docs/Connectivity%20Object.md) that contains more information about the connectivity test. The main properties of interest from the Connectivity object that are useful for determining if a URL or service is blocked or functional are:

* **Blocked** - whether the service appears to be blocked. Value should be **false**.
* **TestUrl** - the URL that was used to perform the test.
* **UnblockUrl** - the URL to get unblocked. Can be a URL pattern rather than a literal URL.
* **DnsAliases** - a list of DNS aliases for the TestUrl. Pattern based unblocks of the TestUrl may need matching unblocks of all the DNS aliases.
* **IpAddresses** - a list of IP addresses corresponding to the TestUrl. Unblocking based on the listed IP addresses is not effective due to cloud providers and content delivery networks that may return many different IP addresses.
* **Description** - a description of what the URL is for.
* **Resolved** - whether the URL resolves its DNS entry to IP addresses or DNS aliases. Value should be **true**.
* **ExpectedStatusCode** - the expected HTTP status code returned by the test.
* **ActualStatusCode** - the actual HTTP status code returned by the test. Value will be 0 when Blocked is true or Resolved is false.
* **UnexpectedStatus** - was the actual status code an unexpected value regardless of whether the actual status code was the same as the expected status code.

See [Interpreting results](./docs/Interpreting%20Results.md) for more information.

### Saving results

The [Connectivity object](./docs/Connectivity%20Object.md) can be saved to a JSON file using the **[Save-HttpConnectivity](./docs/Save-HttpConnectivity.md)** command from the PowerShell module. The Save-HttpConnectivity command supports the following options:

* **-Verbose** - prints verbose output to the console.
* **-Objects** - the connectivity object, or an array of connectivity objects, to save to a JSON file.
* **-OutputPath** - the path to a folder to save the JSON file to.
* **-FileName** - the name of the file, minus the file extension, to save the connectivity object(s) to.

## Connectivity tests

The table below documents the currently implemented connectivity tests in the [Examples folder](./Examples/).

| Vendor | Product / Service |
| -- | -- |
| [Adobe](./Examples/Adobe/) | [Adobe Reader Manager updates](./Examples/Adobe/ARMUpdate/) |
| [Apple](./Examples/Apple/) | [macOS updates](./Examples/Apple/MacOSUpdate/) |
| [Google](./Examples/Google/) | [Chrome updates](./Examples/Google/ChromeBrowser/) |
| [Microsoft](./Examples/Microsoft/) | [Windows Analytics Update Compliance](./Examples/Microsoft/WindowsAnalytics/) |
| [Microsoft](./Examples/Microsoft/) | [Windows Analytics Upgrade Readiness](./Examples/Microsoft/WindowsAnalytics/) |
| [Microsoft](./Examples/Microsoft/) | [Windows Defender Advanced Threat Protection](./Examples/Microsoft/WindowsDefenderAdvancedThreatProtection/) |
| [Microsoft](./Examples/Microsoft/) | [Windows Defender Antivirus](./Examples/Microsoft/WindowsDefenderAntiVirus/) |
| [Microsoft](./Examples/Microsoft/) | [Windows Defender SmartScreen](./Examples/Microsoft/WindowsDefenderSmartScreen/) |
| [Microsoft](./Examples/Microsoft/) | [Windows Telemetry](./Examples/Microsoft/WindowsTelemetry/) |
| [Microsoft](./Examples/Microsoft/) | [Windows Update](./Examples/Microsoft/WindowsUpdate/) |
| [Mozilla](./Examples/Mozilla) | [Firefox updates](./Examples/Mozilla/Firefox/) |

## Documentation

Additional documentation is available in the [documentation folder](./docs/).

## License

See [LICENSE](./LICENSE.md).

## Contributing

See [CONTRIBUTING](./CONTRIBUTING.md).

## Disclaimer

See [DISCLAIMER](./DISCLAIMER.md).
