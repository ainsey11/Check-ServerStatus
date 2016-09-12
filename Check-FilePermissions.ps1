$dbservername = "PC01390"
$databasename = "FilePermissions"
$timestamp = Get-Date
$RootPath = "D:\Documents"

#MAGICAAAL SQL VOOODDOOOOO YO
$SqlConnection = New-Object System.Data.SqlClient.SQLConnection
#Connection String
$SqlConnection.ConnectionString = "Server=$dbservername;Database=$databasename;Integrated Security=SSPI;"
$ConnectionString = "Server=$dbservername;Database=$databasename;Integrated Security=SSPI;"
#Insert Statement to be pushed into the database
$insertstatement = "INSERT INTO permissions(Folderpath,Identityreference,AccessControlType,Isinherited,Inheritanceflags,PropagationFlags,timestamp)
                    VALUES ('$($folder.FullName)','$($ACL.IdentityReference)','$($ACL.AccessControlType)','$($ACL.IsInherited)','$($ACL.InheritanceFlags)','$($ACL.PropagationFlags)','$($timestamp)')"


$Folders = dir $RootPath\*\*\*\ | where {$_.psiscontainer -eq $true}

foreach ($Folder in $Folders){
    $ACLs = get-acl $Folder.fullname | ForEach-Object { $_.Access  }
    Foreach ($ACL in $ACLs){
    #MAGICAAAL SQL VOOODDOOOOO YO
    $SqlConnection = New-Object System.Data.SqlClient.SQLConnection
    #Connection String
    $SqlConnection.ConnectionString = "Server=$dbservername;Database=$databasename;Integrated Security=SSPI;"
    $ConnectionString = "Server=$dbservername;Database=$databasename;Integrated Security=SSPI;"
    #Insert Statement to be pushed into the database
    $insertstatement = "INSERT INTO permissions(Folderpath,Identityreference,AccessControlType,Isinherited,Inheritanceflags,PropagationFlags,timestamp)
                    VALUES ('$($folder.FullName)','$($ACL.IdentityReference)','$($ACL.AccessControlType)','$($ACL.IsInherited)','$($ACL.InheritanceFlags)','$($ACL.PropagationFlags)','$($timestamp)')"
     # Opens Connection, Pushes the data then closes the connection to keep it tidy
    $SqlConnection.Open()
    $SqlCmd = New-Object "System.Data.SqlClient.SqlCommand" ($insertstatement,$SqlConnection)
    $SqlCmd.ExecuteNonQuery()
    $SqlConnection.Close()
    # Have a little nap sql, you worked hard today.
    Start-Sleep 1
    }}