# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability within SMSpam, please report it responsibly.

### How to Report

1. **Do NOT** create a public GitHub issue for security vulnerabilities
2. Send a detailed report to the project maintainer
3. Include the following information:
   - Type of vulnerability
   - Full paths of source file(s) related to the vulnerability
   - Location of the affected source code
   - Step-by-step instructions to reproduce the issue
   - Proof-of-concept or exploit code (if possible)
   - Impact of the issue

### What to Expect

- Acknowledgment of your report within 48 hours
- Regular updates on the progress
- Credit for the discovery (unless you prefer to remain anonymous)

## Security Best Practices

### For Users

- Keep your iOS device updated to the latest version
- Only install SMSpam from official sources (App Store or this GitHub repository)
- Review app permissions before installation

### For Developers

- All code changes must pass security review
- No external network calls without explicit user consent
- All data processing happens locally on-device
- No personal data is collected or transmitted

## Privacy

SMSpam is designed with privacy in mind:

- **No Data Collection** - We don't collect any personal data
- **Local Processing** - All message analysis happens on your device
- **No External Servers** - No data is sent to external servers
- **No Analytics** - No third-party analytics or tracking

## Dependencies

We regularly update dependencies to ensure security:
- SwiftUI (Apple framework)
- Standard iOS frameworks only
- No third-party dependencies in the main app

## Security Updates

Security updates will be released as patch versions (e.g., 1.0.1) and announced through:
- GitHub Releases
- Project README updates
