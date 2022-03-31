$AppsList = "26720RandomSaladGamesLLC.SimpleMahjong",
"26720RandomSaladGamesLLC.SimpleSolitaire",
"5A894077.McAfeeSecurity",
"7EE7776C.LinkedInforWindows",
"828B5831.HiddenCityMysteryofShadows",
"AD2F1837.myHP",
"AD2F1837.OMENCommandCenter",
"A278AB0D.DisneyMagicKingdoms",
"A278AB0D.MarchofEmpires",
"4DF9E0F8.Netflix",
"C27EB4BA.DropboxOEM",
"57540AMZNMobileLLC.AmazonAlexa",
"Amazon.com.Amazon",
"DolbyLaboratories.DolbyAccess",
"flaregamesGmbH.RoyalRevolt2",
"king.com.BubbleWitch3Saga",
"king.com.CandyCrushSaga",
"king.com.CandyCrushSodaSaga",
"king.com.CandyCrushFriends",
"king.com.FarmHeroesSaga",
"Micorsoft.Advertising.Xaml",
"Microsoft.BingFinance",
"Microsoft.BingNews",
"Microsoft.BingSports",
"Microsoft.BingWeather",
"Microsoft.CommsPhone",
"Microsoft.Messaging",
"Microsoft.MicrosoftOfficeHub",
"Microsoft.MicrosoftSolitaireCollection",
"Microsoft.OneConnect_5.1807.1991.0_x64__8wekyb3d8bbwe",
"Microsoft.People",
"Microsoft.SkypeApp",
"Microsoft.WindowsCommunicationsApps",
"Microsoft.WindowsPhone",
"Microsoft.XboxApp",
"Microsoft.ZuneMusic",
"Microsoft.ZuneVideo",
"PricelinePartnerNetwork.Booking.comUSABigsavingson",
"SpotifyAB.SpotifyMusic",
"NORDCURRENT.COOKINGFEVER",
"DellInc.DellSupportAssistforPCs"
    
ForEach ($App in $AppsList)
{
	$Packages = Get-AppxPackage | Where-Object {$_.Name -eq $App}
	if ($Packages -ne $null)
	{
		Write-Host "Removing Appx Package: $App" -Fore White
		foreach ($Package in $Packages) { Remove-AppxPackage -package $Package.PackageFullName }
	}
	else { Write-Host "Unable to find package: $App" -fore DarkGray }

	$AllUsersPackage = Get-AppxPackage -AllUsers | Where-Object {$_.Name -eq $App}
	if ($AllUsersPackage -ne $null)
	{
		Write-Host "Removing Appx Provisioned Package All Users: $App" -fore White
		remove-AppxPackage -AllUsers $AllUsersPackage
	}
	else { Write-Host "Unable to find All Users package: $App" -Fore DarkGray }
    	
    $ProvisionedOnlinePackage = Get-AppxProvisionedPackage -online | Where-Object {$_.displayName -eq $App}
	if ($ProvisionedOnlinePackage -ne $null)
	{
		Write-Host "Removing Appx Provisioned Package Online: $App" -fore White
		remove-AppxProvisionedPackage -online -packagename $ProvisionedOnlinePackage.PackageName
	}
	else { Write-Host "Unable to find provisioned online package: $App" -Fore DarkGray }
}

$dir = "C:\CT-Installers"
If(!(Test-Path $dir))
{
    New-Item -ItemType directory -Path $dir
}

# Remove-Item $MyINvocation.InvocationName
# Write-Host "File has been deleted." -fore green