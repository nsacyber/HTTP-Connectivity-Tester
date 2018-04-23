Set-StrictMode -Version 4

$global:rateLimitCount = 0
$global:sleepSeconds = 5 * 60

Function Get-ErrorMessage() {
<#
    .SYNOPSIS  
    Gets a formatted error message from an error record.
   
    .DESCRIPTION
    Gets a formatted error message from an error record.

    .EXAMPLE
    Get-ErrorMessage -ErrorRecords $_
    #>
    [CmdletBinding()]
    [OutputType([string])]
    Param(
        [Parameter(Mandatory=$true, HelpMessage='The PowerShell error record object to get information from')]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.ErrorRecord]$ErrorRecord
    )
    Process {
        $msg = [System.Environment]::NewLine,'Exception Message: ',$ErrorRecord.Exception.Message -join ''

        if($ErrorRecord.Exception.HResult -ne $null) {
            $msg = $msg,[System.Environment]::NewLine,'Exception HRESULT: ',('{0:X}' -f $ErrorRecord.Exception.HResult),$ErrorRecord.Exception.HResult -join ''
        }
      
       if($ErrorRecord.Exception.StackTrace -ne $null) {
           $msg = $msg,[System.Environment]::NewLine,'Exception Stacktrace: ',$ErrorRecord.Exception.StackTrace -join ''
       }
      
       if (($ErrorRecord.Exception | Get-Member | Where-Object { $_.Name -eq 'WasThrownFromThrowStatement'}) -ne $null) {
           $msg = $msg,[System.Environment]::NewLine,'Explicitly Thrown: ',$ErrorRecord.Exception.WasThrownFromThrowStatement -join ''
       }

       if ($ErrorRecord.Exception.InnerException -ne $null) {
           if ($ErrorRecord.Exception.InnerException.Message -ne $ErrorRecord.Exception.Message) {
               $msg = $msg,[System.Environment]::NewLine,'Inner Exception: ',$ErrorRecord.Exception.InnerException.Message -join ''
           }

           if($ErrorRecord.Exception.InnerException.HResult -ne $null) {
               $msg = $msg,[System.Environment]::NewLine,'Inner Exception HRESULT: ',('{0:X}' -f $ErrorRecord.Exception.InnerException.HResult),$ErrorRecord.Exception.InnerException.HResult -join ''
           }
       }

       $msg = $msg,[System.Environment]::NewLine,'Call Site: ',$ErrorRecord.InvocationInfo.PositionMessage -join ''
   
       if (($ErrorRecord | Get-Member | Where-Object { $_.Name -eq 'ScriptStackTrace'}) -ne $null) {
           $msg = $msg,[System.Environment]::NewLine,"Script Stacktrace: ",$ErrorRecord.ScriptStackTrace -join ''
       }
   
       return $msg
    }
}

# locked URL result
# --------------------------------------------------------------------------------------------------------------------
# url                 : https://url.com
# unrated             : False
# curtrackingid       : 622805
# locked              : True
# locked_message      : This Web page matches a list of high-profile URLs which are rated correctly and will not be
#                       rated differently, thus it cannot be submitted via this page.
# locked_special_note :
# multiple            : False
# ratedate            : Last Time Rated/Reviewed: > 7 days <img
#                       onmouseover='document.getElementById("dtsDiv").style.display="block";'
#                       onmouseout='document.getElementById("dtsDiv").style.display="none";'src='images/info24.gif'
#                       width=10 height=10></img><div id='dtsDiv' style='background-color: white; position:absolute;
#                       display:none'><table cellspacing="0" cellpadding="4" width="600" style="border: 1px solid
#                       black;"><thead><th  bgcolor=003366>&nbsp;</th></thead><tbody><tr><td class='bodytext'>The URL
#                       submitted for review was rated more than 7 days ago.  The default setting for Symantec SG
#                       clients to download rating changes is once a day.  There is no need to show ratings older than
#                       this.<br><br>Since Symantec&#39;s desktop client K9 and certain OEM partners update differently,
#                       ratings may differ from those of a Symantec SG as well as those present on the Site Review
#                       Tool.</td></tr></tbody></table></div>
# categorization      : <a href="javascript:showPopupWindow('catdesc.jsp?catnum=38')">Technology/Internet</a> and <a
#                       href="javascript:showPopupWindow('catdesc.jsp?catnum=88')">Web Ads/Analytics</a>
# threatrisklevel     :
# threatrisklevel_en  :
# linkable            : True

