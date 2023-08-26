#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Identity.SignIns"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        CA Policy: Internals-AttackSurfaceReduction-AllApps-UnknownPlatforms-Block

    .DESCRIPTION
    
        A CA Policy blocking all Internals on unknown platforms. 

    .NOTES
        AUTHOR: Chris Dymond
        UPDATED: 26-08-2023
#>

# Apply Your Object Ids
$CA_Internals_Persona_Group = ''
$breakGlassAccounts = @('','')

$policy = [Microsoft.Graph.PowerShell.Models.MicrosoftGraphConditionalAccessPolicy]::new()
$policy.DisplayName = 'Internals-AttackSurfaceReduction-AllApps-UnknownPlatforms-Block'
$policy.State = 'disabled'

$policy.Conditions.Users.IncludeGroups = $CA_Internals_Persona_Group
$policy.Conditions.Users.ExcludeUsers = $breakGlassAccounts
$policy.Conditions.Applications.IncludeApplications = 'All'
$policy.Conditions.ClientAppTypes = 'all'
$policy.Conditions.Platforms.ExcludePlatforms = @('android','iOS','windows','macOS','linux','windowsPhone')
$policy.Conditions.Platforms.IncludePlatforms = 'all'
<# Optionally include all locations with trusted locations excluded #>
# $policy.Conditions.Locations.IncludeLocations = 'All'
# $policy.Conditions.Locations.ExcludeLocations = 'AllTrusted'

$policy.GrantControls.Operator = 'OR'
$policy.GrantControls.BuiltInControls = @('block')

Connect-MgGraph -Scopes @('Policy.ReadWrite.ConditionalAccess') | Out-Null

New-MgIdentityConditionalAccessPolicy -BodyParameter $policy

