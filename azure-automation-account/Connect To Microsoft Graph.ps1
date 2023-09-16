#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        Retrieving an Access Token for Microsoft Graph from an Automation Account
        Managed Identity.
        
    .DESCRIPTION
        Using an Azure Automation Account Managed Identity to get an Access Token to 
        connect to Microsoft Graph.

    .NOTES
        AUTHOR: https://github.com/dwarfered/msgraph-sdk-powershell-examples
        UPDATED: 16-09-2023
#>

#region Supporting Functions
function Get-ManagedIdentityMsGraphAccessToken {
    [CmdletBinding()]
    [OutputType([securestring])]
    param()
    process {
        $headers = [System.Collections.Generic.Dictionary[string, string]]::new()
        $headers.Add("X-IDENTITY-HEADER", $env:IDENTITY_HEADER) 
        $headers.Add("Metadata", "True") 

        $body = @{resource = 'https://graph.microsoft.com/' } 
        $params = @{
            Uri         = $env:IDENTITY_ENDPOINT;
            Method      = 'POST';
            Headers     = $headers;
            ContentType = 'application/x-www-form-urlencoded';
            Body        = $body;
        }
        $graphAccessToken = Invoke-RestMethod @params
        ConvertTo-SecureString $graphAccessToken.access_token -AsPlainText -Force
    }
}
#endRegion

$accessToken = Get-ManagedIdentityMsGraphAccessToken
Connect-MgGraph -AccessToken $accessToken | Out-Null