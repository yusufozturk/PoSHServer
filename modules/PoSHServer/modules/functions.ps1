# Copyright (C) 2014 Yusuf Ozturk
# This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

function Confirm-PoSHAdminPrivileges {

<#
    .SYNOPSIS
     
        Function to test administrative privileges

    .EXAMPLE
     
        Confirm-PoSHAdminPrivileges
		
#>

	$User = [Security.Principal.WindowsIdentity]::GetCurrent()
	if((New-Object Security.Principal.WindowsPrincipal $User).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
	{
		$Result = "Validated"
	}
	$Result
}

function Confirm-PoSHServerIP {

<#
    .SYNOPSIS
     
        Function to verify IP address on server

    .EXAMPLE
     
        Confirm-PoSHServerIP -IP "192.168.2.1"
		
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (

    [Parameter(
        Mandatory = $true,
        HelpMessage = 'IP address')]
    [string]$IP
)

	# Get Networking Adapter Configuration 
	$IPConfigs = Get-WmiObject Win32_NetworkAdapterConfiguration
   
	# Get All IP Addresses 
	foreach ($IPConfig in $IPConfigs) 
	{ 
		if ($IPConfig.IPaddress) 
		{ 
			foreach ($IPAddress in $IPConfig.IPaddress) 
			{ 
				if ("$IP" -eq "$IPAddress")
				{
					$Result = "Validated"
				}
			}
		}
	}
	
	$Result
}

function Get-DirectoryContent {

<#
    .SYNOPSIS
     
        Function to get directory content

    .EXAMPLE
     
        Get-DirectoryContent -Path "C:\" -HeaderName "poshserver.net" -RequestURL "http://poshserver.net" -SubfolderName "/"
		
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (

    [Parameter(
        Mandatory = $true,
        HelpMessage = 'Directory Path')]
    [string]$Path,

    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Header Name')]
    [string]$HeaderName,

    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Request URL')]
    [string]$RequestURL,
	
    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Subfolder Name')]
    [string]$SubfolderName
)

@"
<html>
<head>
<title>$($HeaderName)</title>
</head>
<body>
<h1>$($HeaderName) - $($SubfolderName)</h1>
<hr>
"@
$ParentDirectory = $RequestURL + $Subfoldername + "../"
@"
<a href="$($ParentDirectory)">[To Parent Directory]</a><br><br>
<table cellpadding="5">
"@
$Files = (Get-ChildItem "$Path")
foreach ($File in $Files)
{
$FileURL = $RequestURL + $Subfoldername + $File.Name
if (!$File.Length) { $FileLength = "[dir]" } else { $FileLength = $File.Length }
@"
<tr>
<td align="right">$($File.LastWriteTime)</td>
<td align="right">$($FileLength)</td>
<td align="left"><a href="$($FileURL)">$($File.Name)</a></td>
</tr>
"@
}
@"
</table>
<hr>
</body>
</html>
"@
}

function New-PoSHLogHash {

<#
    .SYNOPSIS
     
        Function to hash PoSHServer log file

    .EXAMPLE
     
        New-PoSHLogHash -LogSchedule "Hourly" -LogDirectory "C:\inetpub\logs"
		
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (

    [Parameter(
        Mandatory = $true,
        HelpMessage = 'Log Schedule')]
    [string]$LogSchedule,

    [Parameter(
        Mandatory = $true,
        HelpMessage = 'Log Directory Path')]
    [string]$LogDirectory,
	
	[Parameter(
        Mandatory = $false,
        HelpMessage = 'Debug Mode')]
    $DebugMode = $false
)

	if ($LogSchedule -eq "Hourly")
	{
		$LogNameFormatLastHour = (Get-Date).AddHours(-1).ToString("yyMMddHH")
		$LogFileNameLastHour = "u_ex" + $LogNameFormatLastHour + ".log"
		$LogFilePathLastHour = $LogDirectory + "\" + $LogFileNameLastHour
		$SigFileName = "u_ex" + $LogNameFormatLastHour + ".sign"
		$SigFilePath = $LogDirectory + "\" + $SigFileName
		$DateFileName = "u_ex" + $LogNameFormatLastHour + ".date"
		$DateFilePath = $LogDirectory + "\" + $DateFileName
		$LastLogFilePath = $LogFilePathLastHour
	}
	else
	{
		$LogNameFormatYesterday = (Get-Date).AddDays(-1).ToString("yyMMdd")
		$LogFileNameYesterday = "u_ex" + $LogNameFormatYesterday + ".log"
		$LogFilePathYesterday = $LogDirectory + "\" + $LogFileNameYesterday
		$SigFileName = "u_ex" + $LogNameFormatYesterday + ".sign"
		$SigFilePath = $LogDirectory + "\" + $SigFileName
		$DateFileName = "u_ex" + $LogNameFormatYesterday + ".date"
		$DateFilePath = $LogDirectory + "\" + $DateFileName
		$LastLogFilePath = $LogFilePathYesterday
	}

	if ([System.IO.File]::Exists($LastLogFilePath))  
	{
		if (![System.IO.File]::Exists($SigFilePath))
		{
			$LogHashJobArgs = @($LastLogFilePath,$SigFilePath,$DateFilePath)
			
			try
			{
				$LogHashJob = Start-Job -ScriptBlock {
					param ($LastLogFilePath, $SigFilePath, $DateFilePath)
					if (![System.IO.File]::Exists($DateFilePath))  
					{
						$HashAlgorithm = "MD5"
						$HashType = [Type] "System.Security.Cryptography.$HashAlgorithm"
						$Hasher = $HashType::Create()
						$DateString = Get-Date -uformat "%d.%m.%Y"
						$TimeString = (w32tm /stripchart /computer:time.ume.tubitak.gov.tr /samples:1)[-1].split("")[0]
						$DateString = $DateString + " " + $TimeString
						$InputStream = New-Object IO.StreamReader $LastLogFilePath
						$HashBytes = $Hasher.ComputeHash($InputStream.BaseStream)
						$InputStream.Close()
						$Builder = New-Object System.Text.StringBuilder
						$HashBytes | Foreach-Object { [void] $Builder.Append($_.ToString("X2")) }
						$HashString = $Builder.ToString()
						$HashString = $HashString + " " + $DateString
						$Stream = [System.IO.StreamWriter]$SigFilePath
						$Stream.Write($HashString)
						$Stream.Close()
						$Stream = [System.IO.StreamWriter]$DateFilePath
						$Stream.Write($DateString)
						$Stream.Close()
						$InputStream = New-Object IO.StreamReader $SigFilePath
						$HashBytes = $Hasher.ComputeHash($InputStream.BaseStream)
						$InputStream.Close()
						$Builder = New-Object System.Text.StringBuilder
						$HashBytes | Foreach-Object { [void] $Builder.Append($_.ToString("X2")) }
						$HashString = $Builder.ToString()
						$Stream = [System.IO.StreamWriter]$SigFilePath
						$Stream.Write($HashString)
						$Stream.Close()
					}
				} -ArgumentList $LogHashJobArgs	
			}
			catch
			{
				Add-Content -Value $_ -Path "$LogDirectory\debug.txt"
			}
		}
	}
	else
	{
		Add-Content -Value "Could not find log file." -Path "$LogDirectory\debug.txt"
	}
}

function Start-PoSHLogParser {

<#
    .SYNOPSIS
     
        Function to parse PoSHServer log files

    .EXAMPLE
     
        Start-PoSHLogParser -LogPath "C:\inetpub\logs\hourly.log"
		
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (

    [Parameter(
        Mandatory = $true,
        HelpMessage = 'Log Path')]
    [string]$LogPath
)

	$File = $LogPath
	$Log = Get-Content $File | where {$_ -notLike "#[D,S-V]*" }
	$Columns = (($Log[0].TrimEnd()) -replace "#Fields: ", "" -replace "-","" -replace "\(","" -replace "\)","").Split(" ")
	$Count = $Columns.Length
	$Rows = $Log | where {$_ -notLike "#Fields"}
	$IISLog = New-Object System.Data.DataTable "IISLog"
	foreach ($Column in $Columns) 
	{
		$NewColumn = New-Object System.Data.DataColumn $Column, ([string])
		$IISLog.Columns.Add($NewColumn)
	}
	foreach ($Row in $Rows) 
	{
		$Row = $Row.Split(" ")
		$AddRow = $IISLog.newrow()
		for($i=0;$i -lt $Count; $i++) 
		{
			$ColumnName = $Columns[$i]
			$AddRow.$ColumnName = $Row[$i]
		}
		$IISLog.Rows.Add($AddRow)
	}
	$IISLog
}

function Get-MimeType {

<#
    .SYNOPSIS
     
        Function to get mime types

    .EXAMPLE
     
        Get-MimeType -Extension ".jpg"
		
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (

    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Extension')]
    [string]$Extension
)
	
	switch ($Extension) 
	{ 
		.ps1 {"text/ps1"}
		.psxml {"text/psxml"}
		.psapi {"text/psxml"}
		.posh {"text/psxml"}
		.html {"text/html"} 
		.htm {"text/html"} 
		.php {"text/php"} 
		.css {"text/css"} 
		.jpeg {"image/jpeg"} 
		.jpg {"image/jpeg"}
		.gif {"image/gif"}
		.ico {"image/x-icon"}
		.flv {"video/x-flv"}
		.swf {"application/x-shockwave-flash"}
		.js {"text/javascript"}
		.txt {"text/plain"}
		.rar {"application/octet-stream"}
		.zip {"application/x-zip-compressed"}
		.rss {"application/rss+xml"}
		.xml {"text/xml"}
		.pdf {"application/pdf"}
		.png {"image/png"}
		.mpg {"video/mpeg"}
		.mpeg {"video/mpeg"}
		.mp3 {"audio/mpeg"}
		.wmv {"video/x-ms-wmv"}
		.woff {"application/x-font-woff"}
		default {"text/html"}
	}	
}

function Get-PoSHPHPContent {

<#
    .SYNOPSIS
     
        Function to get php content

    .EXAMPLE
     
        Get-PoSHPHPContent -PHPCgiPath "C:\php.exe" -File "C:\test.php" -PoSHPHPGET "test=value"
		
    .EXAMPLE
     
        Get-PoSHPHPContent -PHPCgiPath "C:\php.exe" -File "C:\test.php" -PoSHPHPPOST "test=value"
		
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (

    [Parameter(
        Mandatory = $true,
        HelpMessage = 'PHP-Cgi Path')]
    [string]$PHPCgiPath,

    [Parameter(
        Mandatory = $true,
        HelpMessage = 'File Path')]
    [string]$File,
	
    [Parameter(
        Mandatory = $false,
        HelpMessage = 'PHP GET String')]
    [string]$PoSHPHPGET,
	
    [Parameter(
        Mandatory = $false,
        HelpMessage = 'PHP POST String')]
    [string]$PoSHPHPPOST
)

	# Set PHP Environment
	$env:GATEWAY_INTERFACE="CGI/1.1"
	$env:SCRIPT_FILENAME="$File"
	$env:REDIRECT_STATUS="200"
	$env:SERVER_PROTOCOL="HTTP/1.1"
	$env:HTTP_ACCEPT="text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8"
	$env:CONTENT_TYPE="application/x-www-form-urlencoded"
	
	if ($PoSHPHPPOST)
	{
		# Set PHP POST Environment
		$env:REQUEST_METHOD="POST"
		$PHP_CONTENT_LENGTH = $PoSHPHPPOST.Length
		$env:CONTENT_LENGTH="$PHP_CONTENT_LENGTH"
		
		# Get PHP Content
		$PHPOutput = "$PoSHPHPPOST" | &$PHPCgiPath
	}
	else
	{
		# Set PHP GET Environment
		$env:REQUEST_METHOD="GET"
		$env:QUERY_STRING="$PoSHPHPGET"
		
		# Get PHP Content
		$PHPOutput = &$PHPCgiPath
	}
	
	# Get PHP Header Line Number
	$PHPHeaderLineNumber = ($PHPOutput | Select-String -Pattern "^$")[0].LineNumber
	
	# Get PHP Header
	$PHPHeader = $PHPOutput | Select -First $PHPHeaderLineNumber
	
	# Get Redirection Location
	$GetPHPLocation = $PHPHeader | Select-String "Location:"
	
	# Check Redirection Location
	if ($GetPHPLocation)
	{
		$GetPHPLocation = $GetPHPLocation -match 'Location: (.*)/?'
		if ($GetPHPLocation -eq $True) { $PHPRedirectionURL = $Matches[1] } else { $PHPRedirectionURL = $Null; }
	}
	
	# Redirect to Location
	if ($PHPRedirectionURL)
	{
		# Redirection Output
		$PHPRedirection = '<html>'
		$PHPRedirection += '<script type="text/javascript">'
		$PHPRedirection += 'window.location = "' + $PHPRedirectionURL + '"'
		$PHPRedirection += '</script>'
		$PHPRedirection += '</html>'
		$PHPRedirection
	}
	else
	{	
		# Output PHP Content
		$PHPOutput = $PHPOutput | Select -Skip $PHPHeaderLineNumber
		$PHPOutput
	}
}

function Get-PoSHPostStream {

<#
    .SYNOPSIS
     
        Function to get php post stream

    .EXAMPLE
     
        Get-PoSHPostStream -InputStream $InputStream -ContentEncoding $ContentEncoding
		
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (

    [Parameter(
        Mandatory = $true,
        HelpMessage = 'Input Stream')]
    $InputStream,
	
    [Parameter(
        Mandatory = $true,
        HelpMessage = 'Content Encoding')]
    $ContentEncoding
)

	$PoSHCommand = New-Object IO.StreamReader ($InputStream,$ContentEncoding)
	$PoSHCommand = $PoSHCommand.ReadToEnd()
	$PoSHCommand = $PoSHCommand.ToString()
	
	if ($PoSHCommand)
	{
		$PoSHCommand = $PoSHCommand.Replace("+"," ")
		$PoSHCommand = $PoSHCommand.Replace("%20"," ")
		$PoSHCommand = $PoSHCommand.Replace("%21","!")
		$PoSHCommand = $PoSHCommand.Replace('%22','"')
		$PoSHCommand = $PoSHCommand.Replace("%23","#")
		$PoSHCommand = $PoSHCommand.Replace("%24","$")
		$PoSHCommand = $PoSHCommand.Replace("%25","%")
		$PoSHCommand = $PoSHCommand.Replace("%27","'")
		$PoSHCommand = $PoSHCommand.Replace("%28","(")
		$PoSHCommand = $PoSHCommand.Replace("%29",")")
		$PoSHCommand = $PoSHCommand.Replace("%2A","*")
		$PoSHCommand = $PoSHCommand.Replace("%2B","+")
		$PoSHCommand = $PoSHCommand.Replace("%2C",",")
		$PoSHCommand = $PoSHCommand.Replace("%2D","-")
		$PoSHCommand = $PoSHCommand.Replace("%2E",".")
		$PoSHCommand = $PoSHCommand.Replace("%2F","/")
		$PoSHCommand = $PoSHCommand.Replace("%3A",":")
		$PoSHCommand = $PoSHCommand.Replace("%3B",";")
		$PoSHCommand = $PoSHCommand.Replace("%3C","<")
		$PoSHCommand = $PoSHCommand.Replace("%3E",">")
		$PoSHCommand = $PoSHCommand.Replace("%3F","?")
		$PoSHCommand = $PoSHCommand.Replace("%5B","[")
		$PoSHCommand = $PoSHCommand.Replace("%5C","\")
		$PoSHCommand = $PoSHCommand.Replace("%5D","]")
		$PoSHCommand = $PoSHCommand.Replace("%5E","^")
		$PoSHCommand = $PoSHCommand.Replace("%5F","_")
		$PoSHCommand = $PoSHCommand.Replace("%7B","{")
		$PoSHCommand = $PoSHCommand.Replace("%7C","|")
		$PoSHCommand = $PoSHCommand.Replace("%7D","}")
		$PoSHCommand = $PoSHCommand.Replace("%7E","~")
		$PoSHCommand = $PoSHCommand.Replace("%7F","_")
		$PoSHCommand = $PoSHCommand.Replace("%7F%25","%")
		$PoSHPostStream = $PoSHCommand
		$PoSHCommand = $PoSHCommand.Split("&")

		$Properties = New-Object Psobject
		$Properties | Add-Member Noteproperty PoSHPostStream $PoSHPostStream
		foreach ($Post in $PoSHCommand)
		{
            $Post = $Post.Replace("%26","&")
			$Post = $Post.Split("=")
			$PostName = $Post[0].Replace("%3D","=")
			$PostValue = $Post[1].Replace("%3D","=")
			$Properties | Add-Member Noteproperty $PostName $PostValue
		}
		Write-Output $Properties
	}
}

function Get-PoSHQueryString {

<#
    .SYNOPSIS
     
        Function to get query string

    .EXAMPLE
     
        Get-PoSHQueryString -Request $Request
		
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (

    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Request')]
    $Request
)

	if ($Request)
	{
		$PoSHQueryString = $Request.RawUrl.Split("?")[1]		
		$QueryStrings = $Request.QueryString
		
		$Properties = New-Object Psobject
		$Properties | Add-Member Noteproperty PoSHQueryString $PoSHQueryString
		foreach ($Query in $QueryStrings)
		{
			$QueryString = $Request.QueryString["$Query"]
			if ($QueryString -and $Query)
			{
				$Properties | Add-Member Noteproperty $Query $QueryString
			}
		}
		Write-Output $Properties
	}
}

function Get-PoSHWelcomeBanner {

<#
    .SYNOPSIS
     
        Function to get welcome banner

    .EXAMPLE
     
        Get-PoSHWelcomeBanner -Hostname "localhost" -Port "8080" -SSL $True -SSLIP "10.10.10.2" -SSLPort "8443"
		
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (

    [Parameter(
        Mandatory = $false,
        HelpMessage = 'IP Address or Hostname')]
	[Alias('IP')]
    [string]$Hostname,

    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Port Number')]
    [string]$Port,

	[Parameter(
        Mandatory = $false,
        HelpMessage = 'Enable SSL')]
    $SSL = $false,
	
    [Parameter(
        Mandatory = $false,
        HelpMessage = 'SSL IP Address')]
    [string]$SSLIP,
	
    [Parameter(
        Mandatory = $false,
        HelpMessage = 'SSL Port Number')]
    [string]$SSLPort,
	
	[Parameter(
        Mandatory = $false,
        HelpMessage = 'Debug Mode')]
    $DebugMode = $false
)
	
	# Get Hostname
	if (!$Hostname -or $Hostname -eq "+") 
	{
		$Hostname = "localhost"
	}
	else
	{
		$Hostname = @($Hostname.Split(","))[0]
	}
	
	# Get Port
	if ($Port -ne "80")
	{
		$Port = ":$Port"
	}
	else
	{
		$Port = $null
	}
	
	if ($SSL)
	{
		# Get SSL Hostname
		if (!$SSLIP -or $SSLIP -eq "+") 
		{
			$SSLIP = "localhost"
		}
		else
		{
			$SSLIP = @($SSLIP.Split(","))[0]
		}
		
		# Get SSL Port
		if ($SSLPort -eq "443")
		{
			$SSLPort = "/"
		}
		else
		{
			$SSLPort = ":$SSLPort"
		}
	}
	
	if (!$DebugMode)
	{
		clear
	}
	
	Write-Host " "
	Write-Host "  Welcome to PoSH Server"
	Write-Host " "
	Write-Host " "
	Write-Host "  You can start browsing your webpage from:"
	Write-Host "  http://$Hostname$Port"
	
	if ($SSL)
	{	
		if ($SSLPort -eq "/")
		{
			Write-Host "  https://$SSLIP"
		}
		else
		{
			Write-Host "  https://$SSLIP$SSLPort"
		}
	}
	
	Write-Host " "
	Write-Host " "
	Write-Host "  Thanks for using PoSH Server.."
	Write-Host " "
	Write-Host " "
	Write-Host " "
}

function New-PoSHAPIXML {

<#
    .SYNOPSIS
     
        Function to create PoSHAPI XML

    .EXAMPLE
     
        New-PoSHAPIXML -ResultCode "1" -ResultMessage "Service unavailable" -RootTag "Result" -ItemTag "OperationResult" -Details
		
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (

    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Result Code')]
    $ResultCode = "-1",

    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Result Message')]
    $ResultMessage = "The operation failed",
	
    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Root Tag')]
    $RootTag = "Result",

    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Item Tag')]
    $ItemTag = "OperationResult",
	
    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Child Items')]
    $ChildItems = "*",
	
    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Attributes')]
    $Attributes = $Null,

	[Parameter(
        Mandatory = $false,
        HelpMessage = 'Details')]
    $Details = $false
)

Begin {
	
	$xml = "<?xml version=""1.0"" encoding=""utf-8""?>`n"
	$xml += "<$RootTag>`n"
	$xml += " <Code>$ResultCode</Code>`n"
	$xml += " <Message>$ResultMessage</Message>`n"
}

Process {

	if ($Details)
	{
		$xml += " <$ItemTag"
		if ($Attributes)
		{
			foreach ($attr in $_ | Get-Member -type *Property $attributes)
			{ 
				$name = $attr.Name
				$xml += " $Name=`"$($_.$Name)`""
			}
		}
		$xml += ">`n"
		foreach ($child in $_ | Get-Member -Type *Property $childItems)
		{
			$name = $child.Name
			$xml += " <$Name>$($_.$Name)</$Name>`n"
		}
		$xml += " </$ItemTag>`n"
	}
}

End {

	$xml += "</$RootTag>`n"
	$xml
}
}

function Request-PoSHCertificate {

<#
    .SYNOPSIS
     
        Function to create PoSH Certificate request

    .EXAMPLE
     
        Request-PoSHCertificate
		
#>

	$SSLSubject = "PoSHServer"
	$SSLName = New-Object -com "X509Enrollment.CX500DistinguishedName.1"
	$SSLName.Encode("CN=$SSLSubject", 0)
	$SSLKey = New-Object -com "X509Enrollment.CX509PrivateKey.1"
	$SSLKey.ProviderName = "Microsoft RSA SChannel Cryptographic Provider"
	$SSLKey.KeySpec = 1
	$SSLKey.Length = 2048
	$SSLKey.SecurityDescriptor = "D:PAI(A;;0xd01f01ff;;;SY)(A;;0xd01f01ff;;;BA)(A;;0x80120089;;;NS)"
	$SSLKey.MachineContext = 1
	$SSLKey.ExportPolicy = 1
	$SSLKey.Create()
	$SSLObjectId = New-Object -com "X509Enrollment.CObjectIds.1"
	$SSLServerId = New-Object -com "X509Enrollment.CObjectId.1"
	$SSLServerId.InitializeFromValue("1.3.6.1.5.5.7.3.1")
	$SSLObjectId.add($SSLServerId)
	$SSLExtensions = New-Object -com "X509Enrollment.CX509ExtensionEnhancedKeyUsage.1"
	$SSLExtensions.InitializeEncode($SSLObjectId)
	$SSLCert = New-Object -com "X509Enrollment.CX509CertificateRequestCertificate.1"
	$SSLCert.InitializeFromPrivateKey(2, $SSLKey, "")
	$SSLCert.Subject = $SSLName
	$SSLCert.Issuer = $SSLCert.Subject
	$SSLCert.NotBefore = Get-Date
	$SSLCert.NotAfter = $SSLCert.NotBefore.AddDays(1825)
	$SSLCert.X509Extensions.Add($SSLExtensions)
	$SSLCert.Encode()
	$SSLEnrollment = New-Object -com "X509Enrollment.CX509Enrollment.1"
	$SSLEnrollment.InitializeFromRequest($SSLCert)
	$SSLEnrollment.CertificateFriendlyName = 'PoSHServer SSL Certificate'
	$SSLCertdata = $SSLEnrollment.CreateRequest(0)
	$SSLEnrollment.InstallResponse(2, $SSLCertdata, 0, "")
}

function Register-PoSHCertificate {

<#
    .SYNOPSIS
     
        Function to register PoSH Certificate

    .EXAMPLE
     
        Register-PoSHCertificate -SSLIP "10.10.10.2" -SSLPort "8443" -Thumbprint "45F53D35AB630198F19A27931283"
		
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (

    [Parameter(
        Mandatory = $false,
        HelpMessage = 'SSL IP Address')]
    [string]$SSLIP,
	
    [Parameter(
        Mandatory = $false,
        HelpMessage = 'SSL Port Number')]
    [string]$SSLPort,
	
    [Parameter(
        Mandatory = $false,
        HelpMessage = 'SSL Thumbprint')]
    $Thumbprint,
	
	[Parameter(
        Mandatory = $false,
        HelpMessage = 'Debug Mode')]
    $DebugMode = $false
)

	$SSLIPAddresses = @($SSLIP.Split(","))
					
	foreach ($SSLIPAddress in $SSLIPAddresses)
	{
		$IPPort = $SSLIPAddress + ":" + $SSLPort
		
		if ($DebugMode)
		{
			# Remove Previous SSL Bindings
			netsh http delete sslcert ipport="$IPPort"
			
			# Add SSL Certificate
			netsh http add sslcert ipport="$IPPort" certhash="$Thumbprint" appid="{00112233-4455-6677-8899-AABBCCDDEEFF}"
		}
		else
		{		
			# Remove Previous SSL Bindings
			netsh http delete sslcert ipport="$IPPort" | Out-Null
			
			# Add SSL Certificate
			netsh http add sslcert ipport="$IPPort" certhash="$Thumbprint" appid="{00112233-4455-6677-8899-AABBCCDDEEFF}" | Out-Null
		}
	}
}

function New-PoSHTimeStamp {

<#
    .SYNOPSIS
     
        Function to generate time stamp

    .EXAMPLE
     
        New-PoSHTimeStamp
		
#>

    $now = Get-Date
	$hr = $now.Hour.ToString()
	$mi = $now.Minute.ToString()
	$sd = $now.Second.ToString()
	$ms = $now.Millisecond.ToString()
	Write-Output $hr$mi$sd$ms
}

function Invoke-AsyncHTTPRequest {

<#
    .SYNOPSIS
     
        Function to invoke async HTTP request

    .EXAMPLE
     
        Invoke-AsyncHTTPRequest
		
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param (

    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Script Block')]
    $ScriptBlock,
	
    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Listener')]
    $Listener,
	
    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Hostname')]
    $Hostname,
	
    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Hostnames')]
    $Hostnames,
	
    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Home Directory. Example: C:\inetpub\wwwroot')]
    [string]$HomeDirectory,
	
    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Log Directory. Example: C:\inetpub\wwwroot')]
    [string]$LogDirectory,
	
	[Parameter(
        Mandatory = $false,
        HelpMessage = 'PoSHServer Module Path')]
    [string]$PoSHModulePath,
	
	[Parameter(
        Mandatory = $false,
        HelpMessage = 'Custom Child Config Path')]
    [string]$CustomChildConfig,
	
    [Parameter(
        Mandatory = $false,
        HelpMessage = 'Debug Mode')]
    [switch]$DebugMode = $false
)

	$Pipeline = [System.Management.Automation.PowerShell]::Create()
	$Pipeline.AddScript($ScriptBlock)
	$Pipeline.AddArgument($Listener)
	$Pipeline.AddArgument($Hostname)
	$Pipeline.AddArgument($Hostnames)
	$Pipeline.AddArgument($HomeDirectory)
	$Pipeline.AddArgument($LogDirectory)
	$Pipeline.AddArgument($PoSHModulePath)
	$Pipeline.AddArgument($CustomChildConfig)
	$Pipeline.AddArgument($DebugMode)
	$Pipeline.BeginInvoke()
}