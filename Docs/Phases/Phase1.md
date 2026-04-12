# Phase#1 - Setup & Data Flow

Goal:
- Run the iOS IdentityLookup `MessageFilterExtension`.
- Share data between the extension and the main app.

App data flow (high level):
1. An SMS triggers `MessageFilterExtension.handle(...)`.
2. The extension returns an `ILMessageFilterQueryResponse`.
3. When logging is enabled, the extension writes to the shared app group via `UserDefaults(suiteName: ...)`.
4. The main app reads the same shared app group and shows logs in the UI.

Checklist:
- App Group entitlement exists for both targets.
- The shared key (e.g. `spam_logs`) is read/written consistently.