# multiple submission result
# ------------------------------------------------------------------------------------------------------------------
# url                : http://url.com
# unrated            : False
# curtrackingid      : 692018
# locked             : False
# multiple           : True
# multiple_message   : Only a single submission per site is needed unless the content differs.  A pending related submission already exists.; 
# ratedate           : This page was rated by our WebPulse system; 
# categorization     : <a href="javascript:showPopupWindow('catdesc.jsp?catnum=38')">Technology/Internet</a>; 
# threatrisklevel    :
# threatrisklevel_en :
# linkable           : True

# unlocked URL result (locked_message and locked_special_note are missing)
# --------------------------------------------------------------------------------------------------------------------
# url                : http://url.com
# unrated            : False
# curtrackingid      : 690630
# locked             : False
# multiple           : False
# ratedate           : This page was rated by our WebPulse system
# categorization     : <a href="javascript:showPopupWindow('catdesc.jsp?catnum=38')">Technology/Internet</a>
# threatrisklevel    : 
# threatrisklevel_en : 
# linkable           : True

# rate limit exceeded result
# --------------------------------------------------------------------------------------------------------------------
# url       : http://url.com
# error     : Please complete the CAPTCHA
# errorType : captcha  

Function Get-BlueCoatSiteReview() {
    <#
    .SYNOPSIS
    Gets BlueCoat Site Review data for a URL.

    .DESCRIPTION
    Gets BlueCoat Site Review data for a URL.

    .EXAMPLE
    Get-BlueCoatSiteReview -Url http://www.site.com
    #>
    [CmdletBinding()]
    [OutputType([psobject])]
    Param (
        [Parameter(Mandatory=$true, HelpMessage='The URL to get BlueCoat Site Review information for.')]
        [ValidateNotNullOrEmpty()]
        [Uri]$Url
    )

    $siteReviewData = $null

    $uri = $Url

    $proxyUri = [System.Net.WebRequest]::GetSystemWebProxy().GetProxy($uri)

    $params = @{
        Uri = 'https://sitereview.bluecoat.com/rest/categorization';
        Method = 'POST';
        ProxyUseDefaultCredentials = (([string]$proxyUri) -ne $uri);
        UseBasicParsing = $true;
        UserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.168 Safari/537.36'
        ContentType = 'text/plain';
        Body =  @{url = $uri};
        Verbose = $false
    }

    if (([string]$proxyUri) -ne $uri) {
        $params.Add('Proxy',$proxyUri)
    }

    $ProgressPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

    $statusCode = 0

    try {
        $response = Invoke-WebRequest @params

        $statusCode = $response.StatusCode 
    } catch [System.Net.WebException] {
        throw "BlueCoat Site Review request for $Url failed with status code $statusCode"
    }

    if ($statusCode -eq 200) {
        $returnedJson = $response.Content | ConvertFrom-Json

        Write-Debug -Message ('JSON: {0}' -f $returnedJson)

        if ($returnedJson.PSObject.Properties.Name -contains 'errorType') {
            $m = 'Error retrieving Blue Coat data. Error Type: {0} Error Message: {1}' -f $returnedJson.errorType, $returnedJson.error
            throw $m
        } else {

            $cats = @{}

            $categoryParts = [string[]]@($returnedJson.categorization -split 'and')

            $categoryParts | ForEach-Object {
                $catMatched = $_ -match ".*(catdesc\.jsp\?catnum=\d*).*>(.*)</a>.*"

                $name = ''
                $link = ''

                if($catMatched -and $matches.Count -ge 3) {
                    $name = $matches[2].Trim()
                    $link = '{0}/{1}' -f 'https://sitereview.bluecoat.com',$matches[1].Trim()
                    $cats.Add($name, $link)
                }
            }

            $dateMatched = $returnedJson.ratedate -match 'Last Time Rated/Reviewed:\s*(.+)\s*<img.*' 

            $lastRated = ''

            if($dateMatched -and $matches.Count -ge 2) {
                $lastRated = $matches[1].Trim()
            }

            $siteReviewData = [pscustomobject]@{
                SubmittedUri = $Uri;
                ReturnedUri = [System.Uri]$returnedJson.url;
                IsRated = -not([bool]$returnedJson.unrated);
                LastedRated = $lastRated;
                IsLocked = [bool]$returnedJson.locked;
                LockMessage = if ([bool]$returnedJson.locked) { [string]$returnedJson.locked_message } else { '' };
                IsPending = [bool]$returnedJson.multiple;
                PendingMessage = if ([bool]$returnedJson.multiple) { [string]$returnedJson.multiple_message } else { '' };
                Categories = $cats;
            }
        }
    } else {
        throw "Request failed with status code $statusCode"
    }

    return $siteReviewData
}

