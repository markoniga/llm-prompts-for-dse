# LLM Prompts

A repository of LLM prompts that can be served over MCP to your LLM. Write once, prompt anywhere.

## Features

- A collection of useful LLM prompts (see: [src/llm-prompts](./src/llm-prompts/))
- LLM prompts are served via MCP
- Easily extendable for additional LLM prompts
- Built with TypeScript and the official MCP SDK
- Complete data workflow prompt pathway for analytics engineering tasks

---

## Available prompts

### General Prompts

#### `getCodeChangePlanningInstructions`

- **Description:** Provides detailed, step-by-step instructions for planning an LLM-assisted code change.
  Use this tool to help a software developer and LLM collaboratively create a robust, actionable plan
  for implementing a code change, including best practices for clarifying requirements,
  structuring tasks, and managing dependencies.
- **Returns:** The full contents of [`code-change-planning-instructions.md`](./src/llm-prompts/code-change-planning-instructions.md)

#### `getGitCommitInstructions`

- **Description:** Returns best-practice instructions and examples for writing semantic git commit messages. Use this tool to help a developer or LLM generate clear, conventional commit messages that communicate the intent and context of code changes, following the semantic commit format.
- **Returns:** The full contents of [`git-commit-instructions.md`](./src/llm-prompts/git-commit-instructions.md)

#### `getDataReconciliationInstructions`

- **Description:** Returns best-practice instructions and examples for data reconciliation. Use this tool to help a developer or LLM generate clear, conventional data reconciliation messages that communicate the intent and context of data changes.
- **Returns:** The full contents of [`data-reconcilitation.md`](./src/llm-prompts/data-reconcilitation.md)

### Data Workflow Prompts

The data workflow prompts form a complete pathway that guides data scientists and analytics engineers from initial question to code merged. These prompts work together in a sequential flow to ensure high-quality data transformations, documentation, and testing.

#### Data Workflow Pathway Diagram

```mermaid
flowchart TD
    Q[User asks a question] --> I(interpret_intent.prompt)
    I --> C(context_gap.prompt)
    C -->|needs code| G(generate_code.prompt)
    C -->|needs docs only| D(gen_docs.prompt)
    G --> V(validate_risk.prompt)
    V -->|safe| R(run_dbt.prompt)
    V -->|needs confirm| CF{{"Proceed?"}}
    CF -- yes --> R
    CF -- no --> ABORT[[Abort]]
    R --> T(test_results.prompt)
    T -->|fail| FX(fixup_suggestions.prompt)
    T -->|pass| PR(create_pr.prompt)
    PR --> M(merge_guard.prompt)
    M --> DONE[Code merged ✅]
    subgraph rollbacks
        V -->|high risk detected| RB(rollback_plan.prompt)
    end
```

#### `getInterpretIntentPrompt`

- **Description:** Returns a prompt to help clarify user goals and classify data workflow intents. Use this tool to determine if a user is asking a question, requesting a code change, or needing documentation updates.
- **Returns:** The full contents of [`interpret_intent.prompt`](./src/llm-prompts/data-workflow/interpret_intent.prompt)

#### `getContextGapPrompt`

- **Description:** Returns a prompt to identify missing information needed to address a data workflow request. Use this tool to analyze context gaps and gather necessary schema information or business logic.
- **Returns:** The full contents of [`context_gap.prompt`](./src/llm-prompts/data-workflow/context_gap.prompt)

#### `getGenerateCodePrompt`

- **Description:** Returns a prompt to generate high-quality dbt code for models, macros, tests, and other artifacts. Use this tool to create SQL code that follows best practices and project standards.
- **Returns:** The full contents of [`generate_code.prompt`](./src/llm-prompts/data-workflow/generate_code.prompt)

#### `getGenDocsPrompt`

- **Description:** Returns a prompt to generate comprehensive documentation for dbt models, columns, and tests. Use this tool to create clear explanations of business logic and data lineage.
- **Returns:** The full contents of [`gen_docs.prompt`](./src/llm-prompts/data-workflow/gen_docs.prompt)

#### `getValidateRiskPrompt`

- **Description:** Returns a prompt to assess risks in proposed data operations, particularly SQL queries and dbt model changes. Use this tool to evaluate potential impacts on data integrity, performance, and cost, and perform schema reconciliation between environments.
- **Returns:** The full contents of [`validate_risk.prompt`](./src/llm-prompts/data-workflow/validate_risk.prompt)

