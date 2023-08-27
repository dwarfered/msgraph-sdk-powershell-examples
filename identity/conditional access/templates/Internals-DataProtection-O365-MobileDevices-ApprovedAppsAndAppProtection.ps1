#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Identity.SignIns"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        CA Policy: Internals-DataProtection-O365-MobileDevices-ApprovedAppsAndAppProtection

    .DESCRIPTION
    
        A CA Policy mandating all Internals with mobile devices use approved client apps and
        use App Protection Policies (APP)

    .NOTES
        AUTHOR: Chris Dymond
        UPDATED: 20-08-2023
#>

$config = Get-Content -Path ./config.json -Raw | ConvertFrom-Json

$policy = [Microsoft.Graph.PowerShell.Models.MicrosoftGraphConditionalAccessPolicy]::new()
$policy.DisplayName = 'Internals-DataProtection-O365-MobileDevices-ApprovedAppsAndAppProtection'
$policy.State = 'disabled'

$policy.Conditions.Users.IncludeGroups = $config.'CA-Persona-Internals'
$policy.Conditions.Users.ExcludeGroups = $config.'CA-Persona-Internals-DataProtection-Exclusions'
$policy.Conditions.Users.ExcludeUsers = $config.'BreakGlassAccounts'
$policy.Conditions.Applications.IncludeApplications = 'Office365'
$policy.Conditions.ClientAppTypes = 'all'
$policy.Conditions.Platforms.IncludePlatforms = @('android', 'iOS')

$policy.GrantControls.Operator = 'OR'
$policy.GrantControls.BuiltInControls = @('approvedApplication','compliantApplication')

$requiredScopes = @('Policy.Read.All', 'Policy.ReadWrite.ConditionalAccess', 'Application.Read.All')
$currentScopes = (Get-MgContext).Scopes
if ($currentScopes -match ([string]::Join('|',$requiredScopes)).Count -ne $requiredScopes.Count) {
    Connect-MgGraph -Scopes $requiredScopes | Out-Null
}

New-MgIdentityConditionalAccessPolicy -BodyParameter $policy

