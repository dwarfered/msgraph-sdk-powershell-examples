#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Beta.Applications"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        Finding SAML application token signing key expiry dates.

        NOTE: Requires Microsoft.Graph.Beta for the 'preferredTokenSigningKeyEndDateTime'
        attribute.

    .DESCRIPTION
    
    .NOTES
        AUTHOR: https://github.com/dwarfered/msgraph-sdk-powershell-examples
        UPDATED: 14-09-2023
#>

$requiredScopes = @('Application.Read.All')
$currentScopes = (Get-MgContext).Scopes
if ($currentScopes -match ([string]::Join('|', $requiredScopes)).Count -ne $requiredScopes.Count) {
    Connect-MgGraph -Scopes $requiredScopes | Out-Null
}

$params = @{
    'All'      = $true;
    'Filter'   = "accountEnabled eq true and preferredTokenSigningKeyEndDateTime ge 2021-01-02T12:00:00Z";
    'PageSize' = '999';
    'Select'   = 'preferredTokenSigningKeyEndDateTime,appDisplayName'
}

$samlPrincipals = Get-MgBetaServicePrincipal @params

$samlPrincipals = $samlPrincipals | Sort-Object PreferredTokenSigningKeyEndDateTime
| Select-Object AppDisplayName, 
@{
    Name       = 'Expiry Date Time'; 
    Expression = { $_.PreferredTokenSigningKeyEndDateTime.ToLocalTime(); }
},
@{
    Name       = 'Expiry Status'; 
    Expression = { 
        $expiry = $_.PreferredTokenSigningKeyEndDateTime.ToLocalTime()
        $dateSoon = (Get-Date).AddMonths(1)
        if ($expiry -gt (Get-Date) -and $expiry -lt $dateSoon) {
            'Expires Soon'
        }
        elseif ($expiry -lt (Get-Date)) {
            'Expired'
        }
        else {
            'Current'
        }
    }
}

$samlPrincipals | Format-Table