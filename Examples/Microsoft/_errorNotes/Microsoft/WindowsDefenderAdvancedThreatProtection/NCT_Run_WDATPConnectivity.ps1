cd C:\Users\ncterry\Desktop
cd .\HTTP-Connectivity-Tester\Examples\Microsoft\
cd .\WindowsDefenderAdvancedThreatProtection
$connectivity = Get-WDATPConnectivity -Verbose
$connectivity | Format-List -Property Blocked,TestUrl,UnblockUrl,DnsAliases,IpAddresses,Description,Resolved,ActualStatusCode,ExpectedStatusCode,UnexpectedStatus 
Save-HttpConnectivity -FileName ('WDATPConnectivity_{0:yyyyMMdd_HHmmss}' -f (Get-Date)) -Objects $connectivity