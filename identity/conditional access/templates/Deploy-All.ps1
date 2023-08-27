$ErrorActionPreference = 'stop'

./Guests-BaseProtection-AllApps-MFA.ps1
./Guests-DataProtection-AllApps-SignInSessionPolicy.ps1
./Guests-IdentityProtection-AllApps-LegacyAuthenticationClients-Block.ps1
./Guests-IdentityProtection-AllApps-MediumOrHighRisk-MFA.ps1

./Internals-AttackSurfaceReduction-AllApps-UnknownPlatforms-Block.ps1
./Internals-BaseProtection-AllApps-MFAorCompliantDeviceOrDomainJoined.ps1
./Internals-DataProtection-O365-MobileDevices-ApprovedAppsAndAppProtection.ps1
./Internals-DataProtection-O365-UnmanagedDevice-AppEnforcedRestrictions.ps1
./Internals-IdentityProtection-AllApps-HighSignInRisk-MFA.ps1
./Internals-IdentityProtection-AllApps-HighUserRisk-MFAandPasswordChange.ps1
./Internals-IdentityProtection-AllApps-LegacyAuthenticationClients-Block.ps1
./Internals-IdentityProtection-RegisterSecurityInfo-BYODOrUntrustedLocation-MFA.ps1