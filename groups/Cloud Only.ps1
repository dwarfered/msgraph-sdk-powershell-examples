#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Groups"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        Get-MgGroup cloud only objects.

    .DESCRIPTION
        An example of how to use Get-MgGroup to find all cloud only groups.

    .NOTES
        AUTHOR: Chris Dymond
        UPDATED: 19-08-2023
#>

Connect-MgGraph -Scopes @('Group.Read.All') | Out-Null

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