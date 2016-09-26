#Imports required modules
Import-Module ActiveDirectory

#Sets some locations and gets some handy info from AD
$today = Get-Date
$cutoffdate = $today.AddDays(-10)
$Serverlist = Get-ADComputer -Filter {(Operatingsystem -Like "Windows Server*") -And (Enabled -eq "True") -And (LastLogonDate -gt $cutoffdate)} | foreach { $_.Name }

foreach ($server in $Serverlist){
$updatesession =  [activator]::CreateInstance([type]::GetTypeFromProgID("Microsoft.Update.Session",$server))  
$updatesearcher = $updatesession.CreateUpdateSearcher()  
$searchresult = $updatesearcher.Search("IsInstalled=0")  
Write-Output "$((Get-Date).ToShortTimeString()): PATCHING MESSAGE - There are $($searchresult.Updates.count) updates via WSUS to be processed on $($server)"  
}