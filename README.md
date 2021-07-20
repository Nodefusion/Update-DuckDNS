# Update-DuckDNS

Update-DuckDNS is simple PowerShell script and cmdlet to update Dynamic DNS record on Duck DNS service.

# Dependency and requirments

* Duck DNS account (free) registration - https://www.duckdns.org
* Create a new domain (example: mydomain.duckdns.org) 
* PowerShell 7

# Installation

Run this PowerShell to create folder and download latest stable Update-DuckDNS

```powershell
#Requires -RunAsAdministrator
#Requires -Version 7

New-Item -ItemType Directory "$Env:Programfiles\Update-DuckDNS"

Invoke-WebRequest https://raw.githubusercontent.com/Nodefusion/Update-DuckDNS/main/Update-DuckDNS.psm1 -OutFile $Env:Programfiles\Update-DuckDNS\Update-DuckDNS.psm1
```

* Modify file $Env:Programfiles\Update-DuckDNS and configure parametere defaults as needed (token, domains and others)

## Installation on Windows Task Scheduler

Run this Powershell to setup Windows Task Scheduler. Check for Module Path and TimeSpan

```powershell
#Requires -RunAsAdministrator
#Requires -Version 7

$timeSpan = New-TimeSpan -Minutes 15

$workingDirectory = $Env:Programfiles+'\Update-DuckDNS'
$execute = (Get-Command -Name pwsh).Path

$action = New-ScheduledTaskAction -Execute $execute -Argument (-join('-NonInteractive -NoLogo -NoProfile -WorkingDirectory "', $workingDirectory, '" -Command "Import-Module -Force -Name ./ && Update-DuckDNS"'))
$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval $timespan
$principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RunOnlyIfNetworkAvailable -DontStopOnIdleEnd -MultipleInstances IgnoreNew

Register-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -Settings $settings -TaskName "Update-DuckDNS" -Description "Updates the IP address of your Duck DNS domain(s)."
```

# Usage

## Examples

Load module

```powershell
Import-Module "$Env:Programfiles\Update-DuckDNS"
```

Simple IP update for given domain name parameter

```powershell
Update-DuckDNS -Domain mydomain.duckdns.org
```

IPv6 update

```powershell
Update-DuckDNS -Domain mydomain.duckdns.org -DetectIPv6 $true
```

Clear IP data

```powershell
Update-DuckDNS -Domain mydomain.duckdns.org -Clear $true
```

Verbose output

```powershell
Update-DuckDNS -Domain mydomain.duckdns.org -Verbose
```

## Check status

```powershell
Get-WinEvent -ProviderName 'Microsoft-Windows-PowerShell' -MaxEvents 20 | Where Id -eq 4104
```

# Support

Please submit new GitHub issue on this repository.

# Known limitations

Not tested on Linux nor macOS.

# License

This project is released under MIT License, Copyright (c) 2021 Nodefusion - www.nodefusion.com
