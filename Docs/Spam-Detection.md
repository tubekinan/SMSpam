# Spam Detection

Learn how SMSpam detects and blocks spam messages.

## Detection Methods

SMSpam uses multiple detection methods:

### 1. Sender Analysis

Checks the sender information:
- Sender name/number
- Matches against blocked senders list
- Case-insensitive comparison

### 2. Sender Regex

Advanced pattern matching on sender:
```regex
(\+90[\s\-]?\(?850\)?|0850)
```
Matches Turkish spam number formats.

### 3. Content Regex

Pattern matching on message body:
```regex
[A-Z]+i[A-Z]+
```
Detects corrupted Turkish text often used in spam.

### 4. Keyword Matching

Checks for spam keywords:
- gambling terms
- promotional words
- scam indicators

### 5. Short URL Detection

Identifies suspicious shortened URLs:
- bit.ly
- t2m.io
- tinyurl.com
- goo.gl
- ow.ly
- And many more...

## Spam Categories

### Banking Spam

Detects fake banking messages:
- Impersonating banks
- Fake security alerts
- Account verification scams

### Gambling Spam

Blocks casino/betting promotions:
- Free spin offers
- Bonus claims
- Betting advertisements

### Suspicious Links

Identifies messages with:
- Shortened URLs
- Suspicious domains
- Phishing links

### General Spam

Catches other spam types:
- Marketing messages
- Subscription scams
- Prize scams

## Default Rules

### Blocked Senders
```
xbank
ybank
ybankasi


```

### Spam Patterns
```
(\+90[\s\-]?\(?850\)?|0850|90850)
[A-Z]+i[A-Z]+
```

### Keywords
```
bonus
freespin
freebet
jackpot
slot
çekim
bahis
yatırım
```

## How Detection Works

1. SMS received
2. Check whitelist → Allow if matched
3. Check blocked senders → Block if matched
4. Check sender regex → Block if matched
5. Check content regex → Block if matched
6. Check keywords → Block if matched
7. Check short URLs → Block if matched
8. Allow message

## Customization

See [Customization Guide](Customization.md) to modify detection rules.
