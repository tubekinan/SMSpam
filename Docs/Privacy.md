# Privacy & Security

SMSpam is designed with privacy as a core principle.

## Privacy Principles

### 1. Local Processing

All message analysis happens on your device:
- No data sent to external servers
- No cloud processing
- No internet connection required

### 2. No Data Collection

We don't collect:
- Personal information
- Message content
- Contact lists
- Location data
- Usage statistics

### 3. Open Source

The source code is publicly available:
- Anyone can inspect the code
- Community can verify privacy claims
- No hidden functionality

## Data Storage

### What Data is Stored?

| Data | Location | Purpose |
|------|----------|---------|
| Spam logs | Device | Display blocked messages |
| Settings | Device | Remember your preferences |
| Language | UserDefaults | Remember language choice |
| Custom rules | Device | Your spam rules |

### Where is Data Stored?

- All data stored locally on device
- Uses iOS secure storage
- Not synced to iCloud
- Not backed up to computer

## Permissions

### SMS Access

SMSpam requires SMS access to:
- Read incoming messages
- Analyze message content
- Identify spam patterns

### Why SMS Access?

Without SMS access, the app cannot:
- Analyze message content
- Detect spam patterns
- Block unwanted messages

## Security Measures

### Code Security

- No external network calls
- No third-party analytics
- Minimal dependencies
- Regular security reviews

### Data Security

- Local storage only
- iOS security framework
- No sensitive data transmission

## Your Rights

You have the right to:
- Access your data
- Delete your data
- Stop using the app anytime
- Export your settings

## Contact

For privacy concerns:
- Open an issue on GitHub
- Check our [SECURITY.md](https://github.com/tubekinan/SMSpam/blob/main/SECURITY.md)

## Updates

This privacy policy may be updated:
- Changes will be noted in releases
- Major changes will be announced
- Continued use implies acceptance
