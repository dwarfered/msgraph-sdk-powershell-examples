#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.13.1" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Reports"; ModuleVersion="2.13.1" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        Finding authentication method mismatch errors.

        This occurs when the authentication method by which the user authenticated with the service doesn't match
        the requested authentication method defined by the provider (ie. for SAML providers)

        Example:
        AADSTS75011: Authentication method 'X509, MultiFactor' by which the user authenticated with the service
        doesn't match requested authentication method 'Password, ProtectedTransport'. 
        Contact the <APP NAME> application owner.
 
        Solution:
        The RequestedAuthnContext is an optional value and can be removed from their configuration.
        Alternatively set urn:oasis:names:tc:SAML:2.0:ac:classes:unspecified on the SAML SP.

         
    .NOTES
        AUTHOR: https://github.com/dwarfered/msgraph-sdk-powershell-examples
        UPDATED: 15-02-2024

        https://learn.microsoft.com/en-us/troubleshoot/azure/active-directory/error-code-aadsts75011-auth-method-mismatch

#>

$requiredScopes = @('AuditLog.Read.All', 'Directory.Read.All')
$currentScopes = (Get-MgContext).Scopes

if ($null -eq $currentScopes) {
    Connect-MgGraph -Scopes $requiredScopes | Out-Null
}
elseif (($currentScopes -match ([string]::Join('|', $requiredScopes))).Count -ne $requiredScopes.Count) {
    Connect-MgGraph -Scopes $requiredScopes | Out-Null
}

$params = @{
    'All'      = $true;
    'PageSize' = '999';
    'Filter'   = "status/errorCode eq 75011";
}

$results = Get-MgAuditLogSignIn @params

$results | Group-Object AppId | Sort-Object -Descending Count | Select-Object Count,
@{
    Name       = 'AffectedApp'; 
    Expression = { $_.Group.AppDisplayName[0]; }
}