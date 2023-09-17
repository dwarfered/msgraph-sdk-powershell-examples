#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Users"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        Get-MgUser cloud only accounts.

    .DESCRIPTION
        An example of how to use Get-MgUser to find all cloud only accounts.

    .NOTES
        AUTHOR: https://github.com/dwarfered/msgraph-sdk-powershell-examples
        UPDATED: 16-09-2023
#>

$requiredScopes = @('User.Read.All')
$currentScopes = (Get-MgContext).Scopes
if (($currentScopes -match ([string]::Join('|', $requiredScopes))).Count -ne $requiredScopes.Count) {
    Connect-MgGraph -Scopes $requiredScopes | Out-Null
}

$params = @{ 
    'All'              = $true; 
    'PageSize'         = '999';
    'Filter'           = "onPremisesSyncEnabled ne true and userType eq 'member'";
    'ConsistencyLevel' = 'eventual'; 
    'CountVariable'    = 'userCount';
}

$allCloudOnlyUsers = Get-MgUser @params

$allCloudOnlyUsers.UserPrincipalName