[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]$HostNameOrIP,

    [Parameter(Mandatory = $false, Position = 1)]
    [ValidateRange(1, [IPEndPoint]::MaxPort)]
    [int]$Port = 80,

    [Parameter(Mandatory = $false, Position = 2)]
    [ValidateRange(1, 30)]
    [int]$Attempts = 4
)

[IPAddress]$SourceAddress = (Test-Connection $env:COMPUTERNAME -Count 1).IPV4Address

try {
    if ($HostNameOrIP -match "[a-z]") {
        [IPAddress[]]$Addresses = [System.Net.Dns]::GetHostAddresses($HostNameOrIP)
        [IPAddress]$TargetIPAddress = $Addresses[0].IPAddressToString
    }
    else {
        [IPAddress]$TargetIPAddress = $HostNameOrIP
    }
}
catch {
    throw
}

for ($i = 1; $i -le $Attempts; $i++) {                
    try {
        $TCPClient = New-Object System.Net.Sockets.TCPClient($($TargetIPAddress.AddressFamily))                  
        $Connect = $TCPClient.BeginConnect($TargetIPAddress, $Port, $null, $null)
        $Latency = Measure-Command { $Connect.AsyncWaitHandle.WaitOne(3000, $true) }

        if ($TCPClient.Connected) {
            $TCPClient.EndConnect($Connect);

            [PsCustomObject][ordered]@{
                SourceAddress = $SourceAddress.IPAddressToString
                RemoteAddress = $TargetIPAddress.IPAddressToString
                RemotePort    = $Port
                Connected     = $TCPClient.Connected
                Latency       = $Latency.TotalMilliseconds
                Exception     = $null
            }

            $TcpClient.Dispose()
        }
        else {
            $TCPClient.Dispose()

            [PsCustomObject][ordered]@{
                SourceAddress = $SourceAddress.IPAddressToString
                RemoteAddress = $TargetIPAddress.IPAddressToString
                RemotePort    = $Port
                Connected     = $false
                Latency       = $null
                Exception     = "RequestTimeout"
            }
        }
    
        Start-Sleep -Seconds 1        
    }
    catch {
        [PsCustomObject][ordered]@{
            SourceAddress = $SourceAddress.IPAddressToString
            RemoteAddress = $TargetIPAddress.IPAddressToString
            RemotePort    = $Port
            Connected     = $false
            Latency       = $null
            Exception     = $_.Exception.Message
        }
    }
}
