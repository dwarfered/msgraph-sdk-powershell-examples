#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Users"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        Get-MgUser where licenses are assigned.

    .DESCRIPTION
        An example of how to use Get-MgUser to find all accounts assigned licenses.

    .NOTES
        AUTHOR: Chris Dymond
        UPDATED: 19-08-2023
#>

Connect-MgGraph -Scopes @('User.Read.All') | Out-Null

$params = @{
    'All'              = $true;
    'Filter'           = 'assignedLicenses/$count ne 0';
    'CountVariable'    = 'userCount';
    'ConsistencyLevel' = 'eventual';
    'PageSize'         = '999';
}

$users = Get-MgUser @params

$users.UserPrincipalName