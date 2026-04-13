# Getting Started

This guide will help you set up and start using SMSpam.

## Installation

### From Source Code

1. **Clone the Repository**
   ```bash
   git clone https://github.com/tubekinan/SMSpam.git
   cd SMSpam
   ```

2. **Open in Xcode**
   ```bash
   open SMSpam.xcodeproj
   ```

3. **Configure Signing**
   - Select the SMSpam target
   - Go to "Signing & Capabilities"
   - Select your development team
   - Enable "Automatic signing"

4. **Build and Run**
   - Select your target device or simulator
   - Press `Cmd + R` to build and run

### Requirements

| Requirement | Version |
|-------------|---------|
| macOS | Latest stable |
| Xcode | 15.0+ |
| iOS | 16.0+ |
| Swift | 5.9+ |

## First Launch

When you first launch SMSpam:

1. The app will request necessary permissions
2. Grant SMS access when prompted
3. The home screen will display

## Navigation

### Home Screen

- **Logo** - App branding
- **Statistics** - Total and today's spam counts
- **Recent Logs** - Latest blocked messages
- **Settings** - Access via gear icon

### Settings Screen

- **Language** - Change app language
- **Whitelist** - Manage trusted senders
- **Rule Engine** - Customize spam detection
- **Log Settings** - Configure log storage

## Next Steps

- [Customize Spam Rules](Customization.md)
- [Manage Whitelist](User-Guide.md#whitelist)
- [Change Language](Localization.md)
