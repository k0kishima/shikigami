# P-WAKE-BG — Background-Agent completion wakes idle parent

## Probe ID

P-WAKE-BG

## Hypothesis

When the parent session is idle (no user input, no in-flight tool call)
and a child spawned via `Agent(run_in_background=true)` exits, the
parent receives a wakeup that produces a new orchestrator turn.

## Setup (manual reproduction)

1. Start a fresh Claude Code session in a scratch repo (no prior
   conversation, no pending background agents). Note the version with
   `claude --version` and confirm it matches the row's Environment in
   `docs/PROBES.md`.
2. Instruct the session, verbatim:

   > Spawn one Agent with `run_in_background=true` whose task is
   > `sleep 30 && echo done`. After spawning, end your turn. Do not
   > type anything. Wait.

3. Record:
   - **(a)** Wall-clock time at end-of-turn (the moment after the
     orchestrator finishes its post-spawn turn).
   - **(b)** Wall-clock time at which a new orchestrator turn appears
     in the TUI.
   - **(c)** Whether the user touched the keyboard at any point
     between (a) and (b). If yes, the run is INCONCLUSIVE for the
     wake hypothesis — re-run.

## Expected outcome

A new orchestrator turn appears within ~5s of T+30s (i.e., (b) − (a)
≈ 30s plus harness latency) without any user input.

## Result interpretation

- **PASS**: New orchestrator turn appeared with no keystroke between
  (a) and (b), within ~35s of (a).
- **FAIL**: No new orchestrator turn appeared within a generous
  window (e.g., 5 minutes) and a subsequent keystroke flushed
  pending output that semantically corresponds to the child's exit
  at T+30.
- **INCONCLUSIVE**: User touched the keyboard mid-wait, or the
  session hit an unrelated error.

If parent does not wake without keystroke but does wake with one,
classify the run as INCONCLUSIVE for "wake" and PASS for "render-lag
interferes with wake observability"; cross-reference P-RENDER-LAG.

## Environment record (fill at run time)

- Claude Code version: …
- OS: …
- Install method: native | npm-global | homebrew
- Shell: …
- Terminal emulator + version: …
- Window focus state during wait: focused | not focused
- tmux / screen / direct: …

## Notes

- The terminal-focus field is mandatory: macOS in particular has been
  observed to throttle background-tab updates under some emulators.
- Do not run this probe inside an editor's embedded terminal — TUI
  repaint behavior in embedded terminals is not the doctrine target.
