###LOCAL AD###

#you need to register a dll in order to see the Schema master:
regsvr32 schmmgmt.dll

#to find the masters from the commandline:
dcdiag /test:knowsofroleholders /v
netdom query fsmo

#force replication
repadmin /SyncAll
repadmin /BridgeHeads

#Troubleshooting GPO:
rsop.msc
gpresult /r - will show us all the GPOs applied to the machine
gpresult /Scope User /v
gpresult /Scope Computer /v

#get all properties of an AD object 
get-aduser -Identity <UPN> -Properties *
get-aduser -filter * -resultsetsize 100 | select-object Name, userprincipalname  - will give us only the name and UPN


####POWER SHELL####
Get-Host - information about powersehll

Get-Module - to get the isntalled modules.

(get-mailbox).name - will show the names of all my mailboxes. It shows the property of what you have received as a result.

In PS objects have MTHODS and PROPERTIES.
PROPERTIES are things that the object is. A characteristic of the object.
MTHOD is something that the object can do.

$ - signifiesa a variable. 

#both commands will return the same output. They will give the mailbox name and every property that contains *address*
get-mailbox ivansto | select-object name, *address*
get-mailbox ivansto | fl name, *address*

#we can can selece a property and rename it. Here, we selected all the names of boxes and gave a new name to the column output with @{name="THEBOXNAME and than told PS withi what to fill it, in our case it is the same, with the name, but we could have given another property:

get-mailbox | select-object -property name, @{name="THEBOXNAME"; expression={$_.name}}

