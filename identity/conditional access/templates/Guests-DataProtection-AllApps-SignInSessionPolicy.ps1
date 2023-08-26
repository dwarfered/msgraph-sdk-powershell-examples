#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Identity.SignIns"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        CA Policy: Guests-DataProtection-AllApps-SignInSessionPolicy

    .DESCRIPTION
    
        A CA Policy mandating a 1 hour session limit for Guests.

    .NOTES
        AUTHOR: Chris Dymond
        UPDATED: 19-08-2023
#>

$config = Get-Content -Path ./config.json -Raw | ConvertFrom-Json

$policy = [Microsoft.Graph.PowerShell.Models.MicrosoftGraphConditionalAccessPolicy]::new()
$policy.DisplayName = 'Guests-DataProtection-AllApps-SignInSessionPolicy'
$policy.State = 'disabled'

$policy.Conditions.Users.IncludeGuestsOrExternalUsers.ExternalTenants.MembershipKind = 'all'
$policy.Conditions.Users.IncludeGuestsOrExternalUsers.GuestOrExternalUserTypes = 'internalGuest,b2bCollaborationGuest,b2bCollaborationMember,b2bDirectConnectUser,otherExternalUser,serviceProvider'
$policy.Conditions.Users.ExcludeGroups = $config.'CA-Persona-Guests-DataProtection-Exclusions'
$policy.Conditions.Users.ExcludeUsers = $config.'BreakGlassAccounts'
$policy.Conditions.Applications.IncludeApplications = 'All'
$policy.Conditions.ClientAppTypes = 'all'

$policy.SessionControls.PersistentBrowser.IsEnabled = $true
$policy.SessionControls.PersistentBrowser.Mode = 'never'
$policy.SessionControls.SignInFrequency.AuthenticationType = 'primaryAndSecondaryAuthentication'
$policy.SessionControls.SignInFrequency.FrequencyInterval = 'timeBased'
$policy.SessionControls.SignInFrequency.IsEnabled = $true
$policy.SessionControls.SignInFrequency.Type = 'hours'
$policy.SessionControls.SignInFrequency.Value = 1


Connect-MgGraph -Scopes @('Policy.ReadWrite.ConditionalAccess') | Out-Null

New-MgIdentityConditionalAccessPolicy -BodyParameter $policy

