# iPhone Deployment Guide

This guide explains how to deploy SMSpam to a physical iPhone device for testing and distribution.

## Prerequisites

- macOS with latest stable version
- Xcode 15.0 or later
- iPhone running iOS 16.0 or later
- Apple Developer account (free or paid)
- USB cable to connect iPhone to Mac

## Step-by-Step Deployment

### 1. Prepare Your iPhone

1. Connect your iPhone to your Mac using a USB cable
2. On your iPhone, tap "Trust" when prompted to trust this computer
3. Go to Settings → General → Device Management & ensure your Mac is trusted

### 2. Configure Xcode Project

1. Open `SMSpam.xcodeproj` in Xcode
2. Select the SMSpam project in the project navigator
3. Select the SMSpam target
4. Go to the "Signing & Capabilities" tab
5. Check "Automatically manage signing"
6. Select your Apple ID from the Team dropdown
7. Ensure the Bundle Identifier is unique (typically `com.yourname.smspam`)

### 3. Set Up Provisioning Profiles

With automatic signing enabled:
- Xcode will create a development provisioning profile when you first build
- For distribution (App Store/TestFlight), you'll need to create distribution profiles in Apple Developer portal

### 4. Build and Run on iPhone

1. In Xcode's toolbar, select your iPhone from the device dropdown (should show your iPhone's name)
2. Click the Run button (⌘R) or select Product → Run
3. Xcode will:
   - Build the application
   - Install it on your iPhone
   - Launch the app automatically

### 5. Trust the Developer App (First Launch Only)

On your iPhone:
1. Go to Settings → General → VPN & Device Management
2. Under "Developer App", select your Apple ID
3. Tap "Trust [Your Name]"
4. Confirm trust

### 6. Test SMS Functionality

To test spam detection:
1. Send an SMS to your iPhone that matches your spam rules
2. The message should be moved to the Junk folder by iOS
3. Open SMSpam to see the logged spam message

## Common Issues and Solutions

### "Failed to create provisioning profile"
- Ensure you have an active internet connection
- Verify your Apple ID has two-factor authentication enabled
- Try manually signing in Xcode: Preferences → Accounts → + → Apple ID

### "Unable to install application"
- Check that your iPhone's iOS version meets the minimum requirement (iOS 16.0+)
- Ensure you have enough storage space on your iPhone
- Try restarting both your iPhone and Mac

### "App crashes on launch"
- Check the device console in Xcode (Window → Devices and Simulators → View Device Logs)
- Look for SMSpam crash logs
- Common causes: missing entitlements, incorrect App Group configuration

### Spam not being filtered
1. Verify the SpamFilterExtension is enabled:
   - Settings → Messages → Unknown & Spam → SMSpam Filter
2. Ensure you've granted SMS permission:
   - Settings → SMSpam → Toggle on "SMS & MMS"
3. Check that your App Group ID matches in both targets:
   - Main app: SMSpam → Signing & Capabilities → App Groups
   - Extension: SpamFilterExtension → Signing & Capabilities → App Groups
   - Both should have: `group.com.inan.smspam`

## App Store Distribution

### Preparing for Release
1. Change the build configuration from Debug to Release
2. In Signing & Capabilities, ensure you have a distribution certificate and provisioning profile
3. Increase the build number (CFBundleVersion) in the Info.plist
4. Archive the project: Product → Archive

### Uploading to App Store Connect
1. In the Archives window, select your archive and click "Distribute App"
2. Choose "App Store Connect" as the distribution method
3. Follow the prompts to upload your build
4. Complete the App Store Connect listing (screenshots, description, etc.)

## Ad Hoc/Enterprise Distribution
For internal testing:
1. Export as Ad Hoc or Enterprise instead of App Store Connect
2. Distribute the .ipa file via email, website, or MDM solution
3. Users must trust the developer profile on their devices (Settings → General → VPN & Device Management)

## Troubleshooting Tips

- Always check the device console for real-time logs
- Derived data can sometimes cause issues: delete `~/Library/Developer/Xcode/DerivedData`
- Clean build folder: Product → Clean Build Folder (⇧⌘K)
- Ensure both main app and extension targets have the same Swift version
- Verify that the extension's `Info.plist` has the `NSExtensionPointIdentifier` set to `com.apple.messages-filter`

## Security Notes

- Never hardcode signing credentials in your repository
- Keep your Apple ID secure with two-factor authentication
- For App Store distribution, use an App Store Connect API key instead of your password when possible