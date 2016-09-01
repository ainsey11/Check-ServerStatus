# Gets list of users created within the past day

#Imports required modules
Import-Module ActiveDirectory

$dbservername = "10.159.32.37"
$databasename = "ThingsGoingOnTest1"


    $When = ((Get-Date).AddDays(-30)).Date
    $Userlist = Get-ADUser -Filter {whenCreated -ge $When} -Properties whenCreated
  
    Foreach ($user in $Userlist){

    $timestamp = Get-Date
    $whencreated = $User.Whencreated | out-String
   
    
    #MAGICAAAL SQL VOOODDOOOOO YO
    $SqlConnection = New-Object System.Data.SqlClient.SQLConnection

    #Connection String
    $SqlConnection.ConnectionString = "Server=$dbservername;Database=$databasename;Integrated Security=SSPI;"
    $ConnectionString = "Server=$dbservername;Database=$databasename;Integrated Security=SSPI;"

    #Insert Statement to be pushed into the database
    $insertstatement = "INSERT INTO created_users(username,Whencreated,timestamp)
                        VALUES ('$($user.SamAccountName)','$([datetime]$whencreated)','$($timestamp)')"

    # Opens Connection, Pushes the data then closes the connection to keep it tidy
    $SqlConnection.Open()
    $SqlCmd = New-Object "System.Data.SqlClient.SqlCommand" ($insertstatement,$SqlConnection)
    $SqlCmd.ExecuteNonQuery()
    $SqlConnection.Close()
    # Have a little nap sql, you worked hard today.
    Start-Sleep 2
    }