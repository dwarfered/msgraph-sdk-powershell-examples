#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Identity.SignIns"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        CA Policy: Internals-IdentityProtection-RegisterSecurityInfo-BYODOrUntrustedLocation-MFA

    .DESCRIPTION
    
        A CA Policy to prevent the registration of security information when off the trusted network or on 
        a personal device.

        NOTE:
            - Create an Azure AD group 'CA-Persona-Internals' with your critera of membership
            - Exclude your Break Glass (or Emergency) accounts

    .NOTES
        AUTHOR: Chris Dymond
        UPDATED: 19-08-2023
#>

# Apply Your Object Ids
$CAInternalsPersonaGroup = ''
$BreakGlassAccounts = @('','')

$policy = [Microsoft.Graph.PowerShell.Models.MicrosoftGraphConditionalAccessPolicy]::new()
$policy.DisplayName = 'Internals-IdentityProtection-RegisterSecurityInfo-BYODOrUntrustedLocation-MFA'
$policy.State = 'enabledForReportingButNotEnforced'

$policy.Conditions.Users.IncludeGroups = $CAInternalsPersonaGroup
$policy.Conditions.Users.ExcludeGroups = $BreakGlassAccounts
$policy.Conditions.Devices.DeviceFilter.Mode = 'exclude'
$policy.Conditions.Devices.DeviceFilter.Rule = 'device.trustType -eq "AzureAD" -or device.trustType -eq "ServerAD"'
$policy.Conditions.Applications.IncludeUserActions = 'urn:user:registersecurityinfo'
$policy.Conditions.ClientAppTypes = 'all'
$policy.Conditions.Locations.IncludeLocations = 'All'
$policy.Conditions.Locations.ExcludeLocations = 'AllTrusted'

$policy.GrantControls.Operator = 'OR'
$policy.GrantControls.BuiltInControls = 'mfa'

Connect-MgGraph -Scopes @('Policy.ReadWrite.ConditionalAccess') | Out-Null

New-MgIdentityConditionalAccessPolicy -BodyParameter $policy

