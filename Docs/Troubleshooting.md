# Troubleshooting

Common issues and solutions.

## Installation Issues

### Cannot Open Xcode Project

**Problem:** Xcode cannot open the project file.

**Solution:**
1. Ensure Xcode 15.0+ is installed
2. Delete derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData`
3. Reopen the project

### Build Fails

**Problem:** Build fails with errors.

**Solution:**
1. Update Xcode to latest version
2. Clean build folder: `Cmd + Shift + K`
3. Delete DerivedData folder
4. Try building again

## Runtime Issues

### App Crashes on Launch

**Problem:** App closes immediately after opening.

**Solution:**
1. Force quit the app
2. Restart your device
3. Reinstall the app
4. Check iOS version (requires 16.0+)

### Spam Not Being Detected

**Problem:** Spam messages are not being blocked.

**Solution:**
1. Check if SMS permission is granted
2. Verify whitelist doesn't include spam sender
3. Check spam rules are configured
4. Review spam logs for detection

### Language Change Not Working

**Problem:** Changing language doesn't update UI.

**Solution:**
1. Close and reopen the app
2. Check the selected language is supported
3. Force quit and restart
4. Reinstall if issue persists

## Configuration Issues

### Regex Not Working

**Problem:** Custom regex patterns don't match.

**Solution:**
- Test regex at [regex101.com](https://regex101.com)
- Ensure proper escaping
- Check for typos
- Use simple patterns first

### Keywords Not Matching

**Problem:** Keywords don't block messages.

**Solution:**
1. Keywords are case-insensitive
2. Check spelling
3. Try partial matches
4. Add variations

## Data Issues

### Spam Logs Empty

**Problem:** No logs showing.

**Solution:**
1. Check if spam is actually being received
2. Verify detection rules are active
3. Check if messages are from new senders
4. Review log settings

### Cannot Clear Logs

**Problem:** Delete logs option not working.

**Solution:**
1. Ensure you're in Settings
2. Navigate to Log Settings
3. Confirm deletion when prompted

## Performance Issues

### App Running Slow

**Problem:** UI is laggy or slow.

**Solution:**
1. Reduce log count in settings
2. Close background apps
3. Restart device
4. Update to latest iOS

## Getting Help

If issues persist:
1. Check [GitHub Issues](https://github.com/tubekinan/SMSpam/issues)
2. Search for similar problems
3. Create new issue with details
4. Include device and iOS version

## Known Limitations

- Requires iOS 16.0 or later
- May not detect all spam types
- Whitelist overrides all rules
- Logs have maximum storage limit
