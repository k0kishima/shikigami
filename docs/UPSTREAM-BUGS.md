# Title
Claude Code 2.1.119 (Darwin): single-keystroke (no Enter) flushes background-Agent completion output — TUI repaint appears gated on readline event, not on harness wakeup

# TL;DR
After spawning an `Agent(run_in_background=true)` and ending the parent's
turn, the TUI does not display the child's completion notification or
output until the user presses a single character (no Enter required).
The single-keystroke trigger is structurally diagnostic — it implicates
the readline / TUI repaint path, not session wakeup or input submission.

# Environment
- Claude Code: 2.1.119
- OS: Darwin 25.2.0 (macOS)
- Install method: <fill at filing time — npm-global | native | homebrew>
- Shell: zsh
- Terminal emulator: <fill at filing time — iTerm2 / Terminal.app / Alacritty / tmux>
- `script(1)` variant used: <BSD or GNU>
- Reproduction repo: https://github.com/<...>/shikigami (probe scripts under docs/probes/)

# Reproduction (minimal)
1. In a fresh Claude Code session, instruct: "Spawn one
   `Agent(run_in_background=true, prompt='Bash: sleep 30 && echo done')`.
   After spawning, end your turn. Do not type anything."
2. Wait 90 seconds without touching the keyboard or moving focus.
3. Press a single character (e.g. space — verify readline consumes it
   without Enter).

# Expected behavior
Within ~5 seconds of T+30 (the child's exit), the parent renders a
new orchestrator turn containing the child's completion output. No
user input should be required.

# Actual behavior
The terminal stays visually frozen at the post-spawn state until a
keystroke is pressed. On the keystroke, a burst of previously-buffered
output (typically including the child's completion message and any
interim subagent stdout) is rendered all at once.

# Discriminating data
- A **single character** (no Enter) is sufficient to flush. This rules
  out "input submission triggered work"; the trigger is the readline /
  TUI repaint event itself.
- `script(1)` capture (`script -t 0 out.typescript claude` on BSD)
  shows a multi-second gap between the previous TUI write and the
  keystroke-triggered burst, with the burst containing bytes that
  semantically correspond to a moment ~T+30 (verifiable from
  timestamps embedded in the child's output, e.g. `date` in the
  child's prompt).
- Background-spawned subagents cannot `SendMessage` in 2.1.119
  (`ToolSearch(query="select:SendMessage")` returns "No matching
  deferred tools found" inside the child). So the only wake channel
  for a background child is the harness completion event — and that
  event appears not to drive a TUI repaint reliably.

# Cross-references
- #48160 — related: SendMessage tool surface non-uniformity across
  subagent spawn modes.
- #39651 — related: cross-team global name resolution; possibly
  shares a session/event-routing code path with this issue.

# Ask
(a) Confirm: is this a TUI render bug, a session wake-up bug, or both?
(b) Workaround for users on 2.1.119 — is there an env flag or
    `--no-altscreen`-style mitigation we can set?
(c) Target version / ETA for the fix.

# Why this matters
Multi-agent orchestration setups (Claude Code Agent Teams) rely on
background-spawn completion as the only reliable wake channel for
background workers. With this bug, an orchestrator session that
delegates work and ends its turn appears frozen indefinitely to the
user, who reasonably interprets "no output" as "stuck" and pages
through the conversation, accidentally flushing the buffer.
