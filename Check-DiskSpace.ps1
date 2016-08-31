Import-Module ActiveDirectory
$Serverlist = Get-ADComputer -Filter {(Operatingsystem -Like "Windows Server*") -And (Enabled -eq "True")}
function DriveSpace-StandardServer {

param( [string] $strComputer) 



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
       $timestamp = Get-Date #-format dd-MM-yyyy
       $sqlCommand = New-Object System.Data.SqlClient.SqlCommand
       $sqlCommand.Connection = $sqlConnection
       $Insert_stmt= "INSERT INTO Disk_space(SpaceFree,DriveLetter,Warning_State,Error_State,Servername,timestamp)
       VALUES ('$($PercentFree)','$($Drive)','$($Warning_State)','$($Error_State)','$($strComputer)','$($timestamp)')"
       $sqlCommand.CommandText = $insert_stmt
       $DBServer = "PC01390"
       $DBName = "ThingsGoingOnTest1"
       $sqlConnection = New-Object System.Data.SqlClient.SqlConnection
       $sqlConnection.ConnectionString = "Server=$DBServer;Database=$DBName;Integrated Security=True;"
       $sqlConnection.Open()
       $sqlcommand.ExecuteNonQuery()
# Quit if the SQL connection didn't open properly.
       if ($sqlConnection.State -ne [Data.ConnectionState]::Open) 
       {
        "Connection to DB is not open."
       }
       

# Close the connection.
      if ($sqlConnection.State -eq [Data.ConnectionState]::Open) 
      {
       $sqlConnection.Close()
       }


    }
}
}

DriveSpace-StandardServer "PC01390"