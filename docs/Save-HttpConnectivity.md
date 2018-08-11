# Save-HttpConnectivity

Saves HTTP [Connectivity object](./Connectivity%20Object.md)s to a JSON file.

## Examples

### Example 1

```powershell
    Save-HttpConnectivity -FileName 'Connectivity' -Objects $connectivity
```

### Example 2

```powershell
    Save-HttpConnectivity -FileName 'Connectivity' -Objects $connectivity -OutputPath "$env:userprofile\Documents\ConnectivityTestResults"
```

### Example 3

```powershell
    Save-HttpConnectivity -FileName 'Connectivity' -Objects $connectivity -Compress
```

## Syntax

```powershell
Save-HttpConnectivity [-FileName <String>] [-Objects <System.Management.Automation.PSCustomObject[]>] [-OutputPath <String>] [-Compress] [<CommonParameters>]
```

## Parameters

### Required parameters

#### FileName

The filename without the extension.

Type: String
Required: True
Default value: None

#### Objects

The connectivity object(s) to save.

Type: System.Collections.Generic.List[System.Management.Automation.PSCustomObject]
Required: True
Default value: None

### Optional parameters

#### OutputPath

The path to save the file to. Defaults to the user's Desktop folder.

Type: String
Required: False
Default value: "$env:userprofile\Desktop"

#### Compress

Compress the JSON text output.

Type: System.Management.Automation.SwitchParameter
Required: False
Default value: None

## Inputs

None.

## Outputs

None.