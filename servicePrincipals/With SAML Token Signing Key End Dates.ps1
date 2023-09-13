#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Beta.Applications"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        Finding SAML application token signing key expiry dates.

        NOTE - requires the beta cmdlet to select preferredTokenSigningKeyEndDateTime

    .DESCRIPTION
    
    .NOTES
        AUTHOR: Chris Dymond
        UPDATED: 12-09-2023
#>

$requiredScopes = @('Application.Read.All')
$currentScopes = (Get-MgContext).Scopes
if ($currentScopes -match ([string]::Join('|', $requiredScopes)).Count -ne $requiredScopes.Count) {
    Connect-MgGraph -Scopes $requiredScopes | Out-Null
}

$params = @{
    'All'      = $true;
    'Filter'   = "accountEnabled eq true";
    'PageSize' = '999';
    'Select'   = 'preferredTokenSigningKeyEndDateTime,appDisplayName'
}

$allPrincipals = Get-MgBetaServicePrincipal @params

$samlPrincipals = $allPrincipals | Where-Object { $_.PreferredTokenSigningKeyEndDateTime -ne $null }

$samlPrincipals = $samlPrincipals | Sort-Object PreferredTokenSigningKeyEndDateTime
| Select-Object AppDisplayName, 
@{
    Name       = 'SigningKeyEndAsLocalDateTime'; 
    Expression = { $_.PreferredTokenSigningKeyEndDateTime.ToLocalTime(); }
},
@{
    Name       = 'State'; 
    Expression = { if ($_.PreferredTokenSigningKeyEndDateTime.ToLocalTime() -lt (Get-Date)) { 'Expired' } else { 'Active' } }
}

$samlPrincipals