Output:
Name                                                         THEBOXNAME
----                                                         ----------
DiscoverySearchMailbox{D919BA05-46A6-415f-80AD-7E09334BB852} DiscoverySearchMailbox{D919BA05-46A6-415f-80AD-7E09334B...
IvanSto                                                      IvanSto
s4                                                           s4

with another property:
Name                                                         THEBOXNAME
----                                                         ----------
IvanSto                                                      IvanSto@h1br.onmicrosoft.com
s4                                                           s4@hybr1d.dnsabr.com

#we can sent output to files 
get-mailbox > boxes.txt
get-mailbox > "$home\Desktop\mailbox.txt" - will output to the desktop of the current user
get-mailbox > "c:\users\$env:USERNAME\desktop\mail.txt" - will save output to the desktop

we can also export to csv

get-mailbox | export-csv "$home\Desktop\mailbox.csv"

#we can use the command to see how many objects are going to be given to us be a command.
get-mailbox | Measure-Object

#we can select a number of objects that are given to us: (we can laso see the last objects)
get-mailbox | select -first 2
get-mailbox | select -last 2

#all mean the same thing:
Get-Process | where {$_.HandleCount -gt 900}
Get-Process | where {$psitem.HandleCount -gt 900}
Get-Process | where HandleCount -gt 900
Get-Process | ? HandleCount -gt 900

#use get-member to check what objects you are getting back 

#Clear the DNS Server Cache:
Clear-DnsClientCache
Clear-DNsServerCache

#to get/set the execution policy
Get-ExecutionPolicy
Set-ExecutionPolicy


In order to run a script:
.\<script>


#To write someting on the screen
Write-Output

#To take input from 
Read-Host "What is you pass" -asSecureString

#>


###Function to connect to EXO, SC, MSOL###
function Connect_MSOL_EXO_SC
{
$username = "ivansto@kibertron.onmicrosoft.com"
$password = ConvertTo-SecureString "" -AsPlainText -Force
$psCred = New-Object System.Management.Automation.PSCredential -ArgumentList ($username, $password)
Import-Module MSOnline
Connect-MSolService -Credential $psCred
Write-Host "Connected to MSONLINE"
Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline -Credential $psCred -ShowProgress $true
Write-Host "Connected to EXO"
Connect-IPPSSession -Credential $psCred
Write-Host "Connected to Security and Copliance"
}

function Connect-MSOL_ONLY{
$username = "admin@h1br.onmicrosoft.com"
$password = ConvertTo-SecureString "s3cr37p455##" -AsPlainText -Force
$psCred = New-Object System.Management.Automation.PSCredential -ArgumentList ($username, $password)
Import-Module MSOnline
Connect-MSolService -Credential $psCred
}


### CREATEA A TEST USER NO LICESNE ASSIGNED ###

function Create_TestUser{
    Param([string]$display_name, [string]$UPN, [string]$location, [string]$password )
    
    while($true){
    $display_name = Read-Host "Enter DisplayName"
    $users = get-msoluser | Where-Object{$_.DisplayName -eq $display_name}
    if($users -eq $null)
    {
    Write-Host "DisplayName is not used. Creating the user"
    break
    }else {
	Write-Host "Please provide another name as the one provided is already in use"
}
    }
    $my_upn = $display_name
    $UPN = $my_upn + "@h1br.onmicrosoft.com"
    $location = "BG"
    $password = "F!t!p4ld!"
    New-MsolUser -DisplayName $display_name -UserPrincipalName $UPN -UsageLocation $location -Password $password
    }

### Removes Complexity In AD ###

#example for -Identity : hybr1d.dnsabr.local




function prepare_admin_account{
$id = (Get-ADDomain).DistinguishedName
Set-ADDefaultDomainPasswordPolicy `
-Identity $id `
-ComplexityEnabled $False `
-MinPasswordLength 1 `
-PasswordHistoryCount 0 `
-MinPasswordAge 00.00:00:00 `
-MaxPasswordAge 00.00:00:00

gpupdate /force

$NewPwd = ConvertTo-SecureString "1" -AsPlainText -Force
Set-ADAccountPassword -Identity Administrator -NewPassword $NewPwd -Reset
}

### Removes Complexity Locally ###
function prepare_local_admin{
secedit /export /cfg c:\secpol.cfg
(gc C:\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File C:\secpol.cfg
secedit /configure /db c:\windows\security\local.sdb /cfg c:\secpol.cfg /areas SECURITYPOLICY
rm -force c:\secpol.cfg -confirm:$false

gpupdate /force

$Password = ConvertTo-SecureString "1" -AsPlainText -Force
$UserAccount = Get-LocalUser -Name "Administrator"
$UserAccount | Set-LocalUser -Password $Password

### Set-TimeZone ###

Set-TimeZone -Id "FLE Standard Time"

### Rename-computer ###

$old_computer_name = $env:computername
$computer_name = Read-Host "Enter the new computer name"

Rename-computer -ComputerName $old_computer_name -NewName $computer_name

}


function Configure_IP{

Param([UInt32]$InterfaceIndex, [string]$IP, [Byte]$prefix_length, [string]$default_gateway, [string]$dns_server )

Get-NetIPConfiguration 

$IP = Read-Host "Enter IP"
$default_gateway = Read-Host "Enter Default Gateway"
$prefix_length = Read-Host "Enter Prefix Length"
$InterfaceIndex = Read-Host "Enter Interface Index"
$dns_server = Read-Host "Enter Dn"

New-NetIPAddress -IPAddress $IP -DefaultGateway $default_gateway -PrefixLength $prefix_length -InterfaceIndex $InterfaceIndex

Set-DnsClientServerAddress -InterfaceIndex $InterfaceIndex -ServerAddresses $dns_server
}


<#
### Install AD with PowerShell ###
Install-WindowsFeature –Name AD-Domain-Services –IncludeManagementTools

Import-Module ADDSDeployment

$pwd = ConvertTo-SecureString "Sup3r53cur3p455" -AsPlainText -Force
$domain_name = Read-Host "Enter a domain name"

Install-ADDSForest `
-CreateDnsDelegation:$false `
-SafeModeAdministratorPassword $pwd `
-DatabasePath "C:\Windows\NTDS" `
-DomainMode "WinThreshold" `
-DomainName $domain_name `
-ForestMode "WinThreshold" `
-InstallDns:$true `
-LogPath "C:\Windows\NTDS" `
-NoRebootOnCompletion:$false `
-SysvolPath "C:\Windows\SYSVOL" `
-Force:$true
#>

### Add a suffix in AD ###
# Get-ADForest | Set-ADForest -UPNSuffixes @{add="kibertron.onmicrosoft.com"}

<#
##############################
##### Create Test Users #####
##############################

$suffix = (Get-ADForest).upnsuffixes
write-host "UPN_Suffix:$suffix"
$val = [int](Read-Host "Enter number of test users")
$count_of_users = 0
$name_of_user = Read-Host "Name of test user"

while($count_of_users -ne $val)
{
    $count_of_users++
    
    $created_user = $name_of_user + $count_of_users.ToString()
   
    $pwd1 = ConvertTo-SecureString "1" -AsPlainText -Force
    $upn_suffix = $created_user + $suffix
    New-ADUser `
        -Name $created_user `
        -AccountPassword $pwd1 `
	-UserPrincipalName $upn_suffix `
        -Title "CEO" `
        -State "California" `
        -City "San Francisco" `
        -Description "Test Account Creation" `
        -Department "Engineering" `
        -Enabled $True
Write-Host $created_user "created"
#-Path "OU=synced_user,DC=f0r3,DC=local" - given as an example
}

<#

### disable all security on the server ####
function Disable-IEESC {

$AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"

$UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"

Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0

Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0

Stop-Process -Name Explorer

Write-Host "IE Enhanced Security Configuration (ESC) has been disabled." -ForegroundColor Green

### Disable Firewall with PS ###
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
Set-MpPreference -DisableRealtimeMonitoring $true

}

### AADC ####

%programdata%\AADConnect - view ad connect logs

dsregcmd /status - to see if a device is joined or registerd in AAD

#>

###################################
#### Join a PC to AD ##############
###################################
<#

$username = "administrator"
$password = ConvertTo-SecureString "1" -AsPlainText -Force
$psCred = New-Object System.Management.Automation.PSCredential -ArgumentList ($username, $password)
Add-Computer -DomainName kibertron.local -Credential $psCred

#>

<#

Set Logonserver - in CMD will show which was the DC that authenticated the user
gpresult /r - will from which DC the GPOs were taken.
systeminfo | findstr /i "domain" - will show if a mahcine is joined to a domain

#>

#########
#########
##AZURE##
#########

<#


az account list - will list the subscriptions 
az account list-locations -o table - view all the REGIONS in Azure

az ad group list | grep displayName - in the CLOUD SHELL, we can use GREP.
az ad group list --query [].displayName - will work in the locak shell as well.
get-azadgroup | select displayName

get-azadgroup | get-member - to view all the properties for a group

#>

#####################################
#####################################
#Start a transcript on the desctop
#####################################
#####################################
cd $env:USERPROFILE\Desktop\
Start-Transcript -Append -Path "$($env:USERPROFILE)\Desktop\transcript.txt" 
$startTime = Get-Date
Write-Host "Session Started:"$startTime.ToString("u") 
Write-Host "Session Started:"$startTime.ToString("u")
#########################################
#########################################


######################
#### AKS #####
######################

#Set-Alias -Name list -Value Get-ChildItem


#connect to the AKS cluster
#az aks get-credentials --resource-group aks --name aks

#ALIASES#
Function kdd-all(){kubectl delete --all deployments \
echo "kubectl delete --all deployments"}

Function kgd(){kubectl get deployment}

Function ka-f(){kubectl apply -f}

Function kgs(){kubectl get services}

Function kgp(){kubectl get pod}
