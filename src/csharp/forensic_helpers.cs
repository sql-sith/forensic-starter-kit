using System;
using System.Diagnostics;
using System.Text.Json;

public static class Forensic
{
    public static bool ForensicOn = true;
    public static readonly string CorrelationId = Guid.NewGuid().ToString();
    public static readonly Stopwatch ForensicStart = Stopwatch.StartNew();

    public static void ForensicLog(string message, Stopwatch start, string level = "INFO")
    {
        if (!ForensicOn) return;

        var log = new
        {
            ts = DateTime.UtcNow.ToString("o"),
            elapsed_ms = start.ElapsedMilliseconds,
            corr_id = CorrelationId,
            level,
            msg = message
        };
        Console.WriteLine(JsonSerializer.Serialize(log));
    }

    public static void ForensicCheck(bool condition, string message)
    {
        if (ForensicOn && !condition)
        {
            ForensicLog(message, ForensicStart, "WARN");
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
            ForensicLog($"{_name} start", _scopeStart);
        }

        public void Dispose()
        {
            ForensicLog($"{_name} end", _scopeStart);
        }
