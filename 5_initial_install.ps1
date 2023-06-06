########################################
########INITIAL INSTALL ###########
#####################################

function prepare_local_admin{

secedit /export /cfg c:\secpol.cfg
(gc C:\secpol.cfg).replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File C:\secpol.cfg
secedit /configure /db c:\windows\security\local.sdb /cfg c:\secpol.cfg /areas SECURITYPOLICY
rm -force c:\secpol.cfg -confirm:$false

gpupdate /force

$Password = ConvertTo-SecureString "1" -AsPlainText -Force
$UserAccount = Get-LocalUser -Name "Administrator"
$UserAccount | Set-LocalUser -Password $Password

### Set-TimeZone ###

Set-TimeZone -Id "FLE Standard Time"

### Rename-computer ###

$old_computer_name = $env:computername
$computer_name = Read-Host "Enter the new computer name"

Rename-computer -ComputerName $old_computer_name -NewName $computer_name
}

function Disable-IEESC {
$AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
$UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0
Stop-Process -Name Explorer
Write-Host "IE Enhanced Security Configuration (ESC) has been disabled." -ForegroundColor Green
### Disable Firewall with PS ###
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
Set-MpPreference -DisableRealtimeMonitoring $true

#isntall CHROME
$LocalTempDir = $env:TEMP; $ChromeInstaller = "ChromeInstaller.exe";
(new-object    System.Net.WebClient).DownloadFile('http://dl.google.com/chrome/install/375.126/chrome_installer.exe', "$LocalTempDir\$ChromeInstaller");
& "$LocalTempDir\$ChromeInstaller" /silent /install; 
$Process2Monitor =  "ChromeInstaller"; Do { $ProcessesFound = Get-Process | ?{$Process2Monitor -contains $_.Name} | Select-Object -ExpandProperty Name; 
If ($ProcessesFound) { "Still running: $($ProcessesFound -join ', ')" | Write-Host; Start-Sleep -Seconds 2 } 
else { rm "$LocalTempDir\$ChromeInstaller" -ErrorAction SilentlyContinue -Verbose } } Until (!$ProcessesFound)

$SourceFilePath = "%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe"
$ShortcutPath = "$($env:USERPROFILE)\Desktop\PowerShell.lnk"
$WScriptObj = New-Object -ComObject ("WScript.Shell")
$shortcut = $WscriptObj.CreateShortcut($ShortcutPath)
$shortcut.TargetPath = $SourceFilePath
$shortcut.Save()

Push-Location
    Set-Location HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced
    Set-ItemProperty . HideFileExt "0"
    Pop-Location
    Stop-Process -processName: Explorer -force # This will restart the Explorer service to make this work.

#Activate Hidden Files
$Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$Value = 1
Set-ItemProperty -Path $Path -Name Hidden -Value $Value
$Shell = New-Object -ComObject Shell.Application
$Shell.Windows() | ForEach-Object { $_.Refresh() }

}

function prepare_admin_account{
$id = (Get-ADDomain).DistinguishedName
Set-ADDefaultDomainPasswordPolicy `
-Identity $id `
-ComplexityEnabled $False `
-MinPasswordLength 1 `
-PasswordHistoryCount 0 `
-MinPasswordAge 00.00:00:00 `
-MaxPasswordAge 00.00:00:00

gpupdate /force

$NewPwd = ConvertTo-SecureString "1" -AsPlainText -Force
Set-ADAccountPassword -Identity Administrator -NewPassword $NewPwd -Reset
}

