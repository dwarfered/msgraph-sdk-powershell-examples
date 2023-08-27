#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Identity.SignIns"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        CA Policy: Internals-IdentityProtection-AllApps-HighSignInRisk-MFA

    .DESCRIPTION
    
        A CA Policy mandating all Internals with High Sign-In Risk perform MFA.

        NOTE:
            - Users's who have not enrolled for MFA with High Sign-In Risk will be blocked requiring
              administrator intervention.

    .NOTES
        AUTHOR: Chris Dymond
        UPDATED: 20-08-2023
#>

$config = Get-Content -Path ./config.json -Raw | ConvertFrom-Json

$policy = [Microsoft.Graph.PowerShell.Models.MicrosoftGraphConditionalAccessPolicy]::new()
$policy.DisplayName = 'Internals-IdentityProtection-AllApps-HighSignInRisk-MFA'
$policy.State = 'disabled'

$policy.Conditions.Users.IncludeGroups = $config.'CA-Persona-Internals'
$policy.Conditions.Users.ExcludeGroups = $config.'CA-Persona-Internals-IdentityProtection-Exclusions'
$policy.Conditions.Users.ExcludeUsers = $config.'BreakGlassAccounts'
$policy.Conditions.Applications.IncludeApplications = 'All'
$policy.Conditions.ClientAppTypes = 'all'
$policy.Conditions.SignInRiskLevels = 'high'

$policy.GrantControls.Operator = 'OR'
$policy.GrantControls.BuiltInControls = @('mfa')

$policy.SessionControls.SignInFrequency.AuthenticationType = 'primaryAndSecondaryAuthentication'
$policy.SessionControls.SignInFrequency.FrequencyInterval = 'everyTime'
$policy.SessionControls.SignInFrequency.IsEnabled = $true

Connect-MgGraph -Scopes @('Policy.ReadWrite.ConditionalAccess') | Out-Null

New-MgIdentityConditionalAccessPolicy -BodyParameter $policy

