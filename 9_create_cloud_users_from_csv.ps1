#CSV - cloud_users_license.csv

$my_skuid = (Get-MsolAccountSku).accountskuid


for ($counter=0; $counter -lt $my_skuid.Length; $counter++)
{
	Write-host $counter,$my_skuid[$counter]
	
}

$my_choice = [int](Read-Host "Enter the number of the domain: ")


#save the suffix in a variable
$choice_of_sku = $my_skuid[$my_choice]

$csv =  .{Invoke-WebRequest "https://raw.githubusercontent.com/AlenProst/csv/main/cloud_users_license.csv" -OutFile "C:\UsersTEmp\cloud_users_license.csv" 
Import-Csv -Path "C:\UsersTEmp\cloud_users_license.csv"}

function create_cloud_users_csv{
	$domain = "@fr330ff1c3.onmicrosoft.com"
	$SKU = $choice_of_sku
	
	$csv | Select-Object -Property `
	@{Name="DisplayName";Expression={$_.DisplayName}},
	@{Name="UserPrincipalName";Expression={$_.UserPrincipalName + $domain}},
	@{Name="UsageLocation";Expression={$_.UsageLocation}},
	@{Name="Password";Expression={$_.Password}} | foreach {New-MsolUser -DisplayName $_.DisplayName -UserPrincipalName $_.UserPrincipalName `
		-UsageLocation $_.UsageLocation -Password $_.Password -LicenseAssignment $SKU} 
	}

#DELETE THE CREATED USERS
function delete_cloud_created_users{
    $domain = "@fr330ff1c3.onmicrosoft.com"
    $csv | Select-Object -Property `
    @{Name="DisplayName";Expression={$_.DisplayName}},
    @{Name="UserPrincipalName";Expression={$_.UserPrincipalName + $domain}},
    @{Name="UsageLocation";Expression={$_.UsageLocation}},
    @{Name="Password";Expression={$_.Password}} | foreach {Remove-MsolUser -UserPrincipalName $_.UserPrincipalName -Force}
}
function permanently_delete_cloud_created_users{
    $domain = "@fr330ff1c3.onmicrosoft.com"
    $csv | Select-Object -Property `
    @{Name="DisplayName";Expression={$_.DisplayName}},
    @{Name="UserPrincipalName";Expression={$_.UserPrincipalName + $domain}},
    @{Name="UsageLocation";Expression={$_.UsageLocation}},
    @{Name="Password";Expression={$_.Password}} | foreach {Remove-MsolUser -UserPrincipalName $_.UserPrincipalName -RemoveFromRecycleBin -Force}
}


