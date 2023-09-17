# Microsoft Graph - PowerShell SDK Examples

Identity and Access Management of Entra ID (Azure AD) via the PowerShell SDK for Microsoft Graph.

## Prerequisite
[PowerShell SDK for Microsoft Graph](https://github.com/microsoftgraph/msgraph-sdk-powershell)
```powershell
Install-Module Microsoft.Graph -AllowClobber -Force
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

## Applications
### [Where Disabled or Invalid](/applications/Where%20Disabled%20or%20Invalid.ps1)
> Find Application Registrations that have been disabled or are missing their Enterprise Application instance.
### [With Credentials](/applications/With%20Credentials.ps1)
> Find Application Registrations with Password or Certificate Credentials.
### [With Certificate or Secret Expiry Status](/applications/With%20Certificate%20or%20Secret%20Expiry%20Status.ps1)
> Find Application Registration Certificate or Secret expiry status.
### [Without Owners](/applications//Without%20Owners.ps1)
> Find Application Registrations without assigned Owners.

## Service Principals
### [Add Microsoft Graph App Role Assignment](/servicePrincipals/Add%20Microsoft%20Graph%20App%20Roles.ps1)
> Adding a Microsoft Graph App Role to a Service Principal. ie. 'User.Read.All'
### [With SAML Expiry Status](/servicePrincipals/With%20SAML%20Expiry%20Status.ps1)
> Find SAML SSO expiry status on enabled Enterprise Applications.

## Azure Automation Account
### [Acquire Access Token for Microsoft Graph](/azure-automation-account/Connect%20To%20Microsoft%20Graph.ps1)
> Retrieve an Access Token for Microsoft Graph from an Azure AD Automation Account Managed Identity.

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
### [Where Assigned Licenses](users/With%20Assigned%20Licenses.ps1)
> Find all accounts assigned licenses.
### [Where Email Address Is Value](users/Where%20Email%20Address%20Is%20Value.ps1)
> Find Member account by email address.
### [Where On-Premises Extension Attribute Is Value](users/Where%20AD%20onPremisesExtensionAttribute%20Is%20Value.ps1)
> Find all Member accounts by on-premises extensionAttribute.
### [Where UserPrincipalName Starts With](/users/Where%20UserPrincipalName%20Starts%20With.ps1)
> Find accounts by User Principal Name prefix.


## Conditional Access

- [Policies](identity/conditional%20access/Policies.ps1)

### Templates

Zero Trust Persona-based Azure AD Conditional Access Policies

Based upon the excellent [Microsoft Learn: Conditional Access architecture and personas](https://learn.microsoft.com/en-us/azure/architecture/guide/security/conditional-access-architecture) and [Framework and policies](https://learn.microsoft.com/en-us/azure/architecture/guide/security/conditional-access-framework) pages authored by [Claus Jespersen](https://www.linkedin.com/in/claus-jespersen-25b0422/).

> Note that for clarity, I have deviated to the following naming convention: <br> **Persona**-**PolicyType**-**App/User Action**-**Condition**-**AccessControl**<br>

<small>*This collection is a work in progress*.</small>

#### [Guests-BaseProtection-AllApps-MFA](/identity/conditional%20access/templates/Guests-BaseProtection-AllApps-MFA.ps1)
> Guests must perform MFA for all applications.
#### [Guests-DataProtection-AllApps-SignInSessionPolicy](/identity/conditional%20access/templates/Guests-DataProtection-AllApps-SignInSessionPolicy.ps1)
> Guest may only sign-in for a limited time to all applications.
- [Guests-IdentityProtection-AllApps-LegacyAuthenticationClients-Block](/identity/conditional%20access/templates/Guests-IdentityProtection-AllApps-LegacyAuthenticationClients-Block.ps1)
- [Guests-IdentityProtection-AllApps-MediumOrHighRisk-MFA](/identity/conditional%20access/templates/Guests-IdentityProtection-AllApps-MediumOrHighRisk-MFA.ps1)

- [Internals-AttackSurfaceReduction-AllApps-UnknownPlatforms-Block](/identity/conditional%20access/templates/Internals-AttackSurfaceReduction-AllApps-UnknownPlatforms-Block.ps1)
- [Internals-BaseProtection-AllApps-MFAorCompliantDeviceOrDomainJoined](/identity/conditional%20access/templates/Internals-BaseProtection-AllApps-MFAorCompliantDeviceOrDomainJoined.ps1)
- [Internals-DataProtection-O365-MobileDevices-ApprovedAppsAndAppProtection](/identity/conditional%20access/templates/Internals-DataProtection-O365-MobileDevices-ApprovedAppsAndAppProtection.ps1)
- [Internals-DataProtection-O365-UnmanagedDevice-AppEnforcedRestrictions](/identity/conditional%20access/templates/Internals-DataProtection-O365-UnmanagedDevice-AppEnforcedRestrictions.ps1)
- [Internals-IdentityProtection-AllApps-HighSignInRisk-MFA](/identity/conditional%20access/templates/Internals-IdentityProtection-AllApps-HighSignInRisk-MFA.ps1)
- [Internals-IdentityProtection-AllApps-HighUserRisk-MFAandPasswordChange](/identity/conditional%20access/templates/Internals-IdentityProtection-AllApps-HighUserRisk-MFAandPasswordChange.ps1)
- [Internals-IdentityProtection-AllApps-LegacyAuthenticationClients-Block](/identity/conditional%20access/templates/Internals-IdentityProtection-AllApps-LegacyAuthenticationClients-Block.ps1)
- [Internals-IdentityProtection-RegisterSecurityInfo-BYODOrUntrustedLocation-MFA](/identity/conditional%20access/templates/Internals-IdentityProtection-RegisterSecurityInfo-BYODOrUntrustedLocation-MFA.ps1)

## Red Team
- [Finding Global Administrators](/red-team/Finding%20Global%20Administrators.ps1)
- [Finding Single Page Applications with Passwords](/red-team/Finding%20SPAs%20with%20Passwords.ps1)