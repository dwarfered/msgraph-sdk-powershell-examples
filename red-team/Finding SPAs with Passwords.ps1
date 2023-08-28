#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Applications"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        Using Microsoft Graph to find Single Page Applications (SPAs) with defined credentials.

    .DESCRIPTION
        It is discouraged to associate SPA applications with Passwords or 
        Certificate credentials. SPA's are readable in the web browser.
        Exposed secrets can allow malicious actors to sign in and act as your 
        application, granting all of the application permissions that are
        assigned.

    .NOTES
        AUTHOR: Chris Dymond
        UPDATED: 28-08-2023
#>

$requiredScopes = @('Application.Read.All')
$currentScopes = (Get-MgContext).Scopes
if ($currentScopes -match ([string]::Join('|', $requiredScopes)).Count -ne $requiredScopes.Count) {
    Connect-MgGraph -Scopes $requiredScopes | Out-Null
}

$allApplications = Get-MgApplication -All -PageSize 999

$allApplicationsWithPasswords = $allApplications | Where-Object { $_.PasswordCredentials -ne $null }

$allSpaApplicationsWithPasswords = $allApplicationsWithPasswords `
| Where-Object { $_.Spa.RedirectUris.Count -ne 0 }