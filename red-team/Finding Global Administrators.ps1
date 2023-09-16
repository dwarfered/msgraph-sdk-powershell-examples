#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Identity.DirectoryManagement"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        Using Microsoft Graph to find Global Administrators.

    .DESCRIPTION
        An example of how to use directoryRoles to discover Global Administrator accounts.

        This assumes acquisition of an access token from a standard member user logging into
        Azure Active Directory via the Azure Portal.
            
            $accessToken = ConvertTo-SecureString 'ey...' -AsPlainText -Force
            Connect-MgGraph -AccessToken $accessToken

    .NOTES
        AUTHOR: https://github.com/dwarfered/msgraph-sdk-powershell-examples
        UPDATED: 16-09-2023
#>

$params = @{
    'All'              = $true;
    'Filter'           = "DisplayName eq 'Global Administrator'";
}

$globalAdministratorRoleId = Get-MgDirectoryRole @params | Select-Object -ExpandProperty Id
<#
    Every tenant has unique ids for the instance of the built-in roles
    This first query finds the RoleId of the Global Administrator
#>

$globalAdministrators = Get-MgDirectoryRoleMember -DirectoryRoleId $globalAdministratorRoleId -All

$globalAdministrators.AdditionalProperties.userPrincipalName