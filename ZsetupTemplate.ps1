$parentScriptName = $MyInvocation.InvocationName
##############################################
#     Set the $registredOwners Variable      #
##############################################
$registeredOwners = ""

New-Item -Path "HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "RegisteredOwner" -Force | Out-Null
New-ItemProperty -Path "HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name RegisteredOwner -Value $registeredOwners -PropertyType STRING -Force | Out-Null
New-Item -Path "HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name "RegisteredOrganization" -Force | Out-Null
New-ItemProperty -Path "HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name RegisteredOrganization -Value $registeredOwners -PropertyType STRING -Force | Out-Null

# ##################################################### #
# Place company specific items below this comment Block #
# ##################################################### #

.\installByList.ps1