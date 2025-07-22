#-----------------------
# This script is how to assign Graph Roles and permission on a System assigned 
# Managed Identity that usually created with Logic App
# Before you can start this script you have to make sure you installed Graph powershell Module
# Install-Module Microsoft.Graph -Scope CurrentUser -Repository PSGallery -Force
#------------------------



# -------------------------------
# 1. Connect to Microsoft Graph
# you might be asked to ask for permission to do this task depends on how your tenant is being 
# configured . ask your IAM admin or the tenant admin to consent your request so you would be able to 
# perform this action.
# -------------------------------
Connect-MgGraph -Scopes "Application.ReadWrite.All","AppRoleAssignment.ReadWrite.All","Directory.Read.All"

   

# -------------------------------
# 2. Set Logic App AppID
# -------------------------------
$AppAppId = "The App ID"  # Change this to your Logic App name

# -------------------------------
# 3. Get the Logic App's Service Principal
# -------------------------------
$sp = Get-MgServicePrincipal -Filter "AppId eq '$AppAppId'"
if (-not $sp) {
    Write-Error "Service Principal for '$logicAppName' not found."
    return
}

# -------------------------------
# 4. Get Microsoft Graph Service Principal
# This parts get the Service principal of the Graph API.
# Do not change the ID . This id is presented from microsoft
# -------------------------------
$graphSp = Get-MgServicePrincipal -Filter "AppId eq '00000003-0000-0000-c000-000000000000'"

# -------------------------------
# 5. Define permissions to assign
# Here you can assign one permission or multiple permissions at once
# -------------------------------
$permissions = @(
    "Mail.Send"
    "User.Read.All",
    "Group.Read.All"
)

# -------------------------------
# 6. Assign each permission
# A for loop to loop through the permissions and assign them.
# -------------------------------
foreach ($perm in $permissions) {
    $role = $graphSp.AppRoles | Where-Object {
        $_.Value -eq $perm -and $_.AllowedMemberTypes -contains "Application"
    }

    if ($role) {
        Write-Host "Assigning '$perm' to '$logicAppName'..."
        New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $sp.Id -PrincipalId $sp.Id -ResourceId $graphSp.Id -AppRoleId $role.Id
    }
    else {
        Write-Warning "Permission '$perm' not found on Microsoft Graph."
    }
}

# -------------------------------
# 7. Verify Assignments
# This step is optional just to confirm that the permissions have been assigned to service principal
# -------------------------------
Get-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $sp.Id | Format-Table DisplayName, AppRoleId
