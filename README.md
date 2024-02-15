# Microsoft Graph - PowerShell SDK Examples

Identity and Access Management of Entra ID (Azure AD) via the PowerShell SDK for Microsoft Graph.

## Prerequisite
[PowerShell SDK for Microsoft Graph](https://github.com/microsoftgraph/msgraph-sdk-powershell)
```powershell
Install-Module Microsoft.Graph -AllowClobber -Force
```
Optionally, also install:
```powershell
Install-Module Microsoft.Graph.Beta -AllowClobber -Force
```

## Connect to Microsoft Graph

Using the Microsoft Graph Command Line Tools Enterprise Application
```powershell
Connect-MgGraph -Scopes @('')
```

Using an existing Access Token
```powershell
Connect-MgGraph -AccessToken (ConvertTo-SecureString 'ey..' -AsPlainText -Force)
```

Using an Application Registration (Platform: Mobile and desktop applications, redirect http://localhost)
```powershell
Connect-MgGraph -ClientId 'abc..' -TenantId 'abc..'
```

Using a ClientId and Secret (Password)
```powershell
$tenantId = ''
$clientId = ''
$secret = ConvertTo-SecureString '' -AsPlainText -Force
$secretCredential = New-Object System.Management.Automation.PSCredential ($clientId, $secret)
$params = @{
    'SecretCredential' = $secretCredential
    'TenantId'         = $tenantId
}
Connect-MgGraph @params
```

## Audit Logs
### [Authentication Method Mismatch](/auditLogs/signIns/authentication-method-mismatch.ps1)
> This Entra ID error occurs when the authentication method by which the user authenticated with the service doesn't match the requested authentication method defined by the provider.
### [Conditional Access Policy Failures](/auditLogs/signIns/conditional-access-policy-failures.ps1)
> Retrieving and storing current Conditional Access Policy sign-in failures.

## Application Registrations
### [Disabled or Invalid](/applications/disabled-or-invalid.ps1)
> Find Application Registrations that have been disabled or are missing their Enterprise Application instance (Service Principal).
### [With Credentials](/applications/With%20Credentials.ps1)
> Find Application Registrations with Password or Certificate Credentials.
### [With Certificate or Secret Expiry Status](/applications/With%20Certificate%20or%20Secret%20Expiry%20Status.ps1)
> Find Application Registration Certificate or Secret expiry status.
### [Without Owners](/applications//Without%20Owners.ps1)
> Find Application Registrations without assigned Owners.

## Service Principals
### [Add Microsoft Graph App Role Assignment](/servicePrincipals/Add%20Microsoft%20Graph%20App%20Roles.ps1)
> Adding a Microsoft Graph App Role to a Service Principal (Application/Managed Identity). ie. 'User.Read.All'
### [Where Enterprise Application](/servicePrincipals/Where%20Enterprise%20Application.ps1)
> Find all Enterprise Applications
### [Where Managed Identity](/servicePrincipals/Where%20Managed%20Identity.ps1)
> Find all Managed Identities
### [Where Microsoft Application](/servicePrincipals/Where%20Microsoft%20Application.ps1)
> Find all Microsoft Applications
### [With AppRoles Assigned from AppId](/servicePrincipals/With%20AppRoles%20Assigned%20From%20AppId.ps1)
> Find all Enterprise Applications with the ability to consumer services in Microsoft Graph, AAD Graph and O365 API without a signed in user.
### [With SAML Expiry Status](/servicePrincipals/With%20SAML%20Expiry%20Status.ps1)
> Find SAML SSO expiry status on enabled Enterprise Applications.

## Azure Automation Account
### [Acquire Access Token for Microsoft Graph](/azure-automation-account/Connect%20To%20Microsoft%20Graph.ps1)
> Retrieve an Access Token for Microsoft Graph from an Azure AD Automation Account Managed Identity.

## Identity Protection
### [Confirm User Compromised](/identityProtection/Confirm%20User%20Compromised.ps1)
> Confirm one or more riskyUser objects as compromised. This action sets the targeted user's risk level to high.

## Groups
### [Cloud Only](/groups/Cloud%20Only.ps1)
> Find all cloud only groups (those not synchronised from AD on-premises).

## Users
### [Cloud Only](users/Cloud%20Only.ps1)
> Find all cloud only accounts.
### [Guests](users/Guests.ps1)
> Find all Guest accounts.
### [Last Sign In Activity](users/Last%20Sign%20In%20Activity.ps1)
> Find the last sign-in activity of an account.
### [Members](users/Members.ps1)
> Find all Member accounts.
### [Password Change](/users/Password%20Change.ps1)
> Make a cloud or on-premises user change their password on their next sign-in to Azure. This cannot be used in conjunction with Passthrough Authentication.
### [Where Assigned Licenses](users/With%20Assigned%20Licenses.ps1)
> Find all accounts assigned licenses.
### [Where Email Address Is Value](users/Where%20Email%20Address%20Is%20Value.ps1)
> Find Member account by email address.
### [Where On-Premises Extension Attribute Is Value](users/Where%20AD%20onPremisesExtensionAttribute%20Is%20Value.ps1)
> Find all Member accounts by on-premises extensionAttribute.
### [Where UserPrincipalName Starts With](/users/Where%20UserPrincipalName%20Starts%20With.ps1)
> Find accounts by User Principal Name prefix.


## Conditional Access

### [Policies](identity/conditional%20access/Policies.ps1)
> Find all Conditional Access Policies.

### Templates

[Zero Trust Persona-based Azure AD Conditional Access Policies](https://github.com/dwarfered/ConditionalAccessforZeroTrust)

## Red Team
### [Finding Global Administrators](/red-team/Finding%20Global%20Administrators.ps1)
> Find accounts with the Global Administrator role using an access token acquired for the Azure Portal (Entra).
### [Finding Single Page Applications with Passwords](/red-team/Finding%20SPAs%20with%20Passwords.ps1)
> Find Application Registrations for Single Page Applications that contain secrets.

## Miscellaneous
### [Client Credentials Flow](/native-powershell/Client%20Credentials%20Flow.ps1)
> Obtaining an Access Token for Microsoft Graph using the Application Client Credentials grant using native PowerShell and the Invoke-RestMethod cmdlet.
### [Device Code Flow](/native-powershell/Device%20Code%20Flow.ps1)
>  Obtaining an Access Token for Microsoft Graph using the Device Code grant and PowerShell with the Invoke-RestMethod cmdlet.