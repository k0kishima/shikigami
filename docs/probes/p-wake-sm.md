# P-WAKE-SM — Foreground SendMessage wakes idle parent

## Probe ID

P-WAKE-SM

## Hypothesis

A foreground subagent inside a `TeamCreate`'d team that calls
`SendMessage(to="team-lead", ...)` causes the parent session to
receive a turn while idle.

## Setup (manual reproduction)

1. Start a fresh Claude Code session. Confirm version.
2. From the parent session, preload the team management deferred
   tools and create a team:

   ```
   ToolSearch(query="select:TeamCreate,SendMessage")
   TeamCreate(team_name="probe-wake-sm-<unix-ts>", description="P-WAKE-SM probe")
   ```

   Capture the `team_name` returned (the runtime may slug it).
3. Spawn a foreground `Agent(...)` (NOT `run_in_background=true`)
   with the prompt:

   > Preload `SendMessage` via `ToolSearch(query="select:SendMessage")`.
   > Then `SendMessage(to="team-lead", body="P-WAKE-SM ping at T0")`.
   > Then run `Bash sleep 60`. Then exit.

4. The foreground spawn keeps the parent's turn occupied until the
   child returns; for this probe, the parent should **end its turn
   immediately after the spawn returns** so it is idle when the
   child's `SendMessage` arrives. (If the harness in your version
   keeps the parent occupied for the full child lifetime, this probe
   degenerates and should be marked INCONCLUSIVE.)
5. Record:
   - **(a)** Wall-clock at parent end-of-turn.
   - **(b)** Wall-clock at which the parent renders the SendMessage
     delivery (the "P-WAKE-SM ping at T0" body, surfaced as a
     subagent message in the parent TUI).
   - **(c)** Whether a keystroke was required between (a) and (b).

## Expected outcome

Parent renders the SendMessage delivery promptly (within a few
seconds of the child sending) without keystroke. If a keystroke is
required, the render-lag class is the same as P-WAKE-BG.

## Result interpretation

- **PASS**: Parent rendered the message without keystroke, well
  before T+60.
- **FAIL**: Parent did not render the message until a keystroke at
  some t > T0, with the delivered content semantically corresponding
  to T0.
- **INCONCLUSIVE**: The harness kept the parent occupied for the
  full child lifetime, so the "idle parent receives wakeup" property
  could not be tested.

## Environment record (fill at run time)

- Claude Code version: …
- OS: …
- Install method: …
- Shell: …
- Terminal emulator + version: …
- Window focus state: …
- Whether the parent was actually idle at the moment the child sent
  the SendMessage (yes/no, with reasoning): …

## Notes

- This probe is the cleanest discriminator between "wakeup signal"
  and "render trigger". If both P-WAKE-BG and P-WAKE-SM require a
  keystroke, the bug is purely render-lag (the wake event arrives
  but is not painted). If only P-WAKE-BG requires a keystroke, the
  wakeup signal itself differs by spawn mode.
- The team name uses a unique suffix to avoid collisions with
  other concurrent Shikigami sessions (cross-reference
  anthropics/claude-code#39651).
