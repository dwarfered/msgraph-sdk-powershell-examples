#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Identity.SignIns"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        CA Policy: Internals-DataProtection-O365-Unmanaged-AppEnforcedRestrictions

    .DESCRIPTION
    
        A CA Policy mandating all Internals with unamanged devices adhere to App Enforced Restrictions.
        Applies to those not on devices Joined or compliant in Intune.

        NOTE:
            - Blocks or limits access to SharePoint Online, OneDrive, and Exchange Online content
              from unmanaged devices.
            - The settings for these are set in the respect admin areas of SharePoint, Exchange etc

    .NOTES
        AUTHOR: Chris Dymond
        UPDATED: 20-08-2023
#>

# Apply Your Object Ids
$CA_Internals_Persona_Group = 'dcdc6e8d-a073-4642-9340-c8d62414954f'
$breakGlassAccounts = @('a67541c2-bb42-4c88-9b6d-7cb45d286776')

$policy = [Microsoft.Graph.PowerShell.Models.MicrosoftGraphConditionalAccessPolicy]::new()
$policy.DisplayName = 'Internals-DataProtection-O365-Unmanaged-AppEnforcedRestrictions'
$policy.State = 'disabled'

$policy.Conditions.Users.IncludeGroups = $CA_Internals_Persona_Group
$policy.Conditions.Users.ExcludeUsers = $breakGlassAccounts
$policy.Conditions.Applications.IncludeApplications = 'Office365'
$policy.Conditions.ClientAppTypes = 'all'
<# Optionally exclude trusted locations #>
# $policy.Conditions.Locations.IncludeLocations = 'All'
# $policy.Conditions.Locations.ExcludeLocations = 'AllTrusted'

$policy.SessionControls.ApplicationEnforcedRestrictions.IsEnabled = $true

Connect-MgGraph -Scopes @('Policy.ReadWrite.ConditionalAccess') | Out-Null

New-MgIdentityConditionalAccessPolicy -BodyParameter $policy

