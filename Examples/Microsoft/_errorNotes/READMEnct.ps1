<#
General Instructions
Every single step from setup to execution.


1) Empire - low side
2) Open Powershell
3) Start the remote machine that Luis created for me, that has internet access.
4) > mstsc -v:kansas_dev


5) That opens a fresh Windows 10 Machine, basically a Remote VM.

6) We imported and installed VSCode, and LibreOffice in here.
7) We imported our original code notes.
8) We have internet, we downloaded the Http-Connectivity-Tester repo zip from GitHub
9) We have everything saved on the Desktop since this is easy access for a specific task.

10) We did have notes and adjustments from a prior work 
	Saved in Desktop Folder > HTTP_Originals

11) New fresh zip repo from GitHub
	Saved in Desktop	> HTTP-Connectivity-Tester.zip
    Don't unzip yet. See below.
========================================================#>

#CMD >> powershell.exe -ExecutionPolicy Bypass
#CMD >> powershell.exe -ExecutionPolicy Unrestricted

#Open powershell
Set-ExecutionPolicy Unrestricted -Scope Process
#Close that powershell window

#Open new powershell window as an admin
Set-ExecutionPolicy Unrestricted

cd $env:USERPROFILE
#I dragged http-connectivity-tester.zip to VM-desktop.
cd Desktop
Unblock-File -Path '.\HTTP-Connectivity-Tester-master(original download).zip'


#Change the name of the zipped
mv '.\HTTP-Connectivity-Tester-master(original download).zip' '.\HTTP-Connectivity-Tester.zip'

#Expand the zip
Expand-Archive -Path .\HTTP-Connectivity-Tester.zip -DestinationPath .\


#Change the name of the unzipped, as master came through
mv .\HTTP-Connectivity-Tester-master .\HTTP-Connectivity-Tester

#Move into folder
cd .\HTTP-Connectivity-Tester

#Check which folders are powershell module directories, where modules can be installed.
$env:PSModulePath
<#Results:
    C:\Users\ncterry\Documents\WindowsPowerShell\Modules
    C:\Program Files\WindowsPowerShell\Modules
    C:\Windows\system32\WindowsPowerShell\v1.0\Modules
#>

#Move the local sub-folder to one of these
mv .\HttpConnectivityTester 'C:\Program Files\WindowsPowerShell\Modules'

#Close this powershell and open another as an Admin

<#==============================================
13) Current work in the Http-Connectivity-Tester is just in the Microsoft directory:
	> C:\Users\ncterry\Desktop\HTTP-Connectivity-Tester\Examples\Microsoft

14) In the Microsoft directory, There are 7 folders, with a focus on 3:
	    AzureActiveDirectory
	    WindowsAnalytics
	    >>>WindowsDefenderAdvancedThreatProtection
	    >>>WindowsDefenderAntiVirus
	    >>>WindowsDefenderSmartScreen
	    WindowsTelemetry
	    WindowsUpdate

15) Inside of each, as backup, we copy the original code files with '_Original'. No changes to those
	>>>WindowsDefenderAdvancedThreatProtection
		> WDATPConnectivity.ps1
		> WDATPConnectivity_Original.ps1

16) In these folders, we also have related notes, readme, spreadsheet, etc.
	These will need to be removed when submitted.
#>

#These are our notes, below and above, but they are taken from the given notes on the GitHub repo.

#In the new PowerShell window, Move to unlocked/unzipped folder on the Desktop
#Shown above are the 3 folders we are focused on.

#This example below is targeted at a specific folder.
#Adjust/repeat for each you work on.
#For each that you are adjusting you take these same commands, but adjust the directories, and internal Cmdlet names.
#For example, below we have the code to focus on the WindowsTelemetry directory:
#=============================
#Import the connectivity test
cd C:\Users\ncterry\Desktop
cd .\HTTP-Connectivity-Tester\Examples\Microsoft\WindowsTelemetry

#Import the connectivity test
Import-Module -Name .\WindowsTelemetryConnectivity.psm1

#An example of a test.
$connectivity = Get-WindowsTelemetryConnectivity -Verbose
$connectivity | Format-List -Property Blocked,TestUrl,UnblockUrl,DnsAliases,IpAddresses,Description,Resolved,ActualStatusCode,ExpectedStatusCode,UnexpectedStatus 

