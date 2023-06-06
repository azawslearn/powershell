
###########################################
####OFFICE365 GROUPS ###############
###############################

$myDomains = Get-MSolDomain | Select-Object Name -ExpandProperty Name

Write-host "AVAILABLE DOMAINS:`n"
#loop through all the domains in the tenant
for ($counter=0; $counter -lt $myDomains.Length; $counter++){
    
    Write-host $counter,$myDomains[$counter]

}

#read the input from user for which domain should be used
$my_choice = [int](Read-Host "Enter the number of the domain: ")

$suffix = $myDomains[$my_choice]

Write-Host "YOUR CHOICE WAS:`n`n  $suffix`n "

$my_number = [int](Read-Host "Enter the number of the OFFICE 365 GROUPS: ")

$counter = 0
while($counter -ne $my_number)
{
$randomNumber = Get-Random -Maximum 100000
$groupDomain = $suffix
$groupDispalyName = "o365Group" + $randomNumber.ToString()
$mail = $groupDispalyName + "@" + $groupDomain

New-UnifiedGroup -DisplayName $groupDispalyName -Alias $groupDispalyName `
-EmailAddresses $mail -AccessType Private

$counter++

}
