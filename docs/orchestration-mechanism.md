# How Orchestration Works

<p align='center'>
  English | <a href='./orchestration-mechanism.ja.md'>日本語</a>
</p>

## Adopting Claude Code Agent Teams

Shikigami's orchestration is built on [Claude Code](https://claude.ai/code)'s **Agent Teams** feature.

Agent Teams provides a groundbreaking capability: generating AI agent teams through natural language instructions alone.
By leveraging this feature, Shikigami can realize dynamic task force generation without building an orchestration engine from scratch.

## Tradeoffs

This approach creates a hard dependency on Claude Code.
However, we accept this tradeoff in exchange for the significant reduction in implementation complexity.

*Note: In the future, we plan to enable cross-model agent communication to support multi-model orchestration.
