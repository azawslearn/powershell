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

$val = [int](Read-Host "Enter number of DLs")
$count_of_dls = 0
$name_of_dls = Read-Host "Name of DLs"

while($count_of_dls -ne $val)

{
    $count_of_dls++
    
    $created_dl = $name_of_dls + $count_of_dls.ToString()

    $upn_suffix = $created_dl +  $suffix
   

    New-DistributionGroup `
        -Name $created_dl `
        -OrganizationalUnit "DLs" `
        -PrimarySmtpAddress $upn_suffix `
	-type "Distribution"

         Write-Host $created_dl "created"
}
