# SMSpam - iOS SMS Spam Blocker

A modern iOS application that automatically detects and blocks spam SMS messages using customizable rules and regex patterns.

![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![iOS](https://img.shields.io/badge/iOS-16.0+-blue)
![License](https://img.shields.io/badge/License-MIT-green)

## Features

- **Automatic Spam Detection** - Analyzes SMS messages using customizable rules
- **Whitelist Management** - Add trusted senders that will never be blocked
- **Regex Rules** - Create powerful patterns to match spam messages
- **Keyword Filtering** - Block messages containing specific keywords
- **Short URL Detection** - Identify suspicious shortened URLs
- **Spam Logging** - Track blocked messages with detailed information
- **Multi-language Support** - Available in 8 languages (Turkish, English, German, French, Spanish, Chinese, Japanese, Kurdish)
- **Modern UI** - Clean, native iOS design with SwiftUI

## Screenshots

*Screenshots coming soon*

## Requirements

- iOS 16.0 or later
- Xcode 15.0 or later
- Swift 5.9

## Installation

1. Clone the repository:
```bash
git clone https://github.com/tubekinan/SMSpam.git
```

2. Open `SMSpam.xcodeproj` in Xcode

3. Select a simulator or connected device

4. Press `Cmd + R` to build and run

## Usage

### Home Screen
- View blocked spam messages
- Filter by spam type (Banking, Gambling, Suspicious Link, General)
- Tap on a log to see full message details

### Settings
- **Language** - Switch between 8 supported languages
- **Whitelist** - Add trusted phone numbers or patterns
- **Rule Engine** - Customize spam detection rules:
  - Blocked Senders
  - Sender Regex
  - Content Regex
  - Keywords
  - Short URL Patterns
- **Log Settings** - Configure maximum log storage

### Spam Types
- **Banking** - Fake banking and financial scams
- **Gambling** - Casino and betting promotions
- **Suspicious Link** - Messages with shortened URLs
- **General** - Other spam content

## Architecture

```
SMSpam/
├── ContentView.swift      # Main UI components
├── LanguageManager.swift  # Localization handling
├── SMSpamApp.swift        # App entry point
├── Assets.xcassets/       # App icons and images
├── de.lproj/             # German translations
├── en.lproj/             # English translations
├── es.lproj/             # Spanish translations
├── fr.lproj/             # French translations
├── ja.lproj/             # Japanese translations
├── ku.lproj/             # Kurdish translations
├── tr.lproj/             # Turkish translations
└── zh-Hans.lproj/        # Simplified Chinese translations
SpamFilterExtension/       # Message filtering extension
```

## Default Spam Rules

### Blocked Senders
- akbank, isbank, isbankasi, finansbank, fibabanka

### Spam Patterns
- Turkish number patterns: `(\+90[\s\-]?\(?850\)?|0850|90850)`
- Corrupted Turkish text: `[A-Z]+i[A-Z]+`

### Gambling Keywords
- bonus, freespins, freebet, jackpot, slot, çekim, bahis, yatırım, etc.

### Short URL Patterns
- t2m.io, bit.ly, tinyurl.com, goo.gl, ow.ly, rb.gy, cutt.ly

## Localization

The app supports 8 languages. To add a new language:

1. Create a new `.lproj` folder (e.g., `pt.lproj`)
2. Copy `Localizable.strings` from another language
3. Translate all key-value pairs
4. Add the language to `LanguageManager.swift`

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Privacy

SMSpam processes all messages locally on your device. No personal data is sent to external servers. All analysis happens on-device to protect your privacy.

## Contact

- GitHub: [@tubekinan](https://github.com/tubekinan)
