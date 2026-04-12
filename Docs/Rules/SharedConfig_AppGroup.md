# Shared Config (App Group + UserDefaults)

Purpose:
- Share configuration/data between the main app and the `SpamFilterExtension`.

Concept:
- Use the same App Group `suiteName` with `UserDefaults(suiteName: ...)`.
- Define shared keys in one place (avoid duplication).

Example suite:
- `group.com.inan.smspam`

Example key:
- `spam_logs`

