$computerName = "ArroyoVM"
$keyVaultName = "MaxiPruebaTecKeyVault"
$secretName = "LocalAdminPassword"

# prompt user
$newPassword = Read-Host "Enter the new local admin password" -AsSecureString
Set-LocalUser -Name "ArroyoUser" -Password $newPassword


Connect-AzAccount
$keyVault = Get-AzKeyVault -VaultName $keyVaultName
$encryptedPassword = ConvertFrom-SecureString -SecureString $newPassword
$secret = Set-AzKeyVaultSecret -VaultName $keyVaultName -Name $secretName -SecretValue $encryptedPassword

