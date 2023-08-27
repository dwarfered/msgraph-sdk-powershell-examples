# Microsoft Graph - PowerShell SDK Examples

Identity and Access Management of Entra ID (Azure AD) via the PowerShell SDK for Microsoft Graph.

## Prerequisite
[PowerShell SDK for Microsoft Graph](https://github.com/microsoftgraph/msgraph-sdk-powershell)
```powershell
Install-Module Microsoft.Graph -AllowClobber -Force
```

## Connect to Microsoft Graph

```powershell
# Using the Microsoft Graph Command Line Tools Enterprise Application
Connect-MgGraph -Scopes @('')
# Using an existing Access Token
Connect-MgGraph -AccessToken (ConvertTo-SecureString 'ey..'-AsPlainText -Force)
# Using an Application Registration (Platform: Mobile and desktop applications, redirect http://localhost)
Connect-MgGraph -ClientId 'abc..' -TenantId 'abc..'
```

## Users

- [Cloud Only](users/Cloud%20Only.ps1)
- [Guests](users/Guests.ps1)
- [Last Sign In Activity](users/Last%20Sign%20In%20Activity.ps1)
- [Members](users/Members.ps1)
- [With AD ExtensionAttribute Value](users/With%20AD%20ExtensionAttribute.ps1)
- [With Assigned Licenses](users/With%20Assigned%20Licenses.ps1)
- [With Email Address Value](users/With%20Email%20Address.ps1)
- [With UserPrincipalName Starting With](/users/With%20UserPrincipalName%20Starting%20With.ps1)

## Conditional Access

- [Policies](identity/conditional%20access/Policies.ps1)

### Templates

Zero Trust Persona-based Azure AD Conditional Access Policies

Based upon the excellent [Microsoft Learn: Conditional Access architecture and personas](https://learn.microsoft.com/en-us/azure/architecture/guide/security/conditional-access-architecture) and [Framework and policies](https://learn.microsoft.com/en-us/azure/architecture/guide/security/conditional-access-framework) pages authored by [Claus Jespersen](https://www.linkedin.com/in/claus-jespersen-25b0422/).

> Note that for clarity, I have deviated to the following naming convention: <br> **Persona**-**PolicyType**-**App/User Action**-**Condition**-**AccessControl**<br>

<small>*This collection is a work in progress*.</small>

- [Guests-BaseProtection-AllApps-MFA](/identity/conditional%20access/templates/Guests-BaseProtection-AllApps-MFA.ps1)
- [Guests-DataProtection-AllApps-SignInSessionPolicy](/identity/conditional%20access/templates/Guests-DataProtection-AllApps-SignInSessionPolicy.ps1)
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
