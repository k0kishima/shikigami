# Role Definition Guide

<p align='center'>
  English | <a href='./role-definition-guide.ja.md'>日本語</a>
</p>

This document explains how to define role templates used in Shikigami.

## Overview

Role templates are placed in the `roles/` directory. File names follow the `{role_name}.md` format.

## Language

Role templates must be written in English.

Role templates are read and interpreted by AI agents, not humans. Since current LLMs generally have higher comprehension and reasoning accuracy in English, writing roles in English maximizes the AI's ability to understand and follow the instructions.

Human-facing documentation (such as files in `docs/`) may be provided in multiple languages, but role templates should always be in English.

## Origin of the Format

This format is designed based on the agent definition of CrewAI, a multi-agent framework.

| Item | Origin |
|------|--------|
| Description | Equivalent to CrewAI's `role` |
| Goal | CrewAI |
| Backstory | CrewAI |
| Constraints | MetaGPT's `constraints` |
| Tools | CrewAI |
| Temperature | Added independently for LLM settings |

CrewAI was chosen because it is simple, highly readable, and compatible with Markdown format.

## Basic Structure

All role templates include the following items.

| Item | Required | Description |
|------|----------|-------------|
| Description | ○ | Overview of the role |
| Goal | ○ | Goals to achieve |
| Backstory | ○ | Persona settings |
| Constraints | ○ | Constraints and prohibitions |
| Tools | ○ | Available tools |
| Temperature | ○ | Recommended temperature and rationale |

## Guidelines for Each Item

### Description

Describe the role overview in 1-2 sentences. Include the position within the task force (such as which layer it is placed in) if applicable.

```markdown
## Description

A role responsible for code implementation in software development. Generates high-quality, maintainable code based on requirements and design.
```

### Goal

List the goals this role should achieve in bullet points. Specific and verifiable goals are preferred.

```markdown
## Goal

- Accurately implement code that meets given requirements
- Write readable and maintainable code
- Follow the existing codebase's style and conventions
```

### Backstory

Describe the persona settings for the role. Including background of expertise and experience gives consistency to the role's behavior.

```markdown
## Backstory

A senior software engineer with over 10 years of practical experience. Proficient in multiple languages and frameworks, emphasizing clean code principles and best practices.
```

### Constraints

List the constraints and prohibitions the role must follow in bullet points.

```markdown
## Constraints

- Strive for testable design
- Avoid excessive abstraction and premature optimization
- Do not add features not in the requirements
```

### Tools

List the tools available to the role in bullet points.

```markdown
## Tools

- File read/write
- Command execution (build, test, linter, etc.)
- Web search (documentation reference)
```

### Temperature

Describe the recommended temperature value and its rationale.

```markdown
## Temperature

0.3

Set low to prioritize stability and consistency. Code generation requires accuracy over creativity.
```

Temperature guidelines:

| Value | Use Case |
|-------|----------|
| 0.1-0.3 | Accuracy/stability focused (evaluation, verification, code generation) |
| 0.4-0.6 | Balanced (requirements analysis, design) |
| 0.7-1.0 | Creativity/diversity focused (ideation, exploration) |

## Additional Items for Special Roles

### Orchestrator

Since the orchestrator has the responsibility of designing and generating task forces, it includes a "Task Force Design Principles" section in addition to the basic items.

```markdown
## Task Force Design Principles

The orchestrator follows these principles when designing task forces.

### Parallelization Criteria
...

### Layer Structure Criteria
...
```
