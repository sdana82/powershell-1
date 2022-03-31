$installerList_noSwiches = "\biosConfigs\multiplatform_202009040720_x64.exe";

forEach ($installPackage in $installerList_noSwiches)
    {
    $installPath_noSwitches = $PSScriptRoot + $installPackage
    Write-host Configuring BIOS
    Start-Process -FilePath $installPath_noSwitches -Wait
    }

Write-Host Installing .NET 3.5
Dism /online /Enable-Feature /FeatureName:"NetFx3" /NoRestart

# Applicaion install command array
$acrbatReaderInstallerPath = "/i " + $PSScriptRoot + "\acrobatReader\AcroRead.msi /qn EULA_ACCEPT=YES /norestart"
$chromeInstaller = "/i " + $PSScriptRoot + "\Chrome\GoogleChromeStandaloneEnterprise.msi /qn"
$fireFoxInstaller = '/i "' + $PSScriptRoot + '\FireFox\Firefox Setup 92.0.msi" TASKBAR_SHORTCUT=false DESKTOP_SHORTCUT=false /quiet'
$goToMeetingInstaller = "/i " + $PSScriptRoot + "\GoToMeeting\G2MSetup10.17.19796_IT.msi G2MINSTALLFORALLUSERS=1 G2MRUNATLOGON=false /quiet"
$zoomInstaller = "/i " + $PSScriptRoot + '\zoom\ZoomInstallerFull.msi /quiet /qn /norestart ZoomAutoUpdate="true"'
$openJavaJDK = "/i" + $PSScriptRoot + '\openJava\bellsoft-jdk17.0.2+9-windows-amd64.msi /quiet /qn /norestart'

# Applicaion install array
$installerList = (
    ("Acrobat Reader","$env:SystemRoot\system32\msiexec.exe","$acrbatReaderInstallerPath","msi"),
    ("FireFox","$env:SystemRoot\system32\msiexec.exe","$fireFoxInstaller","msi"),
    ("Chrome","$env:SystemRoot\system32\msiexec.exe","$chromeInstaller","msi"),
    ("Go To Meeting","$env:SystemRoot\system32\msiexec.exe","$goToMeetingInstaller","msi"),
    ("Java x64",".\java\jre-8u321-windows-x64.exe","/s",""),
    ("java x86",".\java\jre-8u321-windows-i586.exe","/s",""),
    ("openJavaJDK","$env:SystemRoot\system32\msiexec.exe","$openJavaJDK","msi"),
    ("Teams",".\msTeams\Teams_windows_x64.exe", "-s",""),
    ("Zoom","$env:SystemRoot\system32\msiexec.exe","$zoomInstaller","msi")
    );

# Install loop
 forEach ($installer in $installerList)
     {
     if ($installer[3] -eq "msi")
        {
        $installPath = $installer[1]
        } Else {
        $installPath = $PSScriptRoot + $installer[1]
        }
     Write-Host Installing $installer[0]
     Start-Process -FilePath $installPath -ArgumentList $installer[2] -Wait
     }

# Uninstall office Frence and Spanish
$preinstalledOfficePath = "C:\Program Files\Common Files\Microsoft Shared\ClickToRun\OfficeClickToRun.exe"
if (Test-Path $preinstalledOfficePath) {
$uninstallList = (
    ("Office French","C:\Program Files\Common Files\Microsoft Shared\ClickToRun\OfficeClickToRun.exe","scenario=install scenariosubtype=ARP sourcetype=None productstoremove=O365HomePremRetail.16_fr-fr_x-none culture=fr-fr version.16=16.0 displaylevel=false"),
    ("Office Spanish","C:\Program Files\Common Files\Microsoft Shared\ClickToRun\OfficeClickToRun.exe", "scenario=install scenariosubtype=ARP sourcetype=None productstoremove=O365HomePremRetail.16_es-es_x-none culture=es-es version.16=16.0 displaylevel=false")
);

    forEach ($uninstaller in $uninstallList) {
    Write-host Uninstalling $uninstaller[0]
    Start-Process -FilePath $uninstaller[1] -ArgumentList $uninstaller[2] -Wait -ErrorAction SilentlyContinue
    }
}

$currentVersionInfo = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\'
$installedBuildVer = $currentVersionInfo.CurrentBuildNumber
$currentBuildVer = "19044"

$versionNameArray = (
    ("17134","1803"),
    ("17763","1809"),
    ("18362","19H1"),
    ("18363","19H2"),
    ("19041","20H1"),
    ("19042","20H2"),
    ("19043","21H1"),
    ("19044","21H2"),
    ("22000","22H1")
    );

if ($installedBuildVer -le $currentBuildVer) {
    Write-Host Setting Computer Preferences
    .\Win10\setCustomizationsComputer.ps1

    Write-Host Uninstalling Bloat
    .\Win10\uninstallBloat.ps1
} else {
    Write-Host Setting Computer Preferences
    .\Win11\setCustomizationsComputer.ps1

    Write-Host Uninstalling Bloat
    .\Win11\uninstallBloat.ps1
}

# Install the latest Microsof Feature Update
if (!($parentScriptName -eq ".\setupPACT.ps1")) {
    .\installFeatureUpdate-iso.ps1
}