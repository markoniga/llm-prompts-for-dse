# Version: v0.1.0
# Last-Updated: 2025-06-16
# Owner: data-eng
# Description: Execute targeted dbt run/test

# Run dbt Prompt

## Purpose
This prompt helps execute dbt commands safely and efficiently. It generates optimized dbt commands with appropriate flags and options based on the task requirements, ensuring reliable and efficient model builds and tests.

## Usage
Use this prompt when you need to run dbt commands as part of a data workflow, particularly after code changes have been validated and are ready for execution.

## Input Context
- The specific models or tests to run
- Current state of the dbt project
- Dependencies between models
- Performance considerations
- Environment (development, testing, production)
- Time constraints
- Risk assessment from validate_risk prompt

## Output Format
```json
{
  "execution_plan": {
    "summary": "Brief summary of the execution plan",
    "environment": "development|testing|production",
    "estimated_runtime": "Estimated time to complete the execution",
    "resource_impact": "low|medium|high",
    "models_affected": ["model1", "model2"]
  },
  "command_generation": {
    "primary_command": {
      "command": "Full dbt command to execute",
      "purpose": "Purpose of this command",
      "expected_outcome": "What this command should accomplish"
    },
    "flags_explanation": [
      {
        "flag": "Flag used in the command",
        "purpose": "Purpose of this flag",
        "impact": "Impact of using this flag"
      }
    ],
    "selection_method": {
      "approach": "direct|selector|tag|state",
      "rationale": "Explanation of why this selection method was chosen",
      "alternatives_considered": ["Alternative 1", "Alternative 2"]
    }
  },
  "execution_steps": [
    {
      "step_number": 1,
      "description": "Description of this step",
      "command": "Command to execute for this step",
      "verification": "How to verify this step was successful",
      "fallback": "What to do if this step fails"
    }
  ],
  "verification_plan": {
    "success_criteria": [
      "Criterion 1 for successful execution",
      "Criterion 2 for successful execution"
    ],
    "verification_queries": [
      {
        "purpose": "Purpose of this verification query",
        "query": "SQL query to verify results",
        "expected_result": "Expected result of the query"
      }
    ],
    "log_analysis": [
      {
        "log_pattern": "Pattern to look for in logs",
        "interpretation": "What this pattern means",
        "action_if_found": "What to do if this pattern is found"
      }
    ]
  },
  "performance_optimization": {
    "strategies_applied": [
      {
        "strategy": "Strategy used to optimize performance",
        "implementation": "How this strategy was implemented",
        "expected_benefit": "Expected benefit of this strategy"
      }
    ],
    "monitoring_recommendations": [
      "Recommendation 1 for monitoring execution",
      "Recommendation 2 for monitoring execution"
    ]
  },
  "post_execution_actions": [
    {
      "action": "Action to take after execution",
      "purpose": "Purpose of this action",
      "implementation": "How to implement this action"
    }
  ]
}
```

## Instructions

1. **Analyze the requirements**
   - Understand the specific models or tests to run
   - Identify dependencies between models
   - Consider the environment and its constraints
   - Assess the risk level and potential impact

2. **Design the execution plan**
   - Determine the appropriate dbt command(s) to use
   - Select the right models using the most efficient selector
   - Choose appropriate flags and options
   - Break complex operations into logical steps

3. **Optimize for performance**
   - Consider using --threads flag for parallelization
   - Use selective model building when appropriate
   - Leverage dbt's state comparison for incremental builds
   - Consider defer options for cross-environment references

4. **Implement safety measures**
   - Include appropriate error handling
   - Add verification steps
   - Consider transaction boundaries
   - Plan for potential failures

5. **Create verification procedures**
   - Define success criteria
   - Design verification queries
   - Specify log patterns to watch for
   - Establish performance baselines

6. **Document post-execution actions**
   - Specify cleanup steps
   - Recommend documentation updates
   - Suggest notifications to stakeholders
   - Plan for downstream processes

## Preset MCP Query Guidelines

When generating queries for Preset MCP, follow these critical rules:

1. **Table Query Format**
   - Always use the format: `<schema>.<table_name>` when querying tables
   - Example: `SELECT * FROM marketing.campaign_metrics`

2. **Schema Usage**
   - For production queries, use domain names directly (e.g., `marketing`, `finance`)
   - For development queries, use `dev_<username>` format (e.g., `dev_moniga.campaign_metrics`)
   - For intermediate processing tables, use the `_backroom` suffix (e.g., `marketing_backroom.campaign_staging`)

