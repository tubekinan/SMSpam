# Localization

SMSpam supports 7 languages.

## Supported Languages

| Language | Code | Native Name |
|----------|------|-------------|
| Turkish | tr | Türkçe |
| English | en | English |
| German | de | Deutsch |
| French | fr | Français |
| Spanish | es | Español |
| Chinese (Simplified) | zh-Hans | 中文 |
| Japanese | ja | 日本語 |

## Changing Language

1. Open SMSpam
2. Go to Settings
3. Select Language
4. Choose your language
5. App refreshes automatically

## Adding New Languages

### Step 1: Create .lproj Folder

Create a new folder:
```
SMSpam/de.lproj
```

### Step 2: Create Localizable.strings

Create the translation file:
```bash
touch SMSpam/de.lproj/Localizable.strings
```

### Step 3: Add Translations

Add key-value pairs:
```strings
"app.name" = "SMSpam";
"settings.title" = "Settings";
"settings.language" = "Language";
```

### Step 4: Update LanguageManager.swift

Add to `supportedLanguages`:
```swift
("de", "German", "Deutsch")
```

### Step 5: Add to BundleLanguage

Add to `supportedLanguageCodes`:
```swift
"de"
```

## Translation Keys

### General
```
app.name
app.version
save
cancel
close
delete
edit
add
all
```

### Home
```
home.title
home.spam.blocker
home.total.spam
home.today
home.recent.logs
home.no.spam
```

### Settings
```
settings.title
settings.language
settings.whitelist
settings.rule.engine
settings.blocked.senders
```

### Spam Types
```
spam.type.banking
spam.type.gambling
spam.type.suspicious.link
spam.type.general
```

## Tips for Translators

1. Keep text concise
2. Consider text expansion (some languages are longer)
3. Test on different screen sizes
4. Maintain consistency
5. Use formal/informal appropriately for the language
