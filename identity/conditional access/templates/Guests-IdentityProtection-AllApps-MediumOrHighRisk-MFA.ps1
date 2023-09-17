#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Identity.SignIns"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        CA Policy: Guests-IdentityProtection-AllApps-MediumOrHighRisk-MFA

    .DESCRIPTION
    
        A CA Policy mandating all Guests with Medium or High Risk perform MFA.

        Applies to both Sign-In Risk and User Risk.

    .NOTES
        AUTHOR: https://github.com/dwarfered/msgraph-sdk-powershell-examples
        UPDATED: 16-09-2023
#>

$config = Get-Content -Path ./config.json -Raw | ConvertFrom-Json

$policy = [Microsoft.Graph.PowerShell.Models.MicrosoftGraphConditionalAccessPolicy]::new()
$policy.DisplayName = 'Guests-IdentityProtection-AllApps-MediumOrHighRisk-MFA'
$policy.State = 'disabled'

$policy.Conditions.Users.IncludeGuestsOrExternalUsers.ExternalTenants.MembershipKind = 'all'
$policy.Conditions.Users.IncludeGuestsOrExternalUsers.GuestOrExternalUserTypes = 'internalGuest,b2bCollaborationGuest,b2bCollaborationMember,b2bDirectConnectUser,otherExternalUser,serviceProvider'
$policy.Conditions.Users.ExcludeGroups = $config.'GroupId-CA-Persona-Guests-IdentityProtection-Exclusions'
$policy.Conditions.Users.ExcludeUsers = $config.'UserId-BreakGlassAccounts'
$policy.Conditions.Applications.IncludeApplications = 'All'
$policy.Conditions.ClientAppTypes = 'all'
$policy.Conditions.SignInRiskLevels = @('high', 'medium')
$policy.Conditions.UserRiskLevels = @('high','medium')

$policy.GrantControls.Operator = 'OR'
$policy.GrantControls.BuiltInControls = 'mfa'

$requiredScopes = @('Policy.Read.All', 'Policy.ReadWrite.ConditionalAccess', 'Application.Read.All')
$currentScopes = (Get-MgContext).Scopes
if (($currentScopes -match ([string]::Join('|', $requiredScopes))).Count -ne $requiredScopes.Count) {
    Connect-MgGraph -Scopes $requiredScopes | Out-Null
}

New-MgIdentityConditionalAccessPolicy -BodyParameter $policy

