# Range Rules Configuration

Purpose:
- Keep pattern “ranges” (regex patterns, thresholds, lists) out of hard-coded code.

Suggested approach:
- Store rule patterns in an external file (e.g. `SpamRules.json`).
- Load that configuration from the extension at runtime (or at initial startup).

Note:
- Use consistent naming: “Rule(s)”.

