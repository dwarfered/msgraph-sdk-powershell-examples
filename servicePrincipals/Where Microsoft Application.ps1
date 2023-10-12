#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.7.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Beta.Applications"; ModuleVersion="2.7.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        Finding all Microsoft Application Service Principals.
    
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
    'Filter'   = "appOwnerOrganizationId eq f8cdef31-a31e-4b4a-93e4-5f571e91255a";
    'PageSize' = '999';
    'ConsistencyLevel' = 'eventual'; 
    'CountVariable'    = 'principalCount';
}

$microsoftApplications = Get-MgServicePrincipal @params

$microsoftApplications | Format-List
