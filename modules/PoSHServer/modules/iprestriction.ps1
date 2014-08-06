# Copyright (C) 2014 Yusuf Ozturk
# This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

# PoSH Server IP Restriction Module
$ClientIPAddr = $Request.RemoteEndPoint.Address

if ($IPRestriction -eq "On")
{
	if (!($IPWhiteList -match $ClientIPAddr))
	{
		Write-Warning "$ClientIPAddr has no permission, dropping.."
		$IPSessionDrop = "1";
	}
	else
	{
		$IPSessionDrop = "0";
	}
}
else
{
	$IPSessionDrop = "0";
}