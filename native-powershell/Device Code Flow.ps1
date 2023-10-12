$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
    Obtaining an Access Token for Microsoft Graph using the Device Code grant and 
    PowerShell with the Invoke-RestMethod cmdlet.

    .DESCRIPTION
    
    .NOTES
        AUTHOR: https://github.com/dwarfered/msgraph-sdk-powershell-examples
        UPDATED: 12-10-2023
#>

#region Supporting Functions
function Get-TokenUsingDeviceFlow {
    [CmdletBinding()]
    param
    (
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1)]
        [string] $TenantId,
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [string] $ClientId,
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1)]
        [string] $Scope
    )
    process {
        $scope = $Scope
        $uri = "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/devicecode"

        $headers = @{}
        $headers.Add("Content-Type", "application/x-www-form-urlencoded")

        $body = @{
            scope     = $Scope
            client_id = $ClientId
        }

        $deviceCodeRequest = Invoke-RestMethod -Uri $uri -Method POST -Headers $headers -Body $body
        $expires = (Get-Date).AddSeconds($deviceCodeRequest.expires_in)
        $deviceCodeRequest | Add-Member -NotePropertyName expires -NotePropertyValue $expires
        Write-Host $deviceCodeRequest.message

        # Request Token

        $uri = " https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token"
        $body = @{
            tenant      = $tenantId
            grant_type  = 'urn:ietf:params:oauth:grant-type:device_code'
            client_id   = $clientId
            device_code = $deviceCodeRequest.device_code
        }

        $bearerAccessToken = $null

        if ($deviceCodeRequest.interval) {
            do {
                Start-Sleep -Seconds $deviceCodeRequest.interval
                $errMsg = $null
                try {
                    $bearerAccessToken = Invoke-RestMethod -Uri $uri -Method POST -Headers $headers -Body $body
                    $expires = (Get-Date).AddSeconds($bearerAccessToken.expires_in)
                    $bearerAccessToken | Add-Member -NotePropertyName expires -NotePropertyValue $expires
                }
                catch {
                    if ($_.Exception -is [System.Net.Http.HttpRequestException]) {
                        $errMsg = $_.ErrorDetails
                        $errMsg = (ConvertFrom-Json $errMsg).error
                        Write-Host $errMsg
                        if ($errMsg -eq 'invalid_client') {
                            Write-Host -ForegroundColor Yellow "Does $clientId allow public client flows?"
                            throw $_
                        }
                    }
                    else {
                        throw $_
                    }
                }
            } while ($errMsg -eq 'authorization_pending')
        }

        $bearerAccessToken
    }
}
#endRegion

$tenantId = 'common'

# Client that allows public flows i.e. Azure AD PowerShell
$clientId = '1b730954-1685-4b74-9bfd-dac224a7b894'

$msGraphScope = 'https://graph.microsoft.com/.default'
$aadGraphScope = 'https://graph.windows.net/.default'

$msGraphToken = Get-TokenUsingDeviceFlow -TenantId $tenantId -ClientId $clientId -Scope $msGraphScope
$aadToken = Get-TokenUsingDeviceFlow -TenantId $tenantId -ClientId $clientId -Scope $aadGraphScope