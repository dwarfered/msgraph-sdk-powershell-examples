#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Identity.SignIns"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        CA Policy: Internals-IdentityProtection-AllApps-LegacyAuthenticationClients-Block

    .DESCRIPTION
    
        A CA Policy to prevent legacy authentication clients (Exchange ActiveSync clients and other clients)
        for the Internals persona.

        NOTE:
            - Create an Azure AD group 'CA-Persona-Internals' with your critera of membership
            - Exclude your Break Glass (or Emergency) accounts

    .NOTES
        AUTHOR: Chris Dymond
        UPDATED: 19-08-2023
#>

# Apply Your Object Ids
$CA_Internals_Persona_Group = ''
$breakGlassAccounts = @('','')

$policy = [Microsoft.Graph.PowerShell.Models.MicrosoftGraphConditionalAccessPolicy]::new()
$policy.DisplayName = 'Internals-IdentityProtection-AllApps-LegacyAuthenticationClients-Block'
$policy.State = 'disabled'

$policy.Conditions.Users.IncludeGroups = $CA_Internals_Persona_Group
$policy.Conditions.Users.ExcludeUsers = $breakGlassAccounts
$policy.Conditions.Applications.IncludeApplications = 'All'
$policy.Conditions.ClientAppTypes = @('exchangeActiveSync', 'other')

$policy.GrantControls.Operator = 'OR'
$policy.GrantControls.BuiltInControls = 'block'

Connect-MgGraph -Scopes @('Policy.ReadWrite.ConditionalAccess') | Out-Null

New-MgIdentityConditionalAccessPolicy -BodyParameter $policy

