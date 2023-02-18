# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' porperty is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}

#$DS = Invoke-Sqlcmd -Query "SELECT GETDATE() AS TimeOfQuery"  -ConnectionString "Server=tcp:xxxxxxxxx.database.windows.net,1433;Initial Catalog=xxxxxxxxx;Persist Security Info=False;User ID=xxxxxxxxx;Password=xxxxxxxxx;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;" -As DataSet
#$DS = Invoke-Sqlcmd -Query "SELECT * from [dbo].[movie]"  -ConnectionString "Server=tcp:xxxxxxxxx.database.windows.net, 1433; Initial Catalog=xxxxxxxxx; Persist Security Info=False; User ID=xxxxxxxxx; Password=xxxxxxxxx; MultipleActiveResultSets=False; Encrypt=True; TrustServerCertificate=False; Connection Timeout=30; " -As DataSet

#$DS = Invoke-Sqlcmd -Query "SELECT * from [dbo].[movie]"  -ConnectionString "Data Source =xxxxxxxxx.database.windows.net ; Initial Catalog = xxxxxxxxx; Authentication=ActiveDirectoryMsi;" -As DataSet

$resourceURI = "https://database.windows.net/"
$tokenAuthURI = $env:MSI_ENDPOINT + "?resource=$resourceURI&api-version=2017-09-01"
$tokenResponse = Invoke-RestMethod -Method Get -Headers @{"Secret" = "$env:MSI_SECRET" } -Uri $tokenAuthURI
$accessToken = $tokenResponse.access_token

$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = "Data Source =xxxxxxxxx.database.windows.net ; Initial Catalog = xxxxxxxxx"
$SqlConnection.AccessToken = $AccessToken
$SqlConnection.Open()

$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText = "SELECT * from [dbo].[movie]"
$SqlCmd.Connection = $SqlConnection
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd
$DataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSet)

$dtable = $DataSet.Tables[0].Rows | format-table -AutoSize

$dtable

####

$sqlBulkCopy = New-Object ("Data.SqlClient.SqlBulkCopy") -ArgumentList $SqlConnection
$sqlBulkCopy.DestinationTableName = "dbo.moviebuklcopydest"
#$SqlConnection.Open()
$sqlBulkCopy.WriteToServer($DataSet.Tables[0].Rows)
$SqlConnection.Close()

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"
#$DS.Tables[0].Rows | Out-DataTable

#$dtable = $DS.Tables[0].Rows | format-table -AutoSize

#$dtable

#$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
#$SqlConnection.ConnectionString = "Server=tcp:xxxxxxxxx.database.windows.net,1433;Initial Catalog=xxxxxxxxx;Persist Security Info=False;User ID=xxxxxxxxx;Password=xxxxxxxxx;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

#$SqlConnection.ConnectionString = "Data Source =xxxxxxxxx.database.windows.net ; Initial Catalog = xxxxxxxxx; Authentication=ActiveDirectoryMsi;"


#$sqlBulkCopy = New-Object ("Data.SqlClient.SqlBulkCopy") -ArgumentList $SqlConnection
#$sqlBulkCopy.DestinationTableName = "dbo.moviebuklcopydest"

#$SqlConnection.Open()
#$sqlBulkCopy.WriteToServer($DS.Tables[0].Rows)
#$SqlConnection.Close()