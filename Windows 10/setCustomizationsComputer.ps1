$xmlStartMenuFile = $PSScriptRoot + "\setCustomizationsComputer.xml"
Clear-Host

$ErrorActionPreference = 'Stop'
$VerbosePreference = 'Continue'
$userName = "ctadmin"
$objLocalAdminAccount = $null
$Password = ConvertTo-SecureString "L@m38!rd" -asplaintext -force

Try {
    Write-Verbose "Searching for $($USERNAME) in LocalUser DataBase"
    $ObjLocalUser = Get-LocalUser $USERNAME
    Write-Verbose "User $($USERNAME) was found"
    Write-Host "Updating profile information" -ForegroundColor Cyan
    Set-LocalUser -name "ctadmin" -FullName "Cetra Administrator" -Description "Cetra Technology administrative account." -Password $Password -PasswordNeverExpires:$true -UserMayNotChangePassword:$true
    net user ctadmin /passwordreq:yes
}

Catch [Microsoft.PowerShell.Commands.UserNotFoundException] {
    "User $($USERNAME) was not found"
    Write-Host Creating the Cetra Administrator account
    New-LocalUser -Name "ctadmin" -FullName "Cetra Administrator" -Description "Cetra Technology administrative account." -Password $Password -PasswordNeverExpires:$true -UserMayNotChangePassword:$true
    Add-LocalGroupMember -Group Administrators ctadmin
    net user ctadmin /Passwordreq:yes
}

Catch {
    Write-Verbose "An unspecifed error occured" | Write-Error
   # Exit # Stop Powershell! 
}

# Local Computer Policy
# Remove Search from Taskbar
New-Item -Path HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows -Name "Windows Search" -Force | Out-Null
New-ItemProperty -Path "HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name AllowCortana -Value 0 -Type DWORD -Force | Out-Null

# Disable Privacy Consent Screent
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\OOBE" -Name DisablePrivacyExperience -Value 1 -PropertyType DWORD -Force | Out-Null

# Disable Windows Conusmer Features
New-Item -Path HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows -Name CloudContent -Force
New-ItemProperty -Path HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\CloudContent -Name DisableSoftLanding -Value 1 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\CloudContent -Name DisableWindowsConsumerFeatures -Value 1 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\CloudContent -Name SubscribedContent-338389Enabled -Value 0 -PropertyType DWORD -Force | Out-Null

# Disable first logon animation
New-ItemProperty -Path HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name EnableFirstLogonAnimation -Value 0 -PropertyType DWORD -Force | Out-Null

# Disable Start Menu Suggestions
New-ItemProperty -Path HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer -Name AllowOnlineTips -Value 0 -PropertyType DWORD -Force | Out-Null

# Disable automatic device installation
New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" -Name PreventDeviceMetadataFromNetwork -Value 1 -PropertyType DWORD -Force | Out-Null

# Disable News & Interests on Taskbar
New-Item -Path "HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows" -Name "Windows Feeds" -Force | Out-Null
New-ItemProperty -Path "HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" -Name EnableFeeds -Value 0 -PropertyType DWORD -Force | Out-Null

# Disable Backup notifications
New-ItemProperty -Path "HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsBackup" -Name DisableMonitoring -Value 1 -PropertyType DWORD -Force | Out-Null

# Enable Remote Desktop
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\" -Name “fDenyTSConnections” -Value 0 -Force | Out-Null
# Disable NLA
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"  -Name “UserAuthentication” -Value 0 -Force | Out-Null
# Set Firewall Rule to allow RDP access
Enable-NetFirewallRule -DisplayGroup “Remote Desktop”

# Power Settings
## Disable Hibernate
powercfg -h off
Powercfg /Change standby-timeout-ac 0
Powercfg /Change standby-timeout-dc 0
## Disable fast boot
Set-ItemProperty -Path "HKLM:\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Power\" -Name "HiberbootEnabled" -Value 0 -Force | Out-Null
## Turn off HDD
### On Battery 
powercfg /SETDCVALUEINDEX SCHEME_CURRENT 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 0
### Plugged in
powercfg /SETACVALUEINDEX SCHEME_CURRENT 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 0

## Set Close Lid action to Do Nothing
### On Battery
powercfg /SETDCVALUEINDEX SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0
### Plugged in
powercfg /SETACVALUEINDEX SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0

## Set Power Button action to Shut down
### On Battery
powercfg /SETDCVALUEINDEX SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 7648efa3-dd9c-4e3e-b566-50f929386280 3
### Plugged in
powercfg /SETACVALUEINDEX SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 7648efa3-dd9c-4e3e-b566-50f929386280 3

## Set Sleep Button Action to do nothing
### On Battery
powercfg /SETDCVALUEINDEX SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 96996bc0-ad50-47ec-923b-6f41874dd9eb 0
### Plugged in
powercfg /SETACVALUEINDEX SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 96996bc0-ad50-47ec-923b-6f41874dd9eb 0

## Turn off display after
## On Battery
powercfg /SETDCVALUEINDEX SCHEME_CURRENT 7516b95f-f776-4464-8c53-06167f40cc99 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e 900
## Plugged in
powercfg /SETACVALUEINDEX SCHEME_CURRENT 7516b95f-f776-4464-8c53-06167f40cc99 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e 0


# Set the standarized start menu items
Import-StartLayout -LayoutPath $xmlStartMenuFile  -MountPath C:\

# Disable Firewalls
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
# Disable Firewall Notifications
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile" -Name DisableNotifications -Value 1 -Force | Out-Null
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\PublicProfile" -Name DisableNotifications -Value 1 -Force | Out-Null
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile" -Name DisableNotifications -Value 1 -Force | Out-Null

# Set Time Zone
$currentTimeZone = Get-TimeZone
If($currentTimeZone.Id -ne "Hawaiian Standard Time") {
    Set-TimeZone "Hawaiian Standard Time"
}

# Remove News & Intrersts from taskbr
New-Item -Path HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows -Name "Windows Feeds" -Force
New-ItemProperty -Path "HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" -Name EnableFeeds -Value 0 -PropertyType DWORD -Force | Out-Null

# Disable Automatic Device Installation
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" -Name “PreventDeviceMetadataFromNetwork” -Value 1 | Out-Null

# Create the CT-Installers dir
$dir = "C:\CT-Installers"
If(!(Test-Path $dir))
{
    New-Item -ItemType directory -Path $dir
}

# Remove the Files
Remove-Item (Get-PSReadlineOption).HistorySavePath
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Clipboard]::Clear()
Remove-Item $xmlStartMenuFile
Write-Host "XML has been deleted." -fore green
Remove-Item $MyInvocation.InvocationName
Write-Host "File has self destructed." -fore green