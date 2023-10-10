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

$startDateTime = (Get-MgAuditLogSignIn -Top 1).CreatedDateTime
$since = $startDateTime.ToString('yyyy-MM-ddTHH:mm:ssZ')
$fileOutputSuffix = $startDateTime.ToLocalTime().ToString('yyyy-MM-ddTHH-mm-ss')

Write-Host -ForegroundColor Yellow "To stop press CTRL + C"

while ($true) {
    $params = @{
        'All'      = $true;
        'Filter'   = "conditionalAccessStatus eq 'failure' and createdDateTime gt $since";
        'PageSize' = '999';
    }

    $signins = Get-MgAuditLogSignIn @params

    if ($signIns) {
        $signIns = $signIns | Sort-Object CreatedDateTime
        $since = ($signIns | Select-Object -First 1).CreatedDateTime.ToString('yyyy-MM-ddTHH:mm:ssZ')
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
            }

            if ($caPolicySignInFailures.ContainsKey($failedPolicy.Id)) {
                $caPolicySignInFailures[$failedPolicy.Id].caPolicySignInFailures += $signInDetail
                $caPolicySignInFailures[$failedPolicy.Id].caPolicySignInFailuresCount += 1

                $sanitisedFilename = $failedPolicy.DisplayName.Replace('/','')
                $outFile = "./$sanitisedFilename-$fileOutputSuffix.csv"
                $signInDetail 
                | ConvertTo-Csv -NoTypeInformation 
                | Select-Object -Skip 1 
                | Out-File $outFile -Append

            }
            else {
                $detail = [PSCustomObject]@{
                    PolicyName                  = $failedPolicy.DisplayName
                    PolicyId                    = $failedPolicy.Id
                    caPolicySignInFailuresCount = 1
                    caPolicySignInFailures      = @($signInDetail)
                }
                $caPolicySignInFailures.Add($failedPolicy.Id, $detail)

                $sanitisedFilename = $failedPolicy.DisplayName.Replace('/','')
                $outFile = "./$sanitisedFilename-$fileOutputSuffix.csv"
                $signInDetail 
                | ConvertTo-Csv -NoTypeInformation 
                | Out-File $outFile
            }
        }
    }

    $caPolicySignInFailures.GetEnumerator() 
    | Select-Object -ExpandProperty Value 
    | Select-Object PolicyName, CAPolicySignInFailuresCount | Format-Table

    Start-Sleep -Seconds 5

}