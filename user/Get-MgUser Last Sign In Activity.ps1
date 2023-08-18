#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Users"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        Get-MgUser Last Sign In using the SignInActivity property.

    .DESCRIPTION
        An example of how to use the SignInActivity property to retrueve the last sign in of an account.

        NOTE: 
        - Azure AD updates the SignInActivity property roughly once every 6 hours. 
        - All times returned are in UTC+0

    .NOTES
        AUTHOR: Chris Dymond
        UPDATED: 18-08-2023
#>

Connect-MgGraph -Scopes @('User.Read.All', 'AuditLog.Read.All') | Out-Null

$filter = 'accountEnabled eq true'

<#
    --- Other example filters ---
    "accountEnabled eq true and onPremisesExtensionAttributes/extensionAttribute1 eq 'something'"
    "userPrincipalName eq 'someone@contoso.com'"
#>

$select = 'SignInActivity, onPremisesDistinguishedName'

$params = @{ 
    'All'              = $true; 
    'PageSize'         = '999';
    'Filter'           = $filter;
    'ConsistencyLevel' = 'eventual'; 
    'CountVariable'    = 'userCount';
    'Select'           = $select;
}

$users = Get-MgUser @params

$users | ForEach-Object {
    # Store the last sign-in in a new property (comparing interactive and non-interactive)
    $PSItem | Add-Member -NotePropertyName LastSignIn -NotePropertyValue $null -Force
    if ($PSItem.SignInActivity.LastNonInteractiveSignInDateTime -gt $PSItem.SignInActivity.LastSignInDateTime) {
        $PSItem.LastSignIn = $PSItem.SignInActivity.LastNonInteractiveSignInDateTime
    }
    else {
        $PSItem.LastSignIn = $PSItem.SignInActivity.LastSignInDateTime
    }
}

$users | Select-Object Id, OnPremisesDistinguishedName, LastSignIn