#### `getRollbackPlanPrompt`

- **Description:** Returns a prompt to generate comprehensive rollback plans for data operations. Use this tool to create scripts and procedures to restore data to its previous state if an operation fails.
- **Returns:** The full contents of [`rollback_plan.prompt`](./src/llm-prompts/data-workflow/rollback_plan.prompt)

#### `getRunDbtPrompt`

- **Description:** Returns a prompt to help execute dbt commands safely and efficiently. Use this tool to get guidance on running models, tests, and other dbt operations in a controlled manner, including schema reconciliation execution steps.
- **Returns:** The full contents of [`run_dbt.prompt`](./src/llm-prompts/data-workflow/run_dbt.prompt)

#### `getTestResultsPrompt`

- **Description:** Returns a prompt to analyze and interpret dbt test results. Use this tool to understand test outcomes, prioritize fixes, make data quality decisions, and validate schema reconciliation between environments.
- **Returns:** The full contents of [`test_results.prompt`](./src/llm-prompts/data-workflow/test_results.prompt)

#### `getFixupSuggestionsPrompt`

- **Description:** Returns a prompt to generate targeted code fixes for failed dbt tests or performance problems. Use this tool to get specific, actionable code changes to resolve identified issues.
- **Returns:** The full contents of [`fixup_suggestions.prompt`](./src/llm-prompts/data-workflow/fixup_suggestions.prompt)

#### `getCreatePRPrompt`

- **Description:** Returns a prompt to generate comprehensive, well-structured pull request descriptions. Use this tool to create PR content that clearly communicates the purpose and implementation details of code changes, including schema reconciliation documentation.
- **Returns:** The full contents of [`create_pr.prompt`](./src/llm-prompts/data-workflow/create_pr.prompt)

#### `getMergeGuardPrompt`

- **Description:** Returns a prompt to ensure pull requests meet all necessary requirements before being merged. Use this tool to validate that code reviews, tests, schema reconciliation, and other quality checks have been completed.
- **Returns:** The full contents of [`merge_guard.prompt`](./src/llm-prompts/data-workflow/merge_guard.prompt)

---

## Installation

1. **Clone the repository**

   ```sh
   git clone git@github.com:BrentLayne/llm-prompts.git
   ```

2. **Install dependencies**
   ```sh
   yarn install
   ```

---

## Usage

1. **Make sure to build**

Compile the source code so it's ready to run.

```sh
yarn build
```

2. **Add the MCP server to Cursor (or your other MCP client of choice) and get your LLM to pull in prompts that you can then use to prompt the LLM!**

Example Cursor usage:

1. Add to MCP config

```typescript
// in Cursor's mcp.json file
{
   ...other MCPs,
   "llm-prompts": {
      "command": "node",
      "args": [
        "/your/path/to/llm-prompts/build/server.js"
      ]
    }
}
```

2. Prompt the agent to prompt itself

- Example for general prompts: "Read the instructions on how to plan a feature and then follow those instructions to help me write a new feature"

- Example for data workflow prompts: "Help me create a new dbt model for customer segmentation using the data workflow prompts"

### Using the Data Workflow Prompt Pathway

The data workflow prompts are designed to be used in sequence to guide you through the entire process of developing, testing, and deploying dbt models. Here's how to use them effectively:

1. **Start with Intent Classification**:
   - Begin by asking the agent to use the interpret_intent prompt to understand your request
   - Example: "Use the interpret_intent prompt to understand what I'm trying to do with this customer segmentation model"

2. **Fill Context Gaps**:
   - The agent will identify missing information and ask clarifying questions
   - Example: "Use the context_gap prompt to identify what information we need to build this model"

3. **Generate Code or Documentation**:
   - Depending on your needs, the agent will help create SQL code or documentation
   - Example: "Use the generate_code prompt to create a dbt model for customer segmentation"

4. **Validate and Test**:
   - The agent will help assess risks, create rollback plans if needed, and run tests
   - Example: "Use the validate_risk prompt to check if this model change is safe"

5. **Create PR and Merge**:
   - Once the code is ready and tested, the agent will help create a PR and ensure it meets requirements
   - Example: "Use the create_pr prompt to generate a pull request for this new model"

