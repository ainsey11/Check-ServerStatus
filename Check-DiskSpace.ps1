Import-Module ActiveDirectory
$serverlistlocation = "C:\Scripting\Logs\serverlist.txt"
$Serverlist = Get-ADComputer -Filter {(Operatingsystem -Like "Windows Server*") -And (Enabled -eq "True")} | foreach { $_.Name } | Out-File $serverlistlocation

function DriveSpace-StandardServer {

param( [string] $strComputer) 

$dbservername = "10.159.100.104"
$databasename = "ThingsGoingOnTest1"


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
       $timestamp = Get-Date

    $SqlConnection = New-Object System.Data.SqlClient.SQLConnection
    $SqlConnection.ConnectionString = "Server=$dbservername;Database=$databasename;Integrated Security=SSPI;"
    $ConnectionString = "Server=$dbservername;Database=$databasename;Integrated Security=SSPI;"
    $insertstatement = "INSERT INTO Disk_space(SpaceFree,DriveLetter,Warning_State,Error_State,Servername,timestamp)
                        VALUES ('$($PercentFree)','$($Drive)','$($Warning_State)','$($Error_State)','$($strComputer)','$($timestamp)')"
    $SqlConnection.Open()
    $SqlCmd = New-Object "System.Data.SqlClient.SqlCommand" ($insertstatement,$SqlConnection)
    $SqlCmd.ExecuteNonQuery()
    $SqlConnection.Close()
    Start-Sleep 2

    }
    foreach ($computer in cat $serverlistlocation) {DriveSpace-StandardServer "$computer"}
}
}

foreach ($computer in cat $serverlistlocation) {DriveSpace-StandardServer "$computer"}