##
## This script runs via an ARM Microsoft.Resources/deploymentScripts called "UpdateDatabase"
##
## Script execution runs within a Container Instance running Linux
##
## The Container Instance environment is created by the ARM deployment script and attaches
## a dedicated Storage Account for the purpose of the running the script.
##

param(
	[string] $targetServerName,
	[string] $targetUser,
	[string] $targetPassword
)

###############################################################
# Install required powershell modules
###############################################################
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
Install-Module -Name SqlServer -RequiredVersion 21.1.18256

###############################################################
# Set sm connection string
###############################################################
$smConnectionString = "Data Source=tcp:{0};Initial Catalog=SM;User ID={1};Password={2}" -f $targetServerName, $targetUser, $targetPassword

###############################################################
# Output vars to the ARM template to use in subsequent steps
###############################################################

$DeploymentScriptOutputs = @{}

# Get the Stream Host connection profile
$sql = "SELECT [Id] FROM Company WHERE Name = '{0}'"
$company = Invoke-Sqlcmd -ConnectionString $smConnectionString -Query ($sql -f $CompanyName)
# Invoke-Sqlcmd -ConnectionString "Data Source=tcp:xmpro-sqlserver.database.windows.net,1433;Initial Catalog=SM;User ID=xmadmin;Password=jaoeUDjYA2Wq" -Query ("SELECT [Id] FROM Company WHERE Name = 'something'" )
$companyId = $company.Id

# Write-Output "Company"
# Write-Output $company  | Format-Table

# $sql = "SELECT TOP 1
# 			[Id],
# 			[Secret],
# 			[Value] as [EncryptionKey]
# 		FROM [dbo].[EdgeContainer]
# 			INNER JOIN [dbo].[XMCompanySetting] ON [Company] = [CompanyId]
# 		WHERE
# 			[CompanyId] = '{0}'
# 			AND [Name] = 'Default'
# 			AND [SettingId] = (SELECT [Id] FROM [dbo].[XMSetting] WHERE [Name] = 'EncryptionKey')"
# $dsConnectionProfile = Invoke-Sqlcmd -ConnectionString $dsConnectionString -Query ($sql -f $companyId)

# Write-Output "DS Connection Profile"
# Write-Output $dsConnectionProfile  | Format-Table

# $DeploymentScriptOutputs['CollectionId'] = $dsConnectionProfile.Id
# $DeploymentScriptOutputs['CollectionSecret'] = $dsConnectionProfile.Secret
# $DeploymentScriptOutputs['DSEncryptionKey'] = $dsConnectionProfile.EncryptionKey



# Get the products ids and keys
$sql = "SELECT
			LOWER(convert(nvarchar(50), Product.[Id])) as [Id],
			[Key]
		FROM Product
			INNER JOIN ProductKey on [ProductId] = Product.[Id]
		WHERE
			Name = '{0}'"
$smProduct = Invoke-Sqlcmd -ConnectionString $smConnectionString -Query ($sql -f 'XMPro')
$dsProduct = Invoke-Sqlcmd -ConnectionString $smConnectionString -Query ($sql -f 'Data Stream Designer')
$adProduct = Invoke-Sqlcmd -ConnectionString $smConnectionString -Query ($sql -f 'App Designer')
$aiProduct = Invoke-Sqlcmd -ConnectionString $smConnectionString -Query ($sql -f 'AI')
$nbProduct = Invoke-Sqlcmd -ConnectionString $smConnectionString -Query ($sql -f 'XMPro Notebook')

# Write-Output "SM"
# Write-Output $smProduct | Format-Table
# Write-Output "DS"
# Write-Output $dsProduct | Format-Table
# Write-Output "AD"
# Write-Output $adProduct | Format-Table
# Write-Output "AI"
# Write-Output $aiProduct | Format-Table

$DeploymentScriptOutputs['SMProductId'] = $smProduct.Id
$DeploymentScriptOutputs['DSProductId'] = $dsProduct.Id
$DeploymentScriptOutputs['DSProductKey'] = $dsProduct.Key
$DeploymentScriptOutputs['ADProductId'] = $adProduct.Id
$DeploymentScriptOutputs['ADProductKey'] = $adProduct.Key
$DeploymentScriptOutputs['AIProductId'] = $aiProduct.Id
$DeploymentScriptOutputs['AIProductKey'] = $aiProduct.Key

# if ([System.Convert]::ToBoolean($EnableAi)) {
# 	
	# Write-Output "NB"
	# Write-Output $nbProduct | Format-Table

	$DeploymentScriptOutputs['NBProductId'] = $nbProduct.Id
	$DeploymentScriptOutputs['NBProductKey'] = $nbProduct.Key
# }

$productInfo = @{
    SMProductId   = $smProduct.Id
    DSProductId   = $dsProduct.Id
    DSProductKey  = $dsProduct.Key
    ADProductId   = $adProduct.Id
    ADProductKey  = $adProduct.Key
    AIProductId   = $aiProduct.Id
    AIProductKey  = $aiProduct.Key
	NBProductId	  = $nbProduct.Id
	NBProductKey  = $nbProduct.Key
}

# Convert the product information to JSON and output it
$productInfo | ConvertTo-Json