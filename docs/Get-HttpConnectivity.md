# Get-HttpConnectivity

Get HTTP connectivity information for a URL.

## Examples

### Example 1

```powershell
Get-HttpConnectivity -TestUrl http://www.site.com
```

### Example 2

```powershell
Get-HttpConnectivity -TestUrl http://www.site.com -UrlPattern http://*.site.com
```

### Example 3

```powershell
Get-HttpConnectivity -TestUrl http://www.site.com -Method POST
```

### Example 4

```powershell
Get-HttpConnectivity -TestUrl http://www.site.com -ExpectedStatusCode 400
```

### Example 5

```powershell
Get-HttpConnectivity -TestUrl http://www.site.com -Description 'A site that does something'
```

### Example 6

```powershell
Get-HttpConnectivity -TestUrl http://www.site.com -UserAgent 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/68.0.3440.84 Safari/537.36''
```

### Example 7

```powershell
Get-HttpConnectivity -TestUrl http://www.site.com -IgnoreCertificateValidationErrors
```

### Example 8

```powershell
Get-HttpConnectivity -TestUrl http://www.site.com -PerformBluecoatLookup
```

## Syntax

```powershell
Get-HttpConnectivity [-TestUrl <System.Uri>] [-UrlPattern <String>] [-Description <String>] [-ExpectedStatusCode <Int32>] [-Method <String>] [-UserAgent <String>] [-IgnoreCertificateValidationErrors] [-PerformBluecoatLookup] [<CommonParameters>]
```

## Parameters

### Required parameters

#### TestUrl

The URL to test.

Type: System.Uri
Required: True
Default value: None

### Optional parameters

#### UrlPattern

The URL pattern to unblock when the URL to unblock is not a literal URL.

Type: String
Required: True
Default value: None

#### Method

TThe HTTP method used to test the URL. Defaults to 'GET'.

Type: String
Required: False
Default value: 'GET'

#### ExpectedStatusCode

The HTTP status code expected to be returned. Defaults to 200.

Type: Int32
Required: False
Default value: 200

#### Description

A description of the connectivity test or purpose of the URL.

Type: String
Required: False
Default value: None

#### UserAgent

The TPP user agent. Defaults to the Chrome browser user agent.

Type: String
Required: False
Default value: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/67.0.3396.87 Safari/537.36'

#### IgnoreCertificateValidationErrors

Whether to ignore certificate validation errors so they don't affect the connectivity test. Some HTTPS endpoints are not meant to be accessed by a browser so the endpoint will not validate against browser security requirements.

Type: System.Management.Automation.SwitchParameter
Required: False
Default value: None

#### PerformBluecoatLookup

Whether to perform a Symantec BlueCoat Site Review lookup on the URL. Warning: The [Symantec BlueCoat Site Review](https://sitereview.bluecoat.com/) REST API is rate limited. Automatic throttling is performed when this parameter is used.

Type: System.Management.Automation.SwitchParameter
Required: False
Default value: None

## Inputs

None.

## Outputs

A System.Management.Automation.PSCustomObject that is a [Connectivity object.](./Connectivity%20Object.md).