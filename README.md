# Forensic Starter Kit

A cross‑language forensic instrumentation toolkit for developers who need
repeatable, toggle‑driven, low‑overhead logging across multiple stacks.

This kit gives you **drop‑in helpers** for:

- **Toggle‑driven logging** — enable/disable forensic output with a single flag.
- **Correlation IDs** — trace execution across services and scripts.
- **Structured JSON Lines output** — Splunk/ELK‑friendly, machine‑parseable logs.
- **Assumption validation** — `forensicCheck` to assert and log unexpected states.
- **Scoped timers** — automatic start/end logging with elapsed time for code blocks.

## Languages Included

- **Bash** — Functions and a subshell trap‑based scope.
- **C#** — Static helper methods with a `ForensicScope` `IDisposable` class for scoped timing.
- **Go** — Functions with a `withForensicScope` higher‑order function for scoped timing.
- **Node.js** — Functions and a `withForensicScope` wrapper.
- **PowerShell** — Functions plus an `IDisposable` class for scoped timing.
- **Python** — Functions and a `@contextmanager` scope.
- **T‑SQL** — `ForensicLog` and `ForensicCheck` stored procedures, TRY/FINALLY scoped timers.
- **Generic pseudocode** — For adapting the pattern to other languages.


## Output Format

All helpers emit JSON Lines with the same schema:

```json
{"ts":"2025-09-04T17:56:00.123Z","elapsed_ms":42,"corr_id":"abc123","level":"INFO","msg":"Starting batch"}
```

### Fields

- `ts` — UTC timestamp in ISO‑8601 format.
- `elapsed_ms` — Milliseconds since the forensic start time.
- `corr_id` — Correlation ID for tracing across systems.
- `level` — Log level (`INFO`, `WARN`, `ERROR`).
- `msg` — Message text.

## Usage Pattern

1. Set the toggle (`forensicOn`, `FORENSIC_ON`, `@ForensicOn`) to `true`/`1` to enable logging.
2. Log checkpoints with `forensicLog` at key points in your code.
3. Validate assumptions with `forensicCheck` — logs a warning if the condition fails.
4. Wrap blocks in a scoped timer to auto‑log start/end with elapsed time.

### Example (Python)

```python
with forensic_scope("DataLoad"):
    forensic_log("Fetching data", forensic_start)
    # ... load logic ...
    forensic_check(len(rows) > 0, "No rows returned from source")
```

## Why This Kit Exists

When you work across multiple languages and environments, ad‑hoc logging patterns become a maintenance headache. This kit standardizes:

- **Toggle location** — always at the top of the file.
- **Function names** — `forensicLog`, `forensicCheck`, `forensicScope`.
- **Output format** — identical JSON schema across stacks.
- **Minimal dependencies** — no external logging frameworks required.

## Folder Structure

```text
forensic-starter-kit/
│
├── README.md
└── src
   │
   ├── bash/forensic_helpers.sh
   ├── csharp/forensic_helpers.cs
   ├── go/forensic_helpers.go
   ├── node/forensic_helpers.js
   ├── powershell/forensic_helpers.ps1
   ├── python/forensic_helpers.py
   ├── transact-sql/forensic_helpers.sql
   └── pseudocode/forensic_helpers_pseudocode.txt
```

## License

MIT — free to use, modify, and integrate into your own projects.
