#1 Create variables to store the location and resource group names.

$location = "eastus"
$ResourceGroupName = "LB_RG"

 

New-AzResourceGroup `
-Name $ResourceGroupName `
-Location $location

 

#2 Create variables to store the storage account name and the storage account SKU information

$StorageAccountName = "accountformachineslb"
$SkuName = "Standard_LRS"

 
# Create a new storage account

$StorageAccount = New-AzStorageAccount `
-Location $location `
-ResourceGroupName $ResourceGroupName `
-Type $SkuName `
-Name $StorageAccountName

 

Set-AzCurrentStorageAccount `
-StorageAccountName $storageAccountName `
-ResourceGroupName $resourceGroupName

#3 Create a subnet configuration

$subnetConfig = New-AzVirtualNetworkSubnetConfig `
-Name mySubnet `
-AddressPrefix 192.168.1.0/24

 

# Create a virtual network

$vnet = New-AzVirtualNetwork `
-ResourceGroupName $ResourceGroupName `
-Location $location `
-Name MyVnet `
-AddressPrefix 192.168.0.0/16 `
-Subnet $subnetConfig

 

 

#4 Create variables to store the network security group and rules names.

$nsgName = "LB_NSG"
$nsgRuleSSHName = "LB_NSG_Rule"
$nsgRuleWebName = "LB_Rule"

 

 

# Create an inbound network security group rule for port 22

$nsgRuleSSH = New-AzNetworkSecurityRuleConfig -Name $nsgRuleSSHName -Protocol Tcp `
-Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `
-DestinationPortRange 22 -Access Allow

 

# Create an inbound network security group rule for port 80

$nsgRuleWeb = New-AzNetworkSecurityRuleConfig -Name $nsgRuleWebName -Protocol Tcp `
-Direction Inbound -Priority 1001 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `
-DestinationPortRange 80 -Access Allow

 

# Create a network security group

$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Location $location `
-Name $nsgName -SecurityRules $nsgRuleSSH,$nsgRuleWeb

 

#5 Create NIC

 

$nic = New-AzNetworkInterface `
-Name 'VM1_NIC' `
-ResourceGroupName $ResourceGroupName `
-Location $location `
-SubnetId $vnet.Subnets[0].Id `
-PrivateIpAddress "192.168.1.10" `
-NetworkSecurityGroupId $nsg.Id

$nic1 = New-AzNetworkInterface `
-Name 'VM2_NIC' `
-ResourceGroupName $ResourceGroupName `
-Location $location `
-SubnetId $vnet.Subnets[0].Id `
-PrivateIpAddress "192.168.1.11" `
-NetworkSecurityGroupId $nsg.Id

#CREATE A VM

# Define a credential object

$UserName='demouser'
$securePassword = ConvertTo-SecureString 'EmersonFitipaldi1!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($UserName, $securePassword)

 

# Create the VM configuration object

$VmName = "VirtualMachinelatest"
$VmSize = "Standard_B1s"

$VirtualMachine = New-AzVMConfig `
-VMName $VmName `
-VMSize $VmSize

 

$VirtualMachine = Set-AzVMOperatingSystem `
-VM $VirtualMachine `
-Linux `
-ComputerName "MainComputer" `
-Credential $cred

 

$VirtualMachine = Set-AzVMSourceImage `
-VM $VirtualMachine `
-PublisherName "Canonical" `
-Offer "UbuntuServer" `
-Skus "16.04-LTS" `
-Version "latest"

 

# Set the operating system disk properties on a VM

$VirtualMachine = Set-AzVMOSDisk `
-VM $VirtualMachine `
-CreateOption FromImage | `
Set-AzVMBootDiagnostic -ResourceGroupName $ResourceGroupName `
-StorageAccountName $StorageAccountName -Enable |`
Add-AzVMNetworkInterface -Id $nic.Id

 

# Create the VM

