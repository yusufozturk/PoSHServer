# Copyright (C) 2013 Yusuf Ozturk
# This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

# PoSH Server 500 Module
if ($HostName -eq "+") { $HeaderName = "localhost" } else { $HeaderName = $HostNames[0] }
@"
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"> 
<html xmlns="http://www.w3.org/1999/xhtml"> 
<head> 
<title>PoSH Server - 500 - Internal Server Error</title> 
<style type="text/css"> 
<!-- 
body{margin:0;font-size:.7em;font-family:Verdana,Arial,Helvetica,sans-serif;background:#CBE1EF;} 
code{margin:0;color:#006600;font-size:1.1em;font-weight:bold;} 
.config_source code{font-size:.8em;color:#000000;} 
pre{margin:0;font-size:1.4em;word-wrap:break-word;} 
ul,ol{margin:10px 0 10px 40px;} 
ul.first,ol.first{margin-top:5px;} 
fieldset{padding:0 15px 10px 15px;} 
.summary-container fieldset{padding-bottom:5px;margin-top:4px;} 
legend.no-expand-all{padding:2px 15px 4px 10px;margin:0 0 0 -12px;} 
legend{color:#333333;padding:4px 15px 4px 10px;margin:4px 0 8px -12px;_margin-top:0px; 
 border-top:1px solid #EDEDED;border-left:1px solid #EDEDED;border-right:1px solid #969696; 
 border-bottom:1px solid #969696;background:#E7ECF0;font-weight:bold;font-size:1em;} 
a:link,a:visited{color:#007EFF;font-weight:bold;} 
a:hover{text-decoration:none;} 
h1{font-size:2.4em;margin:0;color:#FFF;} 
h2{font-size:1.7em;margin:0;color:#CC0000;} 
h3{font-size:1.4em;margin:10px 0 0 0;color:#CC0000;} 
h4{font-size:1.2em;margin:10px 0 5px 0; 
}#header{width:96%;margin:0 0 0 0;padding:6px 2% 6px 2%;font-family:"trebuchet MS",Verdana,sans-serif; 
 color:#FFF;background-color:#5C87B2; 
}#content{margin:0 0 0 2%;position:relative;} 
.summary-container,.content-container{background:#FFF;width:96%;margin-top:8px;padding:10px;position:relative;} 
.config_source{background:#fff5c4;} 
.content-container p{margin:0 0 10px 0; 
}#details-left{width:35%;float:left;margin-right:2%; 
}#details-right{width:63%;float:left;overflow:hidden; 
}#server_version{width:96%;_height:1px;min-height:1px;margin:0 0 5px 0;padding:11px 2% 8px 2%;color:#FFFFFF; 
 background-color:#5A7FA5;border-bottom:1px solid #C1CFDD;border-top:1px solid #4A6C8E;font-weight:normal; 
 font-size:1em;color:#FFF;text-align:right; 
}#server_version p{margin:5px 0;} 
table{margin:4px 0 4px 0;width:100%;border:none;} 
td,th{vertical-align:top;padding:3px 0;text-align:left;font-weight:bold;border:none;} 
th{width:30%;text-align:right;padding-right:2%;font-weight:normal;} 
thead th{background-color:#ebebeb;width:25%; 
}#details-right th{width:20%;} 
table tr.alt td,table tr.alt th{background-color:#ebebeb;} 
.highlight-code{color:#CC0000;font-weight:bold;font-style:italic;} 
.clear{clear:both;} 
.preferred{padding:0 5px 2px 5px;font-weight:normal;background:#006633;color:#FFF;font-size:.8em;} 
--> 
</style> 
 
</head> 
<body> 
<div id="header"><h1>Server Error in Application "$HeaderName"</h1></div> 
<div id="server_version"><p>PoSH Server Microsoft-HTTPAPI/2.0</p></div> 
<div id="content"> 
<div class="content-container"> 
 <fieldset><legend>Error Summary</legend> 
  <h2>HTTP Error 500 - Internal Server Error</h2> 
  <h3>The page you are requesting cannot be served because of the security restriction.</h3> 
 </fieldset> 
</div> 
<div class="content-container"> 
 <fieldset><legend>Most likely causes:</legend> 
  <ul> 	<li>You are trying to execute PHP files in C:\Windows. By default, PHP has no read access into Windows directory.</li> 	<li>The feature you are trying to use may not be installed.</li> 	<li>The appropriate MIME map is not enabled for the Web site or application.</li> <li>If PHP is not installed.</li></ul> 
 </fieldset> 
</div> 
<div class="content-container"> 
 <fieldset><legend>Things you can try:</legend> 
  <ul> 	<li>Ensure that the expected handler for the current page is mapped.</li> 	<li>Make sure you provided correct php-cgi.exe path in config file.</li> </ul> 
 </fieldset> 
</div> 
 
 
<div class="content-container"> 
 <fieldset><legend>Links and More Information</legend> 
  This error occurs when the file extension of the requested URL is for a MIME type that is not configured on the server. You can add a MIME type for the file extension for files that are not dynamic scripting pages, database, or configuration files. Process those file types using a handler. You should not allows direct downloads of dynamic scripting pages, database or configuration files. 
  <p><a href="http://go.microsoft.com/fwlink/?LinkID=62293&IIS70Error=500,0,0x80070032,8250">View more information &raquo;</a></p> 
   
 </fieldset> 
</div> 
</div> 
</body> 
</html>
"@