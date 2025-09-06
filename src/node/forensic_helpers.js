const forensicOn = true;
const correlationId = crypto.randomUUID();
const forensicStart = new Date();

function forensicLog(message, startTime, level = "INFO") {
    if (forensicOn) {
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
}

function forensicCheck(condition, message) {
    if (forensicOn && !condition) {
        forensicLog(message, forensicStart, "WARN");
    }
}
