# User Guide

Complete guide to using SMSpam.

## Home Screen

### Viewing Statistics

The home screen displays:
- **Total Spam** - Number of blocked spam messages
- **Today's Spam** - Messages blocked today
- **Recent Logs** - Last 5 blocked messages

### Spam Log Details

Tap on any spam log to see:
- Full message content
- Sender information
- Spam type/category
- Detection time

### Spam Categories

| Category | Description | Icon |
|----------|-------------|------|
| Banking | Fake banking messages | 🏦 |
| Gambling | Casino/betting spam | 🎰 |
| Suspicious Link | Shortened URL messages | 🔗 |
| General | Other spam | ⚠️ |

## Settings

### Language

Change the app language:
1. Go to Settings
2. Select Language
3. Choose from 7 languages
4. App refreshes with new language

### Whitelist

Whitelisted numbers are never blocked.

#### Adding to Whitelist

**By Content:**
1. Go to Settings → Whitelist
2. Tap "Add New"
3. Enter sender text
4. Tap Save

**By Regex:**
1. Go to Settings → Whitelist
2. Select "Sender Regex"
3. Enter regex pattern
4. Tap Save

### Rule Engine

Customize how spam is detected.

#### Blocked Senders

Add sender names/numbers to block:
```
akbank
isbank
garanti
```

#### Sender Regex

Block senders matching patterns:
```
(\+90[\s\-]?\(?850\)?|0850)
```

#### Content Regex

Block messages matching text patterns:
```
[A-Z]+i[A-Z]+
```

#### Keywords

Block messages containing specific words:
```
bonus
freebet
jackpot
```

#### Short URL Patterns

Block shortened URLs:
```
t2m\.io
bit\.ly
tinyurl\.com
```

### Log Settings

- **Maximum Logs** - Set how many logs to keep (default: 200)
- Logs are automatically deleted when limit is reached

## Viewing Logs

### Filter by Type

Filter spam logs by category:
1. Tap filter icon on home screen
2. Select spam type
3. View filtered results

### Clear Logs

Clear all spam logs:
1. Go to Settings → Log Settings
2. Select "Clear All Logs"
3. Confirm deletion
