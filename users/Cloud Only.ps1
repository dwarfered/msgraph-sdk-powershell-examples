#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Users"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        Get-MgUser cloud only accounts.

    .DESCRIPTION
        An example of how to use Get-MgUser to find all cloud only accounts.

    .NOTES
        AUTHOR: Chris Dymond
        UPDATED: 19-08-2023
#>

Connect-MgGraph -Scopes @('User.Read.All') | Out-Null

$params = @{ 
    'All'              = $true; 
    'PageSize'         = '999';
    'Filter'           = "onPremisesSyncEnabled ne true and userType eq 'member'";
    'ConsistencyLevel' = 'eventual'; 
    'CountVariable'    = 'userCount';
}

$allCloudOnlyUsers = Get-MgUser @params

$allCloudOnlyUsers.UserPrincipalName