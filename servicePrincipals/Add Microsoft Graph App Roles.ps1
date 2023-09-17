#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Applications"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        Adding Microsoft Graph App Role Assignments to a Service Principal.

    .DESCRIPTION
    
    .NOTES
        AUTHOR: https://github.com/dwarfered/msgraph-sdk-powershell-examples
        UPDATED: 14-09-2023
#>

$principalId = '<Principal ObjectId>'

$requiredScopes = @('AppRoleAssignment.ReadWrite.All', 'Application.Read.All')
$currentScopes = (Get-MgContext).Scopes
if (($currentScopes -match ([string]::Join('|', $requiredScopes))).Count -ne $requiredScopes.Count) {
    Connect-MgGraph -Scopes $requiredScopes | Out-Null
}

$microsoftGraphAppId = '00000003-0000-0000-c000-000000000000'

$appRolesRequired = @(
    'User.Read.All',
    'AuditLog.Read.All'
)

$microsoftGraph = Get-MgServicePrincipal -Filter "appId eq '$microsoftGraphAppId'"

$appRoles = $microsoftGraph.AppRoles | Where-Object { $_.Value -in $appRolesRequired } 

$appRoles | ForEach-Object {

    $params = @{
        "principalId" = $principalId
        "resourceId"  = $microsoftGraph.Id
        "appRoleId"   = $PSItem.Id
    }
      
    New-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $principalId -BodyParameter $params
}
