$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        Obtaining an Access Token for Microsoft Graph using the Application Client Credentials
        grant using native PowerShell and the Invoke-RestMethod cmdlet.

    .DESCRIPTION
    
    .NOTES
        AUTHOR: https://github.com/dwarfered/msgraph-sdk-powershell-examples
        UPDATED: 12-10-2023
#>

$clientId = ''
$clientSecret = ''
$tenantId = ''

$grantType = 'client_credentials'
$scope = 'https://graph.microsoft.com/.default'
$uri = "https://login.microsoftonline.com/$($tenantId)/oauth2/v2.0/token"

$headers = @{}
$headers.Add("Content-Type", "application/x-www-form-urlencoded")

$body = @{
    scope         = $scope
    grant_type    = $grantType
    client_id     = $clientId
    client_secret = $clientSecret
}

# There is no refresh-token for the client_credentials flow
$bearerAccessToken = Invoke-RestMethod -Uri $uri -Method POST -Headers $headers -Body $body
$expires = (Get-Date).AddSeconds($bearerAccessToken.expires_in)
$bearerAccessToken | Add-Member -NotePropertyName expires -NotePropertyValue $expires

$bearerAccessToken