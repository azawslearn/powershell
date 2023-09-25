########################################
########INITIAL INSTALL ###########
#####################################

### Set-TimeZone ###

Set-TimeZone -Id "FLE Standard Time"

### Disable Firewall and Andti-Virus ###


$AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
$UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0
Stop-Process -Name Explorer
Write-Host "IE Enhanced Security Configuration (ESC) has been disabled." -ForegroundColor Green
### Disable Firewall with PS ###
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
Set-MpPreference -DisableRealtimeMonitoring $true

### isntall CHROME ###

$LocalTempDir = $env:TEMP; $ChromeInstaller = "ChromeInstaller.exe";
(new-object    System.Net.WebClient).DownloadFile('http://dl.google.com/chrome/install/375.126/chrome_installer.exe', "$LocalTempDir\$ChromeInstaller");
& "$LocalTempDir\$ChromeInstaller" /silent /install; 
$Process2Monitor =  "ChromeInstaller"; Do { $ProcessesFound = Get-Process | ?{$Process2Monitor -contains $_.Name} | Select-Object -ExpandProperty Name; 
If ($ProcessesFound) { "Still running: $($ProcessesFound -join ', ')" | Write-Host; Start-Sleep -Seconds 2 } 
else { rm "$LocalTempDir\$ChromeInstaller" -ErrorAction SilentlyContinue -Verbose } } Until (!$ProcessesFound)

### Activate file extentions ###

Push-Location
Set-Location HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
Set-ItemProperty . HideFileExt "0"
Pop-Location
Stop-Process -processName: Explorer -force # This will restart the Explorer service to make this work.

##################################
###  SQL SPECIFIC INSTALL   ######
##################################


### Creteing a new folder ###
New-Item -Path "C:\" -Name "SQLInstall" -ItemType Directory

#Crete shared folder
New-SmbShare -Name "SQLInstall" -Path "C:\SQLInstall" -FullAccess "Everyone"
icacls "C:\SQLInstall" /grant Everyone:F

### DOWNLOAD THE SCRIPT THAT SHOULD INSTALL SQL ### 
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/majkinetor/Install-SqlServer/master/Install-SqlServer.ps1" -OutFile "C:\SQLInstall\Install-SqlServer.ps1"


## Download the SQL ISO from GoogleDrive ##

$WebClient = New-Object System.Net.WebClient
$Url = "https://drive.google.com/uc?export=download&id=1vCjfcDnPL0wIweOAwtj93XYbvdAJpoVe&confirm=t"
$WebClient.DownloadFile($Url, "C:\SQLInstall\SQLISO.iso")

### INSTALL SQL ####
cd "C:\SQLInstall"
.\Install-SqlServer.ps1 -ISOPath "C:\SQLInstall\SQLISO.iso"
#.\Install-SqlServer.ps1 -ISOPath "C:\SQLInstall\SQLISO.iso" -SystemAdminAccounts @("nadal\\dcadmin")


### Install the MANAGEMENT STUDIO #####
# Set file and folder path for SSMS installer .exe
$folderpath="c:\windows\temp"
$filepath="$folderpath\SSMS-Setup-ENU.exe"
 
#If SSMS not present, download
if (!(Test-Path $filepath)){
write-host "Downloading SQL Server 2016 SSMS..."
$URL = "https://aka.ms/ssmsfullsetup"
$clnt = New-Object System.Net.WebClient
$clnt.DownloadFile($url,$filepath)
Write-Host "SSMS installer download complete" -ForegroundColor Green
}
# start the SSMS installer
write-host "Beginning SSMS 2016 install..." -nonewline
$Parms = " /Install /Quiet /Norestart /Logs log.txt"
$Prms = $Parms.Split(" ")
& "$filepath" $Prms | Out-Null
Write-Host "SSMS installation complete" -ForegroundColor Green
