######################
###Users in AD#####
##################

#New-ADOrganizationalUnit -Name "syncedO365" -Path "DC=f0r3,DC=LOCAL" -ProtectedFromAccidentalDeletion $False


#CSV - local_AD.csv

$ou_name = "syncedO365"
$ou_path = "DC=n4m3,DC=LOCAL"
$ou_full_path = "OU=$ou_name," + $ou_path

New-ADOrganizationalUnit -Name $ou_name -Path $ou_path -ProtectedFromAccidentalDeletion $False

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

# Creating the password for the users
$pwd1 = ConvertTo-SecureString "1" -AsPlainText -Force

# Import the user data from CSV file
Invoke-WebRequest -Uri https://raw.githubusercontent.com/AlenProst/csv/main/local_ad.csv -OutFile 'C:\Users\Administrator\Desktop\local_ad.csv'

# Loop through each user in the CSV file and create a new AD user
Import-Csv -Path "C:\Users\Administrator\Desktop\local_ad.csv" | 
    Select-Object -Property @{
        Name="UserPrincipalName";Expression={$_.UserPrincipalName + $suffix}
    }, @{
        Name="Name";Expression={$_.DisplayName}
    }, @{
        Name="Country";Expression={$_.UsageLocation}
    } | 
    foreach {
        New-ADUser -Name $_.Name `
        -AccountPassword $pwd1 `
        -UserPrincipalName $_.UserPrincipalName `
        -Enabled $True `
        -Country $_.Country `
        -Path $ou_full_path
    }


