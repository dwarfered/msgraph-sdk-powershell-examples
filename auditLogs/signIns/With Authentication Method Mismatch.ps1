#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Reports"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        Finding authentication method mismatch errors.

        This occurs when the authentication method by which the user authenticated with the service doesn't match
        the requested authentication method defined by the provider.
         
    .NOTES
        AUTHOR: https://github.com/dwarfered/msgraph-sdk-powershell-examples
        UPDATED: 20-09-2023

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