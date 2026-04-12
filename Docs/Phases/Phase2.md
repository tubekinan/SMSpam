# Phase#2 - Roles (Classification) & Patterns

Goal:
- Assign messaging “roles” (e.g., spam/junk) using sender/body patterns.

Role coverage (examples):
- Blocked senders list
- 850-type sender number regex
- Corrupted Turkish character regex
- Gambling/bonus keyword roles
- Short URL patterns
- General spam keywords

Output (current behavior):
- Messages marked as `.junk`
- Sub-action is currently `.none`

Notes:
- Update this doc to match your final role logic.

