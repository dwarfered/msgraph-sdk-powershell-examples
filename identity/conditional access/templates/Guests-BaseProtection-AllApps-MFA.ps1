#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Identity.SignIns"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        CA Policy: Guests-BaseProtection-AllApps-MFA

    .DESCRIPTION
    
        A CA Policy mandating MFA for all Guests.

    .NOTES
        AUTHOR: Chris Dymond
        UPDATED: 19-08-2023
#>

$policy = [Microsoft.Graph.PowerShell.Models.MicrosoftGraphConditionalAccessPolicy]::new()
$policy.DisplayName = 'Guests-BaseProtection-AllApps-MFA'
$policy.State = 'disabled'

$policy.Conditions.Users.IncludeGuestsOrExternalUsers.ExternalTenants.MembershipKind = 'all'
$policy.Conditions.Users.IncludeGuestsOrExternalUsers.GuestOrExternalUserTypes = 'internalGuest,b2bCollaborationGuest,b2bCollaborationMember,b2bDirectConnectUser,otherExternalUser,serviceProvider'
$policy.Conditions.Applications.IncludeApplications = 'All'
$policy.Conditions.ClientAppTypes = 'all'

$policy.GrantControls.Operator = 'OR'
$policy.GrantControls.BuiltInControls = 'mfa'

Connect-MgGraph -Scopes @('Policy.ReadWrite.ConditionalAccess') | Out-Null

New-MgIdentityConditionalAccessPolicy -BodyParameter $policy

