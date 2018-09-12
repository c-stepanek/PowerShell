[CmdletBinding()]
param(
    #Name for the resource group
    [Parameter(Mandatory=$true, Position=0)]
    [String]
    $Name,
    
    #Virutal machine location list
    [Parameter(Mandatory=$false, Position=1)]
    [ValidateSet("australiaeast","australiasoutheast","brazilsouth",
        "canadacentral","canadaeast","centralindia","centralus",
        "eastasia","eastus","eastus2","francecentral","japaneast",
        "japanwest","koreacentral","koreasouth","northcentralus",
        "northeurope","southcentralus","southeastasia","southindia",
        "uksouth","ukwest","westcentralus","westeurope","westindia",
        "westus","westus2")]
    [String]
    $Location = "westus",

    #Virtual machine credentials
    [Parameter(Mandatory=$true, Position=2)]
    [ValidateNotNullOrEmpty()]
    [System.Management.Automation.PSCredential]
    $VMCred,

    #Virtual machine size:
    #Some sizes are not available in all locations
    [Parameter(Mandatory=$false, Position=3)]
    [String]
    $VMSize = "Standard_D1"

)
#comment
if (Get-Module -ListAvailable -Name AzureRM)
{
    Import-Module -Name AzureRM
}
else 
{
    Write-Warning "The AzureRM module was not found. Attempting to install the AzureRM module."
    if (-not [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).Groups -match "S-1-5-32-544"))
    {
        throw "You must run this as Administrator to install the AzureRM module."
    }
    else
    {
        #We will assume you are running at least PowerShell Version 5.0
        #and/or alread have PowerShellGet installed.
        Install-Module -Name AzureRM -Force
    }
}

if ( (Get-AzureRMLocation | Where {$_.Location -eq $Location}).count -eq 0 )
{
    throw "AzureRM location $Location not found. You can find a list of valid locations using Get-AzureRMLocation.";
}
if ( (Get-AzureRmVMSize -Location $Location | Where {$_.Name -match $VMSize}).count -eq 0 )
{
    throw "Could not find a VMSize $VMSize at Location $Location. You can find VMSizes using the Get-AzureRmVMSize -Location <location> cmdlet."
}

#$Name is appended to the ResourceGroup name to make it unique
#$Location list can be found with the 'Get-AzureRMLocation' cmdlet
$ResourceGroup =  ($Name + "-VM-ResourceGroup");

#Create resource group
Write-Verbose "Creating AzureRM Resource Group: $ResourceGroup";
New-AzureRmResourceGroup -ResourceGroupName $ResourceGroup -Location $Location | Out-Null;

#Create virtual network
Write-Verbose "Creating Azure Virtual Network: vSubnet";
$SubnetConfig = New-AzureRmVirtualNetworkSubnetConfig -Name vSubnet -AddressPrefix 192.168.1.0/24;
$VirtualNetwork = New-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroup -Location $Location -Name vNetwork -AddressPrefix 192.168.0.0/16 -Subnet $SubnetConfig;

#Create public IP address
Write-Verbose "Creating a public IP address for ResourceGroup: $ResourceGroup in Location: $Location";
$PublicIP = New-AzureRmPublicIpAddress -ResourceGroupName $ResourceGroup -Location $Location -AllocationMethod Static -Name PublicIPAddress;

#Create network interface card
Write-Verbose "Creating NIC with public IP address";
$NIC = New-AzureRmNetworkInterface -ResourceGroupName $ResourceGroup -Location $Location -Name vNIC -SubnetId $VirtualNetwork.Subnets[0].Id -PublicIpAddressId $PublicIP.Id

#Create firewall rules and network security group
Write-Verbose "Creating firewall rules and network security group";
$RdpAccess = New-AzureRmNetworkSecurityRuleConfig -Name RDP -Protocol Tcp -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * `
-DestinationAddressPrefix * -DestinationPortRange 3389 -Access Allow
$HttpsAccess = New-AzureRmNetworkSecurityRuleConfig -Name HTTPS -Protocol Tcp -Direction Inbound -Priority 1010 -SourceAddressPrefix * -SourcePortRange * `
-DestinationAddressPrefix * -DestinationPortRange 443 -Access Allow
$NetworkSG = New-AzureRmNetworkSecurityGroup -ResourceGroupName $ResourceGroup -Location $Location -Name NetworkSecurityGroup -SecurityRules $RdpAccess,$HttpsAccess
Set-AzureRmVirtualNetworkSubnetConfig -Name vSubnet -VirtualNetwork $VirtualNetwork -NetworkSecurityGroup $NetworkSG -AddressPrefix 192.168.1.0/24 | Out-Null
Set-AzureRmVirtualNetwork -VirtualNetwork $VirtualNetwork | Out-Null

#Create virtual machine
Write-Verbose "Creating Virtual Machine config details";

$VM = New-AzureRmVMConfig -VMName LabVM -VMSize $VMSize;
$VM = Set-AzureRmVMOperatingSystem -VM $VM -Windows -ComputerName "LabVM-$Name" -Credential $VMCred -ProvisionVMAgent -EnableAutoUpdate
$VM = Set-AzureRmVMSourceImage -VM $VM -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2016-Datacenter -Version latest
$VM = Set-AzureRmVMOSDisk -VM $VM -Name OsDisk -DiskSizeInGB 128 -CreateOption FromImage -Caching ReadWrite
$VM = Add-AzureRmVMNetworkInterface -VM $VM -Id $NIC.Id

Write-Verbose "Creating virtual machine $VM.Name in ResourceGroup $ResourceGroup in Location $Location";
New-AzureRmVM -ResourceGroupName $ResourceGroup -Location $Location -VM $VM | Out-Null
Write-Verbose "VM creation successful!"

#Show Public IP address
$publicIP = (Get-AzureRmPublicIpAddress -ResourceGroupName $ResourceGroup).IpAddress;
Write-Output "Virtual machine $VM.Name in ResourceGroup $ResourceGroup in Location $Location has been created with a Public IP $publicIP."
Write-Output "You can use the credentials provided earlier in the process to connect to this VM with RDP."