This workflow ensures that your data transformations are well-designed, properly tested, and safely deployed.

### Schema Reconciliation Features

The data workflow prompts include comprehensive schema reconciliation capabilities to ensure safe and consistent schema changes across environments:

#### Schema Reconciliation Process

1. **Risk Assessment** (`validate_risk.prompt`):
   - Identifies schema changes (column additions, removals, type changes)
   - Quantifies impact on data volume and downstream dependencies
   - Classifies risk level of schema changes (high, medium, low)
   - Generates detailed schema comparison tables

2. **Execution** (`run_dbt.prompt`):
   - Provides pre-execution reconciliation steps to capture baseline schemas
   - Includes specialized commands for reconciliation mode execution
   - Offers post-execution verification queries to validate changes
   - Generates schema change summary reports

3. **Validation** (`test_results.prompt`):
   - Determines if schema reconciliation is needed based on test results
   - Performs reconciliation checks for schema comparison and data integrity
   - Analyzes downstream impact of schema changes
   - Provides reconciliation recommendations and verification steps

4. **Documentation** (`create_pr.prompt`):
   - Generates comprehensive schema reconciliation documentation for PRs
   - Creates detailed schema comparison tables showing changes
   - Includes data volume impact analysis
   - Documents downstream dependency impacts

5. **Verification** (`merge_guard.prompt`):
   - Ensures schema reconciliation is completed before approving merges
   - Verifies reconciliation documentation is complete and accurate
   - Identifies potential reconciliation blockers
   - Provides final reconciliation approval conditions

#### Example Schema Comparison Table

```markdown
## 📊 SCHEMA COMPARISON: `model_name`

| Column Name | Production Type | Dev Type | Status | Impact | Rows Affected |
|-------------|-----------------|----------|---------|---------|---------------|
| user_id | INTEGER | INTEGER | ✅ MATCH | - | - |
| email | VARCHAR(255) | VARCHAR(500) | ⚠️ MODIFIED | Size increased | 0 |
| created_at | TIMESTAMP | TIMESTAMP | ✅ MATCH | - | - |
| new_column | - | VARCHAR(100) | 🆕 ADDED | New data point | All rows |
| old_column | VARCHAR(50) | - | 🗑️ REMOVED | Data loss risk | 1,234,567 |

**Summary**: 5 columns analyzed • 1 modified • 1 added • 1 removed • ⚠️ Data loss risk
```

These schema reconciliation features ensure that schema changes are properly assessed, documented, and verified throughout the development and deployment process, reducing the risk of data integrity issues and unexpected impacts on downstream dependencies.

---

## Local development workflow

### Folder Structure

The repository is organized as follows:

```
src/
├── llm-prompts/               # Root directory for all prompts
│   ├── code-change-planning-instructions.md
│   ├── data-reconcilitation.md
│   ├── git-commit-instructions.md
│   └── data-workflow/         # Data workflow prompts directory
│       ├── interpret_intent.prompt
│       ├── context_gap.prompt
│       ├── generate_code.prompt
│       ├── gen_docs.prompt
│       ├── validate_risk.prompt
│       ├── rollback_plan.prompt
│       ├── run_dbt.prompt
│       ├── test_results.prompt
│       ├── fixup_suggestions.prompt
│       ├── create_pr.prompt
│       └── merge_guard.prompt
└── mcp-server/               # MCP server implementation
    └── server.ts
```

### Adding New Prompts

- Add a new prompt to [src/llm-prompts](./src/llm-prompts/) or create a new subdirectory for related prompts
- Register the prompt in [src/mcp-server/server.ts](./src/mcp-server/server.ts)
- Update the [mcp-prompts-manifest.json](./mcp-prompts-manifest.json) by running the refresh script

### Updating Existing Prompts

1. Edit the prompt file in the appropriate directory
2. Run the refresh script to update the manifest file:
   ```sh
   bash scripts/refresh-mcp-prompts.sh
   ```
3. Rebuild the server to pick up the changes

### Run the MCP server locally (with hot reload)

```sh
yarn dev
```

### Debug with MCP Inspector (always make sure to build first, to pick up your latest changes)

```sh
yarn build
yarn inspector
```

---

## References

- [MCP SDK Documentation](https://github.com/modelcontextprotocol/typescript-sdk)