Function Get-IPAddress() {
    <#
    .SYNOPSIS
    Gets the IP address(es) for a URL.

    .DESCRIPTION
    Gets the IP address(es) for a URL.

    .EXAMPLE
    Get-IPAddress -Url http://www.site.com
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    Param (
        [Parameter(Mandatory=$true, HelpMessage='The URL to get the IP address for.')]
        [ValidateNotNullOrEmpty()]
        [System.Uri]$Url
    )

    $addresses = [string[]]@()

    $dnsResults = $null
  
    $dnsResults = @(Resolve-DnsName -Name $Url.Host -NoHostsFile -Type A_AAAA -QuickTimeout -ErrorAction SilentlyContinue | Where-Object {$_.Type -eq 'A'}) 
    
    $addresses = [string[]]@($dnsResults | ForEach-Object { try { $_.IpAddress } catch [System.Management.Automation.PropertyNotFoundException] {} }) # IpAddress results in a PropertyNotFoundException when a URL is blocked upstream

    return ,$addresses
}

Function Get-IPAlias() {
    <#
    .SYNOPSIS
    Gets DNS alias for a URL.

    .DESCRIPTION
    Gets DNS alias for a URL.

    .EXAMPLE
    Get-IPAlias -Url http://www.site.com
    #>
    [CmdletBinding()]
    [OutputType([string[]])]
    Param (
        [Parameter(Mandatory=$true, HelpMessage='The URL to get the alias address for.')]
        [ValidateNotNullOrEmpty()]
        [System.Uri]$Url
    )

    $aliases = [string[]]@()

    $dnsResults = $null
    
    $dnsResults = @(Resolve-DnsName -Name $Url.Host -Type CNAME -NoHostsFile -QuickTimeout -ErrorAction SilentlyContinue | Where-Object { $_.Type -eq 'CNAME' })
    
    #$aliases = [string[]]@($dnsResults | ForEach-Object { try { $_.NameHost } catch [System.Management.Automation.PropertyNotFoundException] {} }) # NameHost results in a PropertyNotFoundException when a URL is blocked upstream
    $aliases = [string[]]@($dnsResults | ForEach-Object { $_.NameHost })

    return ,$aliases 
}

Function Get-CertificateErrorMessage() {
    <#
    .SYNOPSIS
    Gets certificate error messages for an HTTPS URL.

    .DESCRIPTION
    Gets certificate error messages for an HTTPS URL.

    .EXAMPLE
    Get-CertificateErrorMessage -Url http://www.site.com -Certificate $certificate -Chain $chain -PolicyError $policyError
    #>
    [CmdletBinding()] 
    [OutputType([string])]
    Param(
        [Parameter(Mandatory=$true, HelpMessage='The URL to test')]
        [ValidateNotNullOrEmpty()]
        [Uri]$Url,

        [Parameter(Mandatory=$true, HelpMessage='The certificate')]
        [ValidateNotNull()]
        [Security.Cryptography.X509Certificates.X509Certificate]$Certificate,

        [Parameter(Mandatory=$true, HelpMessage='The certificate chain')]
        [ValidateNotNull()]
        $Chain, # had to drop [Security.Cryptography.X509Certificates.X509Chain] otherwise call to Get-CertificateErrorMessage fails with "Cannot process argument transformation on parameter 'Chain'. Cannot create object of type "System.Security.Cryptography.X509Certificates.X509Chain". "ChainContext" is a ReadOnly property."

        [Parameter(Mandatory=$true, HelpMessage='The SSL error')]
        [ValidateNotNull()]
        [Net.Security.SslPolicyErrors]$PolicyError
    )

    $details = ''

    if($PolicyError -ne [Net.Security.SslPolicyErrors]::None) {
        switch ($PolicyError) {
            'RemoteCertificateChainErrors' {

                if ($Chain.ChainElements.Count -gt 0 -and $Chain.ChainStatus.Count -gt 0) {
                    #todo support more than one chain
                    $element = $Chain.ChainElements[0]
                    $status = $Chain.ChainStatus[0]
                    $details = ('Certificate chain error. Error: {0} Reason: {1} Certificate: {2}' -f $status.Status, $status.StatusInformation,$element.Certificate.ToString($false))
                } else {
                    $details = ('Certificate chain error. Certificate: {0}' -f $Certificate.ToString($false))
                }
                break
            }
            'RemoteCertificateNameMismatch' {
                $cert = New-Object Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList $Certificate

                $sanExtension = $cert.Extensions | Where-Object { $_.Oid.FriendlyName -eq 'Subject Alternative Name' }
                
                if ($sanExtension -eq $null) {
                    $subject = $cert.Subject.Split(',')[0].Replace('CN=', '')
                    $details = ('Remote certificate name mismatch. Host: {0} Subject: {1}' -f $Url.Host,$subject)
                } else {
                    $subject = $certificate.Subject.Split(',')[0].Replace('CN=', '')
                    $asnData = New-Object Security.Cryptography.AsnEncodedData -ArgumentList $sanExtension.Oid,$sanExtension.RawData
                    $sans = $asnData.Format($false).Replace('DNS Name=', '').Replace(',', '').Split(@(' '), [StringSplitOptions]::RemoveEmptyEntries)
                    $details = ('Remote certificate name mismatch. Host: {0} Subject: {1} SANs: {2}' -f $Url.Host,$subject,($sans -join ', '))
                }
                break
            }
            'RemoteCertificateNotAvailable' {
                $details = 'Remote certificate not available.'
            }
            'None' {
                break
            }
            default { 
                $details = ('Unrecognized remote certificate error. {0}' -f $PolicyError)
                break 
            }
        }
    }

    return $details
}