3. **Available Production Schemas**
   - **marts** (Final business logic tables):
     - `activation`, `marketing`, `finance`, `trade`, `cash`, `credit`, `fraud`, `client_data`, 
     - `authentication`, `invest`, `crypto`, `sales`, `tax`
   - **prep** (Intermediate processing tables):
     - `activation_backroom`, `marketing_backroom`, `finance_backroom`, etc.
   - **workspaces** (Specialized analysis schemas):
     - `experiments`, `fraud`, `ltv`, `feature_factory`, `hightouch`

4. **Development Schema Format**
   - Always use `dev_<username>` for development queries
   - Username is derived from the `DEV_SQL_SCHEMA_PREFIX` environment variable

5. **Database Connection**
   - Always use database connection ID = 3 when querying Preset MCP

6. **Schema Discovery**
   - Never query `information_schema` or system tables for schema discovery
   - Do not run exploratory queries like `SHOW SCHEMAS` or `SHOW TABLES`
   - Find schema and table information within the data-vault repository
   - Use the `dbt_project.yml` file as the authoritative source for available schemas

7. **Query Output Requirements**
   - Always display the SQL query used alongside the results
   - Format:
     ```
     -- Query Used:
     SELECT column1
          , column2 
     FROM schema.table_name 
     WHERE condition = 'value'
     ```

## Schema Reconciliation Execution

When running models that modify existing schemas, include reconciliation steps:

### Pre-Execution Reconciliation
- **Schema Baseline Capture**:
  ```sql
  -- Query Used:
  -- Capture production schema structure before changes
  SELECT 
    column_name,
    data_type,
    character_maximum_length,
    is_nullable
  FROM marketing.model_name  -- Use actual domain schema (marketing, finance, tax, etc.)
  ORDER BY column_name;
  ```

- **Data Volume Baseline**:
  ```sql
  -- Query Used:
  -- Capture row counts and data distribution before changes
  SELECT 
    COUNT(*) as total_rows,
    COUNT(DISTINCT primary_key) as distinct_keys,
    MIN(updated_at) as earliest_record,
    MAX(updated_at) as latest_record
  FROM marketing.model_name;  -- Use actual domain schema
  ```

- **Dependency Mapping**:
  ```sql
  -- Identify downstream dependencies before changes
  SELECT 
    dependent_model,
    reference_type
  FROM dbt_metadata.model_refs
  WHERE referenced_model = 'model_name';
  ```

### Execution Commands with Reconciliation
- **Run with Reconciliation Flags**:
  ```bash
  # Run with pre and post hooks for reconciliation
  dbt run --select model_name --vars '{reconciliation_mode: true}'
  ```

- **Incremental Model Reconciliation**:
  ```bash
  # For incremental models, compare before/after states
  dbt run --select model_name --full-refresh --vars '{capture_state: true}'
  ```

- **Post-Run Schema Validation**:
  ```bash
  # Validate schema changes match expectations
  dbt test --select model_name+
  ```

### Post-Execution Reconciliation
- **Schema Comparison Queries**:
  ```sql
  -- Query Used:
  -- Compare development vs production schemas
  SELECT 
    'development' as environment,
    column_name,
    data_type,
    character_maximum_length
  FROM dev_moniga.model_name  -- Use dev_<username> format
  
  UNION ALL
  
  SELECT 
    'production' as environment,
    column_name,
    data_type,
    character_maximum_length
  FROM marketing.model_name  -- Use actual domain schema
  
  ORDER BY column_name, environment;
  ```

- **Data Integrity Verification**:
  ```sql
  -- Query Used:
  -- Verify data integrity after changes
  SELECT 
    'development' as environment,
    COUNT(*) as row_count,
    COUNT(DISTINCT primary_key) as distinct_keys,
    MIN(updated_at) as earliest_date,
    MAX(updated_at) as latest_date
  FROM dev_moniga.model_name  -- Use dev_<username> format
  
  UNION ALL
  
  SELECT 
    'production' as environment,
    COUNT(*) as row_count,
    COUNT(DISTINCT primary_key) as distinct_keys,
    MIN(updated_at) as earliest_date,
    MAX(updated_at) as latest_date
  FROM marketing.model_name;  -- Use actual domain schema
  ```

