# Customization

Customize SMSpam to match your needs.

## Blocked Senders

### Adding Senders

1. Go to Settings → Rule Engine → Blocked Senders
2. Enter sender name or number
3. Tap Save

### Examples
```
xbank
ybank
spam123
+90 555 555 5555
```

## Regex Rules

### What is Regex?

Regex (Regular Expressions) are patterns that match text.

### Sender Regex

Block senders matching a pattern:
```regex
(\+90[\s\-]?\(?850\)?|0850)
```
Matches: +90 850 xxx xxxx, 0850 xxx xxxx, 90850xxxx

### Content Regex

Block messages matching patterns:
```regex
[A-Z]+i[A-Z]+
```
Matches: Corrupted Turkish text like "BANKAM"

### Common Patterns

| Pattern | Matches |
|---------|---------|
| `\d{10}` | 10 digits |
| `\+\d{2}\d+` | International numbers |
| `https?://` | URLs |
| `[A-Z]+` | All uppercase |

### Regex Reference

- `.` - Any character
- `\d` - Any digit
- `\w` - Word character
- `*` - Zero or more
- `+` - One or more
- `?` - Optional
- `()` - Group
- `[]` - Character class

## Keywords

### Adding Keywords

1. Go to Settings → Rule Engine → Keywords
2. Enter keyword
3. Tap Save

### Case Sensitivity

Keywords are case-insensitive by default:
- "BONUS" matches "bonus"
- "FreeBet" matches "freebet"

### Common Spam Keywords

```
bonus
freebet
freespin
jackpot
slot
çekim
cekim
bahis
yatirim
promo
kampanya
```

## Short URLs

### Default Patterns

```
t2m\.io
bit\.ly
tinyurl\.com
goo\.gl
ow\.ly
rb\.gy
cutt\.ly
```

### Adding Patterns

1. Go to Settings → Rule Engine → Short URL Regex
2. Enter domain pattern
3. Tap Save

## Best Practices

1. **Start Simple** - Begin with keywords before regex
2. **Test Thoroughly** - Test rules before adding more
3. **Use Whitelist** - Whitelist important contacts
4. **Keep Logs** - Review spam logs to refine rules
5. **Backup Settings** - Export settings regularly

## Resetting to Defaults

To reset all rules to default:
1. Go to Settings
2. Contact support for reset instructions
