# P-RENDER-LAG — TUI repaint gated on keystroke, not on wakeup

## Probe ID

P-RENDER-LAG

## Hypothesis

In v2.1.119, the parent session receives events while idle but the
TUI does not repaint until a UI event (single keystroke, no Enter
required) triggers readline.

## Setup (manual reproduction)

1. Run Claude Code wrapped in `script(1)` so per-record timing is
   captured. On macOS (BSD `script`):

   ```
   script -t 0 out.typescript claude
   ```

   (`-t 0` writes a separate `out.typescript.timing` file with
   inter-record gaps. On GNU `script`, the equivalent is
   `script --timing=out.timing out.typescript`. Note which variant
   you used in the Environment record.)

2. Reproduce P-WAKE-BG inside that wrapped session: spawn an
   `Agent(run_in_background=true)` whose task is
   `sleep 30 && echo done`, then end the parent's turn. Embed a
   timestamp in the child's output (e.g.,
   `sleep 30 && date -u +"done at %Y-%m-%dT%H:%M:%SZ"`) so the
   semantic time of the child's exit is recoverable from the
   captured stream.

3. After T+30s, wait an additional 60s with NO input (no mouse
   movement onto the terminal, no focus change — leave the window
   alone).

4. Press a single character (e.g., space). **Verify it is consumed
   by readline (i.e., appears in the input buffer) without
   submitting** — do not press Enter. If your terminal/emulator
   submits on space, use a different non-submitting character such
   as a left-arrow keypress.

5. Inspect `out.typescript` (and the timing file) for the inter-byte
   gap between:
   - **(a)** The previous TUI write before the wait.
   - **(b)** The burst that appears after the keystroke.

   If the burst contains previously-buffered "Start ack" / completion
   content (recoverable via the embedded timestamp from step 2), the
   render-lag hypothesis is supported.

## Expected outcome

- **PASS**: A contiguous block of subagent output bytes is emitted
  only after the keystroke timestamp, and that block contains
  content semantically corresponding to T+30 (the embedded `date`).
- **FAIL**: The subagent output bytes are emitted at T+30±1s, with
  no significant gap before the keystroke.

## Result interpretation

- **PASS** confirms the parent received the wake event but the TUI
  buffered the repaint until a readline event. The user-visible bug
  is render-lag, not wake-loss.
- **FAIL** suggests the wake event itself was lost; cross-reference
  P-WAKE-BG to see whether that probe also failed.

## Environment record (fill at run time, mandatory fields)

- Claude Code version: …
- OS: …
- `script(1)` variant: BSD | GNU | other (specify)
- Shell: …
- Terminal emulator + version: …
- tmux / screen presence: yes (version) / no
- Window focus state during 60s idle wait: focused | not focused
- Keystroke character used: …
- Whether Enter was pressed: yes / no (must be no for a valid run)

## Limitations

- This probe cannot be CI-automated; it requires a manual observer
  who can verifiably refrain from input.
- It cannot distinguish "TUI buffered" from "harness buffered"
  without harness-side instrumentation. The interpretation is
  therefore "render path is the bottleneck", not necessarily
  "the TUI specifically".
- If the captured `script` timing shows bytes arriving steadily
  before the keystroke, with the keystroke only flushing a final
  small burst, treat the result as INCONCLUSIVE and re-run.
