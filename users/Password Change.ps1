#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Users"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        Make a cloud or on-premises user change their password on their next sign-in to Azure.

    .NOTES
        AUTHOR: https://github.com/dwarfered/msgraph-sdk-powershell-examples
        UPDATED: 01-10-2023

        https://learn.microsoft.com/en-us/graph/api/resources/users?view=graph-rest-1.0#who-can-perform-sensitive-actions

        forceChangePasswordNextSignIn cannot be used in conjunction with Passthrough Authentication.
#>

$requiredScopes = @('Directory.AccessAsUser.All')
$currentScopes = (Get-MgContext).Scopes

if ($null -eq $currentScopes) {
    Connect-MgGraph -Scopes $requiredScopes | Out-Null
} elseif (($currentScopes -match ([string]::Join('|', $requiredScopes))).Count -ne $requiredScopes.Count) {
    Connect-MgGraph -Scopes $requiredScopes | Out-Null
}

$params = @{
	passwordProfile = @{
		forceChangePasswordNextSignIn = $true
	}
}

$userId = $null

Update-MgUser -UserId $userId -BodyParameter $params
