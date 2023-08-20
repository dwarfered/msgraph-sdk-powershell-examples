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

# Apply Your Object Ids
$CA_Internals_Persona_Group = ''
$breakGlassAccounts = @('','')

$policy = [Microsoft.Graph.PowerShell.Models.MicrosoftGraphConditionalAccessPolicy]::new()
$policy.DisplayName = 'Internals-DataProtection-O365-MobileDevices-ApprovedAppsAndAppProtection'
$policy.State = 'disabled'

$policy.Conditions.Users.IncludeGroups = $CA_Internals_Persona_Group
$policy.Conditions.Users.ExcludeUsers = $breakGlassAccounts
$policy.Conditions.Applications.IncludeApplications = 'Office365'
$policy.Conditions.ClientAppTypes = 'all'
$policy.Conditions.Platforms.IncludePlatforms = @('android', 'iOS')

$policy.GrantControls.Operator = 'OR'
$policy.GrantControls.BuiltInControls = @('approvedApplication','compliantApplication')

Connect-MgGraph -Scopes @('Policy.ReadWrite.ConditionalAccess') | Out-Null

New-MgIdentityConditionalAccessPolicy -BodyParameter $policy

