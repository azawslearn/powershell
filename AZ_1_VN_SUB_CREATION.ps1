
$RGName = "myRGVNET1"
$location = 'eastus'

$vNetName = 'myVNET'
$AddressPrefix = @('10.10.0.0/16')

$subnet01Name = 'subnet_1'
$subnet01AddressPrefix = '10.10.1.0/24'

$subnet02Name = 'subnet_2'
$subnet02AddressPrefix_2 = '10.10.2.0/24'

$subnet03Name = 'subnet_3'
$subnet03AddressPrefix_3 = '10.10.3.0/25'

$subnet04Name = 'subnet_4'
$subnet04AddressPrefix_4 = '10.10.3.128/25'

$subnet05Name = 'subnet_5'
$subnet05AddressPrefix_5 = '10.10.4.0/26'

$subnet06Name = 'subnet_6'
$subnet06AddressPrefix_6 = '10.10.4.64/26'

$subnet07Name = 'subnet_7'
$subnet07AddressPrefix_7 = '10.10.4.128/26'

$subnet08Name = 'subnet_8'
$subnet08AddressPrefix_8 = '10.10.4.192/26'

#create the RG
New-AzResourceGroup -Name $RGName -Location $location 

#Create the VN
New-AzVirtualNetwork -Name $vNetName -ResourceGroupName $RGName -Location $location -AddressPrefix $AddressPrefix

#get the vnet
$azvNet = Get-AzVirtualNetwork -Name $vNetName -ResourceGroupName $RGName

#add the first subnet
Add-AzVirtualNetworkSubnetConfig -Name $subnet01Name -AddressPrefix $subnet01AddressPrefix -VirtualNetwork $azvNet

#add the second subnet
Add-AzVirtualNetworkSubnetConfig -Name $subnet02Name -AddressPrefix $subnet02AddressPrefix_2 -VirtualNetwork $azvNet

$azvNet | Set-AzVirtualNetwork

#split a SUBNET in 2 / 128 hots per subnet

Add-AzVirtualNetworkSubnetConfig -Name $subnet03Name -AddressPrefix $subnet03AddressPrefix_3 -VirtualNetwork $azvNet

Add-AzVirtualNetworkSubnetConfig -Name $subnet04Name -AddressPrefix $subnet04AddressPrefix_4 -VirtualNetwork $azvNet

$azvNet | Set-AzVirtualNetwork

#Split a subnet in 4 / 59 hosts per subnet

Add-AzVirtualNetworkSubnetConfig -Name $subnet05Name -AddressPrefix $subnet04AddressPrefix_5 -VirtualNetwork $azvNet

Add-AzVirtualNetworkSubnetConfig -Name $subnet06Name -AddressPrefix $subnet04AddressPrefix_6 -VirtualNetwork $azvNet

Add-AzVirtualNetworkSubnetConfig -Name $subnet07Name -AddressPrefix $subnet04AddressPrefix_7 -VirtualNetwork $azvNet

Add-AzVirtualNetworkSubnetConfig -Name $subnet08Name -AddressPrefix $subnet04AddressPrefix_8 -VirtualNetwork $azvNet

$azvNet | Set-AzVirtualNetwork

