#Requires -Modules @{ ModuleName="ExchangeOnlineManagement"; ModuleVersion="3.4.0" }

$ErrorActionPreference = 'stop'

<#
    .SYNOPSIS
        Limiting application permissions to specific Exchange Online mailboxes

        By default, apps that have been granted application permissions to the following data sets can access all the mailboxes
        in the organization:

            Calendars
            Contacts
            Mail
            Mailbox settings

            Mail.Read
            Mail.ReadBasic
            Mail.ReadBasic.All
            Mail.ReadWrite
            Mail.Send
            MailboxSettings.Read
            MailboxSettings.ReadWrite
            Calendars.Read
            Calendars.ReadWrite
            Contacts.Read
            Contacts.ReadWrite

    .DESCRIPTION
        Changes to application access policies can take longer than 1 hour to take effect in Microsoft Graph REST API calls.

    .NOTES
        AUTHOR: https://github.com/dwarfered/msgraph-sdk-powershell-examples
        UPDATED: 31-10-2023
#>

Connect-ExchangeOnline

$clientId = ''
# UserMailbox, MailUser or MailUniversalSecurityGroup (containing mailboxes)
$policyScopeGroupId = ''
$description = ''

$params = @{
    AppId = $clientId
    PolicyScopeGroupId = $policyScopeGroupId
    AccessRight = 'RestrictAccess'
    Description = $description
}

# Exchange role required: OrganizationConfiguration 
New-ApplicationAccessPolicy @params

<#
    Outcome when the clinetId targets a mailbox that is not in Policy Scope

    Access to OData is disabled.
    Status: 403 (Forbidden)
    ErrorCode: ErrorAccessDenied
    
#>
