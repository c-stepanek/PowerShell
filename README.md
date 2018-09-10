# PowerShell
Repository for PowerShell scripts.

# New-AzureVM.ps1
Name doesn't matter as long as it's unique.

Location can be found with Get-AzureRMLocation

VMSize can be determined with Get-AzureRMVMSize -Location <location>
  
  We default to Standard_D1 since it's super cheap
  
  The largest VM we'd suggest you go with is Standard_D4s_v3 because of it's unique cost/benefit
  
  For more pricing details: https://azure.microsoft.com/en-us/pricing/details/virtual-machines/windows/


# New-NetworkCapture.ps1
Runs a network capture for 5 minutes by default.

This a PowerShell variant of running "netsh trace start capture=yes tracefile=%temp%\NetworkTrace.etl" in the command prompt.


# TcpPing.ps1
The script will take an IP address (IPv4 or IPv6) or DNS hostname, then will 
test how long it takes to make a TCP socket connection to that IP and port. 

This script produces the following TCP traffic:

-> [SYN]
<- [SYN,ACK]
-> [ACK]
-> [FIN,ACK]
<- [FIN,ACK]
-> [ACK]

Latency is displayed in milliseconds (ms).