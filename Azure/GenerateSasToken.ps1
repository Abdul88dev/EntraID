#--------------
# this script is to create a sas token with user key option and expiration date and time
# this could be used in logic apps or function apps in Azure
#--------------


param(
    [string]$resourceGroupName = "ResourceGroupName",
    [string]$storageAccountName = "StorageAccountname",
    [string]$containerName = "ContainerName",
    [string]$blobName ,
    [int]$expiryInHours = 12
)
#This part is get only the Sas url without any extra output.
# 
$VerbosePreference = 'SilentlyContinue'
$DebugPreference = 'SilentlyContinue'
# Connect to Azure using managed identity (System assigned)
$null =Connect-AzAccount -Identity 

# Get the Storage Account Key
$storageKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName)[0].Value

# Create a context with the storage key
$null = $context = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageKey

# Set start and expiry time
$startTime = (Get-Date).ToUniversalTime().AddMinutes(-5)
$expiryTime = $startTime.AddHours($expiryInHours)

# Generate SAS token
$sasToken = New-AzStorageBlobSASToken `
    -Container $containerName `
    -Blob $blobName `
    -Context $context `
    -Permission r `
    -StartTime $startTime `
    -ExpiryTime $expiryTime `
    -FullUri

# Output or store the token (e.g., save to Key Vault, Log Analytics, etc.)
Write-Output $sasToken