#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Identity.SignIns"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        CA Policy: Internals-IdentityProtection-AllApps-LegacyAuthenticationClients-Block

    .DESCRIPTION
    
        A CA Policy to prevent legacy authentication clients (Exchange ActiveSync clients and other clients)
        for the Internals persona.

    .NOTES
        AUTHOR: https://github.com/dwarfered/msgraph-sdk-powershell-examples
        UPDATED: 16-09-2023
#>

$config = Get-Content -Path ./config.json -Raw | ConvertFrom-Json

$policy = [Microsoft.Graph.PowerShell.Models.MicrosoftGraphConditionalAccessPolicy]::new()
$policy.DisplayName = 'Internals-IdentityProtection-AllApps-LegacyAuthenticationClients-Block'
$policy.State = 'disabled'

$policy.Conditions.Users.IncludeGroups = $config.'GroupId-CA-Persona-Internals'
$policy.Conditions.Users.ExcludeGroups = $config.'GroupId-CA-Persona-Internals-IdentityProtection-Exclusions'
$policy.Conditions.Users.ExcludeUsers = $config.'UserId-BreakGlassAccounts'
$policy.Conditions.Applications.IncludeApplications = 'All'
$policy.Conditions.ClientAppTypes = @('exchangeActiveSync', 'other')

$policy.GrantControls.Operator = 'OR'
$policy.GrantControls.BuiltInControls = 'block'

$requiredScopes = @('Policy.Read.All', 'Policy.ReadWrite.ConditionalAccess', 'Application.Read.All')
$currentScopes = (Get-MgContext).Scopes

if ($null -eq $currentScopes) {
    Connect-MgGraph -Scopes $requiredScopes | Out-Null
} elseif (($currentScopes -match ([string]::Join('|', $requiredScopes))).Count -ne $requiredScopes.Count) {
    Connect-MgGraph -Scopes $requiredScopes | Out-Null
}

New-MgIdentityConditionalAccessPolicy -BodyParameter $policy

