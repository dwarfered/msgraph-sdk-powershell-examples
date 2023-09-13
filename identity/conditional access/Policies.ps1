#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Beta.Identity.SignIns"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        Get-MgBetaIdentityConditionalAccessPolicy for a list of Conditional Access Policies

        The beta endpoint is used as preview polices may be in use within the tenant and these
        are not returned by the default v1.0 endpoint.

    .DESCRIPTION
    
    .NOTES
        AUTHOR: Chris Dymond
        UPDATED: 20-08-2023
#>

Connect-MgGraph -Scopes @('Policy.Read.All') | Out-Null

$policies = Get-MgBetaIdentityConditionalAccessPolicy -All

$policies.DisplayName
