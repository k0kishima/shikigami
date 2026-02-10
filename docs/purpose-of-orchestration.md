# Purpose of Orchestration

<p align='center'>
  English | <a href='./purpose-of-orchestration.ja.md'>日本語</a>
</p>

The purpose of orchestrating AI agents is to overcome LLM non-determinism and obtain high-quality outputs while minimizing human intervention.
To achieve this, we adopt parallelization and layering.

## Ensuring Diversity of Solutions Through Parallelization

### The Non-Deterministic Nature of AI

- Current LLMs do not return a single deterministic value for a given input like a function
- Specifically, even when providing the same model with the same prompt (and even the same temperature), generation results can differ each time due to internal sampling and token selection fluctuations
  - In other words, LLM responses are not "input → output" but rather "input → probability distribution of outputs"
- This characteristic is sometimes metaphorically described as "AI is like gacha"

### Parallel Execution as a Solution

- In non-deterministic generative models, it is not uncommon to fail to obtain a "winning solution" that exists locally in a single trial
- A simple and effective strategy for this problem is to increase the number of samples (trial attempts)
- Parallel execution is an implementation solution that ensures output diversity without increasing wall-time (the actual time humans wait)

### Summary

- Current LLMs inherently perform non-deterministic response generation
- Therefore, generating multiple samples simultaneously is statistically more advantageous than sequential single trials
- We adopt parallel execution as the implementation means to "obtain multiple samples simultaneously"

## Convergence and Output Optimization Through Layering

### Limitations of Parallelization

- Parallelization simply samples the same problem independently n times
- Parallelization itself does not perform any "relative evaluation" or "selection" of generation results
  - Operating with this alone, users still need to read all the increased responses and find the optimal solution among them
- In other words, "quantity" increases, but "quality" does not automatically improve

### Adding Upper Layers to Converge Parallelization

- We address the problem from the previous section by placing a meta-evaluation layer one level above the parallel execution layer
- The upper layer oversees multiple proposals submitted by lower layers, performing comparison, integration, and rejection to converge outputs into "usable solutions"

### Dynamic Layer Design According to Requirements

- Layers are not divided solely for the purpose of converging parallelization
- They can also be separated by roles such as evaluation and decision-making
- Rather than applying a pre-fixed layer structure, optimal layer structures should be designed after analyzing requirements
- In Shikigami, an AI agent with the role of orchestrator is placed as the interface with users
  - The orchestrator performs requirements analysis based on user prompts and dynamically generates a task force with the optimal configuration for the requirements

### Temperature Principles in Layer Design

- The temperature[^1] of each layer designed by the orchestrator is set according to its role
- Layers responsible for exploration have higher temperature, making the probability distribution flatter
  - To emphasize diversity and creativity
- Layers responsible for convergence have lower temperature, making the probability distribution sharper
  - To perform stable decision-making

### Summary

- Rather than applying a pre-fixed layer structure, design and apply optimal layer structures after analyzing requirements
  - This leads to resource reduction and ensuring output quality
- Users only need to review the final output and do not need to intervene in the intermediate processes at each layer

[^1]: Temperature is a parameter that controls the trade-off between creativity (diversity) and determinism.
