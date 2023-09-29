#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Applications"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
    Retrieve Application Roles assigned to Service Principals using a supplied AppId (ie. Microsoft Graph, AAD Graph, ...).
        
    .NOTES
        AUTHOR: https://github.com/dwarfered/msgraph-sdk-powershell-examples
        UPDATED: 27-09-2023
#>

$requiredScopes = @('Application.Read.All')
$currentScopes = (Get-MgContext).Scopes

if ($null -eq $currentScopes) {
    Connect-MgGraph -Scopes $requiredScopes | Out-Null
}
elseif (($currentScopes -match ([string]::Join('|', $requiredScopes))).Count -ne $requiredScopes.Count) {
    Connect-MgGraph -Scopes $requiredScopes | Out-Null
}

#region Supporting Functions
function Get-AppRolesAssignedToServicePrincipalsByAppId {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param
    (
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1)]
        [string] $AppId
    )
    process {
        $principal = Get-MgServicePrincipal -Filter "appId eq '$AppId'"
        $principalAppRoles = $principal.AppRoles | Group-Object -Property Id -AsHashTable
        if ($principal) {
            $appRolesAssigned = Get-MgServicePrincipalAppRoleAssignedTo -ServicePrincipalId $principal.Id -All
            $appRolesAssigned | ForEach-Object {
                $appRole = $principalAppRoles[$PSItem.AppRoleId]
                $PSItem | Add-Member -NotePropertyName ClaimValue -NotePropertyValue $appRole.Value
                $PSItem | Add-Member -NotePropertyName Permission -NotePropertyValue $appRole.DisplayName
            }
            $appRolesAssigned
        }
    }
}
#endRegion

<# Further Microsoft AppIds
https://learn.microsoft.com/en-us/troubleshoot/azure/active-directory/verify-first-party-apps-sign-in
#>

# Microsoft Graph
$msGraphAppRolesAssigned = Get-AppRolesAssignedToServicePrincipalsByAppId -AppId '00000003-0000-0000-c000-000000000000'
# Windows Azure Active Directory (AAD Graph)
$aadGraphAppRolesAssigned = Get-AppRolesAssignedToServicePrincipalsByAppId -AppId '00000002-0000-0000-c000-000000000000'
# Office 365 Exchange Online 
$o365ExoAppRolesAssigned = Get-AppRolesAssignedToServicePrincipalsByAppId -AppId '00000002-0000-0ff1-ce00-000000000000'
# Office 365 Management APIs
$o365MgmtApiRolesAssigned = Get-AppRolesAssignedToServicePrincipalsByAppId -AppId 'c5393580-f805-4401-95e8-94b7a6ef2fc2'

$msGraphAppRolesAssigned | Sort-Object PrincipalDisplayName
| Select-Object PrincipalDisplayName, PrincipalId, ClaimValue, Permission
| Export-Csv -Path .\msGraphAppRolesAssigned.csv -NoTypeInformation

$aadGraphAppRolesAssigned | Sort-Object PrincipalDisplayName
| Select-Object PrincipalDisplayName, PrincipalId, ClaimValue, Permission
| Export-Csv -Path .\aadGraphAppRolesAssigned.csv -NoTypeInformation

$o365ExoAppRolesAssigned | Sort-Object PrincipalDisplayName
| Select-Object PrincipalDisplayName, PrincipalId, ClaimValue, Permission
| Export-Csv -Path .\o365ExoAppRolesAssigned.csv -NoTypeInformation

$o365MgmtApiRolesAssigned | Sort-Object PrincipalDisplayName
| Select-Object PrincipalDisplayName, PrincipalId, ClaimValue, Permission
| Export-Csv -Path .\o365MgmtApiRolesAssigned.csv -NoTypeInformation