#If you want to save the results of that test:
Save-HttpConnectivity -Objects $connectivity -FileName ('WindowsTelemetryConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))

#This is commands from an example on the GitHub instructions. 
#==============================================================

#But now if we go from the  > WindowsDefenderAdvancedThreatProtection folder
#Same instructions as above but we need to adjust for the new folder/files/commands

#=============================
#Import the connectivity test
cd C:\Users\ncterry\Desktop
cd .\HTTP-Connectivity-Tester\Examples\Microsoft\WindowsDefenderAdvancedThreatProtection

#Import the connectivity test
Import-Module -Name .\WDATPConnectivity.psm1

#An example of a test.
$connectivity = Get-WDATPConnectivity -Verbose
$connectivity | Format-List -Property Blocked,TestUrl,UnblockUrl,DnsAliases,IpAddresses,Description,Resolved,ActualStatusCode,ExpectedStatusCode,UnexpectedStatus 

#If you want to save the results of that test:
Save-HttpConnectivity -Objects $connectivity -FileName ('WindowsTelemetryConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date))

#==============================================================

#Now up to this point, our only changes have been to adjust the URLs that Clint had previously.

#17) Open VScode
#18) Direct the open folder at:
#	> C:\Users\ncterry\Desktop\HTTP-Connectivity-Tester\

#Now we open the only target ps1 file:
C:\Users\ncterry\Desktop\HTTP-Connectivity-Tester\Examples\Microsoft\WindowsDefenderAdvancedThreatProtection\WDATPConnectivity.ps1

#Seen above, on the $connectivity.... test that we ran, we will get an Expected Status, and Actual status.
#If the actual status does not match the expected status, we comment out that URL line, and list the status codes:

#Actual/Expected#....code....
#Example
#405/400#$data.Add(@{ TestUrl = 'https://us.vortex-win.data.microsoft.com/collect/v1'; ExpectedStatusCode = 400; Description='WDATP data channel'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # might correspond to https://us.vortex-win.data.microsoft.com/health/keepalive so might be able to remove
#404/400#$data.Add(@{ TestUrl = 'https://us.vortex-win.data.microsoft.com'; ExpectedStatusCode = 400; Description='WDATP data channel'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # might correspond to https://us.vortex-win.data.microsoft.com/health/keepalive so might be able to remove    
#404/400#$data.Add(@{ TestUrl = 'https://v10.vortex-win.data.microsoft.com'; ExpectedStatusCode = 400; Description='WDATP data channel'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # might correspond to https://us.vortex-win.data.microsoft.com/health/keepalive so might be able to remove    
###400/400#$data.Add(@{ TestUrl = 'https://v10.vortex-win.data.microsoft.com/collect/v1'; ExpectedStatusCode = 400; Description='WDATP data channel'; PerformBluecoatLookup=$PerformBluecoatLookup; Verbose=$isVerbose }) # might correspond to https://us.vortex-win.data.microsoft.com/health/keepalive so might be able to remove    
#
<#
In the 4 lines above, the original url is the top: https://us.vortex-win.data.microsoft.com/collect/v1
You can see that the Actual status, did not match the expected status.
We added a single hash, just to comment and show that it is not complete.

Copied the line, pasted below.
Changed the URL, tried again, Actual != Expected, so we give it another single hash.

The bottom URL that we tried, google + guess and check, our Actual/Matched the expected. 
Technically I don't know if this is actually the correct URL, but it appears to work. Clint will need final say.
Since I think that it works, I Commented it out with a triple hash.
Any that worked, including original URLs have a triple hash.
#>

# Now the catch is when we actually have to save and run. 
# Since this is a user-created PS module, if we change it, we have to re-import it into PowerShell.
# So we changed a URL, MAKE SURE TO save the ps1 file.

# Now is a strange part, we cannot run the code from above, again, in the same powershell window/tab as before. Not sure why
# We started by closing Powershell and opening a new window each time, but that is annoying.
# We then tried:
#       PowerShell >> File >> New PowerShell Tab 
#Then run the same code again, but from the new tab.
#
#=============================
#Import the connectivity test
cd C:\Users\ncterry\Desktop
cd .\HTTP-Connectivity-Tester\Examples\Microsoft\WindowsDefenderAdvancedThreatProtection

#Import the connectivity test
Import-Module -Name .\WDATPConnectivity.psm1

#An example of a test.
$connectivity = Get-WDATPConnectivity -Verbose
$connectivity | Format-List -Property Blocked,TestUrl,UnblockUrl,DnsAliases,IpAddresses,Description,Resolved,ActualStatusCode,ExpectedStatusCode,UnexpectedStatus 
#=============================
# Same 5 lines again, but it will import and run the adjusted ps1 module that we changed.






