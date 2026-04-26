# P-BG-SENDMESSAGE-SURFACE — Background subagents lack SendMessage

## Probe ID

P-BG-SENDMESSAGE-SURFACE

## Hypothesis

In v2.1.119, a subagent spawned with `run_in_background=true` does
not have `SendMessage` in its deferred tool surface;
`ToolSearch(query="select:SendMessage")` from inside the child
returns the literal string "No matching deferred tools found".

## Setup (reproduction — automatable from a parent session)

1. From a session that is itself the team lead (i.e., has executed
   `TeamCreate` successfully), spawn:

   ```
   Agent(
     run_in_background=true,
     prompt="Run ToolSearch(query=\"select:SendMessage\"). Report verbatim the result. Then exit."
   )
   ```

2. Wait for the background agent's completion notification (or, if
   the v2.1.119 render-lag bug is in effect — see P-RENDER-LAG —
   press a single key to flush).

3. Read the child's completion message body verbatim.

## Expected outcome

PASS for the hypothesis if the child reports the literal string:

> No matching deferred tools found

## Result interpretation

- **PASS**: Child reported "No matching deferred tools found". The
  background spawn mode does not include `SendMessage` in the
  child's deferred tool surface; the child cannot send a message
  back to the lead and must rely on its completion message body as
  the entire deliverable.
- **FAIL**: Child successfully loaded `SendMessage`'s schema. This
  would invalidate the doctrine in
  `roles/_shared/reporting-contract.md` Branch B and require a
  rewrite.
- **INCONCLUSIVE**: Child failed to run `ToolSearch` at all (e.g.,
  ToolSearch itself unavailable in the child's surface). Re-run
  with adjusted instructions to confirm the child's tool surface
  state.

## Initial observation (recorded with this probe's authoring)

During Phase 1 design and Phase 2 design / review / implementation
(2026-04-26), three background-spawned agents — the SystemArchitect,
the Reviewer, and the Coder (this implementation agent) — were each
asked to run `ToolSearch(query="select:SendMessage")` at the start
of their tasks. Each returned the literal string:

> No matching deferred tools found

This is recorded as **Result: PASS, n=3**.

## Environment record

- Claude Code version: 2.1.119
- OS: Darwin 25.2.0
- Install method: native
- Shell: zsh
- Model: claude-opus-4-7[1m]
- Terminal emulator: (not material to this probe — the result is
  observed inside the harness, not on the TUI)

## Notes

- The user's separate observation of "Start ack" output that *looked
  like* a SendMessage delivery is reconciled by the alternative
  explanation: any subagent's stdout / turn output is rendered to the
  parent the same way regardless of whether it traversed the
  SendMessage path. "Start ack appeared" is therefore not evidence
  for "SendMessage was used".
- This probe is the cheapest of the four to re-run on a Claude Code
  upgrade, since it requires no manual observer — it can be executed
  inside a single orchestrator turn.
