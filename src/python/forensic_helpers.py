"""
Forensic Helpers (Python)
Purpose:
    Toggle‑driven, JSON‑formatted forensic logging with correlation IDs,
    assumption checks, and scoped timing.

Exports:
    - forensicLog(message: str, start_time: datetime, level: str = "INFO")
    - forensicCheck(condition: bool, message: str)
    - forensicScope(name: str, fn: Callable)   # cross‑language parity
    - forensic_scope(name: str) contextmanager # idiomatic with‑block

Scope Options:
    1. Cross‑language parity:
        forensicScope("MyBlock", lambda: do_work())

    2. Idiomatic Python with:
        with forensic_scope("MyBlock"):
            do_work()

Example:
    forensicOn = True

    # Log a checkpoint
    forensicLog("Starting process", forensicStart)

    # Validate assumption
    forensicCheck(len(rows) > 0, "No rows returned")

    # Scoped timing (parity)
    forensicScope("LoadData", lambda: load_data())

    # Scoped timing (idiomatic)
    with forensic_scope("ProcessData"):
        process_data()
"""

import datetime
import json
import uuid
from contextlib import contextmanager
from typing import Callable

forensicOn = True
correlationId = str(uuid.uuid4())
forensicStart = datetime.datetime.utcnow()

def forensicLog(message: str, start_time: datetime.datetime, level: str = "INFO") -> None:
    """Log a JSON‑formatted forensic message with elapsed ms since start_time."""
    if forensicOn:
        now = datetime.datetime.utcnow()
        elapsed_ms = int((now - start_time).total_seconds() * 1000)
        log = {
            "ts": now.isoformat() + "Z",
            "elapsed_ms": elapsed_ms,
            "corr_id": correlationId,
            "level": level,
            "msg": message
        }
        print(json.dumps(log, separators=(",", ":")))

def forensicCheck(condition: bool, message: str) -> None:
    """Log a WARN‑level message if condition is False."""
    if forensicOn and not condition:
        forensicLog(message, forensicStart, "WARN")

@contextmanager
def forensic_scope(name: str):
    """Idiomatic Python context manager for scoped forensic timing."""
    start = datetime.datetime.utcnow()
    forensicLog(f"{name} start", start, "INFO")
    try:
        yield
    finally:
        forensicLog(f"{name} end", start, "INFO")

def forensicScope(name: str, fn: Callable[[], None]) -> None:
    """Cross‑language parity wrapper for scoped forensic timing."""
    with forensic_scope(name):
        fn()
