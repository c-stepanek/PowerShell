# PowerShell
Repository for PowerShell scripts.

# FunWithPowerShell
This script module contains the `New-PowerShellSignatureGenerator` function which displays a 1 liner containing an encoded message.

Module Import
```powershell
PS F:\Repo\PowerShell> Import-Module .\FunWithPowerShell.psm1
```
Example:
```powershell
PS F:\Repo\PowerShell> New-PowerShellSignatureGenerator -Message "Veni, vidi, vici."
```
Output:
```text
-join('56656E692C20766964692C20766963692E' -split'(?<=\G.{2})',17|%{[char][int]"0x$_"})
```

Now anyone can run your 1 liner in PowerShell to see the encoded message.
```powershell
PS F:\Repo\PowerShell> -join('56656E692C20766964692C20766963692E' -split'(?<=\G.{2})',17|%{[char][int]"0x$_"})
Veni, vidi, vici.
PS F:\Repo\PowerShell>
```

# HarTools
This script module contains the `ConvertFrom-Har` function which deserializes the JSON content of a HTTP Archive (.har) file to an object for parsing in PowerShell.

HAR SPEC: "https://w3c.github.io/web-performance/specs/HAR/Overview.html"

Module Import
```powershell
PS F:\Repo\PowerShell> Import-Module .\HarTools.psm1
```
Example 1: Loading HAR content.
```powershell
PS F:\Repo\PowerShell> $har = ConvertFrom-Har -FilePath c:\temp\www.bing.com.har
```
Example 2:  Loading HAR content.
```powershell
PS F:\Repo\PowerShell> $har = ConvertFrom-Har -FileBytes (Get-Content -Path c:\temp\www.bing.com.har -Encoding Byte -Raw)
```
Example 3: Parsing HAR object.
```powershell
PS F:\Repo\PowerShell>$bingRequestEntries = $har.Log.Entries | where {$_.Request.Url -match "www.bing.com"}
PS F:\Repo\PowerShell>$bingRequestEntries[0]


PageRef         : page_1
StartedDateTime : 2/29/2020 9:48:29 AM
Time            : 4.30999998934567
Request         : Method:GET, Url:http://www.bing.com/, QueryString:, PostData:, HttpVersion:HTTP/1.1, Headers:Upgrade-Insecure-Requests:1 User-Agent:Mozilla/5.0 (Windows NT 10.0; Win64; x64)
                  AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.122 Safari/537.36 Edg/80.0.361.62
                  Accept:text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9, HeadersSize:325, BodySize:0
Response        : Status:307, StatusText:Internal Redirect, RedirectUrl:https://www.bing.com/, HttpVersion:HTTP/1.1, Headers:Location:https://www.bing.com/ Non-Authoritative-Reason:HSTS,
                  HeadersSize:99, BodySize:-99
Cache           : BeforeRequest:, AfterRequest:
Timings         : Blocked:0.81699992056191, Dns:-1, Connect:-1, Send:0, Wait:1.40517950053543E-08, Receive:3.49300005473197, SSL:-1
ServerIPAddress :
Connection      :
Comment         :



PS F:\Repo\PowerShell>
```
<br>

# New-AzureVM.ps1
Name doesn't matter as long as it's unique.

Location can be found with `Get-AzureRMLocation`

VMSize can be determined with `Get-AzureRMVMSize -Location <location>`
  
  We default to `Standard_D1` since it's super cheap
  
  The largest VM we'd suggest you go with is `Standard_D4s_v3` because of it's unique cost/benefit
  
  For more pricing details: https://azure.microsoft.com/en-us/pricing/details/virtual-machines/windows/

<br>

# New-NetworkCapture.ps1
Runs a network capture for 5 minutes by default.

This a PowerShell variant of running `netsh trace start capture=yes tracefile=%temp%\NetworkTrace.etl` in the command prompt.

<br>

# TcpPing.ps1
The script will take an IP address (IPv4 or IPv6) or DNS hostname, then will 
test how long it takes to make a TCP socket connection to that IP and port. 

This script produces the following TCP traffic:

-> [SYN]<br />
<- [SYN,ACK]<br />
-> [ACK]<br />
-> [FIN,ACK]<br />
<- [RST,ACK]<br />

Latency is displayed in milliseconds (ms).
```powershell
PS F:\Repo\PowerShell> .\TcpPing.ps1 -HostNameOrIP outlook.office365.com -Port 25 | FT -AutoSize
```
| SourceAddress | RemoteAddress | RemotePort | Connected | Latency | Exception |
| :------------ | :------------ | ---------: | --------: | ------: | --------- |
| 10.131.34.100 | 40.97.119.162 | 25         | True      | 4.6481  |
| 10.131.34.100 | 40.97.119.162 | 25         | True      | 4.6751  |
| 10.131.34.100 | 40.97.119.162 | 25         | True      | 4.8726  |
| 10.131.34.100 | 40.97.119.162 | 25         | True      | 4.8324  |

