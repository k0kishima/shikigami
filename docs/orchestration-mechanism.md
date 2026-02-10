# How Orchestration Works

<p align='center'>
  English | <a href='./orchestration-mechanism.ja.md'>日本語</a>
</p>

This document explains how Shikigami realizes the orchestration concepts described in [Purpose of Orchestration](./purpose-of-orchestration.md).

## Technology Foundation

Shikigami's orchestration is built entirely on [Claude Code](https://claude.ai/code)'s **Agent Teams** feature. Agent Teams allows a Claude Code session to spawn multiple sub-agents (called "teammates"), each with their own system prompt and context. Shikigami uses this capability to dynamically create task forces tailored to each user's requirements.

## System Components

The orchestration mechanism consists of four key components:

| Component | File | Role |
|---|---|---|
| CLI | `bin/shikigami` | Entry point that bootstraps the orchestrator |
| Orchestrator instructions | `CLAUDE.md` | Defines the mandatory workflow |
| Orchestrator role template | `roles/orchestrator.md` | Defines the orchestrator's persona and design principles |
| Specialist role templates | `roles/*.md` | Define personas for spawned agents |

## Bootstrapping Flow

When a user runs the `shikigami` command, the CLI script performs the following sequence:

1. **Prerequisite check** — Verifies that Claude Code is installed
2. **Feature enablement** — Sets `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` to activate Agent Teams
3. **System prompt construction** — Reads the orchestrator role template (`roles/orchestrator.md`), enumerates all available role templates in `roles/`, and assembles a system prompt that includes:
   - The orchestrator's role definition (persona, temperature, design principles)
   - The list of available roles with file paths
   - Instructions on how to spawn teammates by reading role template files
4. **Launch** — Executes `claude --system-prompt "$SYSTEM_PROMPT"` to start Claude Code as the orchestrator

## Workflow Enforcement

The orchestrator's behavior is governed by `CLAUDE.md`, which enforces a strict five-step workflow:

1. **Requirements Analysis** — The orchestrator asks clarifying questions and confirms scope with the user
2. **Task Force Proposal** — The orchestrator proposes a team composition using only the defined role templates and gets user approval
3. **Spawn Task Force** — The orchestrator reads the role template files and spawns agents with those templates as instructions
4. **Report Formation** — The spawned task force composition is displayed to the user
5. **Coordinate** — The orchestrator assigns tasks, manages feedback loops, and reports results

`CLAUDE.md` also defines forbidden actions (e.g., starting work without requirements analysis, doing implementation work directly) to ensure the orchestrator stays in its coordination role.

## Role Templates and Agent Spawning

Each role template in `roles/` defines a specialized agent persona with:

- **Backstory** — A fictional background that shapes the agent's behavior
- **Temperature** — Controls the creativity-determinism tradeoff for that role
- **Responsibilities and constraints** — What the agent should and should not do

When the orchestrator spawns a task force, it reads the template file for each needed role and passes the content as the sub-agent's system prompt via Agent Teams. This means each agent operates with its own specialized instructions independent of the orchestrator's context.

### Available Roles

| Role | Temperature | Purpose |
|---|---|---|
| Coder | 0.3 | Implementation based on requirements and design specs |
| Reviewer | 0.2 | Code quality and design evaluation |
| Tester | 0.3 | Test execution and additional test case creation |
| Security Engineer | 0.2 | Security vulnerability detection |
| Performance Engineer | 0.2 | Performance analysis and bottleneck identification |
| System Architect | 0.4 | Technology selection and system design |

## Realizing Parallelization and Layering

The orchestration concepts from [Purpose of Orchestration](./purpose-of-orchestration.md) are realized as follows:

### Parallelization

Multiple agents with the same role (e.g., two Coders) can be spawned to work on the same problem independently. Their outputs provide the diversity of solutions described in the purpose document.

### Layering

Different roles naturally form layers. For example:
- **Generation layer**: Coder agents produce implementations in parallel
- **Evaluation layer**: A Reviewer agent compares and evaluates the implementations

The orchestrator designs these layers dynamically based on requirements — there is no fixed layer structure.

### Temperature by Layer

Temperature settings in role templates reflect the layer design principles:
- Exploration roles (Coder, System Architect) have higher temperatures (0.3–0.4) for diversity
- Convergence roles (Reviewer, Security Engineer, Performance Engineer) have lower temperatures (0.2) for stable evaluation

## Architecture Overview

```
User
 ↓
bin/shikigami (CLI)
 │  Enables Agent Teams
 │  Builds system prompt from role templates
 ↓
Claude Code (Orchestrator)
 │  System prompt: orchestrator.md + role list
 │  Workflow enforced by: CLAUDE.md
 │
 │  Step 1-2: Requirements analysis → Task force proposal
 │  Step 3:   Spawn agents via Agent Teams
 ↓
┌─────────┬─────────┬─────────┐
│ Coder   │ Coder   │ Tester  │  ← Generation / Execution layer
└────┬────┴────┬────┴────┬────┘
     │         │         │
     ↓         ↓         ↓
┌─────────────────────────────┐
│ Reviewer                    │  ← Evaluation / Convergence layer
└─────────────────────────────┘
```

The specific composition varies per task — the orchestrator determines the optimal structure after requirements analysis.
