import datetime, json, uuid

forensic_on = True
correlation_id = str(uuid.uuid4())
forensic_start = datetime.datetime.utcnow()

def forensic_log(message, start_time, level="INFO"):
    if forensic_on:
        now = datetime.datetime.utcnow()
        elapsed_ms = int((now - start_time).total_seconds() * 1000)
        log = {
            "ts": now.isoformat() + "Z",
            "elapsed_ms": elapsed_ms,
            "corr_id": correlation_id,
            "level": level,
            "msg": message
        }
        print(json.dumps(log, separators=(",", ":")))

def forensic_check(condition, message):
    if forensic_on and not condition:
        forensic_log(message, forensic_start, "WARN")
