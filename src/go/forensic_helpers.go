//------------------------------------------------------------------------------
// Forensic Helpers (Go)
// Purpose:
//     Toggle‑driven, JSON‑formatted forensic logging with correlation IDs,
//     assumption checks, and scoped timing.
//
// Exports:
//     - forensicLog(message string, start time.Time, level string)
//     - forensicCheck(condition bool, message string)
//     - forensicScope(name string, fn func())       // cross‑language parity
//     - startScope(name string) (endFn func())      // idiomatic defer pattern
//
// Scope Options:
//     1. Cross‑language parity:
//         forensicScope("MyBlock", func() {
//             // ... logic ...
//         })
//
//     2. Idiomatic Go defer:
//         end := startScope("MyBlock")
//         defer end()
//         // ... logic ...
//
// Example:
//     package main
//
//     import (
//         "time"
//         "myorg/forensic"
//     )
//
//     func main() {
//         forensic.ForensicOn = true
//
//         // Log a checkpoint
//         forensic.ForensicLog("Starting process", forensic.ForensicStart, "INFO")
//
//         // Validate assumption
//         forensic.ForensicCheck(len(items) > 0, "No items found")
//
//         // Scoped timing (parity)
//         forensic.ForensicScope("LoadData", func() {
//             loadData()
//         })
//
//         // Scoped timing (idiomatic)
//         end := forensic.StartScope("ProcessData")
//         defer end()
//         processData()
//     }
//------------------------------------------------------------------------------

package forensic

import (
	"encoding/json"
	"fmt"
	"time"

	"github.com/google/uuid"
)

var ForensicOn = true
var correlationId = uuid.NewString()
var ForensicStart = time.Now().UTC()

type logEntry struct {
	Ts        string `json:"ts"`
	ElapsedMs int64  `json:"elapsed_ms"`
	CorrID    string `json:"corr_id"`
	Level     string `json:"level"`
	Msg       string `json:"msg"`
}

func ForensicLog(message string, start time.Time, level string) {
	if !ForensicOn {
		return
	}
	now := time.Now().UTC()
	elapsed := now.Sub(start).Milliseconds()
	entry := logEntry{
		Ts:        now.Format(time.RFC3339Nano),
		ElapsedMs: elapsed,
		CorrID:    correlationId,
		Level:     level,
		Msg:       message,
	}
	b, _ := json.Marshal(entry)
	fmt.Println(string(b))
}

func ForensicCheck(condition bool, message string) {
	if ForensicOn && !condition {
		ForensicLog(message, ForensicStart, "WARN")
	}
}

// Cross‑language parity wrapper
func ForensicScope(name string, fn func()) {
	start := time.Now().UTC()
	ForensicLog(fmt.Sprintf("%s start", name), start, "INFO")
	defer ForensicLog(fmt.Sprintf("%s end", name), start, "INFO")
	fn()
}

// Idiomatic Go start/defer end pattern
func StartScope(name string) func() {
	start := time.Now().UTC()
	ForensicLog(fmt.Sprintf("%s start", name), start, "INFO")
	return func() {
		ForensicLog(fmt.Sprintf("%s end", name), start, "INFO")
	}
}
