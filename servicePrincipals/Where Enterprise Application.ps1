#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Applications"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        Finding all Enterprise Application Service Principals.
    
    .NOTES
        AUTHOR: https://github.com/dwarfered/msgraph-sdk-powershell-examples
        UPDATED: 12-10-2023
#>

$requiredScopes = @('Application.Read.All')
$currentScopes = (Get-MgContext).Scopes

if ($null -eq $currentScopes) {
    Connect-MgGraph -Scopes $requiredScopes | Out-Null
} elseif (($currentScopes -match ([string]::Join('|', $requiredScopes))).Count -ne $requiredScopes.Count) {
    Connect-MgGraph -Scopes $requiredScopes | Out-Null
}

$params = @{
    'All'      = $true;
    'Filter'   = "tags/Any(x: x eq 'WindowsAzureActiveDirectoryIntegratedApp')";
    'PageSize' = '999';
}

$enterpriseApplications = Get-MgServicePrincipal @params

$enterpriseApplications | Format-List