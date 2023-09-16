#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Applications"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        Find all application registrations with credentials.

    .DESCRIPTION
    
    .NOTES
        AUTHOR: https://github.com/dwarfered/msgraph-sdk-powershell-examples
        UPDATED: 16-09-2023
#>

$requiredScopes = @('Application.Read.All')
$currentScopes = (Get-MgContext).Scopes
if ($currentScopes -match ([string]::Join('|', $requiredScopes)).Count -ne $requiredScopes.Count) {
    Connect-MgGraph -Scopes $requiredScopes | Out-Null
}

$applications = Get-MgApplication -All -PageSize 999
| Where-Object { $_.KeyCredentials -ne $null -or $_.PasswordCredentials -ne $null }



