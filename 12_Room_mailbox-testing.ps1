##############################################
######ROOM MAILBOX FOR TESTING CLOUD ########
############################################

$myDomains = (Get-MSolDomain).name
Write-Host 
$myDomains
$domainChoice = Read-Host "choose a domain" 
[int]$numberOfShared = Read-Host "Number of RoomMailboxes" 

$i = 0
while($i -lt $numberOfShared){

$randomNumber = Get-Random -Maximum 100000
$NameOfMailbox = "CloudRoom" + $randomNumber.ToString()
$PrimarySMTP = $NameOfMailbox + '@' + $domainChoice

New-Mailbox -Name $NameOfMailbox -DisplayName $NameOfMailbox -Alias $NameOfMailbox -PrimarySmtpAddress $PrimarySMTP  -Room
$NameOfMailbox
$PrimarySMTP 
Set-Mailbox $NameOfMailbox -CustomAttribute1 "DL"

$i++

}
