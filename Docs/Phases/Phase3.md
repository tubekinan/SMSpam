# Phase#3 - Logging & Verification

Goal:
- When the extension classifies messages as spam/junk, store evidence.

Observed flow:
- The extension evaluates offline patterns.
- Matching messages are stored under the shared key `spam_logs`.
- The main app displays those entries in the “Spam Logları” UI.

How to validate (short):
- Run the app in Xcode.
- Open the main “Spam Logları” screen.
- Test with real messages and confirm entries appear.

