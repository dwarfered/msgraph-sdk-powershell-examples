#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Users"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        Get-MgUser where userPrincipalName starts with 'x'.

    .DESCRIPTION
        An example of how to use Get-MgUser to find all accounts with a 
        userPrincipalName starting with one or more prefixes. 

    .NOTES
        AUTHOR: https://github.com/dwarfered/msgraph-sdk-powershell-examples
        UPDATED: 16-09-2023
#>

$requiredScopes = @('User.Read.All')
$currentScopes = (Get-MgContext).Scopes
if (($currentScopes -match ([string]::Join('|', $requiredScopes))).Count -ne $requiredScopes.Count) {
    Connect-MgGraph -Scopes $requiredScopes | Out-Null
}

$upnPrefixes = @(
    'svc',
    'service'
)

$filter = ''

for ($i = 0; $i -lt $upnPrefixes.Count; $i++) {
    if ($i -eq 0) {
        $filter = "startsWith(userPrincipalName,'$($upnPrefixes[$i])')"
    }
    else {
        $filter += " OR startsWith(userPrincipalName,'$($upnPrefixes[$i])')"
    }
}

$users = Get-MgUser -All -PageSize 999 -Filter $filter

$users.UserPrincipalName