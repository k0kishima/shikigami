# Reporting Contract (Shared)

This is the shared reporting discipline that applies to every worker role spawned by the Orchestrator. Role templates reference this file; the Orchestrator appends it to a worker's prompt at spawn time (see `roles/orchestrator.md`, Spawning Agents with Role Templates).

## Visibility model

Your visibility to the Orchestrator comes through explicit signals — primarily the `SendMessage` channel, and (when you were spawned with `run_in_background=true`) the runtime's completion notification on exit. Between those signals, silence is indistinguishable from being stuck.

> **Note on the lead bus name**: In Shikigami, the Orchestrator is addressable as `{{team_lead_name}}`. This is the established convention used throughout worker role templates. When sending a `SendMessage` back to the Orchestrator, use `to="{{team_lead_name}}"`.
>
> In actual agent prompts, `{{team_lead_name}}` is replaced by the Orchestrator at spawn time with its addressable agent name — by default the literal string `team-lead`, which is the Claude Code Agent Teams runtime default for the team lead's `leadAgentId`. Agents will see the resolved literal, not the placeholder.

## Required signals

- **On start**: Immediately after receiving the task, send a one-line `SendMessage(to="{{team_lead_name}}")` acknowledging you've started. Include the high-level plan in one sentence.
- **On blockers**: If you hit any blocker, send `SendMessage(to="{{team_lead_name}}")` immediately describing what is blocking you. Do NOT silently wait or self-resolve based on assumptions that weren't in the spec.
- **On long work**: Send a brief progress `SendMessage` at each major phase boundary or after each long-running command/tool invocation completes. Do NOT rely on wall-clock estimates — you have no reliable clock; use task-structural heuristics (phase transitions, command completions) instead.
- **On completion**: Send a `SendMessage(to="{{team_lead_name}}")` with the deliverable summary. This is mandatory even if the work was trivial.
- **Silence is failure**: If you cannot make progress for any reason, report it. Never leave the `{{team_lead_name}}` waiting without a signal.

Role templates may override or supplement these defaults in a `### Role-specific notes` subsection (for example, Reviewer may not need a long-work ping; Tester explicitly classifies test failures as non-blockers; SecurityEngineer explicitly reports "no findings" as a valid completion payload).
