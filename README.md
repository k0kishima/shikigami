# Shikigami

<p align='center'>
  <img src="assets/social-preview.png" width="720" alt="shikigami" />
</p>

<p align='center'>
  English | <a href='./README.ja.md'>日本語</a>
</p>

An on-demand AI agent orchestrator specialized for software development.

## What is this?

Shikigami[^1] is a tool that leverages AI to streamline software development.

[^1]: Named after spiritual servants summoned by Onmyoji (ancient Japanese court sorcerers). Each AI agent is likened to a shikigami—created with the user's intent and serving their purposes.

- It uses AI agent orchestration as the primary means to achieve goals
- Users interact only with an orchestrator-role AI agent. When users convey their initial request, the orchestrator begins requirements analysis
- Once requirements are defined, the orchestrator generates a team of AI agents (task force) suited to fulfill those requirements
- Subsequent processes are carried out autonomously by the task force

## Target Users

- Users are assumed to be software developers
  - Designed for developers who want to focus on architecture design and decision-making rather than implementation details
- Shikigami's orchestrator conducts interviews with users until requirements are finalized, so users must be able to respond to these
  - Users need domain knowledge about the software they want to develop
  - Users are expected to make clear decisions on technical questions (e.g., database selection, framework choices)

## Prerequisites

- [Claude Code](https://claude.ai/code) >= 2.1.32 (requires Agent Teams support)
- macOS or Linux (UNIX-based OS)

## Installation

```bash
git clone https://github.com/k0kishima/shikigami.git
cd shikigami
./install.sh
```

After installation, restart your terminal or run `source ~/.zshrc` (or `~/.bashrc`).

## Usage

Navigate to your project directory and run:

```bash
shikigami
```

The orchestrator will start and guide you through the requirements analysis process.

## Design

- [Ubiquitous Language](./docs/glossary.md)
- [Purpose of Orchestration](./docs/purpose-of-orchestration.md)
- [How Orchestration Works](./docs/orchestration-mechanism.md)
- [Role Definition Guide](./docs/role-definition-guide.md)