- **Downstream Impact Verification**:
  ```sql
  -- Query Used:
  -- Verify downstream model integrity
  SELECT 
    'downstream_model' as model_name,
    COUNT(*) as row_count,
    COUNT(*) - COUNT(DISTINCT join_key) as duplicate_keys
  FROM dev_moniga.downstream_model  -- Use dev_<username> format
  GROUP BY model_name;
  ```

### Reconciliation Documentation
- **Generate Reconciliation Report**:
  ```bash
  # Create reconciliation documentation
  dbt docs generate --vars '{include_reconciliation: true}'
  ```

- **Schema Change Summary**:
  ```sql
  -- Query Used:
  -- Generate schema change summary
  SELECT 
    column_name,
    CASE 
      WHEN dev.column_name IS NULL THEN 'REMOVED'
      WHEN prod.column_name IS NULL THEN 'ADDED'
      WHEN dev.data_type != prod.data_type THEN 'TYPE CHANGED'
      WHEN dev.character_maximum_length != prod.character_maximum_length THEN 'SIZE CHANGED'
      ELSE 'UNCHANGED'
    END as change_type,
    COALESCE(prod.data_type, 'N/A') as prod_type,
    COALESCE(dev.data_type, 'N/A') as dev_type
  FROM 
    (SELECT column_name, data_type, character_maximum_length FROM dev_moniga.model_name) dev
  FULL OUTER JOIN
    (SELECT column_name, data_type, character_maximum_length FROM marketing.model_name) prod
  ON dev.column_name = prod.column_name
  WHERE dev.column_name IS NULL OR prod.column_name IS NULL OR dev.data_type != prod.data_type OR dev.character_maximum_length != prod.character_maximum_length
  ORDER BY change_type, column_name;
  ```

## Examples

### Example 1: Running a Single Modified Model
Input: Run the newly modified fct_orders model in development

Output:
```json
{
  "execution_plan": {
    "summary": "Execute a targeted run of the fct_orders model in development with appropriate testing",
    "environment": "development",
    "estimated_runtime": "3-5 minutes",
    "resource_impact": "low",
    "models_affected": ["fct_orders"]
  },
  "command_generation": {
    "primary_command": {
      "command": "dbt run --select fct_orders",
      "purpose": "Build only the fct_orders model without rebuilding upstream dependencies",
      "expected_outcome": "Successfully built fct_orders model with the latest changes"
    },
    "flags_explanation": [
      {
        "flag": "--select fct_orders",
        "purpose": "Target only the fct_orders model",
        "impact": "Minimizes execution time by building only what's needed"
      }
    ],
    "selection_method": {
      "approach": "direct",
      "rationale": "Simple direct selection is appropriate for a single model with no special selection needs",
      "alternatives_considered": ["tag-based selection", "state-based selection"]
    }
  },
  "execution_steps": [
    {
      "step_number": 1,
      "description": "Run the fct_orders model",
      "command": "dbt run --select fct_orders",
      "verification": "Check that the command completes successfully with no errors",
      "fallback": "Check logs for errors and address any issues before proceeding"
    },
    {
      "step_number": 2,
      "description": "Run tests on the fct_orders model",
      "command": "dbt test --select fct_orders",
      "verification": "Verify all tests pass",
      "fallback": "If tests fail, review failures and fix issues in the model"
    }
  ],
  "verification_plan": {
    "success_criteria": [
      "dbt run command completes successfully",
      "All tests pass for the fct_orders model",
      "Row count in the model matches expectations"
    ],
    "verification_queries": [
      {
        "purpose": "Verify row count in fct_orders",
        "query": "SELECT COUNT(*) FROM fct_orders",
        "expected_result": "Count should match expected number of orders"
      },
      {
        "purpose": "Check for null values in key fields",
        "query": "SELECT COUNT(*) FROM fct_orders WHERE order_id IS NULL OR customer_id IS NULL",
        "expected_result": "0 rows, confirming no nulls in key fields"
      }
    ],
    "log_analysis": [
      {
        "log_pattern": "Completed successfully",
        "interpretation": "Model built successfully",
        "action_if_found": "Proceed to testing"
      },
      {
        "log_pattern": "Error",
        "interpretation": "Build failed",
        "action_if_found": "Review error details and fix issues"
      }
    ]
  },
  "performance_optimization": {
    "strategies_applied": [
      {
        "strategy": "Targeted model selection",
        "implementation": "Using --select to build only the necessary model",
        "expected_benefit": "Reduced execution time by avoiding unnecessary model builds"
      }
    ],
    "monitoring_recommendations": [
      "Monitor execution time to establish a baseline for this model",
      "Watch for any unexpected resource utilization"
    ]
  },
  "post_execution_actions": [
    {
      "action": "Document changes",
      "purpose": "Keep documentation up to date",
      "implementation": "Update model documentation if behavior or schema has changed"
    },
    {
      "action": "Notify team members",
      "purpose": "Keep team informed of changes",
      "implementation": "Send a message in the data team channel about the updated model"
    }
  ]
}
```

