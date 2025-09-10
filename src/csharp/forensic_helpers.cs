/*
    Forensic Helpers (C#)
    Purpose:
        Toggle‑driven, JSON‑formatted forensic logging with correlation IDs,
        assumption checks, and scoped timing.

    Exports:
        - forensicLog(string message, Stopwatch start, string level = "INFO")
        - forensicCheck(bool condition, string message)
        - forensicScope(string name, Action action)  // cross‑language parity
        - ForensicScope : IDisposable                // idiomatic using pattern

    Scope Options:
        1. Cross‑language parity:
            Forensic.forensicScope("MyBlock", () => {
                // ... logic ...
            });

        2. Idiomatic C# using:
            using (new Forensic.ForensicScope("MyBlock"))
            {
                // ... logic ...
            }

    Example:
        // Enable logging
        Forensic.forensicOn = true;

        // Log a checkpoint
        Forensic.forensicLog("Starting process", Forensic.forensicStart);

        // Validate assumption
        Forensic.forensicCheck(items.Count > 0, "No items found");

        // Scoped timing (parity)
        Forensic.forensicScope("LoadData", () => {
            LoadData();
        });

        // Scoped timing (idiomatic)
        using (new Forensic.ForensicScope("ProcessData"))
        {
            ProcessData();
        }
*/

using System;
using System.Diagnostics;
using System.Text.Json;

public static class Forensic
{
    public static bool forensicOn = true;
    public static readonly string correlationId = Guid.NewGuid().ToString();
    public static readonly Stopwatch forensicStart = Stopwatch.StartNew();

    public static void forensicLog(string message, Stopwatch start, string level = "INFO")
    {
        if (!forensicOn) return;
        var log = new
        {
            ts = DateTime.UtcNow.ToString("o"),
            elapsed_ms = start.ElapsedMilliseconds,
            corr_id = correlationId,
            level,
            msg = message
        };
        Console.WriteLine(JsonSerializer.Serialize(log));
    }

    public static void forensicCheck(bool condition, string message)
    {
        if (forensicOn && !condition)
        {
            forensicLog(message, forensicStart, "WARN");
        }
    }

    public sealed class ForensicScope : IDisposable
    {
        private readonly string _name;
        private readonly Stopwatch _scopeStart;

        public ForensicScope(string name)
        {
            _name = name;
            _scopeStart = Stopwatch.StartNew();
            forensicLog($"{_name} start", _scopeStart, "INFO");
        }

        public void Dispose()
        {
            forensicLog($"{_name} end", _scopeStart, "INFO");
        }
    }

    public static void forensicScope(string name, Action action)
    {
        using (new ForensicScope(name))
        {
            action();
        }
    }
}
