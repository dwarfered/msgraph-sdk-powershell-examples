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
        AUTHOR: Chris Dymond
        UPDATED: 19-08-2023
#>

Connect-MgGraph -Scopes @('User.Read.All') | Out-Null

$smtpProxyAddress = 'smtp:someone@domain.com'

$params = @{
    'Filter' = "proxyAddresses/any(x:x eq '$smtpProxyAddress')";
}

$user = Get-MgUser @params

$user.UserPrincipalName