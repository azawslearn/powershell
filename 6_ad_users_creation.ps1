#####Create multiple users in AD for testing####

$ou_name = "syncedO365"
$ou_path = "DC=b,DC=dns-cloud,DC=LOCAL"
$ou_full_path = "OU=$ou_name," + $ou_path

# Get the ADForest suffixes in a PowerShell array
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
