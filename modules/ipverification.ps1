# Copyright (C) 2014 Yusuf Ozturk
# This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

# PoSH Server IP Address Verification
if ($Hostname)
{
	$IPAddresses = @($Hostname.Split(","))
	foreach ($IPAddress in $IPAddresses)
	{
		if ($IPAddress -ne "127.0.0.1" -and $IPAddress -ne "::1")
		{
			if ($IPAddress -as [ipaddress])
			{
				$IPValidation = Confirm-PoSHServerIP -IP $IPAddress
				if ($IPValidation -ne "Validated")
				{
					Write-Warning "$IPAddress is not exist on your current network configuration."
					Write-Warning "Aborting.."
					$ShouldProcess = $false
				}
			}
		}
	}
}

# PoSH Server SSL IP Address Verification	
if ($SSLIP)
{
	if ($ShouldProcess -ne $false)
	{
		$SSLIPAddresses = @($SSLIP.Split(","))
		foreach ($SSLIPAddress in $SSLIPAddresses)
		{
			if ($SSLIPAddress -ne "127.0.0.1" -and $SSLIPAddress -ne "::1")
			{
				if ($SSLIPAddress -as [ipaddress])
				{
					$IPValidation = Confirm-PoSHServerIP -IP $SSLIPAddress
					if ($IPValidation -ne "Validated")
					{
						Write-Warning "$SSLIPAddress is not exist on your current network configuration."
						Write-Warning "Aborting.."
						$ShouldProcess = $false
					}
				}
			}
		}
	}
}