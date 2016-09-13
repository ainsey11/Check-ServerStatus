
#Setting up variables, kinda obvious tbh
$dbservername = "PC01390" #yeah, you got it kiddo?
$databasename = "FilePermissions" #Kinda obvious what this one does
$timestamp = Get-Date #For the SQL timestamp column, handy when doing select statements
$RootPath = "D:\" #The folder you want to scan for permissions. Note that it only does the top 4 folders, if you want more, add another wildcard on line 20

$Folders = dir $RootPath\*\*\*\*\*\ | where {$_.psiscontainer -eq $true} #Creates list of folders to get ACL's for

foreach ($Folder in $Folders){
    $ACLs = get-acl $Folder.fullname | ForEach-Object { $_.Access  }
    Foreach ($ACL in $ACLs){

    #MAGICAAAL SQL VOOODDOOOOO YO
    $SqlConnection = New-Object System.Data.SqlClient.SQLConnection

    #Connection String
    $SqlConnection.ConnectionString = "Server=$dbservername;Database=$databasename;Integrated Security=SSPI;"
    
    #Insert Statement to be pushed into the database
    $insertstatement = "INSERT INTO permissions(Folderpath,Identityreference,AccessControlType,Isinherited,Inheritanceflags,PropagationFlags,timestamp)
                    VALUES ('$($folder.FullName)','$($ACL.IdentityReference)','$($ACL.AccessControlType)','$($ACL.IsInherited)','$($ACL.InheritanceFlags)','$($ACL.PropagationFlags)','$($timestamp)')"
     # Opens Connection, Pushes the data then closes the connection to keep it tidy
    $SqlConnection.Open()
    $SqlCmd = New-Object "System.Data.SqlClient.SqlCommand" ($insertstatement,$SqlConnection)
    $SqlCmd.ExecuteNonQuery()
    $SqlConnection.Close()
    }}