Connect-AzAccount
$resourceGroupName = "ADO"
$keyVaultName = "MaxiPruebaTecKeyVault"
$keyVault = Get-AzKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroupName
$permissions = @("get", "set", "list", "delete")
$username1 = "fabio.rincon@arroyoconsulting.net"
$username2 = "andres.zapata@arroyoconsulting.net"

$userObjectId1 = (Get-AzADUser -UserPrincipalName $username1).Id
$userObjectId2 = (Get-AzADUser -UserPrincipalName $username2).Id

# Create access
$accessPolicy1 = Set-AzKeyVaultAccessPolicy -VaultName $keyVaultName -ResourceGroupName $resourceGroupName -ObjectId $userObjectId1 -PermissionsToSecrets $permissions
$accessPolicy2 = Set-AzKeyVaultAccessPolicy -VaultName $keyVaultName -ResourceGroupName $resourceGroupName -ObjectId $userObjectId2 -PermissionsToSecrets $permissions

# Display the access policy
$accessPolicy1
$accessPolicy2
      
