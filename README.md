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

- **Bash** — Functions and a subshell trap‑based scope (idiomatic), plus `forensicScope "Name" command...` for cross‑language parity.
- **C#** — Static helper methods with a `ForensicScope` `IDisposable` class for idiomatic `using` blocks, plus `forensicScope(name, Action)` for cross‑language parity.
- **Go** — Functions with an idiomatic `StartScope(name)`/`defer end()` pattern, plus `forensicScope(name, fn)` for cross‑language parity.
- **Node.js** — Functions with `forensicScope(name, fn)` for cross‑language parity; idiomatic usage via `try/finally` block.
- **PowerShell** — Functions plus a `ForensicScope` `IDisposable` class for idiomatic `using` blocks, plus `forensicScope "Name" {}` for cross‑language parity.
- **Python** — Functions with an idiomatic `with forensic_scope(name):` context manager, plus `forensicScope(name, fn)` for cross‑language parity.
- **T‑SQL** — `forensicLog` and `forensicCheck` stored procedures, plus `forensicScope @Name, @Mode` for cross‑language parity; idiomatic usage via TRY/FINALLY.
- **Generic pseudocode** — For adapting the pattern to other languages, including both parity and idiomatic scope options where applicable.


## Scope Options at a Glance

| Language     | Cross‑Language Parity Scope                           | Idiomatic Scope Option                          |
|--------------|-------------------------------------------------------|-------------------------------------------------|
| **Bash**     | `forensicScope "MyBlock" sleep 0.2`                    | Subshell/trap:<br>`(_forensic_scope_start "MyBlock"; sleep 0.2; _forensic_scope_end "MyBlock")` |
| **C#**       | `Forensic.forensicScope("MyBlock", () => { /*...*/ });`| `using (new Forensic.ForensicScope("MyBlock")) { /*...*/ }` |
| **Go**       | `forensicScope("MyBlock", func() { /*...*/ })`         | `end := startScope("MyBlock"); defer end()`     |
| **Node.js**  | `forensicScope("MyBlock", () => { /*...*/ });`         | `const start = new Date(); forensicLog("MyBlock start", start); try { /*...*/ } finally { forensicLog("MyBlock end", start); }` |
| **PowerShell**| `forensicScope "MyBlock" { /*...*/ }`                 | `using ($scope = [ForensicScope]::new("MyBlock")) { /*...*/ }` |
| **Python**   | `forensicScope("MyBlock", lambda: do_work())`          | `with forensic_scope("MyBlock"):\n    do_work()` |
| **T‑SQL**    | `EXEC dbo.forensicScope @Name = N'MyBlock', @Mode = N'start'; /*...*/ EXEC dbo.forensicScope @Name = N'MyBlock', @Mode = N'end';` | TRY/FINALLY:<br>`EXEC dbo.forensicScope @Name = @BlockName, @Mode = N'start'; BEGIN TRY /*...*/ END TRY BEGIN FINALLY EXEC dbo.forensicScope @Name = @BlockName, @Mode = N'end'; END FINALLY;` |
| **Pseudocode**| `forensicScope("MyBlock", fn)`                        | `with forensic_scope("MyBlock"):\n    fn()`     |

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
