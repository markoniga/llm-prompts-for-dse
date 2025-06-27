import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const server = new McpServer({
    name: "mcp-server",
    version: "1.0.0",
});
// Data Workflow Prompts
server.tool("getInterpretIntentPrompt", `Returns a prompt to help clarify user goals and classify data workflow intents.
  Use this tool to determine if a user is asking a question, requesting a code change, or needing documentation updates.`, {}, // No parameters
async () => {
    const promptPath = path.resolve(__dirname, "../src/llm-prompts/data-workflow/interpret_intent.md");
    const text = fs.readFileSync(promptPath, "utf8");
    return {
        content: [{ type: "text", text }],
    };
});
server.tool("getContextGapPrompt", `Returns a prompt to identify missing information needed to address a data workflow request.
  Use this tool to analyze context gaps and gather necessary schema information or business logic.`, {}, // No parameters
async () => {
    const promptPath = path.resolve(__dirname, "../src/llm-prompts/data-workflow/context_gap.md");
    const text = fs.readFileSync(promptPath, "utf8");
    return {
        content: [{ type: "text", text }],
    };
});
server.tool("getGenerateCodePrompt", `Returns a prompt to generate high-quality dbt code for models, macros, tests, and other artifacts.
  Use this tool to create SQL code that follows best practices and project standards.`, {}, // No parameters
async () => {
    const promptPath = path.resolve(__dirname, "../src/llm-prompts/data-workflow/generate_code.md");
    const text = fs.readFileSync(promptPath, "utf8");
    return {
        content: [{ type: "text", text }],
    };
});
server.tool("getGenDocsPrompt", `Returns a prompt to generate comprehensive documentation for dbt models, columns, and tests.
  Use this tool to create clear explanations of business logic and data lineage.`, {}, // No parameters
async () => {
    const promptPath = path.resolve(__dirname, "../src/llm-prompts/data-workflow/gen_docs.md");
    const text = fs.readFileSync(promptPath, "utf8");
    return {
        content: [{ type: "text", text }],
    };
});
server.tool("getValidateRiskPrompt", `Returns a prompt to assess risks in proposed data operations, particularly SQL queries and dbt model changes.
  Use this tool to evaluate potential impacts on data integrity, performance, and cost.`, {}, // No parameters
async () => {
    const promptPath = path.resolve(__dirname, "../src/llm-prompts/data-workflow/validate_risk.md");
    const text = fs.readFileSync(promptPath, "utf8");
    return {
        content: [{ type: "text", text }],
    };
});
server.tool("getRollbackPlanPrompt", `Returns a prompt to generate comprehensive rollback plans for data operations.
  Use this tool to create scripts and procedures to restore data to its previous state if an operation fails.`, {}, // No parameters
async () => {
    const promptPath = path.resolve(__dirname, "../src/llm-prompts/data-workflow/rollback_plan.md");
    const text = fs.readFileSync(promptPath, "utf8");
    return {
        content: [{ type: "text", text }],
    };
});
server.tool("getRunDbtPrompt", `Returns a prompt to help execute dbt commands safely and efficiently.
  Use this tool to get guidance on running models, tests, and other dbt operations in a controlled manner.`, {}, // No parameters
async () => {
    const promptPath = path.resolve(__dirname, "../src/llm-prompts/data-workflow/run_dbt.md");
    const text = fs.readFileSync(promptPath, "utf8");
    return {
        content: [{ type: "text", text }],
    };
});
server.tool("getRunTestsPrompt", `Returns a prompt to execute dbt build and pytest validation tests.
  Runs 'dbt build --select {{ models }}' then 'pytest tests/prompt_formatting' to ensure comprehensive validation.`, {}, // No parameters
async () => {
    const promptPath = path.resolve(__dirname, "../src/llm-prompts/data-workflow/run_tests.md");
    const text = fs.readFileSync(promptPath, "utf8");
    return {
        content: [{ type: "text", text }],
    };
});
server.tool("getReconcilePrompt", `Returns a prompt to automate local dbt build and Preset reconciliation workflow.
  Runs dbt build --select {{ models }}, validates build success, executes Preset MCP reconciliation, and summarizes differences in a clear Markdown table format.`, {}, // No parameters
async () => {
    const promptPath = path.resolve(__dirname, "../src/llm-prompts/data-workflow/reconcile.md");
    const text = fs.readFileSync(promptPath, "utf8");
    return {
        content: [{ type: "text", text }],
    };
});
server.tool("getTestResultsPrompt", `Returns a prompt to analyze and interpret dbt test results.
  Use this tool to understand test outcomes, prioritize fixes, and make data quality decisions.`, {}, // No parameters
async () => {
    const promptPath = path.resolve(__dirname, "../src/llm-prompts/data-workflow/test_results.md");
    const text = fs.readFileSync(promptPath, "utf8");
    return {
        content: [{ type: "text", text }],
    };
});
server.tool("getFixupSuggestionsPrompt", `Returns a prompt to generate targeted code fixes for failed dbt tests or performance problems.
  Use this tool to get specific, actionable code changes to resolve identified issues.`, {}, // No parameters
async () => {
    const promptPath = path.resolve(__dirname, "../src/llm-prompts/data-workflow/fixup_suggestions.md");
    const text = fs.readFileSync(promptPath, "utf8");
    return {
        content: [{ type: "text", text }],
    };
});
server.tool("getCreatePRPrompt", `Returns a prompt to generate comprehensive, well-structured pull request descriptions.
  Use this tool to create PR content that clearly communicates the purpose and implementation details of code changes.`, {}, // No parameters
async () => {
    const promptPath = path.resolve(__dirname, "../src/llm-prompts/data-workflow/create_pr.md");
    const text = fs.readFileSync(promptPath, "utf8");
    return {
        content: [{ type: "text", text }],
    };
});
server.tool("getMergeGuardPrompt", `Returns a prompt to ensure pull requests meet all necessary requirements before being merged.
  Use this tool to validate that code reviews, tests, and other quality checks have been completed.`, {}, // No parameters
async () => {
    const promptPath = path.resolve(__dirname, "../src/llm-prompts/data-workflow/merge_guard.md");
    const text = fs.readFileSync(promptPath, "utf8");
    return {
        content: [{ type: "text", text }],
    };
});
server.tool("getTaxClientSegmentationPrompt", `Returns a prompt to help convert natural-language client segment criteria into SQL queries for tax data analysis.
  Use this tool to create compliant client segment queries with governance controls and cost management.`, {}, // No parameters
async () => {
    const promptPath = path.resolve(__dirname, "../src/llm-prompts/tax_client_segmentation.md");
    const text = fs.readFileSync(promptPath, "utf8");
    return {
        content: [{ type: "text", text }],
    };
});
async function main() {
    const transport = new StdioServerTransport();
    await server.connect(transport);
    console.error("MCP server running on stdio");
}
main().catch((err) => {
    console.error("Fatal error:", err);
    process.exit(1);
});