Function Get-Connectivity() {
    <#
    .SYNOPSIS
    Get connectivity information for a URL.

    .DESCRIPTION
    Get connectivity information for a URL.

    .EXAMPLE
    Get-Connectivity -Url http://www.site.com
    
    .EXAMPLE
    Get-Connectivity -Url http://www.site.com -Method POST

    .EXAMPLE
    Get-Connectivity -Url http://www.site.com -Method POST -ExpectedStatusCode 400

    .EXAMPLE
    Get-Connectivity -Url http://www.site.com -Method POST -ExpectedStatusCode 400 -IgnoreCertificateValidationErrors
    
    .EXAMPLE
    Get-Connectivity -Url http://www.site.com -Method POST -ExpectedStatusCode 400 -IgnoreCertificateValidationErrors -PerformBluecoatLookup
    #>
    [CmdletBinding()]
    [OutputType([void])]
    Param(
        [Parameter(Mandatory=$true, HelpMessage='The URL to test')]
        [ValidateNotNullOrEmpty()]
        [Uri]$TestUrl,

        [Parameter(Mandatory=$false, HelpMessage='The HTTP method to use to test the URL')]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('HEAD','GET', 'POST', IgnoreCase=$true)]
        [string]$Method = 'GET',
        
        [Parameter(Mandatory=$false, HelpMessage='The expected HTTP status code')]
        [ValidateNotNullOrEmpty()]
        [int]$ExpectedStatusCode = 200,

        [Parameter(Mandatory=$false, HelpMessage='Whether to ignore certificate validation errors')]
        [switch]$IgnoreCertificateValidationErrors,
        
        [Parameter(Mandatory=$false, HelpMessage='Whether to perform a BlueCoat Site Review lookup on the URL. Warning: The BlueCoat Site Review REST API is rate limited.')]
        [switch]$PerformBluecoatLookup
    )

    $isVerbose = $verbosePreference -eq 'Continue'

    if ($TestUrl.OriginalString.ToLower().StartsWith('http://') -or $TestUrl.OriginalString.ToLower().StartsWith('https://')) {
        $testUri = $TestUrl
    } else {
        $testUri = [Uri]('http://{0}' -f $testUri.OriginalString)
    }  

    $newLine = [System.Environment]::NewLine

    Write-Verbose -Message ('{0}*************************************************{1}Testing {2}{3}*************************************************{4}' -f $newLine,$newLine,$testUri,$newLine,$newLine)
    
    $script:ServerCertificate = $null
    $script:ServerCertificateChain = $null
    $script:ServerCertificateError = $null

    # can't use Invoke-WebRequest and override the callback due to PowerShell Runspace errors described in this post: http://huddledmasses.org/blog/validating-self-signed-certificates-properly-from-powershell/
    
    if($IgnoreCertificateValidationErrors) {
        $RemoteCertificateValidationCallback = {
            param([object]$sender, [Security.Cryptography.X509Certificates.X509Certificate]$certificate, [Security.Cryptography.X509Certificates.X509Chain]$chain, [Net.Security.SslPolicyErrors]$sslPolicyErrors)

            $script:ServerCertificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $certificate
            $script:ServerCertificateChain = $chain | Select-Object * # clone chain object otherwise we lose ChainElements and ChainStatus property contents on variable assignment... weird
            $script:ServerCertificateError = $sslPolicyErrors
            return $true
        }
    } else {
        $RemoteCertificateValidationCallback = {
            param([object]$sender, [Security.Cryptography.X509Certificates.X509Certificate]$certificate, [Security.Cryptography.X509Certificates.X509Chain]$chain, [Net.Security.SslPolicyErrors]$sslPolicyErrors)

            $script:ServerCertificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $certificate
            $script:ServerCertificateChain = $chain | Select-Object * # clone chain object otherwise we lose ChainElements and ChainStatus property contents on variable assignment... weird
            $script:ServerCertificateError = $sslPolicyErrors

            return [Net.Security.SslPolicyErrors]::None -eq $sslPolicyErrors
        }
    }

    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls11

    $proxyUri = [Net.WebRequest]::GetSystemWebProxy().GetProxy($testUri)

    $request = [Net.WebRequest]::CreateHttp($testUri)
    $request.Proxy = if ($testUri -ne $proxyUri) { [Net.WebRequest]::DefaultWebProxy } else { $null }
    $request.UseDefaultCredentials = ($testUri -ne $proxyUri)
    $request.UserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36'
    $request.Method = $Method
    $request.ServerCertificateValidationCallback = $RemoteCertificateValidationCallback

    $statusCode = 0
    $statusMessage = ''
    $response = $null    

    try {
        $response = $request.GetResponse()
        $httpResponse = $response -as [Net.HttpWebResponse]

        $statusCode = $httpResponse.StatusCode
        $statusMessage = $httpResponse.StatusDescription
    } catch [System.Net.WebException] {
        # useful WINHTTP error message code values and descriptions. will be in the exception
        # https://msdn.microsoft.com/en-us/library/windows/desktop/aa383770(v=vs.85).aspx
        # https://msdn.microsoft.com/en-us/library/windows/desktop/aa384110(v=vs.85).aspx

        $statusMessage = Get-ErrorMessage -ErrorRecord $_

        try {
            $statusCode = [int]$_.Exception.Response.StatusCode # StatusCode property results in a PropertyNotFoundException exception when the URL is blocked upstream
        } catch [System.Management.Automation.PropertyNotFoundException] {
            Write-Verbose -Message ('Unable to access {0} due to {1}' -f $testUri,$statusMessage)
        }
    } finally {
        if ($response -ne $null) {
            $response.Close()
        }
    }

    $hasServerCertificateError = if ($script:ServerCertificateError -eq $null) { $false } else { $script:ServerCertificateError -ne [Net.Security.SslPolicyErrors]::None }

    $serverCertificateErrorMessage = ''
    
    if ($testUri.Scheme.ToLower() -eq 'https' -and $hasServerCertificateError) {
        $serverCertificateErrorMessage = Get-CertificateErrorMessage -Url $testUri -Certificate $script:ServerCertificate -Chain $script:ServerCertificateChain -PolicyError $script:ServerCertificateError
    }

    $address = Get-IPAddress -Url $testUri -Verbose:$false
    $alias = Get-IPAlias -Url $testUri -Verbose:$false
    $actualStatusCode = [int]$statusCode
    $isBlocked = $statusCode -eq 0

    $statusMatch = $ExpectedStatusCode -eq $actualStatusCode

    $connectivitySummary = ('{0}Url: {1}{2}Addresses: {3}{4}Aliases: {5}{6}Actual Status: {7}{8}Expected Status: {9}{10}Status Matched: {11}{12}Status Message: {13}{14}Blocked: {15}{16}Certificate Error: {17}{18}Certificate Error Message: {19}{20}Ignore Certificate Validation Errors: {21}{22}{23}' -f $newLine,$testUri,$newLine,($address -join ', '),$newLine,($alias -join ', '),$newLine,$actualStatusCode,$newLine,$ExpectedStatusCode,$newLine,$statusMatch,$newLine,$statusMessage,$newLine,$isBlocked,$newLine,$hasServerCertificateError,$newLine,$serverCertificateErrorMessage,$newLine,$IgnoreCertificateValidationErrors,$newLine,$newLine)
    Write-Verbose -Message $connectivitySummary
   
    $bluecoat = $null

    if ($PerformBluecoatLookup) { 
        try {

            $global:rateLimitCount++

            if($global:rateLimitCount -gt 10) {
                $nowTime = [DateTime]::Now
                $resumeTime = $nowTime.AddSeconds($global:sleepSeconds)

                Write-Verbose -Message ('Paused for {0} seconds. Current time: {1} Resume time: {2}' -f $global:sleepSeconds,$nowTime,$resumeTime)

                Start-Sleep -Seconds $global:sleepSeconds
                
                $nowTime = [DateTime]::Now
                
                Write-Verbose -Message ('Resumed at {0}' -f $nowTime)

                $global:rateLimitCount = 1 # needs to be 1 since BlueCoat Site Review API is called when exiting this if statement. If left at 0, then will hit the rate limit on successive calls to this cmdlet
            }

            $bluecoat = Get-BlueCoatSiteReview -Url $testUri -Verbose:$isVerbose
            $bluecoatSummary = ('{0}Rated: {1}{2}Last Rated: {3}{4}Locked: {5}{6}Lock Message: {7}{8}Pending: {9}{10}Pending Message: {11}{12}Categories: {13}{14}{15}' -f $newLine,$bluecoat.IsRated,$newLine,$bluecoat.LastedRated,$newLine,$bluecoat.IsLocked,$newLine,$bluecoat.LockMessage,$newLine,$bluecoat.IsPending,$newLine,$bluecoat.PendingMessage,$newLine,($bluecoat.Categories.Keys -join ','),$newLine,$newLine)

            Write-Verbose -Message $bluecoatSummary
        } catch { 
            Write-Verbose -Message $_
        } 
    }

    $connectivity = [pscustomobject]@{
        TestUrl = $testUri;
        Addresses = [string[]]$address;
        Aliases = [string[]]$alias;
        ActualStatusCode = [int]$actualStatusCode;
        ExpectedStatusCode = $ExpectedStatusCode;
        StatusMatched = $statusMatch;
        StatusMessage = $statusMessage;
        IsBlocked = $isBlocked;
        ServerCertificate = $script:ServerCertificate;
        ServerCertificateChain = $script:ServerCertificateChain;
        ServerCertificateError = $script:ServerCertificateError;
        ServerCertificateErrorMessage = $serverCertificateErrorMessage;
        HasServerCertificateError = $hasServerCertificateError;
        IgnoreCertificateValidationErrors = $IgnoreCertificateValidationErrors;
        BlueCoat = $bluecoat;
    }

    return $connectivity
}

