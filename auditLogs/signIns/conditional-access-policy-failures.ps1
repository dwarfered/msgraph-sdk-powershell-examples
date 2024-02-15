#Requires -Modules @{ ModuleName="Microsoft.Graph.Authentication"; ModuleVersion="2.13.1" }
#Requires -Modules @{ ModuleName="Microsoft.Graph.Reports"; ModuleVersion="2.13.1" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS

    Retrieving and storing current Conditional Access Policy sign-in failures.

    Failure: The sign-in satisfied the user and application condition of at least one Conditional Access policy and grant controls are either not satisfied or set to block access.
         
    .NOTES
        AUTHOR: https://github.com/dwarfered/msgraph-sdk-powershell-examples
        UPDATED: 15-02-2024

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

$EXCLUDE_MFA_CHALLENGES = $true
$caPolicySignInFailures = @{}
$since = (Get-MgAuditLogSignIn -Top 1).CreatedDateTime
$sinceAsStr = $since.ToString('yyyy-MM-ddTHH:mm:ssZ')
$fileOutputSuffix = $since.ToLocalTime().ToString('yyyy-MM-ddTHH-mm-ss')
$filter = "conditionalAccessStatus eq 'failure'"
$filter += " and isInteractive eq true and createdDateTime gt $sinceAsStr"
while ($true) {
    $params = @{
        'All'      = $true;
        'Filter'   = $filter;
        'PageSize' = '999';
    }
    $signIns = Get-MgAuditLogSignIn @params
    Clear-Host
    # Graph appears to not respect seconds in the filter, so a further check here is used.
    $signIns = $signIns | Where-Object { $_.CreatedDateTime -gt $since }
    $signIns = $signIns | Sort-Object CreatedDateTime
    if ($signIns.Count -ne 0 ) {
        $since = ($signIns | Select-Object -Last 1).CreatedDateTime
        $sinceAsStr = $since.ToString('yyyy-MM-ddTHH:mm:ssZ')
    }
    foreach ($signIn in $signIns) {
        $failedPolicies = $signIn.AppliedConditionalAccessPolicies `
        | Where-Object { $_.Result -eq 'failure' }
        foreach ($failedPolicy in $failedPolicies) {
            $signInDetail = [PSCustomObject]@{
                UserPrincipalName     = $signIn.UserPrincipalName
                AppDisplayName        = $signIn.AppDisplayName
                CreatedDateTime       = $signIn.CreatedDateTime
                ErrorCode             = $signIn.Status.ErrorCode
                FailureReason         = $signIn.Status.FailureReason
                AdditionalDetails     = $signIn.Status.AdditionalDetails
                DeviceBrowser         = $signIn.DeviceDetail.Browser
                DeviceId              = $signIn.DeviceDetail.DeviceId
                DeviceDisplayName     = $signIn.DeviceDetail.DisplayName
                DeviceIsCompliant     = $signIn.DeviceDetail.IsCompliant
                DeviceIsManaged       = $signIn.DeviceDetail.IsManaged
                DeviceOperatingSystem = $signIn.DeviceDetail.OperatingSystem
                DeviceTrustType       = $signIn.DeviceDetail.TrustType
            }
            # 50072 UserStrongAuthEnrollmentRequiredInterrupt
            # 50074 UserStrongAuthClientAuthNRequiredInterrupt
            # 50076 UserStrongAuthClientAuthNRequired
            # 500121 The user didn't complete the MFA prompt.
            if ($EXCLUDE_MFA_CHALLENGES -and $signIn.Status.ErrorCode -in @('50074', '50076')) {
            }
            else {
                if ($caPolicySignInFailures.ContainsKey($failedPolicy.Id)) {
                    $item = $caPolicySignInFailures[$failedPolicy.Id]
                    $item.FailureCount += 1
                    $item.FailureSignIns += $signInDetail
        
                    $sanitisedFilename = $failedPolicy.DisplayName.Replace('/', '')
                    $outFile = "./$sanitisedFilename-$fileOutputSuffix.csv"
                    $signInDetail `
                    | ConvertTo-Csv -NoTypeInformation `
                    | Select-Object -Skip 1 `
                    | Out-File $outFile -Append
                }
                else {
                    $detail = [PSCustomObject]@{
                        PolicyName     = $failedPolicy.DisplayName
                        PolicyId       = $failedPolicy.Id
                        FailureCount   = 1
                        FailureSignIns = @($signInDetail)
                    }
                    $caPolicySignInFailures.Add($failedPolicy.Id, $detail)
        
                    $sanitisedFilename = $failedPolicy.DisplayName.Replace('/', '')
                    $outFile = "./$sanitisedFilename-$fileOutputSuffix.csv"
                    $signInDetail `
                    | ConvertTo-Csv -NoTypeInformation `
                    | Out-File $outFile
                }
            }
        }
    }
    $caPolicySignInFailures.GetEnumerator() `
    | Select-Object -ExpandProperty Value `
    | Select-Object PolicyName, FailureCount | Format-Table
    Write-Host -ForegroundColor Yellow "Refreshing in 5 seconds. To stop press CTRL + C"
    Start-Sleep -Seconds 5
}
