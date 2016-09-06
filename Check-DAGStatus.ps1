Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

Function Get-ExchangeServerADSite ([String] $excServer)
{
	# We could use WMI to check for the domain, but I think this method is better
	# Get-WmiObject Win32_NTDomain -ComputerName $excServer

	$configNC =([ADSI]"LDAP://RootDse").configurationNamingContext
	$search = new-object DirectoryServices.DirectorySearcher([ADSI]"LDAP://$configNC")
	$search.Filter = "(&(objectClass=msExchExchangeServer)(name=$excServer))"
	$search.PageSize = 1000
	[Void] $search.PropertiesToLoad.Add("msExchServerSite")

	Try {
		$adSite = [String] ($search.FindOne()).Properties.Item("msExchServerSite")
		Return ($adSite.Split(",")[0]).Substring(3)
	} Catch {
		Return $null
	}
}


[Bool] $bolFailover = $False
[String] $errMessage = $null

# Check if all databases are currently mounted on the server with ActivationPreference of 1
Get-MailboxDatabase | Where {$_.Recovery -eq $False} | Sort Name | ForEach {
	$db = $_.Name
	$curServer = $_.Server.Name
	$ownServer = $_.ActivationPreference | ? {$_.Value -eq 1}
	
	# Compare the server where the DB is currently active to the server where it should be
	If ($curServer -ne $ownServer.Key.Name) {
		# Get the AD sites of both servers
		$siteCur = Get-ExchangeServerADSite $curServer
		$siteOwn = Get-ExchangeServerADSite $ownServer.Key
		
		# Check if both servers are on different AD sites
		If ($siteCur -ne $null -and $siteOwn -ne $null -and $siteCur -ne $siteOwn) {
			$errMessage += "`n$db on $curServer should be on $($ownServer.Key) (DIFFERENT AD SITE: $siteCur)!"	
		} Else {
			$errMessage += "`n$db on $curServer should be on $($ownServer.Key)!"
		}

		$bolFailover = $True
	}
}

$errMessage += "`nExchange Environment Databases are not healthy. Please check all Exchange servers.`nIf this alert is ignored then service may stop.`nThe errors are: `n"

# Check the Status of all databases including Content Index and Queues
Get-MailboxDatabase | Where {$_.Recovery -eq $False} | Sort Name | Get-MailboxDatabaseCopyStatus | ForEach {
	If ($_.Status -notmatch "Mounted" -and $_.Status -notmatch "Healthy" -or $_.ContentIndexState -notmatch "Healthy" -or $_.CopyQueueLength -ge 200 -or $_.ReplayQueueLength -ge 200) {
		$errMessage += "`n`n$($_.Name) - Status: $($_.Status) - Copy QL: $($_.CopyQueueLength) - Replay QL: $($_.ReplayQueueLength) - Index: $($_.ContentIndexState)"
		$bolFailover = $True
	}
}

If ($bolFailover) {
    #do magical shit here
	    }
else {
    #idk, log a value saying it's all gravy? sounds like a plan batman

}