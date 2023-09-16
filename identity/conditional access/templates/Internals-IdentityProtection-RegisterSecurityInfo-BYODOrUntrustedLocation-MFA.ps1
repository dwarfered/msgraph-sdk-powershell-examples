#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Identity.SignIns"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        CA Policy: Internals-IdentityProtection-RegisterSecurityInfo-BYODOrUntrustedLocation-MFA

    .DESCRIPTION
    
        A CA Policy to prevent the registration of security information when off the trusted network or on 
        a personal device.

    .NOTES
        AUTHOR: https://github.com/dwarfered/msgraph-sdk-powershell-examples
        UPDATED: 16-09-2023
#>

$config = Get-Content -Path ./config.json -Raw | ConvertFrom-Json

$policy = [Microsoft.Graph.PowerShell.Models.MicrosoftGraphConditionalAccessPolicy]::new()
$policy.DisplayName = 'Internals-IdentityProtection-RegisterSecurityInfo-BYODOrUntrustedLocation-MFA'
$policy.State = 'disabled'

$policy.Conditions.Users.IncludeGroups = $config.'CA-Persona-Internals'
$policy.Conditions.Users.ExcludeGroups = $config.'CA-Persona-Internals-IdentityProtection-Exclusions'
$policy.Conditions.Users.ExcludeUsers = $config.'BreakGlassAccounts'
$policy.Conditions.Devices.DeviceFilter.Mode = 'exclude'
$policy.Conditions.Devices.DeviceFilter.Rule = 'device.trustType -eq "AzureAD" -or device.trustType -eq "ServerAD"'
$policy.Conditions.Applications.IncludeUserActions = 'urn:user:registersecurityinfo'
$policy.Conditions.ClientAppTypes = 'all'
$policy.Conditions.Locations.IncludeLocations = 'All'
$policy.Conditions.Locations.ExcludeLocations = 'AllTrusted'

$policy.GrantControls.Operator = 'OR'
$policy.GrantControls.BuiltInControls = 'mfa'

$requiredScopes = @('Policy.Read.All', 'Policy.ReadWrite.ConditionalAccess', 'Application.Read.All')
$currentScopes = (Get-MgContext).Scopes
if ($currentScopes -match ([string]::Join('|',$requiredScopes)).Count -ne $requiredScopes.Count) {
    Connect-MgGraph -Scopes $requiredScopes | Out-Null
}

New-MgIdentityConditionalAccessPolicy -BodyParameter $policy

