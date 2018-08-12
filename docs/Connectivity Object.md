# Connectivity object

The [Get-HttpConnectivity](./Get-HttpConnectivity.md) cmdlet returns a Connectivity object. The object has properties for troubleshooting connectivity issues. The connectivity object, or an array of connectivity objects, can be passed into the [Save-HttpConnectivity](./Save-HttpConnectivity.md) cmdlet to save the object to a JSON file.

| Property Name | Property Type | Description |
| --- | --- | --- |
| TestUrl | System.Uri | The URL that was used for the test. |
| UnblockUrl | String | The URL to unblock. Can be a literal URL or a pattern-based URL. |
| UrlType | String | Is the type of URL to unblock a literal URL ('Literal') or a pattern-based URL ('Pattern')|
| Resolved | Boolean | Whether the URL resolved. |
| IpAddresses | String[] | The IP addresses associated with the URL. |
| DnsAliases | String[] | The DNS aliases associated with the URL. |
| Description | String | A description of the URL. |
| ActualStatusCode | Int32 | The actual HTTP status code return by the connectivity test. |
| ExpectedStatusCode | Int32 | The expected HTTP status code that should be returned by the connectivity test. |
| StatusMessage | String | The HTTP status message associated with the actual HTTP status code. Can also be an error message. |
| Blocked | Boolean | Whether the URL is blocked. |
| ServerCertificate | System.Management.Automation.PSCustomObject | |
| ServerCertificate.Certificate | System.Security.Cryptography.X509Certificates.X509Certificate2 | An X509 certificiate minus the RawData property. |
| ServerCertificate.Chain | System.Security.Cryptography.X509Certificates.X509Chain | X509 certificate chain information. |
| ServerCertificate.Error | System.Net.Security.SslPolicyErrors | TLS errors associated with the X509 certificate or certificate chain. |
| ServerCertificate.ErrorMessage | String | The error message with the X509 certificate or certificate chain. |
| ServerCertificate.HasError | Boolean | Whether there is a TLS error associated with the X509 certificate or certificate chain. |
| ServerCertificate.IgnoreError | Boolean | Whether to ignore the TLS error during the connectivity test. |
| BlueCoat | System.Management.Automation.PSCustomObject | |
| BlueCoat.SubmittedUri | System.Uri | The submitted URL as returned by the BlueCoat REST API. |
| BlueCoat.ReturnedUri | System.Uri | The returned URL as returned by the BlueCoat REST API. |
| BlueCoat.Rated | Boolean | Whether the URL has been rated. |
| BlueCoat.LastRated | String | When the URL was last dated. If less than 7 days since last rated, then it will be a date. If greater than 7 days since last rated, then it will be "> 7 days". |
| BlueCoat.Locked | Boolean | Whether the rating is locked by BlueCoat. |
| BlueCoat.LockMessage | String | The message indicating why the rating is locked. |
| BlueCoat.Pending | Boolean | Whether a rating decision is pending. |
| BlueCoat.PendingMessage | String | The message indicating why the rating is pending. |
| BlueCoat.Categories | System.Collections.Hashtable[String,String] | A hashtable where the key is the rating category name and the value is the link to the description of the category. |