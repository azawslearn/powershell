$resourceGroupName = "mysqlrg"
$serverName = "myservermysqlforapp"
$location = "westeurope"
$adminUser = "mysqluser"
$adminPassword = "EmersonFitipaldi1!"
$databaseName = "my_aad_users"

az mysql flexible-server create --location $location --resource-group $resourceGroupName  `
  --name $serverName --admin-user $adminUser --admin-password $adminPassword `
  --sku-name Standard_B1ms --public-access 0.0.0.0 --database-name $databaseName


az mysql flexible-server firewall-rule create --resource-group $resourceGroupName --name $serverName --rule-name allowip --start-ip-address 178.169.173.58