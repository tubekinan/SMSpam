# Frequently Asked Questions

Common questions about SMSpam.

## General

### What is SMSpam?

SMSpam is an iOS application that automatically detects and blocks spam SMS messages using customizable rules and regex patterns.

### Is SMSpam free?

Yes, SMSpam is free and open source under the MIT license.

### Does SMSpam work on iPad?

Currently optimized for iPhone. iPad support may be added in future versions.

### What iOS version is required?

iOS 16.0 or later is required.

## Privacy

### Does SMSpam send my data anywhere?

No. All processing happens locally on your device. No data is sent to external servers.

### Does SMSpam collect personal information?

No personal data is collected, stored externally, or shared with third parties.

### Can I delete my data?

Yes. You can clear spam logs and uninstall the app at any time.

## Functionality

### How does spam detection work?

SMSpam uses multiple detection methods:
- Sender name/number matching
- Regex pattern matching
- Keyword filtering
- Short URL detection

### Can I customize spam rules?

Yes. You can add custom:
- Blocked senders
- Regex patterns
- Keywords
- Short URL patterns

### What is the whitelist?

Numbers or patterns in the whitelist are never blocked, even if they match spam rules.

### How many logs can I store?

Default is 200 logs. You can adjust this in Settings.

### Does it work with all SMS apps?

SMSpam works with the default iOS Messages app and any app that uses the standard SMS filtering API.

## Languages

### How many languages are supported?

7 languages: Turkish, English, German, French, Spanish, Chinese, Japanese.

### Can I add a new language?

Yes. See the [Localization Guide](Localization.md) for instructions.

### How do I change the language?

Go to Settings → Language and select your preferred language.

## Technical

### Why does the app need SMS permission?

SMS permission is required to read and analyze incoming messages for spam detection.

### Does the app need internet?

No internet connection is required. All analysis happens on-device.

### Is the source code available?

Yes, the project is open source and available on GitHub.

## Support

### How can I report a bug?

Create an issue on [GitHub](https://github.com/tubekinan/SMSpam/issues) with:
- Steps to reproduce
- Device and iOS version
- Screenshots if applicable

### How can I request a feature?

Create a feature request on [GitHub](https://github.com/tubekinan/SMSpam/issues) with:
- Description of the feature
- Use case
- Any examples or mockups

### Can I contribute?

Yes! See [CONTRIBUTING.md](https://github.com/tubekinan/SMSpam/blob/main/CONTRIBUTING.md) for guidelines.

## Troubleshooting

### Spam is not being detected

1. Check SMS permission is granted
2. Verify whitelist doesn't include the sender
3. Review spam rules in Settings
4. Check spam logs for detection

### App is slow

1. Reduce log count in Settings
2. Restart your device
3. Update to latest iOS version

### Language won't change

1. Force quit and reopen the app
2. Check selected language is supported
3. Reinstall the app if needed

## Still have questions?

- Check [GitHub Discussions](https://github.com/tubekinan/SMSpam/discussions)
- Open an [Issue](https://github.com/tubekinan/SMSpam/issues)
