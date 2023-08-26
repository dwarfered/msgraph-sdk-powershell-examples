#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Identity.SignIns"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        CA Policy: Guests-IdentityProtection-AllApps-LegacyAuthenticationClients-Block

    .DESCRIPTION
    
        A CA Policy to prevent legacy authentication clients (Exchange ActiveSync clients and other clients)
        for Guests.

    .NOTES
        AUTHOR: Chris Dymond
        UPDATED: 19-08-2023
#>

$config = Get-Content -Path ./config.json -Raw | ConvertFrom-Json

$policy = [Microsoft.Graph.PowerShell.Models.MicrosoftGraphConditionalAccessPolicy]::new()
$policy.DisplayName = 'Guests-IdentityProtection-AllApps-LegacyAuthenticationClients-Block'
$policy.State = 'disabled'

$policy.Conditions.Users.IncludeGuestsOrExternalUsers.ExternalTenants.MembershipKind = 'all'
$policy.Conditions.Users.IncludeGuestsOrExternalUsers.GuestOrExternalUserTypes = 'internalGuest,b2bCollaborationGuest,b2bCollaborationMember,b2bDirectConnectUser,otherExternalUser,serviceProvider'
$policy.Conditions.Users.ExcludeGroups = $config.'CA-Persona-Guests-IdentityProtection-Exclusions'
$policy.Conditions.Users.ExcludeUsers = $config.'BreakGlassAccounts'
$policy.Conditions.Applications.IncludeApplications = 'All'
$policy.Conditions.ClientAppTypes = @('exchangeActiveSync', 'other')

$policy.GrantControls.Operator = 'OR'
$policy.GrantControls.BuiltInControls = 'block'

Connect-MgGraph -Scopes @('Policy.ReadWrite.ConditionalAccess') | Out-Null

New-MgIdentityConditionalAccessPolicy -BodyParameter $policy

