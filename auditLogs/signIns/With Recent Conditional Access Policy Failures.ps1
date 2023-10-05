#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.3.0" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Reports"; ModuleVersion="2.3.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS

    Retrieving recent Conditional Access Policy sign-in failures 

    Failure: The sign-in satisfied the user and application condition of at least one Conditional Access policy and grant controls are either not satisfied or set to block access.
         
    .NOTES
        AUTHOR: https://github.com/dwarfered/msgraph-sdk-powershell-examples
        UPDATED: 20-09-2023

        https://learn.microsoft.com/en-us/azure/active-directory/capFailedSignInss-monitoring/concept-sign-in-log-activity-details?tabs=basic-info#considerations-for-sign-in-logs

#>

<#
    For a user delegated sign-in (to read CA Policy) they must be also be one of the following:
    Global Administrator
    Global Reader
    Security Administrator
    Security Reader
    Conditional Access Administrator
#>

$requiredScopes = @('AuditLog.Read.All', 'Directory.Read.All')
$currentScopes = (Get-MgContext).Scopes

if ($null -eq $currentScopes) {
    Connect-MgGraph -Scopes $requiredScopes | Out-Null
}
elseif (($currentScopes -match ([string]::Join('|', $requiredScopes))).Count -ne $requiredScopes.Count) {
    Connect-MgGraph -Scopes $requiredScopes | Out-Null
}

$since = (Get-Date).AddHours(-1).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')

$params = @{
    'All'      = $true;
    'Filter'   = "conditionalAccessStatus eq 'failure' and createdDateTime ge $since";
    'PageSize' = '999';
}

$signins = Get-MgAuditLogSignIn @params

$capFailedSignIns = @{}

foreach ($signIn in $signIns) {
    
    $failedPolicies = $signIn.AppliedConditionalAccessPolicies 
    | Where-Object { $_.Result -eq 'failure' }

    foreach ($failedPolicy in $failedPolicies) {
        if ($capFailedSignIns.ContainsKey($failedPolicy.Id)) {
            $signInDetail = [PSCustomObject]@{
                UserPrincipalName = $signIn.UserPrincipalName
                AppDisplayName    = $signIn.AppDisplayName
                CreatedDateTime   = $signIn.CreatedDateTime
                ErrorCode         = $signIn.Status.ErrorCode
                FailureReason     = $signIn.Status.FailureReason
                AdditionalDetails = $signIn.Status.AdditionalDetails
            }

            $capFailedSignIns[$failedPolicy.Id].FailedSignIns += $signInDetail

        }
        else {
            $signInDetail = [PSCustomObject]@{
                UserPrincipalName = $signIn.UserPrincipalName
                AppDisplayName    = $signIn.AppDisplayName
                CreatedDateTime   = $signIn.CreatedDateTime
                ErrorCode         = $signIn.Status.ErrorCode
                FailureReason     = $signIn.Status.FailureReason
                AdditionalDetails = $signIn.Status.AdditionalDetails
            }

            $detail = [PSCustomObject]@{
                PolicyName   = $failedPolicy.DisplayName
                FailedSignIns = @($signInDetail)
            }
            $capFailedSignIns.Add($failedPolicy.Id, $detail)

        }
    }

}

foreach ($key in $capFailedSignIns.Keys) {
    $item = $capFailedSignIns[$key]
    Write-Output "Policy Name: $($item.PolicyName)"
    Write-Output "Policy Id: $($key)"
    Write-Output "Failed SignIns: $($item.failedSignIns.Count)"
    Write-Output "Unique User Failed SignIns: $(($item.failedSignIns | Select-Object -Unique UserPrincipalName).Count)"
    Write-Output ""
}

Write-Host -ForegroundColor Yellow "For the detail of these signins use:"
Write-Host -ForegroundColor Yellow "`$capFailedSignIns['<PolicyId>'].FailedSignIns"
Write-Host ''