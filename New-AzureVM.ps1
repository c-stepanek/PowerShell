param(
    [Parameter(Mandatory=$true, Position=0)]
    [String]
    $Name,
    [Parameter(Mandatory=$true, Position=1)]
    [String]
    $Location
)

#$Name is appended to the ResourceGroup name to make it unique
#$Location list can be found with the 'Get-AzureRMLocation' cmdlet
$ResourceGroup =  ($Name + "-VM-ResourceGroup")

#Create resource group
New-AzureRmResourceGroup -ResourceGroupName $ResourceGroup -Location $Location

#Create virtual network
$SubnetConfig = New-AzureRmVirtualNetworkSubnetConfig -Name vSubnet -AddressPrefix 192.168.1.0/24
$VirtualNetwork = New-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroup -Location $Location -Name vNetwork -AddressPrefix 192.168.0.0/16 -Subnet $SubnetConfig

#Create public IP address
$PublicIP = New-AzureRmPublicIpAddress -ResourceGroupName $ResourceGroup -Location $Location -AllocationMethod Static -Name PublicIPAddress

#Create network interface card
$NIC = New-AzureRmNetworkInterface -ResourceGroupName $ResourceGroup -Location $Location -Name vNIC -SubnetId $VirtualNetwork.Subnets[0].Id -PublicIpAddressId $PublicIP.Id

#Create firewall rules and network security group
$RdpAccess = New-AzureRmNetworkSecurityRuleConfig -Name RDP -Protocol Tcp -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * `
-DestinationAddressPrefix * -DestinationPortRange 3389 -Access Allow
$HttpsAccess = New-AzureRmNetworkSecurityRuleConfig -Name HTTPS -Protocol Tcp -Direction Inbound -Priority 1010 -SourceAddressPrefix * -SourcePortRange * `
-DestinationAddressPrefix * -DestinationPortRange 443 -Access Allow
$NetworkSG = New-AzureRmNetworkSecurityGroup -ResourceGroupName $ResourceGroup -Location $Location -Name NetworkSecurityGroup -SecurityRules $RdpAccess,$HttpsAccess
Set-AzureRmVirtualNetworkSubnetConfig -Name vSubnet -VirtualNetwork $VirtualNetwork -NetworkSecurityGroup $NetworkSG -AddressPrefix 192.168.1.0/24
Set-AzureRmVirtualNetwork -VirtualNetwork $VirtualNetwork

#Create virtual machine
$Cred = Get-Credential
$VM = New-AzureRmVMConfig -VMName LabVM -VMSize Standard_D1
$VM = Set-AzureRmVMOperatingSystem -VM $VM -Windows -ComputerName LabVM -Credential $Cred -ProvisionVMAgent -EnableAutoUpdate
$VM = Set-AzureRmVMSourceImage -VM $VM -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2016-Datacenter -Version latest
$VM = Set-AzureRmVMOSDisk -VM $VM -Name OsDisk -DiskSizeInGB 128 -CreateOption FromImage -Caching ReadWrite
$VM = Add-AzureRmVMNetworkInterface -VM $VM -Id $NIC.Id

New-AzureRmVM -ResourceGroupName $ResourceGroup -Location $Location -VM $VM

#Show Public IP address
Get-AzureRmPublicIpAddress -ResourceGroupName $ResourceGroup | Select-Object IpAddress
