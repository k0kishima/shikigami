# P-TEAM-ROUTE — Short-form vs qualified-form team-lead routing

## Probe ID

P-TEAM-ROUTE

## Hypothesis

When sending a `SendMessage` to a team lead from a foreground
team-spawned subagent, the bare short-form name `team-lead` routes
correctly while the fully-qualified `team-lead@<team_name>` form does
not route to the lead.

## Setup (manual reproduction)

1. Start a fresh Claude Code session. Confirm the version with
   `claude --version` and record it in the Environment block of the
   `P-TEAM-ROUTE` row in `docs/PROBES.md`.
2. From the parent (lead) session, preload the team management
   deferred tools and create a probe team:

   ```
   ToolSearch(query="select:TeamCreate,SendMessage")
   TeamCreate(team_name="p-team-route-<unix-timestamp>")
   ```

   Capture the returned `team_name` (the runtime may slug it) and the
   `lead_agent_id`.
3. Foreground-spawn an `Agent(...)` (NOT `run_in_background=true`)
   bound to that team with the prompt:

   > Preload `SendMessage` via `ToolSearch(query="select:SendMessage")`.
   > Call `SendMessage(to="team-lead@<the_team_name>", body="P-TEAM-ROUTE qualified-form ping")`.
   > Then call `SendMessage(to="team-lead", body="P-TEAM-ROUTE short-form ping")`.
   > Then exit.

   Substitute `<the_team_name>` with the literal team name returned
   by `TeamCreate` in step 2.
4. Observe, in the lead's conversation, which (if any) of the two
   pings actually appear, and in what order.
5. Record:
   - **(a)** Whether the qualified-form ping (`team-lead@<team_name>`)
     was delivered to the lead.
   - **(b)** Whether the short-form ping (`team-lead`) was delivered
     to the lead.
   - **(c)** Any error returned to the worker for either call (quote
     verbatim).

## Expected outcome

Only the short-form ping arrives at the lead; the qualified-form
ping is silently dropped (or returns an error from the worker side).

## Result interpretation

- **PASS**: Only the short-form ping appeared in the lead's
  conversation.
- **FAIL**: Both pings appeared, or only the qualified-form ping
  appeared.
- **INCONCLUSIVE**: Neither ping appeared (possible team-spawn or
  preload failure unrelated to routing); or the worker errored on a
  cause unrelated to the routing form (e.g., team not yet ready).

## Environment record (fill at run time)

- Claude Code version: …
- OS: …
- Install method: native | npm-global | homebrew
- Shell: …
- Terminal emulator + version: …
- Model in use: …
- `team_name` returned by `TeamCreate`: …
- `lead_agent_id` returned by `TeamCreate`: …

## Notes

- This probe formalizes the cited behavior in
  `roles/orchestrator.md:29`. The behavior was reported anecdotally
  during the original `7d3e354` ("anchor substitution value to
  literal 'team-lead'") commit but never reproduced from a script in
  this repo. Until run, the doctrine treats the qualified-form-fails
  claim as a working assumption.
- Send the qualified-form ping *before* the short-form ping so that
  if both unexpectedly arrive, ordering disambiguates which call
  actually delivered.
