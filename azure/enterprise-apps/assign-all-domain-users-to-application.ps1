#install Azure AD Powershell cmdlet module
Install-Module -Name AzureAD

#Sign user in
$AzureAdCred = Get-Credential
Connect-AzureAD -Credential $AzureAdCred

#set search substrings
$domainSearchString="*@<domainnamehere>"
$appNameString="<applicationDisplayNameHere>"
$roleNameString="<roleNameHere>"

#filter top 
$AzureADUsers = Get-AzureADUser | Where {$_.UserPrincipalName -like $domainSearchString}
# Get the service principal of the app to assign the user to
$servicePrincipal = Get-AzureADServicePrincipal -SearchString $appNameString

#iterate over filtered uses
foreach ($User in  $AzureADUsers){
    $userName=$User.UserPrincipalName
    $appName = $appNameString
    $appRoleName=$roleNameString
    
    #get user to assign role
    $user = Get-AzureADUser -ObjectId "$userName"
    $sp = Get-AzureADServicePrincipal -Filter "displayName eq '$appName'"
    $appRole = $sp.AppRoles | Where-Object { $_.DisplayName -eq $appRoleName }

    #Assign the user to the app role
    New-AzureADUserAppRoleAssignment -ObjectId $user.ObjectId -PrincipalId $user.ObjectId -ResourceId $sp.ObjectId -Id $appRole.Id
}
