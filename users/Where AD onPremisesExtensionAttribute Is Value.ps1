#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Users"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        Get-MgUser where extensionAttribute is 'x'.

    .DESCRIPTION
        An example of how to use Get-MgUser to find all accounts with a particular
        extensionAttribute value. 

            extensionAttribute1-15 are available as part of the exchange ad schema.

    .NOTES
        AUTHOR: https://github.com/dwarfered/msgraph-sdk-powershell-examples
        UPDATED: 16-09-2023
#>

$requiredScopes = @('User.Read.All')
$currentScopes = (Get-MgContext).Scopes
if ($currentScopes -match ([string]::Join('|', $requiredScopes)).Count -ne $requiredScopes.Count) {
    Connect-MgGraph -Scopes $requiredScopes | Out-Null
}

$extensionValue = 'yourValue'

$params = @{
    'All'              = $true;
    'Filter'           = "onPremisesExtensionAttributes/extensionAttribute1 eq '$extensionValue'";
    'CountVariable'    = 'userCount';
    'ConsistencyLevel' = 'eventual';
    'PageSize'         = '999';
}

$allUsersWithExtensionAttributeValue = Get-MgUser @params

$allUsersWithExtensionAttributeValue.UserPrincipalName