#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Identity.SignIns"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        CA Policy: Internals-IdentityProtection-AllApps-HighUserRisk-MFAandPasswordChange

    .DESCRIPTION
    
        A CA Policy mandating all Internals with High User Risk perform MFA and change their password. 

        NOTE:
            - Users's who have not enrolled for MFA with High User Risk will be blocked requiring
              administrator intervention.

    .NOTES
        AUTHOR: Chris Dymond
        UPDATED: 20-08-2023
#>

# Apply Your Object Ids
$CA_Internals_Persona_Group = ''
$breakGlassAccounts = @('','')

$policy = [Microsoft.Graph.PowerShell.Models.MicrosoftGraphConditionalAccessPolicy]::new()
$policy.DisplayName = 'Internals-IdentityProtection-AllApps-HighUserRisk-MFAandPasswordChange'
$policy.State = 'disabled'

$policy.Conditions.Users.IncludeGroups = $CA_Internals_Persona_Group
$policy.Conditions.Users.ExcludeUsers = $breakGlassAccounts
$policy.Conditions.Applications.IncludeApplications = 'All'
$policy.Conditions.ClientAppTypes = 'all'
$policy.Conditions.UserRiskLevels = 'high'

$policy.GrantControls.Operator = 'AND'
$policy.GrantControls.BuiltInControls = @('mfa', 'passwordChange')

$policy.SessionControls.SignInFrequency.AuthenticationType = 'primaryAndSecondaryAuthentication'
$policy.SessionControls.SignInFrequency.FrequencyInterval = 'everyTime'
$policy.SessionControls.SignInFrequency.IsEnabled = $true

Connect-MgGraph -Scopes @('Policy.ReadWrite.ConditionalAccess') | Out-Null

New-MgIdentityConditionalAccessPolicy -BodyParameter $policy

