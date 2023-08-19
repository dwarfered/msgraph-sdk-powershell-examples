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
        AUTHOR: Chris Dymond
        UPDATED: 19-08-2023
#>

Connect-MgGraph -Scopes @('User.Read.All') | Out-Null

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