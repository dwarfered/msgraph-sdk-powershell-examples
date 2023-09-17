#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Groups"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        Get-MgGroup cloud only objects.

    .DESCRIPTION
        An example of how to use Get-MgGroup to find all cloud only groups.

    .NOTES
        AUTHOR: https://github.com/dwarfered/msgraph-sdk-powershell-examples
        UPDATED: 16-09-2023
#>

$requiredScopes = @('Group.Read.All')
$currentScopes = (Get-MgContext).Scopes
if (($currentScopes -match ([string]::Join('|', $requiredScopes))).Count -ne $requiredScopes.Count) {
    Connect-MgGraph -Scopes $requiredScopes | Out-Null
}

<#>
    onPremisesSyncEnabled
        'true' if this group is synced from an on-premises directory; 
        'false' if this group was originally synced from an on-premises directory but is no longer synced;
        'null' if this object has never been synced from an on-premises directory (default). 
#>

$params = @{
    'All'              = $true;
    'PageSize'         = '999';
    'Filter'           = 'onPremisesSyncEnabled ne true';
    'ConsistencyLevel' = 'eventual';
    'CountVariable'    = 'groupCount'

}

$groups = Get-MgGroup @params