#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Identity.SignIns"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        Get-MgIdentityConditionalAccessPolicy for a list of Conditional Access Policies

    .DESCRIPTION
    
    .NOTES
        AUTHOR: Chris Dymond
        UPDATED: 19-08-2023
#>

Connect-MgGraph -Scopes @('Policy.Read.All') | Out-Null

$policies = Get-MgIdentityConditionalAccessPolicy -All

$policies.DisplayName
