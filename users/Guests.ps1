#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Users"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        Get-MgUser to retrieve all Guest accounts.

    .DESCRIPTION
        An example of how to use Get-MgUser to find all Guest user accounts.

    .NOTES
        AUTHOR: Chris Dymond
        UPDATED: 19-08-2023
#>

Connect-MgGraph -Scopes @('User.Read.All') | Out-Null

$users = Get-MgUser -All -PageSize 999 -Filter "userType eq 'Guest'"

$users.UserPrincipalName