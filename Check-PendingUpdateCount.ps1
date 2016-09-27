#Imports required modules
Import-Module ActiveDirectory
$dbservername = "PC00934"
$databasename = "ThingsGoingOnTest1"
$timestamp = Get-Date

#Sets some locations and gets some handy info from AD
$today = Get-Date
$cutoffdate = $today.AddDays(-10)
$Serverlist = Get-ADComputer -Filter {(Operatingsystem -Like "Windows Server*") -And (Enabled -eq "True") -And (LastLogonDate -gt $cutoffdate)} | foreach { $_.Name }

foreach ($server in $Serverlist){
$updatesession =  [activator]::CreateInstance([type]::GetTypeFromProgID("Microsoft.Update.Session",$server))  
$updatesearcher = $updatesession.CreateUpdateSearcher()  
$searchresult = $updatesearcher.Search("IsInstalled=0")  
Write-Output "$((Get-Date).ToShortTimeString()): PATCHING MESSAGE - There are $($searchresult.Updates.count) updates via WSUS to be processed on $($server)"  
    #MAGICAAAL SQL VOOODDOOOOO YO
    $SqlConnection = New-Object System.Data.SqlClient.SQLConnection
    #Connection String
    $SqlConnection.ConnectionString = "Server=$dbservername;Database=$databasename;Integrated Security=SSPI;"
    $ConnectionString = "Server=$dbservername;Database=$databasename;Integrated Security=SSPI;"
    #Insert Statement to be pushed into the database
    $insertstatement = "INSERT INTO windows_updates(servername,updatescount,timestamp)
                        VALUES ('$($server)','$($searchresult.Updates.count)','$($timestamp)')"
    # Opens Connection, Pushes the data then closes the connection to keep it tidy
    $SqlConnection.Open()
    $SqlCmd = New-Object "System.Data.SqlClient.SqlCommand" ($insertstatement,$SqlConnection)
    $SqlCmd.ExecuteNonQuery()
    $SqlConnection.Close()

}