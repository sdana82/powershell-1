Clear-Host

#############################
#  Variables to be changed  #
#############################
$installerDir = ""

# Local admin user creation info
$userName = ""
$userFullName = ""
$userDescription = ""
$Password = ConvertTo-SecureString "" -AsPlainText -Force
$checkForUser = (Get-LocalUser).Name -contains $userName
$checkLocalAdminGroup = (Get-LocalGroupMember -Group Administrators).Name -contains $env:COMPUTERNAME + "\" + $userName
$checkLocalUserGroup = (Get-LocalGroupMember -Group Users).Name -contains  $env:COMPUTERNAME + "\" + $userName

# Start menu items
$configStartPins = '{ "pinnedList": [ {"desktopAppId":"Microsoft.Windows.Explorer"},{"desktopAppId":"Microsoft.Windows.ControlPanel"},{"packagedAppId":"Microsoft.WindowsTerminal_8wekyb3d8bbwe!App"},{"desktopAppId":"Microsoft.Windows.Shell.RunDialog"}, {"packagedAppId":"windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel"} ] }'
$configStartPins_ProviderSet = 1
$configStartPins_WinningProvider = "B5292708-1619-419B-9923-E5D9F3925E71"


if ($checkForUser -eq $false) {
    Write-Host "$userName does not exist"
    Write-Host "Creating User $userName"
    New-LocalUser -Name $userName -FullName $userFullName -Description $userDescription -Password $Password -PasswordNeverExpires:$true -UserMayNotChangePassword:$true
    Add-LocalGroupMember -Group Administrators $userName
    net user $userName /Passwordreq:yes
} ElseIf ($checkForUser -eq $true) {
    Write-Host "$userName exists"
    Write-Host "Making corrections as needed"

    #############################
    #  Variables to be changed  #
    #############################
        $isUserActive = (Get-LocalUser $userName).Enabled

    if ($isUserActive -eq $false) {
        Enable-LocalUser -Name $userName 
    }
    Set-LocalUser -Name $userName -FullName $fullName -Description $userDescription -Password $Password -PasswordNeverExpires:$true -UserMayChangePassword:$false
    if ($checkLocalAdminGroup -eq $false) {
        Add-LocalGroupMember -Group "Administrators" $userName
    }
    if ($checkLocalUserGroup -eq $true) {
        Remove-LocalGroupMember -Group "Users" -Member $userName
    }
}

# Set Time Zone
$currentTimeZone = Get-TimeZone
If($currentTimeZone.Id -ne "Hawaiian Standard Time") {
    Set-TimeZone "Hawaiian Standard Time"
    Write-Host "Time zone has been set to HST"
}

# Create the CT-Installers dir
If(!(Test-Path $installerDir)) {
    New-Item -ItemType directory -Path $installerDir | Out-Null
    Write-Host "CT-Installers directory has been created"
}

# Configure start menu items
New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\" -Name Start -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Start" -Name "ConfigureStartPins" -Value $configStartPins -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Start" -Name "ConfigureStartPins_ProviderSet" -Value 1 -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\current\device\Start" -Name "ConfigureStartPins_WinningProvider" -Value "B5292708-1619-419B-9923-E5D9F3925E71" -Force | Out-Null

New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\providers\" -Name "B5292708-1619-419B-9923-E5D9F3925E71" -Force | Out-Null
New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\providers\B5292708-1619-419B-9923-E5D9F3925E71\" -Name "default" -Force | Out-Null
New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\providers\B5292708-1619-419B-9923-E5D9F3925E71\default\" -Name "Device" -Force | Out-Null
New-Item -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\providers\B5292708-1619-419B-9923-E5D9F3925E71\default\Device\" -Name "Start" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\providers\B5292708-1619-419B-9923-E5D9F3925E71\default\Device\Start" -Name ConfigureStartPins -Value $configStartPins -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\providers\B5292708-1619-419B-9923-E5D9F3925E71\default\Device\Start" -Name ConfigureStartPins_LastWrite -Value 1 -Force | Out-Null

# Disable Firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile" -Name DisableNotifications -Value 1 -Force | Out-Null
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\PublicProfile" -Name DisableNotifications -Value 1 -Force | Out-Null
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\StandardProfile" -Name DisableNotifications -Value 1 -Force | Out-Null

# Disable Automatic Device Installation
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" -Name “PreventDeviceMetadataFromNetwork” -Value 1 | Out-Null

# Disable first logon animation
New-ItemProperty -Path "HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name EnableFirstLogonAnimation -Value 0 -PropertyType DWORD -Force | Out-Null

# Disable Windows Conusmer Features
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows" -Name CloudContent -Force | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name DisableSoftLanding -Value 1 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name DisableWindowsConsumerFeatures -Value 1 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name SubscribedContent-338389Enabled -Value 0 -PropertyType DWORD -Force | Out-Null

# Disable Don't launch privacy settings experience on user logon
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows" -Name "OOBE" -Force | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE" -Name "DisablePrivacyExperience" -Value 1 -PropertyType DWORD -Force | Out-Null

# Enable Remote Desktop
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' -Value 0 -Force | Out-Null
# Disable NLA
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name 'UserAuthentication' -Value 0 -Force | Out-Null
# Set Firewall Rule to allow RDP access
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Power Settings
## Disable Hibernate
powercfg -h off
Powercfg /Change standby-timeout-ac 0
Powercfg /Change standby-timeout-dc 0
## Disable fast start
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power\" -Name "HiberbootEnabled" -Value 0 -Force
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
powercfg /SETDCVALUEINDEX SCHEME_CURRENT 7516b95f-f776-4464-8c53-06167f40cc99 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e 600
## Plugged in
powercfg /SETACVALUEINDEX SCHEME_CURRENT 7516b95f-f776-4464-8c53-06167f40cc99 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e 1200

<# Remove Setup Files
Remove-Item $MyInvocation.InvocationName
Write-Host "File has self destructed." -fore green
#>
