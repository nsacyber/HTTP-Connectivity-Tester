# Get-WDATPConnectivity

Gets connectivity information for Windows Defender Advanced Threat Protection.

## Examples

### Example 1

```powershell
Get-WDATPConnectivity
```

### Example 2

```powershell
Get-WDATPConnectivity -Verbose
```

### Example 3

```powershell
Get-WDATPConnectivity -Verbose -WorkspaceId 'a1a1a1a1-b2b2-c3c3-d4d4-e5e5e5e5e5e5'
```

### Example 4

```powershell
Get-WDATPConnectivity -Verbose -UrlType 'Endpoint'
```

### Example 5

```powershell
Get-WDATPConnectivity -Verbose -WorkspaceId '12345678-90AB-CDEF-GHIJ-1234567890AB'
```

### Example 6

```powershell
Get-WDATPConnectivity -PerformBlueCoatLookup
```

### Example 7

```powershell
Get-WDATPConnectivity -Verbose -PerformBlueCoatLookup
```

## Syntax

```powershell
Get-WDATPConnectivity [-UrlType <String>] [-WorkspaceId <String>] [-PerformBluecoatLookup] [<CommonParameters>]
```

## Parameters

### Optional parameters

#### UrlType

Selects the type of URLs to test. **All**, **Endpoint**, and **SecurityCenter** are accepted values. **All** is the default behavior.

Type: String

Required: True

Default value: All

#### WorkspaceId

The workspace identifier used for down level operating system support for WDATP.

The Workspace ID of WDATP tenant is needed to test connectivity for down level support. The Workspace ID can be found in the WDATP Security Center under **Settings** > **Machine management** > **Onboarding** by selecting the **Windows 7 SP1 and 8.1** or **Windows Server 2012 R2 and 2016** option.

Type: String

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

A System.Management.Automation.PSCustomObject that is a [Connectivity object.](./../../../docs/Connectivity%20Object.md).