### Example 2: Running Multiple Related Models with Dependencies
Input: Run the updated customer dimension models and all dependent models in production

Output:
```json
{
  "execution_plan": {
    "summary": "Execute a targeted run of customer dimension models and their downstream dependencies in production",
    "environment": "production",
    "estimated_runtime": "15-20 minutes",
    "resource_impact": "medium",
    "models_affected": ["dim_customers", "dim_customer_addresses", "fct_orders", "fct_customer_interactions", "rpt_customer_metrics"]
  },
  "command_generation": {
    "primary_command": {
      "command": "dbt run --select dim_customers dim_customer_addresses+ --exclude dim_customers dim_customer_addresses",
      "purpose": "Build all models that depend on the customer dimension models, but not the dimension models themselves (which will be built first)",
      "expected_outcome": "Successfully built all downstream models that depend on the customer dimensions"
    },
    "flags_explanation": [
      {
        "flag": "--select dim_customers dim_customer_addresses+",
        "purpose": "Select the customer dimension models and all downstream dependencies",
        "impact": "Ensures all affected models are rebuilt with the latest changes"
      },
      {
        "flag": "--exclude dim_customers dim_customer_addresses",
        "purpose": "Exclude the dimension models themselves from this run (they'll be built separately)",
        "impact": "Allows for a phased approach with verification between steps"
      }
    ],
    "selection_method": {
      "approach": "selector with downstream dependencies",
      "rationale": "Using the '+' operator ensures all downstream dependencies are captured, which is critical when changing dimension models",
      "alternatives_considered": ["tag-based selection", "manual model enumeration"]
    }
  },
  "execution_steps": [
    {
      "step_number": 1,
      "description": "Run the customer dimension models first",
      "command": "dbt run --select dim_customers dim_customer_addresses",
      "verification": "Check that the command completes successfully and verify row counts",
      "fallback": "If build fails, review errors and fix issues before proceeding"
    },
    {
      "step_number": 2,
      "description": "Run tests on the dimension models",
      "command": "dbt test --select dim_customers dim_customer_addresses",
      "verification": "Verify all tests pass for the dimension models",
      "fallback": "If tests fail, fix issues before proceeding to downstream models"
    },
    {
      "step_number": 3,
      "description": "Run all downstream dependent models",
      "command": "dbt run --select dim_customers dim_customer_addresses+ --exclude dim_customers dim_customer_addresses",
      "verification": "Check that all downstream models build successfully",
      "fallback": "If any models fail, address issues and rerun failed models"
    },
    {
      "step_number": 4,
      "description": "Run tests on all affected models",
      "command": "dbt test --select dim_customers dim_customer_addresses+",
      "verification": "Verify all tests pass across all affected models",
      "fallback": "Address any test failures before considering the deployment complete"
    }
  ],
  "verification_plan": {
    "success_criteria": [
      "All dbt commands complete successfully",
      "All tests pass for all affected models",
      "Row counts in dimension and fact tables match expectations",
      "No unexpected null values in key fields"
    ],
    "verification_queries": [
      {
        "purpose": "Verify row count in customer dimensions",
        "query": "SELECT COUNT(*) FROM dim_customers",
        "expected_result": "Count should match expected number of customers"
      },
      {
        "purpose": "Verify integrity between dimensions and facts",
        "query": "SELECT COUNT(*) FROM fct_orders o LEFT JOIN dim_customers c ON o.customer_id = c.customer_id WHERE c.customer_id IS NULL",
        "expected_result": "0 rows, confirming referential integrity"
      },
      {
        "purpose": "Check for data quality in key metrics",
        "query": "SELECT COUNT(*) FROM rpt_customer_metrics WHERE lifetime_value < 0",
        "expected_result": "0 rows, confirming no negative lifetime values"
      }
    ],
    "log_analysis": [
      {
        "log_pattern": "Completed successfully",
        "interpretation": "Models built successfully",
        "action_if_found": "Continue to next step"
      },
      {
        "log_pattern": "Error in model",
        "interpretation": "Build failed for a specific model",
        "action_if_found": "Review error details and fix the specific model"
      },
      {
        "log_pattern": "Runtime exceeded",
        "interpretation": "Model took longer than expected to build",
        "action_if_found": "Investigate performance issues and optimize the model"
      }
    ]
  },
  "performance_optimization": {
    "strategies_applied": [
      {
        "strategy": "Phased execution",
        "implementation": "Building dimension models first, then downstream models",
        "expected_benefit": "Allows for verification at each phase and easier troubleshooting"
      },
      {
        "strategy": "Parallel execution",
        "implementation": "dbt's default parallelization based on the dependency graph",
        "expected_benefit": "Optimal build time by building independent models concurrently"
      }
    ],
    "monitoring_recommendations": [
      "Monitor execution time for each phase",
      "Watch for any models that take significantly longer than others",
      "Monitor database resource utilization during execution"
    ]
  },
  "post_execution_actions": [
    {
      "action": "Verify dashboards and reports",
      "purpose": "Ensure business intelligence tools are showing correct data",
      "implementation": "Check key dashboards that use customer data"
    },
    {
      "action": "Update documentation",
      "purpose": "Keep documentation up to date",
      "implementation": "Update data dictionary and model documentation with any schema changes"
    },
    {
      "action": "Notify stakeholders",
      "purpose": "Inform users of the updated data",
      "implementation": "Send notification to analytics users about the customer data refresh"
    }
  ]
}
```

