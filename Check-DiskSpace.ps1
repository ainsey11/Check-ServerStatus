#Imports required modules
Import-Module ActiveDirectory

#Sets some locations and gets some handy info from AD
$serverlistlocation = "C:\Scripting\Logs\serverlist.txt"
$Serverlist = Get-ADComputer -Filter {(Operatingsystem -Like "Windows Server*") -And (Enabled -eq "True")} | foreach { $_.Name } | Out-File $serverlistlocation

#The function itself
function DriveSpace-StandardServer {

param( [string] $strComputer) 

$dbservername = "<Enter DB Server Name Here"
$databasename = "<Enter DB Name Here>"


# Does the server responds to a ping (otherwise the WMI queries will fail)

$query = "select * from win32_pingstatus where address = '$strComputer'"
$result = Get-WmiObject -query $query
if ($result.protocoladdress) {

    # Get the Disks for this computer
    $colDisks = get-wmiobject Win32_LogicalDisk -computername $strComputer -Filter "DriveType = 3"

    # For each disk calculate the free space
    foreach ($disk in $colDisks) {
       if ($disk.size -gt 0) {$PercentFree = [Math]::round((($disk.freespace/$disk.size) * 100))}
       else {$PercentFree = 0}

		$Drive = $disk.DeviceID
       "$strComputer - $Drive - $PercentFree"

       # Creates flags if following criteria is met
       if ($PercentFree -le 10){
       [int]$Warning_State = 1
       [int]$Error_State = 0}

       if ($PercentFree -le 5){
       [int]$Warning_State = 0
       [int]$Error_State = 1}

       if ($PercentFree -gt 11){
       [int]$Warning_State = 0
       [int]$Error_State = 0
       }
       #gets date for timestamp in sql so we can truncate past 30 days
       $timestamp = Get-Date
    #MAGICAAAL SQL VOOODDOOOOO YO
    $SqlConnection = New-Object System.Data.SqlClient.SQLConnection
    #Connection String
    $SqlConnection.ConnectionString = "Server=$dbservername;Database=$databasename;Integrated Security=SSPI;"
    $ConnectionString = "Server=$dbservername;Database=$databasename;Integrated Security=SSPI;"
    #Insert Statement to be pushed into the database
    $insertstatement = "INSERT INTO Disk_space(SpaceFree,DriveLetter,Warning_State,Error_State,Servername,timestamp)
                        VALUES ('$($PercentFree)','$($Drive)','$($Warning_State)','$($Error_State)','$($strComputer)','$($timestamp)')"
    # Opens Connection, Pushes the data then closes the connection to keep it tidy
    $SqlConnection.Open()
    $SqlCmd = New-Object "System.Data.SqlClient.SqlCommand" ($insertstatement,$SqlConnection)
    $SqlCmd.ExecuteNonQuery()
    $SqlConnection.Close()
    # Have a little nap sql, you worked hard today.
    Start-Sleep 2

    }
    
}
}

foreach ($computer in cat $serverlistlocation) {DriveSpace-StandardServer "$computer"
}
