# PROBES.md — Empirical evidence ledger

This file is the canonical registry of empirically observed behaviors that
Shikigami doctrine relies on. **Every "verified in probe Pn" or
"empirically …" claim in any role file MUST resolve to a row here.**
Claims without a corresponding probe row MUST be removed or rewritten
as a hypothesis (e.g., "we suspect …, untested").

## Schema

Each probe is one H2 section with the following required fields:

- **Probe ID**: `P-<DOMAIN>-<NUM>` (e.g., `P-WAKE-001`). Domains:
  WAKE, RENDER, BG, FG, TEAM, SURFACE.
- **Authored**: ISO-8601 date (UTC) of first authoring.
- **Last run**: ISO-8601 date of last execution.
- **Hypothesis**: one sentence — the single proposition under test.
- **Setup**: numbered, copy-pasteable steps. Includes the runnable
  artifact path under `docs/probes/`.
- **Expected outcome**: prediction stated *before* running.
- **Observed outcome (last run)**: literal observation; quote tool
  output verbatim where possible.
- **Result**: PASS | FAIL | INCONCLUSIVE | PENDING (PENDING allowed
  only on initial authoring before first run).
- **Environment**: Claude Code version (e.g., `2.1.119`), OS (e.g.,
  `Darwin 25.2.0`), install method (`native` | `npm-global` | `homebrew`),
  shell, model in use.
- **Linked commit / PR**: SHA(s) and PR number(s) where this probe's
  result is cited.
- **Notes**: free-form. Caveats, retries, flakiness, etc.

## Discipline

1. No role file (`roles/*.md`, `CLAUDE.md`, `roles/_shared/*.md`) may
   say "verified", "empirically", "confirmed", "guaranteed", or
   "always" about runtime behavior unless a `P-…` probe row supports it.
2. Removing a probe row from `PROBES.md` requires removing or
   rewriting every dependent claim in the same commit.
3. A FAILing probe is not deleted — it stays with `Result: FAIL` and
   is cited as evidence that the corresponding doctrine path is
   *known broken*.
4. Probes are re-run against each new Claude Code minor release that
   the project supports. Update **Last run** + **Environment** + add
   a "Run history" subsection on regression.

## P-WAKE-BG

- **Probe ID**: P-WAKE-BG
- **Authored**: 2026-04-26
- **Last run**: (not yet run)
- **Hypothesis**: When the parent session is idle (no user input, no
  in-flight tool call) and a child spawned via
  `Agent(run_in_background=true)` exits, the parent receives a wakeup
  that produces a new orchestrator turn.
- **Setup**: See `docs/probes/p-wake-bg.md` for full reproduction
  steps. Summary: spawn one background `Agent` running
  `sleep 30 && echo done`; end the parent's turn; do not touch the
  keyboard; record wall-clock times.
- **Expected outcome**: A new orchestrator turn appears within ~5s
  of T+30s without any user input.
- **Observed outcome (last run)**: (none — PENDING)
- **Result**: PENDING
- **Environment**: Target — Claude Code 2.1.119, Darwin 25.2.0.
  Environment record at first run must include whether the terminal
  was the focused window during the wait.
- **Linked commit / PR**: Phase 2 doctrine reset (this commit).
- **Notes**: If parent does not wake without keystroke but does wake
  with one, classify INCONCLUSIVE for "wake" and PASS for "render-lag
  interferes with wake observability" (cross-reference P-RENDER-LAG).

## P-WAKE-SM

- **Probe ID**: P-WAKE-SM
- **Authored**: 2026-04-26
- **Last run**: (not yet run)
- **Hypothesis**: A foreground subagent inside a `TeamCreate`'d team
  that calls `SendMessage(to="team-lead", ...)` causes the parent
  session to receive a turn while idle.
- **Setup**: See `docs/probes/p-wake-sm.md` for full reproduction
  steps. Summary: fresh session; `TeamCreate`; spawn foreground
  `Agent` that preloads `SendMessage` via `ToolSearch`, sends a
  ping, then `Bash sleep 60`, then exits.
- **Expected outcome**: Parent renders the SendMessage delivery
  promptly without keystroke. (If keystroke required → render-lag
  class same as P-WAKE-BG.)
- **Observed outcome (last run)**: (none — PENDING)
- **Result**: PENDING
- **Environment**: Target — Claude Code 2.1.119, Darwin 25.2.0.
- **Linked commit / PR**: Phase 2 doctrine reset (this commit).
- **Notes**: Cleanest discriminator between "wakeup signal" and
  "render trigger". If both P-WAKE-BG and P-WAKE-SM require a
  keystroke, the bug is purely render-lag. If only P-WAKE-BG does,
  the wakeup signal differs by spawn mode.

## P-RENDER-LAG

- **Probe ID**: P-RENDER-LAG
- **Authored**: 2026-04-26
- **Last run**: (not yet run)
- **Hypothesis**: In v2.1.119, the parent session receives events
  while idle but the TUI does not repaint until a UI event (single
  keystroke, no Enter required) triggers readline.
- **Setup**: See `docs/probes/p-render-lag.md` for full reproduction
  steps. Summary: run Claude Code under `script(1)` to capture
  per-record timing; reproduce P-WAKE-BG; wait 60s past T+30 with
  no input; press a single character and inspect inter-byte gaps.
- **Expected outcome**: PASS if a contiguous block of subagent
  output bytes is emitted only after the keystroke timestamp;
  FAIL if at T+30±1s.
- **Observed outcome (last run)**: (none — PENDING)
- **Result**: PENDING
- **Environment**: Target — Claude Code 2.1.119, Darwin 25.2.0.
  Manual observer must record the keystroke character used, whether
  Enter was pressed, terminal emulator + version, focus state, and
  tmux/screen presence.
- **Linked commit / PR**: Phase 2 doctrine reset (this commit).
- **Notes**: Cannot CI-automate. Cannot distinguish "TUI buffered"
  from "harness buffered" without harness instrumentation.

## P-BG-SENDMESSAGE-SURFACE

- **Probe ID**: P-BG-SENDMESSAGE-SURFACE
- **Authored**: 2026-04-26
- **Last run**: 2026-04-26
- **Hypothesis**: In v2.1.119, a subagent spawned with
  `run_in_background=true` does not have `SendMessage` in its
  deferred tool surface; `ToolSearch(query="select:SendMessage")`
  returns "No matching deferred tools found".
- **Setup**: See `docs/probes/p-bg-sendmessage-surface.md` for full
  reproduction steps. Summary: from a session that is itself the
  team lead, spawn `Agent(run_in_background=true, prompt="Run
  ToolSearch(query=\"select:SendMessage\"). Report verbatim. Then
  exit.")`; read the child's completion message body.
- **Expected outcome**: PASS if child reports "No matching deferred
  tools found".
- **Observed outcome (last run)**: PASS. During Phase 1 / Phase 2
  authorship the SystemArchitect, Reviewer, and Coder agents (this
  agent) were all background-spawned and each ran
  `ToolSearch(query="select:SendMessage")`; in every observation the
  result was the literal string "No matching deferred tools found".
- **Result**: **PASS (n=3)**
- **Environment**: Claude Code 2.1.119, Darwin 25.2.0,
  install method `native`, shell `zsh`, model
  `claude-opus-4-7[1m]`.
- **Linked commit / PR**: Phase 2 doctrine reset (this commit).
- **Notes**: The user's observation of "Start ack" output that
  *looked like* a SendMessage delivery is reconciled by the
  alternative explanation: any subagent's stdout/turn output is
  rendered to the parent the same way regardless of whether it went
  through SendMessage.
