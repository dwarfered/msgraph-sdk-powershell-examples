#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Groups"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        Get all Microsoft 365 Groups and their current Owners.

    .DESCRIPTION
        
    .NOTES
        AUTHOR: https://github.com/dwarfered/msgraph-sdk-powershell-examples
        UPDATED: 24-10-2023
#>

$requiredScopes = @('Group.Read.All', 'User.Read.All')
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
    'Filter'   = "(groupTypes/any(c:c eq 'Unified'))";
    'Expand'   = 'owners($select=id,userPrincipalName,displayName)';
    'Select'   = 'id,displayName';
}

$m365groups = Get-MgGroup @params
$m365groupsWithOwners = $m365groups | Where-Object { $_.Owners.Count -ne 0 }

$m365groupsWithOwners | Select-Object Id, DisplayName, Owners
| Select-Object Id, DisplayName, @{
    Name       = 'OwnersUpn';
    Expression = { $_.Owners.AdditionalProperties.userPrincipalName -join ', ' }
},
@{
    Name       = 'OwnersDisplayName';
    Expression = { $_.Owners.AdditionalProperties.displayName -join ', ' }
}
| Export-Csv -Path ".\output.csv" -NoTypeInformation