Function Save-Connectivity() {
    [CmdletBinding()]
    [OutputType([void])]
    Param(
        [Parameter(Mandatory=$true, HelpMessage='The filename without the extension')]
        [ValidateNotNullOrEmpty()]
        [string]$FileName,

        [Parameter(Mandatory=$true, HelpMessage='Path to save the output to')]
        [System.Collections.Generic.List[pscustomobject]]$Results,

        [Parameter(Mandatory=$false, HelpMessage='Path to save the output to')]
        [string]$OutputPath,

        [Parameter(Mandatory=$false, HelpMessage='Compress JSON output')]
        [switch]$Compress
    )

    $parameters = $PSBoundParameters

    $isVerbose = $verbosePreference -eq 'Continue'

    if (-not($parameters.ContainsKey('OutputPath'))) {
        $OutputPath = $env:USERPROFILE,'Desktop' -join [System.IO.Path]::DirectorySeparatorChar
    }

    $OutputPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputPath)

    if (-not(Test-Path -Path $OutputPath)) {
        New-Item -Path $OutputPath -ItemType Directory
    }

    #$fileName = ($targetUrl.OriginalString.Split([string[]][IO.Path]::GetInvalidFileNameChars(),[StringSplitOptions]::RemoveEmptyEntries)) -join '-'
    $json = $Results | ConvertTo-Json -Depth 3 -Compress:$Compress
    $json | Out-File -FilePath "$OutputPath\$FileName.json" -NoNewline -Force
}