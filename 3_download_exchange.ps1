#to fine the link we clik on manual download.
$url = "https://download.microsoft.com/download/0/b/7/0b702b8b-03ab-4553-9e2c-c73bb0c8535f/ExchangeServer2016-x64-CU20.ISO"
$output = "C:\Users\Ivan\Desktop\exo\ex.iso"
$start_time = Get-Date

Import-Module BitsTransfer

Start-BitsTransfer -Source $url -Destination $output

Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
