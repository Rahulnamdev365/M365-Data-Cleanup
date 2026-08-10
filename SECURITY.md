# Security Policy

## Reporting a Security Issue

Please do not publicly disclose security vulnerabilities through GitHub Issues.

Security issues should be reported privately through the repository's GitHub security reporting mechanism when available.

## Sensitive Information

Never include the following in issues, pull requests, logs, screenshots, or discussions:

- Microsoft 365 credentials
- Access tokens
- Refresh tokens
- Client secrets
- Private keys
- Certificates
- Tenant secrets
- Employee personal information
- Mailbox contents
- Compliance case information
- Production deletion logs

## Responsible Testing

Do not test destructive functionality against production Microsoft 365 data without appropriate authorization.

Use a dedicated development or test tenant whenever possible.

## Design Principle

The project must never intentionally bypass:

- Microsoft Purview retention
- eDiscovery holds
- Litigation Holds
- Legal holds
- Microsoft 365 security controls