### Example 3: Incremental Model Rebuild with State Comparison
Input: Rebuild the incremental fct_transactions model using state comparison to optimize performance

Output:
```json
{
  "execution_plan": {
    "summary": "Execute an optimized incremental rebuild of the fct_transactions model using dbt state comparison",
    "environment": "production",
    "estimated_runtime": "10-15 minutes",
    "resource_impact": "medium",
    "models_affected": ["fct_transactions"]
  },
  "command_generation": {
    "primary_command": {
      "command": "dbt run --select fct_transactions --state ./target --defer",
      "purpose": "Rebuild the fct_transactions model incrementally, using state comparison to process only new or changed data",
      "expected_outcome": "Successfully updated fct_transactions with only the necessary changes, optimizing build time"
    },
    "flags_explanation": [
      {
        "flag": "--select fct_transactions",
        "purpose": "Target only the fct_transactions model",
        "impact": "Focuses the operation on just the needed model"
      },
      {
        "flag": "--state ./target",
        "purpose": "Use the state from the previous run for comparison",
        "impact": "Enables dbt to determine what has changed since the last run"
      },
      {
        "flag": "--defer",
        "purpose": "Use the previous state for upstream dependencies",
        "impact": "Avoids rebuilding upstream models that haven't changed"
      }
    ],
    "selection_method": {
      "approach": "state-based",
      "rationale": "State comparison is ideal for optimizing incremental models with large datasets",
      "alternatives_considered": ["full refresh", "standard incremental without state"]
    }
  },
  "execution_steps": [
    {
      "step_number": 1,
      "description": "Ensure state from previous run is available",
      "command": "ls -la ./target",
      "verification": "Confirm manifest.json exists in the target directory",
      "fallback": "If state is not available, run without --state and --defer flags"
    },
    {
      "step_number": 2,
      "description": "Run the transactions model with state comparison",
      "command": "dbt run --select fct_transactions --state ./target --defer",
      "verification": "Check that the command completes successfully",
      "fallback": "If errors occur, check logs and consider falling back to standard incremental build"
    },
    {
      "step_number": 3,
      "description": "Run tests on the updated model",
      "command": "dbt test --select fct_transactions",
      "verification": "Verify all tests pass",
      "fallback": "If tests fail, investigate issues and fix before proceeding"
    }
  ],
  "verification_plan": {
    "success_criteria": [
      "dbt run command completes successfully",
      "All tests pass for the fct_transactions model",
      "New transactions are present in the model",
      "Historical transactions remain unchanged"
    ],
    "verification_queries": [
      {
        "purpose": "Verify new transactions are included",
        "query": "SELECT COUNT(*) FROM fct_transactions WHERE transaction_date >= CURRENT_DATE - 7",
        "expected_result": "Count should match expected number of recent transactions"
      },
      {
        "purpose": "Verify historical data integrity",
        "query": "SELECT COUNT(*) FROM fct_transactions WHERE transaction_date < CURRENT_DATE - 7",
        "expected_result": "Count should match the known historical transaction count"
      },
      {
        "purpose": "Check for data quality",
        "query": "SELECT COUNT(*) FROM fct_transactions WHERE amount IS NULL OR amount = 0",
        "expected_result": "Should return expected count of zero-amount transactions (if any)"
      }
    ],
    "log_analysis": [
      {
        "log_pattern": "Running with dbt=",
        "interpretation": "Confirms dbt version being used",
        "action_if_found": "Verify it's the expected version"
      },
      {
        "log_pattern": "Completed successfully",
        "interpretation": "Model built successfully",
        "action_if_found": "Proceed to testing"
      },
      {
        "log_pattern": "Skipping",
        "interpretation": "Some models were skipped due to state comparison",
        "action_if_found": "Verify this is expected behavior"
      },
      {
        "log_pattern": "Building fct_transactions incrementally",
        "interpretation": "Confirms incremental strategy is being used",
        "action_if_found": "Continue monitoring build"
      }
    ]
  },
  "performance_optimization": {
    "strategies_applied": [
      {
        "strategy": "State comparison",
        "implementation": "Using --state flag to compare against previous run",
        "expected_benefit": "Processes only changed data, significantly reducing build time"
      },
      {
        "strategy": "Deferred references",
        "implementation": "Using --defer flag to avoid rebuilding upstream dependencies",
        "expected_benefit": "Further reduces build time by using existing upstream models"
      },
      {
        "strategy": "Targeted selection",
        "implementation": "Building only the specific model needed",
        "expected_benefit": "Minimizes scope of the operation"
      }
    ],
    "monitoring_recommendations": [
      "Compare execution time to previous full builds to quantify optimization",
      "Monitor the number of rows processed vs. total rows in the table",
      "Watch for any unexpected full table scans in the query plan"
    ]
  },
  "post_execution_actions": [
    {
      "action": "Save new state",
      "purpose": "Preserve state for future incremental builds",
      "implementation": "Ensure the target directory is backed up or committed to version control"
    },
    {
      "action": "Update run statistics",
      "purpose": "Track performance improvements",
      "implementation": "Record build time and rows processed for comparison with future runs"
    },
    {
      "action": "Verify downstream processes",
      "purpose": "Ensure dependent processes are working correctly",
      "implementation": "Check that any ETL processes or reports using this data are functioning properly"
    }
  ]
}
```

