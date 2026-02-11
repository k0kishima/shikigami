# Custom Roles

<p align='center'>
  English | <a href='./custom-roles.ja.md'>日本語</a>
</p>

## Overview

Shikigami provides built-in roles (Coder, Reviewer, Tester, etc.), but they may not be sufficient for every project.
The custom roles feature allows you to define project-specific roles and incorporate them into task forces.

## Use Cases

- Specialize Coder into frontend and backend engineers
- Add roles not available as built-in, such as data engineer or infrastructure engineer
- Create specialized roles with project-specific domain knowledge

## Location

Place role templates in `.shikigami/roles/` in your working directory.

```
<working directory>/
  .shikigami/
    roles/
      frontend_coder.md
      backend_coder.md
      data_engineer.md
    contexts/          ← Role-specific context (can be used together)
      frontend_coder.md
      backend_coder.md
```

## Template Format

Custom roles must follow the [Role Definition Guide](./role-definition-guide.md).
Use the same format as built-in roles (Description, Goal, Backstory, Constraints, Tools, Temperature).

## Overriding Built-in Roles

When a custom role has the same name as a built-in role, the custom role takes precedence.

For example, placing `.shikigami/roles/coder.md` will cause it to be used instead of the built-in `roles/coder.md`.
This allows you to adjust built-in role behavior to suit your project.

## Using with Context Files

Custom roles can also use context management via `.shikigami/contexts/`.
We recommend the following separation: use role templates for role definitions (persona, goals, constraints) and context files for project-specific information (standards, policies).

| File | Content |
|------|---------|
| `.shikigami/roles/frontend_coder.md` | Role definition (persona as a React-specialized frontend developer, etc.) |
| `.shikigami/contexts/frontend_coder.md` | Project-specific information (component design standards, CSS naming conventions, etc.) |

## Orchestrator Behavior

When proposing a task force, the orchestrator uses both built-in and custom roles as candidates.

1. List built-in roles (`$ROLES_DIR/`)
2. List custom roles (`.shikigami/roles/`)
3. Override with custom roles where names conflict
4. Design the task force based on the merged role list
