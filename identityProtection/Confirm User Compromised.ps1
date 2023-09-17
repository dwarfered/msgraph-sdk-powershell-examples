#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Identity.SignIns"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        Confirm one or more riskyUser objects as compromised. 
        This action sets the targeted user's risk level to high.
        Conditional Access Policy applying to this risk level will apply.

        For delegated scenarios, the signed-in user must have one of the following Azure AD roles.
            Security Administrator
            Global Administrator
            
    .DESCRIPTION

        Audit Log Record

        Service: Identity Protection
        Category: Other
        Activity: ConfirmAccountCompromised
        Status reason: Dismiss Success. Item updated: 1. Action type: ConfirmAccountCompromised

    .NOTES
        AUTHOR: https://github.com/dwarfered/msgraph-sdk-powershell-examples
        UPDATED: 17-09-2023
#>

$requiredScopes = @('IdentityRiskyUser.ReadWrite.All')
$currentScopes = (Get-MgContext).Scopes
if (($currentScopes -match ([string]::Join('|', $requiredScopes))).Count -ne $requiredScopes.Count) {
    Connect-MgGraph -Scopes $requiredScopes | Out-Null
}

$userIds = @('')

if ($userIds.Count -gt 0) {
    Confirm-MgRiskyUserCompromised -UserIds $userIds
}
