# Reporting Contract (Shared)

This is the shared reporting discipline that applies to every worker role spawned by the Orchestrator. Role templates reference this file; the Orchestrator appends it to a worker's prompt at spawn time (see `roles/orchestrator.md`, Spawning Agents with Role Templates).

## Spawn-mode branch (read this first)

Your Orchestrator told you which mode you were spawned in. If you don't
know, run `ToolSearch(query="select:SendMessage")` once: a "No matching
deferred tools found" result means you are in background mode.

### Branch B — Background (`run_in_background=true`)

`SendMessage` is not in your tool surface in Claude Code 2.1.119
(see PROBES.md / P-BG-SENDMESSAGE-SURFACE). Therefore:

- **Your completion message body IS the entire deliverable.** Make it
  self-contained, structured, and complete. There is no follow-up
  channel; you cannot send a "actually one more thing" later.
- Do NOT emit "On start", "On blockers", or "On long work" signals —
  they have nowhere to go.
- If you hit an unrecoverable blocker, exit with a completion body
  that states the blocker explicitly in the first line.
- Do NOT end with "I'll continue working on X" — your turn ending IS
  the deliverable boundary.

### Branch F — Foreground / team-spawned

`SendMessage` is available (after `ToolSearch(query="select:SendMessage")`
preload) and you are addressable as part of a team. The lead is
`{{team_lead_name}}` (substituted by the Orchestrator at spawn time
to the literal `team-lead`).

- **On start**: one-line `SendMessage(to="{{team_lead_name}}")` ack with
  the high-level plan in one sentence.
- **On blockers**: send a `SendMessage` describing the blocker.
- **On phase boundaries**: brief progress `SendMessage`.
- **On completion**: `SendMessage` with deliverable summary AND make
  the final task result self-contained (the SendMessage may not wake
  the lead's TUI promptly — see CAVEAT in `roles/orchestrator.md`).

> **CAVEAT for Branch F**: `SendMessage` is fire-and-forget. There is a
> v2.1.119 TUI render-lag bug under which the lead may not see your
> message until they press any key. Do NOT block waiting for an
> acknowledgment. If you cannot proceed without lead input, state the
> question in your completion body and exit; the lead will respond on
> the next turn.

## Override hook

Role templates may override or supplement these defaults in a
`### Role-specific notes` subsection (Reviewer may skip the long-work
ping; Tester classifies test failures as non-blockers; SecurityEngineer
treats "no findings" as a valid completion payload).
