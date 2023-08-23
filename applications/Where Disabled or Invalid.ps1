#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Applications"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        Find all first-party disabled applications and those that have had their 
        Enterprise Application (Service Principal) deleted.

    .DESCRIPTION
    
    .NOTES
        AUTHOR: Chris Dymond
        UPDATED: 23-08-2023
#>

Connect-MgGraph -Scopes @('Application.Read.All') | Out-Null

$allApplications = Get-MgApplication -All -PageSize 999 -Select @('DisplayName', 'AppId')

$servicePrincipals = Get-MgServicePrincipal -All -PageSize 999 -Select AppId, AccountEnabled
$servicePrincipals = $servicePrincipals | Group-Object -AsHashTable { $_.AppId }  

$disabledApplications = @()
$invalidApplications = @()

$allApplications | ForEach-Object {
    $sp = $servicePrincipals[$PSItem.AppId]
    if ($null -eq $sp) {
        $invalidApplications += $PSItem
    }
    elseif ($sp.AccountEnabled -eq $false) {
        $disabledApplications += $PSITem
    }
}

Write-Output "Disabled Applications $($disabledApplications.Count)"
#$disabledApplications | Select-Object DisplayName, AppId
Write-Output "Invalid Applications $($invalidApplications.Count)"
#$invalidApplications | Select-Object DisplayName, AppId