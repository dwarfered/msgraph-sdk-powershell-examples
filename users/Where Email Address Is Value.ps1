#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Users"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        Get-MgUser where proxyAddresses contains email address 'x'.

    .DESCRIPTION
        An example of how to use Get-MgUser to find an account with a particular
        email address.

    .NOTES
        AUTHOR: https://github.com/dwarfered/msgraph-sdk-powershell-examples
        UPDATED: 16-09-2023
#>

$requiredScopes = @('User.Read.All')
$currentScopes = (Get-MgContext).Scopes
if (($currentScopes -match ([string]::Join('|', $requiredScopes))).Count -ne $requiredScopes.Count) {
    Connect-MgGraph -Scopes $requiredScopes | Out-Null
}

$smtpProxyAddress = 'smtp:someone@domain.com'

$params = @{
    'Filter' = "proxyAddresses/any(x:x eq '$smtpProxyAddress')";
}

$user = Get-MgUser @params

$user.UserPrincipalName