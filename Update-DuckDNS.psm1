#Requires -Version 7
<#
.SYNOPSIS
Updates the IP address of your Duck DNS domain(s).

.DESCRIPTION
Update-DuckDNS updates the IP address of your Duck DNS domain(s). Intended to be run as a scheduled task.

.LINK
Update-DuckDNS on link https://github.com/Nodefusion/Update-DuckDNS

.EXAMPLE
Update-DuckDNS -Domain mydomain.duckdns.org

.INPUTS
For the Value parameter, one or more objects of any kind can be written
to the pipeline. However, the object is converted to a string before it
is added to the item.

.OUTPUTS
Status if successly updated or not.

.PARAMETER Token
Your Duck DNS account token.

.PARAMETER Domains
A comma-separated list of your Duck DNS domains to update.

.PARAMETER IP
If left blank, Duck DNS detect IPv4 addresses, if you want you can supply a valid IPv4 or IPv6 address.

.PARAMETER IPv6
If you want to update BOTH of your IPv4 and IPv6 records at once, then you can use the optional parameter IPv6.

.PARAMETER DetectIPv6
If set to true, it will detect IPv6 from OS

.PARAMETER Clear
If set to true, the update will ignore all IPs and clear both your records.
#>
function Update-DuckDNS {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $false, Position = 0, HelpMessage = 'Your Duck DNS account token.')]
    [String] $Token = '134739b2-SetYourTokenHere-39a4b14893c8',

    [Parameter(Mandatory = $false, Position = 1, HelpMessage = 'The Duck DNS subdomain, can be a single domain or a comma separated list of domains.')]
    [String[]] $Domains = 'mydomain.duckdns.org',

    [Parameter(Mandatory = $false, Position = 2, HelpMessage = 'If left blank, Duck DNS detect IPv4 addresses, if you want you can supply a valid IPv4 or IPv6 address.')]
    [String] $IP = '',

    [Parameter(Mandatory = $false, Position = 3, HelpMessage = 'If you want to update BOTH of your IPv4 and IPv6 records at once, then you can use the optional parameter IPv6.')]
    [String] $IPv6 = '',

    [Parameter(Mandatory = $false, Position = 4, HelpMessage = 'If set to true, it will detect IPv6 from OS')]
    [Bool] $DetectIPv6 = $false,

    [Parameter(Mandatory = $false, Position = 5, HelpMessage = 'If set to true, the update will ignore all IPs and clear both your records.')]
    [Bool] $Clear = $false
  )
  Begin {
    if ($DetectIPv6) {
      try {
        $IPv6 = (Get-NetIPAddress -AddressFamily IPv6 -PrefixOrigin RouterAdvertisement -AddressState Preferred -SuffixOrigin link).IPAddress
      }
      catch {
        Write-Verbose "Could not detect current IPv6"
      }  
    }

    [bool]$Verbose = $false;

    $Uri = "https://www.duckdns.org/update?domains={0}&token={1}&ip={2}&ipv6={3}&clear={4}&verbose={5}" -F ($Domains -Join ","), $Token, $IP, $Ipv6, $Clear, $Verbose
  }
  Process {
    try {
      $response = Invoke-WebRequest -Uri $Uri
    } catch {
      if ($IsWindows) {
        New-WinEvent -ProviderName 'Microsoft-Windows-PowerShell' -id 4100 -Payload("Update-DuckDNS", $response, "Exception: $_");
      }
      Write-Error -Message $_ -ErrorAction Stop
    }
  }
  End {
    If ($response.StatusDescription -eq "OK") {
      $content = [System.Text.Encoding]::UTF8.GetString($response.Content)
      # Expect starting with OK as per documentation and specification https://www.duckdns.org/spec.jsp
      if ($content.StartsWith("OK")) {
        # All is ok.
        Write-Output $content
      }
      else {
        # Unexpected content returned
        if ($IsWindows) {
          New-WinEvent -ProviderName 'Microsoft-Windows-PowerShell' -id 4100 -Payload("Update-DuckDNS", $content, "Unexpected DuckDNS content received.");
        }
        Write-Error "Unexpected DuckDNS content received: $content" -Category InvalidResult -CategoryReason $content -ErrorAction Stop
      }
    }
    else {
        # Unexpected content returned
        if ($IsWindows) {
          New-WinEvent -ProviderName 'Microsoft-Windows-PowerShell' -id 4100 -Payload("Update-DuckDNS", $response, "Unexpected DuckDNS response.");
        }
        Write-Error "Unexpected DuckDNS response: $response" -Category InvalidResult -ErrorAction Stop
    }
  }
}
