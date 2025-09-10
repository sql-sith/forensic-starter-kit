/*
    Forensic Helpers (Node.js)
    Purpose:
        Toggle‑driven, JSON‑formatted forensic logging with correlation IDs,
        assumption checks, and scoped timing.

    Exports:
        - forensicLog(message: string, startTime: Date, level: string = "INFO")
        - forensicCheck(condition: boolean, message: string)
        - forensicScope(name: string, fn: Function)  // cross‑language parity

    Scope Options:
        1. Cross‑language parity:
            forensicScope("MyBlock", () => {
                // ... logic ...
            });

        2. Idiomatic Node.js try/finally:
            const start = new Date();
            forensicLog("MyBlock start", start);
            try {
                // ... logic ...
            } finally {
                forensicLog("MyBlock end", start);
            }

    Example:
        // Enable logging
        export const forensicOn = true;

        // Log a checkpoint
        forensicLog("Starting process", forensicStart);

        // Validate assumption
        forensicCheck(items.length > 0, "No items found");

        // Scoped timing (parity)
        forensicScope("LoadData", () => {
            loadData();
        });

        // Scoped timing (idiomatic)
        const start = new Date();
        forensicLog("ProcessData start", start);
        try {
            processData();
        } finally {
            forensicLog("ProcessData end", start);
        }
*/

import crypto from "crypto";

export const forensicOn = true;
export const correlationId = crypto.randomUUID();
export const forensicStart = new Date();

export function forensicLog(message, startTime, level = "INFO") {
    if (!forensicOn) return;
    const now = new Date();
    const elapsedMs = now - startTime;
    console.log(JSON.stringify({
        ts: now.toISOString(),
        elapsed_ms: elapsedMs,
        corr_id: correlationId,
        level,
        msg: message
    }));
}

export function forensicCheck(condition, message) {
    if (forensicOn && !condition) {
        forensicLog(message, forensicStart, "WARN");
    }
}

export function forensicScope(name, fn) {
    const start = new Date();
    forensicLog(`${name} start`, start, "INFO");
    try {
        fn();
    } finally {
        forensicLog(`${name} end`, start, "INFO");
    }
}
