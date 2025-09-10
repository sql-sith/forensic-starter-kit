#!/usr/bin/env bash
#------------------------------------------------------------------------------
# Forensic Helpers (Bash)
# Purpose:
#     Toggle‑driven, JSON‑formatted forensic logging with correlation IDs,
#     assumption checks, and scoped timing.
#
# Exports:
#     - forensicLog "<message>" [<level>]           # default level INFO
#     - forensicCheck <exit_code> "<message>"
#     - forensicScope "<name>" <command...>         # cross‑language parity
#     - _forensic_scope_start "<name>"              # idiomatic start
#     - _forensic_scope_end "<name>"                # idiomatic end
#
# Scope Options:
#     1. Cross‑language parity:
#         forensicScope "MyBlock" sleep 0.2
#
#     2. Idiomatic Bash subshell/trap:
#         (
#             _forensic_scope_start "MyBlock"
#             sleep 0.2
#             _forensic_scope_end "MyBlock"
#         )
#
# Example:
#     # Enable logging
#     FORENSIC_ON=true
#
#     # Log a checkpoint
#     forensicLog "Starting script"
#
#     # Validate assumption (non‑zero exit code triggers WARN)
#     false
#     forensicCheck $? "Expected condition failed"
#
#     # Scoped timing (parity)
#     forensicScope "LoadData" sleep 0.2
#
#     # Scoped timing (idiomatic)
#     (
#         _forensic_scope_start "ProcessData"
#         sleep 0.2
#         _forensic_scope_end "ProcessData"
#     )
#------------------------------------------------------------------------------

FORENSIC_ON=true
correlationId=$(uuidgen)
FORENSIC_START=$(date -u +%s%3N)

forensicLog() {
    if [ "$FORENSIC_ON" = true ]; then
        local message="$1"
        local level="${2:-INFO}"
        local now_ms
        now_ms=$(date -u +%s%3N)
        local elapsed_ms=$((now_ms - FORENSIC_START))
        local ts
        ts=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")
        printf '{"ts":"%s","elapsed_ms":%d,"corr_id":"%s","level":"%s","msg":"%s"}\n' \
            "$ts" "$elapsed_ms" "$correlationId" "$level" "$message"
    fi
}

forensicCheck() {
    local exit_code="$1"
    local message="$2"
    if [ "$FORENSIC_ON" = true ] && [ "$exit_code" -ne 0 ]; then
        forensicLog "$message" "WARN"
    fi
}

# Idiomatic start/end helpers
_forensic_scope_start() {
    local name="$1"
    forensicLog "$name start" "INFO"
    __FORENSIC_SCOPE_START_MS=$(date -u +%s%3N)
    export __FORENSIC_SCOPE_START_MS
}

_forensic_scope_end() {
    local name="$1"
    forensicLog "$name end" "INFO"
    unset __FORENSIC_SCOPE_START_MS
}

# Cross‑language parity wrapper
forensicScope() {
    local name="$1"; shift
    _forensic_scope_start "$name"
    "$@"
    local rc=$?
    _forensic_scope_end "$name"
    return $rc
}

