#######################
####LOCAL MAILBOXES####
#######################



#looping throug the array with the index of the suffix

$my_suffixes = Get-ADForest | Select-Object -ExpandProperty UPNSuffixes

# If there is only one suffix, use it directly without looping
if ($my_suffixes.Count -eq 1) {
    $suffix = "@" + $my_suffixes
} else {
    # Loop through the array with the index of the suffix
    for ($counter=0; $counter -lt $my_suffixes.Length; $counter++){
        Write-host $counter, $my_suffixes[$counter]
    }
    # Read the input from user 
    $my_choice = [int](Read-Host "Enter the number of the domain: ")
    # Save the suffix in a variable
    $suffix = "@" + $my_suffixes[$my_choice]
}

$val = [int](Read-Host "Enter number of test users")
$count_of_users = 0
$name_of_user = Read-Host "Name of test user"
$db = (Get-MailboxDatabase).name
while($count_of_users -ne $val)

{
    $count_of_users++
    
    $created_user = $name_of_user + $count_of_users.ToString()
   
    $pwd1 = ConvertTo-SecureString "1" -AsPlainText -Force
    $upn_suffix = $created_user +  $suffix
    New-Mailbox `
        -Name $created_user `
        -Password $pwd1 `
	-UserPrincipalName $upn_suffix `
        -Database $db `
        -OrganizationalUnit ex_user
         Write-Host $created_user "created"
}
