#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Applications"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        Finding Application Registration Certificates & Secrets that have expired or
        are soon to expire. 
         
    .NOTES
        AUTHOR: https://github.com/dwarfered/msgraph-sdk-powershell-examples
        UPDATED: 16-09-2023
#>

$requiredScopes = @('Application.Read.All')
$currentScopes = (Get-MgContext).Scopes
if (($currentScopes -match ([string]::Join('|', $requiredScopes))).Count -ne $requiredScopes.Count) {
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

$appCredentials = @()

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
        $certificate | Add-Member -NotePropertyName ExpiryStatus -NotePropertyValue $expiryStatus
        $certificate | Add-Member -NotePropertyName AppDisplayName -NotePropertyValue $application.DisplayName
        $certificate | Add-Member -NotePropertyName AppId -NotePropertyValue $application.AppId
        $certificate | Add-Member -NotePropertyName Kind -NotePropertyValue 'Certificate'
        $appCredentials += $certificate
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
        $secret | Add-Member -NotePropertyName ExpiryStatus -NotePropertyValue $expiryStatus
        $secret | Add-Member -NotePropertyName AppDisplayName -NotePropertyValue $application.DisplayName
        $secret | Add-Member -NotePropertyName AppId -NotePropertyValue $application.AppId
        $secret | Add-Member -NotePropertyName Kind -NotePropertyValue 'Client Secret'
        $appCredentials += $secret
    }

}

$appCredentials | Sort-Object EndDateTime 
| Select-Object AppDisplayName, AppId, Kind, ExpiryStatus,
@{
    Name       = 'Expiry Date Time'; 
    Expression = { $_.EndDateTime.ToLocalTime(); }
}
| Format-Table