New-AzVM `
-ResourceGroupName $ResourceGroupName `
-Location $location `
-VM $VirtualMachine


#SECOND VM

$UserName='demouser'
$securePassword = ConvertTo-SecureString 'EmersonFitipaldi1!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($UserName, $securePassword)

 

# Create the VM configuration object

$VmName1 = "VirtualMachinelatest2"
$VmSize1 = "Standard_B1s"

$VirtualMachine1 = New-AzVMConfig `
-VMName $VmName1 `
-VMSize $VmSize1

 

$VirtualMachine1 = Set-AzVMOperatingSystem `
-VM $VirtualMachine1 `
-Linux `
-ComputerName "MainComputer" `
-Credential $cred

 

$VirtualMachine1 = Set-AzVMSourceImage `
-VM $VirtualMachine1 `
-PublisherName "Canonical" `
-Offer "UbuntuServer" `
-Skus "16.04-LTS" `
-Version "latest"

 

# Set the operating system disk properties on a VM

$VirtualMachine1 = Set-AzVMOSDisk `
-VM $VirtualMachine1 `
-CreateOption FromImage | `
Set-AzVMBootDiagnostic -ResourceGroupName $ResourceGroupName `
-StorageAccountName $StorageAccountName -Enable |`
Add-AzVMNetworkInterface -Id $nic1.Id

 

# Create the VM

New-AzVM `
-ResourceGroupName $ResourceGroupName `
-Location $location `
-VM $VirtualMachine1



#CREATE A LOADBALANCER

$publicip = @{
    Name = 'LB_Public_IP'
    ResourceGroupName = $ResourceGroupName
    Location = $location
    Sku = 'Standard'
    AllocationMethod = 'static'
    Zone = 1,2,3
}

New-AzPublicIpAddress @publicip


## Place public IP created in previous steps into variable. ##

$pip = @{
    Name = 'LB_Public_IP'
    ResourceGroupName = $ResourceGroupName
}

$publicIp = Get-AzPublicIpAddress @pip

 

## Create load balancer frontend configuration and place in variable. ##

$fip = @{
    Name = 'myFrontEnd'
    PublicIpAddress = $publicIp
}

$feip = New-AzLoadBalancerFrontendIpConfig @fip

 

## Create backend address pool configuration and place in variable. ##

$bepool = New-AzLoadBalancerBackendAddressPoolConfig -Name 'myBackEndPool'

 

## Create the health probe and place in variable. ##

$probe = @{
    Name = 'myHealthProbe'
    Protocol = 'tcp'
    Port = '80'
    IntervalInSeconds = '360'
    ProbeCount = '5'
}

$healthprobe = New-AzLoadBalancerProbeConfig @probe

 

## Create the load balancer rule and place in variable. ##

$lbrule = @{
    Name = 'myHTTPRule'
    Protocol = 'tcp'
    FrontendPort = '80'
    BackendPort = '80'
    IdleTimeoutInMinutes = '15'
    FrontendIpConfiguration = $feip
    BackendAddressPool = $bePool
}

$rule = New-AzLoadBalancerRuleConfig @lbrule -EnableTcpReset -DisableOutboundSNAT

## Create the load balancer resource. ##

$loadbalancer = @{
    ResourceGroupName = $ResourceGroupName
    Name = 'myLoadBalancer'
    Location = 'eastus'
    Sku = 'Standard'
    FrontendIpConfiguration = $feip
    BackendAddressPool = $bePool
    LoadBalancingRule = $rule
    Probe = $healthprobe
}

New-AzLoadBalancer @loadbalancer

 

###############################################

##############################################

#ADD THE VM TO THE BACKEND POOL

 

 

$loadBalancerName = "myLoadBalancer"

$backendPoolName = "myBackEndPool"

$vmName = "VirtualMachinelatest"

$nicName = "VM1_NIC"
$nic1Name = "VM2_NIC"

 

# Get the load balancer and backend pool