### 🔄 NEXT MCP PROMPT
**After completing dbt execution:**
- **If build success**: Use `getRunTestsPrompt` to run dbt build + pytest validation tests
- **If build failure**: Use `getTestResultsPrompt` to analyze what went wrong and get fix recommendations
- **If warnings only**: Use `getRunTestsPrompt` but include warning context for comprehensive testing

## POST-EXECUTION RECONCILIATION

### Automatic Preset Reconciliation Chain
**After successful dbt build completion, automatically trigger testing then reconciliation:**

```bash
# Step 1: Successful dbt build
dbt build --select {{ models }}

# Step 2: If build passes, chain to testing
# Execute getRunTestsPrompt with the same {{ models }}

# Step 3: If tests pass, chain to reconciliation  
# Execute getReconcilePrompt with the same {{ models }}
```

**Complete Workflow Chain:**
1. ✅ **Build Success** → Use `getRunTestsPrompt`
2. 🧪 **Tests Pass** → Use `getReconcilePrompt`
3. 📊 **Generate Diff Summary** → Markdown table format
4. 🎯 **Determine Next Action** → Deploy, review, or fix

**Integration Logic:**
- **dbt Success**: Chain to `getRunTestsPrompt`
- **Test Success**: Chain to `getReconcilePrompt`  
- **Any Failure**: Use `getTestResultsPrompt` for troubleshooting

**Expected Output After Chain:**
> 🚀 **dbt build completed successfully**  
> 🧪 **Initiating comprehensive testing...**  
> 🔄 **Starting Preset reconciliation...**  
> 📊 **All results ready for review**

## Safety Guardrails
- Always recommend testing changes in development before production
- Suggest phased approaches for complex operations
- Include verification steps after each significant operation
- Recommend appropriate error handling and fallback options
- Consider resource utilization and timing of operations
- Suggest appropriate notifications to stakeholders
- Include post-execution verification to ensure data integrity
- Consider the impact on downstream processes and dependencies
- Recommend appropriate documentation updates
- Always provide clear success criteria for each operation
