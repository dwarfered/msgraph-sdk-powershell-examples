#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.13.1" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Applications"; ModuleVersion="2.13.1" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        Find all disabled application registrations and those that have had their 
        Enterprise Application (Service Principal) deleted.

    .DESCRIPTION
    
    .NOTES
        AUTHOR: https://github.com/dwarfered/msgraph-sdk-powershell-examples
        UPDATED: 15-02-2024
#>

$requiredScopes = @('Application.Read.All')
$currentScopes = (Get-MgContext).Scopes

if ($null -eq $currentScopes) {
    Connect-MgGraph -Scopes $requiredScopes | Out-Null
} elseif (($currentScopes -match ([string]::Join('|', $requiredScopes))).Count -ne $requiredScopes.Count) {
    Connect-MgGraph -Scopes $requiredScopes | Out-Null
}

$allApplications = Get-MgApplication -All -PageSize 999 -Select @('DisplayName', 'AppId')

$servicePrincipals = Get-MgServicePrincipal -All -PageSize 999 -Select AppId, AccountEnabled
$servicePrincipals = $servicePrincipals | Group-Object -AsHashTable { $_.AppId }  

$disabledApplications = @()
$invalidApplications = @()

$allApplications | ForEach-Object {
    $sp = $servicePrincipals[$PSItem.AppId]
    if ($null -eq $sp) {
        # The application registration has no instance (Service Principal / Enterprise Application)
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