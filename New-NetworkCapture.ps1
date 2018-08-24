<#
.SYNOPSIS
Captures network traffic.
.DESCRIPTION
This a PowerShell variant of "netsh trace start capture=yes tracefile=d:\NetworkTrace.etl"
This script must be run as Administrator.
.PARAMETER FilePath
The file path for the trace output. Default is user's temp folder.
Example: C:\Users\<UserName>\AppData\Local\Temp
.PARAMETER Duration
The capture length in minutes. Default is 5 minutes.
.EXAMPLE
New-NetworkCapture
This will capture for 5 minutes and output NetworkTrace.etl to the user's temp folder.
.EXAMPLE
New-NetworkCapture -FilePath d:\NetCap.etl -Duration 10
This will capture for 10 minutes and output to d:\NetCap.etl
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false,
    HelpMessage="Trace file output location")]
    [string] $FilePath = "$env:TEMP\NetworkTrace.etl",

    [Parameter(Mandatory=$false,
    HelpMessage="Capture length in minutes")]
    [ValidateRange(1,10)]
    [int] $Duration = 5
)

if (-not [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).Groups -match "S-1-5-32-544")) {
    throw "You must run this as Administrator to continue."
}
  
New-NetEventSession -Name "Capture" -CaptureMode SaveToFile -LocalFilePath $FilePath | Out-Null
Add-NetEventPacketCaptureProvider -SessionName "Capture" -Level 4 -CaptureType Physical | Out-Null
Write-Verbose "Start Capture"
Start-NetEventSession -Name "Capture"

Write-Verbose "Capture will run for $Duration minute(s)"
Start-Sleep -Seconds (New-TimeSpan -Minutes $Duration).TotalSeconds

Write-Verbose "Stop Capture"
Stop-NetEventSession -Name "Capture"
Remove-NetEventSession -Name "Capture"