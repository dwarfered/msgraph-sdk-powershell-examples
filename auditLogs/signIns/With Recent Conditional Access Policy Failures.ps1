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

$caPolicySignInFailures = @{}

$since = (Get-MgAuditLogSignIn -Top 1).CreatedDateTime
$sinceAsStr = $since.ToString('yyyy-MM-ddTHH:mm:ssZ')
$fileOutputSuffix = $since.ToLocalTime().ToString('yyyy-MM-ddTHH-mm-ss')

while ($true) {
    $params = @{
        'All'      = $true;
        'Filter'   = "conditionalAccessStatus eq 'failure' and isInteractive eq true and createdDateTime gt $sinceAsStr";
        'PageSize' = '999';
    }

    $signIns = Get-MgAuditLogSignIn @params
    Clear-Host
    # Write-Host -ForegroundColor Yellow "Results: $($signIns.Count)"

    # Graph appears to not respect seconds in the filter, so a further check here is used.
    $signIns = $signIns | Where-Object {$_.CreatedDateTime -gt $since}
    $signIns = $signIns | Sort-Object CreatedDateTime
    # Write-Host -ForegroundColor Yellow "Results to Process: $($signIns.Count)"

    if ($signIns.Count -ne 0 ) {
        $sinceAsStr = ($signIns | Select-Object -Last 1).CreatedDateTime.ToString('yyyy-MM-ddTHH:mm:ssZ')
        $since = ($signIns | Select-Object -Last 1).CreatedDateTime
    }

    foreach ($signIn in $signIns) {
        $failedPolicies = $signIn.AppliedConditionalAccessPolicies 
        | Where-Object { $_.Result -eq 'failure' }

        foreach ($failedPolicy in $failedPolicies) {

            $signInDetail = [PSCustomObject]@{
                UserPrincipalName = $signIn.UserPrincipalName
                AppDisplayName    = $signIn.AppDisplayName
                CreatedDateTime   = $signIn.CreatedDateTime
                ErrorCode         = $signIn.Status.ErrorCode
                FailureReason     = $signIn.Status.FailureReason
                AdditionalDetails = $signIn.Status.AdditionalDetails
                DeviceBrowser = $signIn.DeviceDetail.Browser
                DeviceId = $signIn.DeviceDetail.DeviceId
                DeviceDisplayName = $signIn.DeviceDetail.DisplayName
                DeviceIsCompliant = $signIn.DeviceDetail.IsCompliant
                DeviceIsManaged = $signIn.DeviceDetail.IsManaged
                DeviceOperatingSystem = $signIn.DeviceDetail.OperatingSystem
                DeviceTrustType = $signIn.DeviceDetail.TrustType
            }

            if ($caPolicySignInFailures.ContainsKey($failedPolicy.Id)) {
                $item = $caPolicySignInFailures[$failedPolicy.Id]
                $item.FailureCount +=1
                $item.FailureSignIns += $signInDetail

                $sanitisedFilename = $failedPolicy.DisplayName.Replace('/', '')
                $outFile = "./$sanitisedFilename-$fileOutputSuffix.csv"
                $signInDetail 
                | ConvertTo-Csv -NoTypeInformation 
                | Select-Object -Skip 1 
                | Out-File $outFile -Append

            }
            else {
                $detail = [PSCustomObject]@{
                    PolicyName = $failedPolicy.DisplayName
                    PolicyId   = $failedPolicy.Id
                    FailureCount      = 1
                    FailureSignIns    = @($signInDetail)
                }
                $caPolicySignInFailures.Add($failedPolicy.Id, $detail)

                $sanitisedFilename = $failedPolicy.DisplayName.Replace('/', '')
                $outFile = "./$sanitisedFilename-$fileOutputSuffix.csv"
                $signInDetail 
                | ConvertTo-Csv -NoTypeInformation 
                | Out-File $outFile
            }
        }
    }

    $caPolicySignInFailures.GetEnumerator() 
    | Select-Object -ExpandProperty Value 
    | Select-Object PolicyName, FailureCount | Format-Table

    Write-Host -ForegroundColor Yellow "Refreshing in 5 seconds. To stop press CTRL + C"

    Start-Sleep -Seconds 5

}