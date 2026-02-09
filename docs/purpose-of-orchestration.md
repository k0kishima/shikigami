# Purpose of Orchestration

<p align='center'>
  English | <a href='./purpose-of-orchestration.ja.md'>日本語</a>
</p>

The purpose of orchestrating AI agents is to overcome LLM non-determinism and obtain high-quality outputs while minimizing human intervention.  
To achieve this, we adopt parallelization and hierarchical structuring.

## Addressing LLM's "Gacha" Nature Through Parallelization

### The Non-Deterministic Nature of AI

- Current LLMs do not return a single deterministic value for a given input like a function
- Specifically, even when providing the same model with the same prompt (and even the same temperature), generation results can differ each time due to internal sampling and token selection fluctuations
  - In other words, LLM responses are not "input → output" but rather "input → probability distribution of outputs"
- This characteristic is sometimes metaphorically described as "AI is like gacha"

### Parallel Execution as a Solution

- In non-deterministic generative models, it is not uncommon to fail to obtain a "winning solution" that exists locally in a single trial
- A simple and effective strategy for this problem is to increase the number of samples (trial attempts)
- Parallel execution is an implementation solution that ensures output diversity without increasing wall-time (the actual time humans wait)

### Conclusion

- Current LLMs inherently perform non-deterministic response generation
- Therefore, generating multiple samples simultaneously is statistically more advantageous than sequential single trials
- We adopt parallel execution as the implementation means to "obtain multiple samples simultaneously"

## Adding Upper Layers to Compensate for Parallelization Limits

### Parallelization Alone Is Insufficient

- Parallelization simply samples the same problem independently n times
- "Quantity" increases, but "quality" does not automatically improve
- With parallelization alone, humans still need to read all the increased responses and find the optimal solution among them

### Adding Upper Layers to Converge Parallelization

- Parallelization itself does not perform any "relative evaluation" or "selection" of generation results
- We address this problem by placing a meta-evaluation layer one level above the parallel execution layer
- By overseeing multiple proposals and performing comparison, integration, and rejection, we converge the parallel layer's output into "usable solutions"

### Conclusion

- Parallelization ensures diversity of solutions, and the layer above performs efficient convergence—this is the evaluation layer
- Evaluation and decision-making are separate tasks
  - Evaluation is "judging the quality of each proposal," while decision-making is "deciding which proposal to adopt"
  - Separating these maintains consistency in evaluation criteria while enabling flexible decision-making according to context
- Based on this concept, for example, a configuration where a decision-making layer is placed above the evaluation layer can be considered
- However, this is a principle of layer separation, and actual hierarchical structures are designed dynamically according to requirements

## Automating Up to Decision-Making Through Hierarchical Structuring

### Dynamic Hierarchical Design According to Requirements

- The number of layers and the role of each layer in hierarchical structuring should vary according to the nature of the task
- Rather than applying a pre-fixed hierarchical structure, optimal hierarchical structures should be designed after analyzing requirements
- In Shikigami, the orchestrator performs requirements analysis and dynamically generates a task force with the optimal configuration for that task
  - Simple tasks: Shallow hierarchy (e.g., 2 layers: generation → decision-making)
  - Standard tasks: Medium hierarchy (e.g., 3 layers: generation → evaluation → decision-making)
  - Complex tasks: Deep hierarchy (e.g., 5 layers: research → generation → evaluation → integration → decision-making)
- By optimizing the hierarchical structure itself according to requirements, we avoid excessive complexity while ensuring necessary quality

### Temperature Principles in Hierarchical Design

- In the hierarchy designed by the orchestrator, each layer's temperature is set according to its role
- Temperature is a parameter that controls the trade-off between creativity (diversity) and determinism
- Layers responsible for exploration have higher temperature, making the probability distribution flatter
  - To emphasize diversity and creativity
- Layers responsible for convergence have lower temperature, making the probability distribution sharper
  - To perform stable decision-making

### Conclusion

- Hierarchical structuring improves efficiency and accuracy through role separation and temperature gradients
- However, the optimal hierarchical structure differs for each task
- Shikigami's orchestrator dynamically designs the optimal hierarchical structure based on requirements analysis and realizes it as a task force
