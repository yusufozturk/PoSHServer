# Copyright (C) 2014 Yusuf Ozturk
# This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

# PoSH Server Logging Module
# Fields: date time s-sitename s-computername s-ip cs-method cs-uri-stem s-port c-ip cs-version cs(User-Agent) cs(Cookie) cs(Referer) cs-host sc-status
$LogDate = Get-Date -format yyyy-MM-dd
$LogTime = Get-Date -format HH:mm:ss
$LogSiteName = $Hostname
if ($LogSiteName -eq "+") { $LogSiteName = "localhost" }
$LogComputerName = Get-Content env:computername
$LogServerIP = $Request.LocalEndPoint.Address
$LogMethod = $Request.HttpMethod
$LogUrlStem = $Request.RawUrl
$LogServerPort = $Request.LocalEndPoint.Port
$LogClientIP = $Request.RemoteEndPoint.Address
$LogClientVersion = $Request.ProtocolVersion
if (!$LogClientVersion) { $LogClientVersion = "-" } else { $LogClientVersion = "HTTP/" + $LogClientVersion }
$LogClientAgent = [string]$Request.UserAgent
if (!$LogClientAgent) { $LogClientAgent = "-" } else { $LogClientAgent = $LogClientAgent.Replace(" ","+") }
$LogClientCookie = [string]$Response.Cookies.Value
if (!$LogClientCookie) { $LogClientCookie = "-" } else { $LogClientCookie = $LogClientCookie.Replace(" ","+") }
$LogClientReferrer = [string]$Request.UrlReferrer
if (!$LogClientReferrer) { $LogClientReferrer = "-" } else { $LogClientReferrer = $LogClientReferrer.Replace(" ","+") }
$LogHostInfo = [string]$LogServerIP + ":" + [string]$LogServerPort

# Log Output
$LogOutput = "$LogDate $LogTime $LogSiteName $LogComputerName $LogServerIP $LogMethod $LogUrlStem $LogServerPort $LogClientIP $LogClientVersion $LogClientAgent $LogClientCookie $LogClientReferrer $LogHostInfo $LogResponseStatus"

# Logging to Log File
if ($LogSchedule -eq "Hourly")
{
	$LogNameFormat = Get-Date -format yyMMddHH
	$LogFileName = "u_ex" + $LogNameFormat + ".log"
	$LogFilePath = $LogDirectory + "\" + $LogFileName
}
else
{
	$LogNameFormat = Get-Date -format yyMMdd
	$LogFileName = "u_ex" + $LogNameFormat + ".log"
	$LogFilePath = $LogDirectory + "\" + $LogFileName
}

if ($LastCheckDate -ne $LogNameFormat)
{
	if (![System.IO.File]::Exists($LogFilePath))  
	{
		$LogHeader = "#Fields: date time s-sitename s-computername s-ip cs-method cs-uri-stem s-port c-ip cs-version cs(User-Agent) cs(Cookie) cs(Referer) cs-host sc-status"
		Add-Content -Path $LogFilePath -Value $LogHeader -EA SilentlyContinue
	}
	
	# Set Last Check Date
	$LastCheckDate = $LogNameFormat
}

try
{
	Add-Content -Path $LogFilePath -Value $LogOutput -EA SilentlyContinue
}
catch
{
	Add-Content -Value $_ -Path "$LogDirectory\debug.txt"
}