$loadBalancer = Get-AzLoadBalancer -ResourceGroupName $ResourceGroupName -Name $loadBalancerName
$backendPool = $loadBalancer.BackendAddressPools | Where-Object {$_.Name -eq $backendPoolName}

 

# Get the VM and NIC

$vm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $vmName
$nic = Get-AzNetworkInterface -ResourceGroupName $resourceGroupName -Name $nicName
$nic1 = Get-AzNetworkInterface -ResourceGroupName $resourceGroupName -Name $nic1Name
 

# Add the backend pool to the NIC's IP configuration

$nic.IpConfigurations[0].LoadBalancerBackendAddressPools = $backendPool
$nic1.IpConfigurations[0].LoadBalancerBackendAddressPools = $backendPool

 

# Update the NIC

Set-AzNetworkInterface -NetworkInterface $nic
Set-AzNetworkInterface -NetworkInterface $nic1



#OUTBOUND RULE
###########################################################


$slb = Get-AzLoadBalancer -ResourceGroupName "LB_RG" -Name "MyLoadBalancer"
$slb | Add-AzLoadBalancerOutboundRuleConfig -Name "NewRule" -Protocol "Tcp" -FrontendIPConfiguration $slb.FrontendIpConfigurations[0] -BackendAddressPool $slb.BackendAddressPools[0] -IdleTimeoutInMinutes 5
$slb | Set-AzLoadBalancerOutboundRuleConfig -Name "NewRule" -Protocol "Tcp" -FrontendIPConfiguration $slb.FrontendIpConfigurations[0] -BackendAddressPool $slb.BackendAddressPools[0] -IdleTimeoutInMinutes 10 | Set-AzLoadBalancer



#########################################################


#JUMP BOX

$publicip = @{
    Name = 'JumpBox_Public_IP'
    ResourceGroupName = $ResourceGroupName
    Location = $location
    Sku = 'Standard'
    AllocationMethod = 'static'
    Zone = 1,2,3
}

New-AzPublicIpAddress @publicip

$publicIpAddress = Get-AzPublicIpAddress -ResourceGroupName $ResourceGroupName -Name 'JumpBox_Public_IP'
$publicIpAddressId = $publicIpAddress.Id

$nic2 = New-AzNetworkInterface -Name 'JumpBox_NIC' `
    -ResourceGroupName $ResourceGroupName `
    -Location $location `
    -SubnetId $vnet.Subnets[0].Id `
    -PrivateIpAddress "192.168.1.12" `
    -NetworkSecurityGroupId $nsg.Id `
    -PublicIpAddressId $publicIpAddressId





$UserName='demouser'
$securePassword = ConvertTo-SecureString 'EmersonFitipaldi1!' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($UserName, $securePassword)

 

# Create the VM configuration object

$VmName3 = "ANSIBLE"
$VmSize3 = "Standard_B1s"

$VirtualMachine3 = New-AzVMConfig `
-VMName $VmName3 `
-VMSize $VmSize3

 

$VirtualMachine3 = Set-AzVMOperatingSystem `
-VM $VirtualMachine3 `
-Linux `
-ComputerName "MainComputer" `
-Credential $cred

 

$VirtualMachine3 = Set-AzVMSourceImage `
-VM $VirtualMachine3 `
-PublisherName "Canonical" `
-Offer "UbuntuServer" `
-Skus "16.04-LTS" `
-Version "latest"

 

# Set the operating system disk properties on a VM

$VirtualMachine3 = Set-AzVMOSDisk `
-VM $VirtualMachine3 `
-CreateOption FromImage | `
Set-AzVMBootDiagnostic -ResourceGroupName $ResourceGroupName `
-StorageAccountName $StorageAccountName -Enable |`
Add-AzVMNetworkInterface -Id $nic2.Id

 

# Create the VM

New-AzVM `
-ResourceGroupName $ResourceGroupName `
-Location $location `
-VM $VirtualMachine3

