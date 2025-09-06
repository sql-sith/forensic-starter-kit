#!/usr/bin/env bash
FORENSIC_ON=true
CORRELATION_ID=$(uuidgen)
FORENSIC_START=$(date -u +%s%3N)

forensic_log() {
    if [ "$FORENSIC_ON" = true ]; then
        local now_ms=$(date -u +%s%3N)
        local elapsed_ms=$((now_ms - FORENSIC_START))
        local ts=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")
        printf '{"ts":"%s","elapsed_ms":%d,"corr_id":"%s","level":"%s","msg":"%s"}\n' \
            "$ts" "$elapsed_ms" "$CORRELATION_ID" "${3:-INFO}" "$1"
    fi
}

forensic_check() {
    if [ "$FORENSIC_ON" = true ] && [ "$1" -ne 0 ]; then
        forensic_log "$2" "WARN"
    fi
}
