##############################################
####DL and MAIL ENABLED SECURITY GROUP CREATION######
##############################################

$myDomains = (Get-MSolDomain).name
Write-Host 
$myDomains
$domainChoice = Read-Host "choose a domain" 
[int]$numberOfGroups = Read-Host "Number of SharedMailboxes" 


$counter = 0
while($counter -ne $numberOfGroups){
$randomNumber = Get-Random -Maximum 100000
$NameOfDistributionGroup = "DL" + $randomNumber.ToString()
$NameOfSecurityMailEnabled = "MailEnabledSecurity" + $randomNumber.ToString()

$PrimaryDL = $NameOfDistributionGroup + "@" + $domainChoice
$PrimatyMailEnabledSecurity = $NameOfSecurityMailEnabled + "@" + $domainChoice

New-DistributionGroup -Type "Distribution" -Name $NameOfDistributionGroup -PrimarySmtpAddress $PrimaryDL

New-DistributionGroup -Type "Security" -Name $NameOfSecurityMailEnabled -PrimarySmtpAddress $PrimatyMailEnabledSecurity
$counter++
}
