#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Applications"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        Finding Application Registration Certificate & Secret expired and soon to be
        expired credentials. 
         
    .NOTES
        AUTHOR: https://github.com/dwarfered/msgraph-sdk-powershell-examples
        UPDATED: 15-09-2023
#>

$requiredScopes = @('Application.Read.All')
$currentScopes = (Get-MgContext).Scopes
if ($currentScopes -match ([string]::Join('|', $requiredScopes)).Count -ne $requiredScopes.Count) {
    Connect-MgGraph -Scopes $requiredScopes | Out-Null
}

$params = @{
    'All'      = $true;
    'PageSize' = '999';
    'Select'   = 'DisplayName, AppId, KeyCredentials, PasswordCredentials';
}

$applications = Get-MgApplication @params
| Where-Object { 
    $_.KeyCredentials -ne $null -or $_.PasswordCredentials -ne $null
}

foreach ($application in $applications) {
    
    foreach ($certificate in $application.KeyCredentials) {
        $expiry = $certificate.EndDateTime.ToLocalTime()
        $dateSoon = (Get-Date).AddMonths(1)
        $expiryStatus = $null
        if ($expiry -gt (Get-Date) -and $expiry -lt $dateSoon) {
            $expiryStatus = 'Expires Soon'
        }
        elseif ($expiry -lt (Get-Date)) {
            $expiryStatus = 'Expired'
        }
        else {
            $expiryStatus = 'Current'
        }
        $certificate | Add-Member -NotePropertyName ExpiryStatus -NotePropertyValue $expiryStatus -Force
    }

    foreach ($secret in $application.PasswordCredentials) {
        $expiry = $secret.EndDateTime.ToLocalTime()
        $dateSoon = (Get-Date).AddMonths(1)
        $expiryStatus = $null
        if ($expiry -gt (Get-Date) -and $expiry -lt $dateSoon) {
            $expiryStatus = 'Expires Soon'
        }
        elseif ($expiry -lt (Get-Date)) {
            $expiryStatus = 'Expired'
        }
        else {
            $expiryStatus = 'Current'
        }
        $secret | Add-Member -NotePropertyName ExpiryStatus -NotePropertyValue $expiryStatus -Force
    }

}

$expiredAndExpiring = $applications 
| Where-Object {
    $_.KeyCredentials.ExpiryStatus -in @('Expired', 'Expires Soon') -or
    $_.PasswordCredentials.ExpiryStatus -in @('Expired', 'Expires Soon')
}
| Select-Object DisplayName, AppId, KeyCredentials, PasswordCredentials

# Applications returned have at least one expired or expiring soon credential.
# $expiredAndExpiring.count
$expiredAndExpiring | Format-Table

