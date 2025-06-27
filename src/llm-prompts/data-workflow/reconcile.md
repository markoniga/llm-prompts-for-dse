# Version: v0.1.0
# Last-Updated: 2025-06-16
# Owner: analytics-platform
# Description: Run dbt build & Preset reconciliation

# Reconcile Prompt

## PURPOSE
This prompt automates local dbt build and Preset reconciliation workflow. It runs `dbt build --select {{ models }}`, validates the build success, executes Preset MCP reconciliation, and summarizes differences in a clear Markdown table format.

## CURSOR AGENT EXECUTION GUIDE
**Use this prompt AFTER successful code generation** to validate changes and reconcile with production systems.

### Pre-Execution Checklist
- [ ] Target models are clearly identified 
- [ ] Local dbt environment is properly configured
- [ ] Preset MCP connection is available
- [ ] User has necessary permissions for build and reconciliation

## EXECUTION WORKFLOW

### Step 1: Validate Environment
**Check these REQUIRED components:**
- dbt project is accessible and configured
- Target models exist and are selectable
- Preset connection is established
- Build directory has sufficient space

### Step 2: Execute dbt Build
**Command pattern:**
```bash
dbt build --select {{ models }}
```

**Success criteria:**
- All models compile without errors
- All tests pass
- No critical warnings
- Build completes within reasonable time

### Step 3: Generate and Execute Reconciliation Queries
**Build reconciliation queries in chat first, then execute via Preset MCP:**

**Step 3a: Generate reconciliation queries in chat for review**
```sql
-- Overall comparison of data completeness between production and dev for {{ model_name }}
SELECT 
    'Production' as environment,
    COUNT(*) as total_records,
    COUNT(CASE WHEN primary_key IS NOT NULL THEN 1 END) as records_with_primary_key,
    COUNT(CASE WHEN primary_key IS NULL THEN 1 END) as records_without_primary_key,
    COUNT(CASE WHEN updated_at IS NOT NULL THEN 1 END) as records_with_updated_at,
    ROUND(COUNT(CASE WHEN primary_key IS NOT NULL THEN 1 END) * 100.0 / COUNT(*), 2) as pct_with_primary_key,
    MAX(updated_at) as last_updated
FROM {{ schema }}.{{ model_name }}

UNION ALL

SELECT 
    'Dev' as environment,
    COUNT(*) as total_records,
    COUNT(CASE WHEN primary_key IS NOT NULL THEN 1 END) as records_with_primary_key,
    COUNT(CASE WHEN primary_key IS NULL THEN 1 END) as records_without_primary_key,
    COUNT(CASE WHEN updated_at IS NOT NULL THEN 1 END) as records_with_updated_at,
    ROUND(COUNT(CASE WHEN primary_key IS NOT NULL THEN 1 END) * 100.0 / COUNT(*), 2) as pct_with_primary_key,
    MAX(updated_at) as last_updated
FROM dev_{{ username }}.{{ model_name }}
```

**Step 3b: Execute via Preset MCP after query validation**
Only execute after confirming queries are correct:
```
mcp.preset.query(database_id=3, sql=<validated_query>)
```

**Reconciliation checks:**
- Schema alignment verification
- Row count comparisons
- Data freshness validation
- Dependency consistency

### Step 4: Generate Diff Summary
**Output format:** Comprehensive Markdown table showing differences

## MANDATORY OUTPUT FORMAT
**Use this compact Markdown format for reconciliation results:**

### 🚀 Build Execution Summary
- **command_executed** → `dbt build --select model1 model2...`
- **execution_time** → 2m 34s
- **models_built** → 3 models (2 successful, 1 warning)
- **tests_run** → 12 tests (11 passed, 1 warning)
- **overall_status** → ✅ SUCCESS | ⚠️ WARNING | ❌ FAILED

### 📊 Preset Reconciliation Results
| Model | Dev Rows | Prod Rows | Row Diff | Schema Match | Data Fresh | Status |
|-------|----------|-----------|----------|--------------|------------|--------|
| stg_orders | 1,234,567 | 1,234,560 | +7 | ✅ MATCH | ✅ FRESH | 🟢 OK |
| fct_revenue | 456,789 | 456,788 | +1 | ✅ MATCH | ⚠️ 2h OLD | 🟡 CHECK |
| dim_customers | 89,012 | 89,012 | 0 | ❌ MISMATCH | ✅ FRESH | 🔴 ISSUE |

### 🔍 Detailed Differences
**Schema Mismatches:**
<details>
<summary>📋 <strong>dim_customers schema differences</strong></summary>

| Column | Dev Type | Prod Type | Status |
|--------|----------|-----------|---------|
| user_id | INTEGER | BIGINT | 🔄 TYPE CHANGE |
| email | VARCHAR(255) | VARCHAR(500) | 📏 SIZE CHANGE |
| new_field | VARCHAR(100) | - | 🆕 ADDED |

</details>

**Row Count Analysis:**
- **Total deviation**: +8 rows across all models
- **Acceptable variance**: ±10 rows
- **Status**: 🟢 Within acceptable limits

**Data Freshness Issues:**
- **fct_revenue**: Last updated 2h ago (expected: <1h)
- **Recommendation**: Check upstream data pipeline schedule

### 🎯 Reconciliation Actions Required
- **Immediate**: Review dim_customers schema change impact
- **Short-term**: Investigate fct_revenue freshness delay  
- **Long-term**: Establish automated reconciliation monitoring

### 🛠️ Next Steps
1. **If all green**: Proceed with deployment
2. **If yellow warnings**: Review and document acceptable variances
3. **If red issues**: Address critical mismatches before deployment

## STEP-BY-STEP EXECUTION PROCESS

### Step 1: Pre-Build Validation
```bash
# Verify dbt project and models
dbt deps
dbt parse
dbt ls --select {{ models }}
```

**Expected output:** Clean list of target models without errors

### Step 2: Execute Build with Monitoring
```bash
# Run build with detailed logging
dbt build --select {{ models }} --profiles-dir ~/.dbt
```

**Monitor for:**
- Compilation errors
- Test failures
- Performance bottlenecks
- Warning messages

### Step 3: Capture Build Results
**Parse dbt output for:**
- Models successfully built
- Tests executed and results
- Execution time per model
- Any warnings or errors

### Step 4: Execute Reconciliation via Preset MCP
**CRITICAL: Follow Preset MCP Query Guidelines**

**Schema Usage Rules:**
- **Production**: Use domain schema directly (e.g., `marketing`, `finance`, `tax`, `trade`)
- **Development**: Use `dev_<username>` format (e.g., `dev_moniga`, `dev_johndoe`)
- **Prep Tables**: Use `_backroom` suffix (e.g., `tax_backroom`, `marketing_backroom`)
- **Database ID**: Always use `database_id=3`
- **Query Format**: Always use `<schema>.<table_name>`

**NEVER query information_schema or system tables for schema discovery**

**Available Production Schemas:**
- **marts** (Final business logic tables): `activation`, `marketing`, `finance`, `trade`, `cash`, `credit`, `fraud`, `client_data`, `authentication`, `invest`, `crypto`, `sales`, `tax`
- **prep** (Intermediate processing tables): `activation_backroom`, `marketing_backroom`, `finance_backroom`, `trade_backroom`, `cash_backroom`, `credit_backroom`, `fraud_backroom`, `tax_backroom`, etc.
- **workspaces** (Specialized analysis): `experiments`, `fraud`, `ltv`, `feature_factory`, `hightouch`

**Development Schema Notes:**
- Username is derived from `DEV_SQL_SCHEMA_PREFIX` environment variable
- Format: `dev_<username>` (e.g., `dev_moniga`, `dev_johndoe`)

**After building and validating queries in chat:**
```
# Execute validated reconciliation queries via MCP
mcp.preset.query(database_id=3, sql=<row_count_query>)
mcp.preset.query(database_id=3, sql=<schema_comparison_query>)
mcp.preset.query(database_id=3, sql=<freshness_check_query>)
```

**Always display the SQL query used alongside results for transparency**

**Collect metrics from query results:**
- Row counts (dev vs prod)
- Data completeness percentages
- Schema comparisons  
- Data freshness timestamps
- Dependency validation

### Step 5: Generate Actionable Summary
**Create clear decision matrix:**
- 🟢 **GREEN**: No action needed, safe to proceed
- 🟡 **YELLOW**: Review required, document variances
- 🔴 **RED**: Critical issues, deployment blocked

## OPTIMIZED EXAMPLE EXECUTION

### Example: Reconciling Tax Payment Pipeline
**Models:** `prep_tax_payments`, `stg_tax_payments`, `fct_tax_payments`

**Build Command:**
```bash
dbt build --select prep_tax_payments stg_tax_payments fct_tax_payments
```

**Reconciliation Query Example:**
```sql
-- Query Used:
-- Overall comparison of data completeness between production and dev
SELECT 
    'Production' as environment,
    COUNT(*) as total_records,
    COUNT(CASE WHEN return_id IS NOT NULL THEN 1 END) as records_with_return_id,
    COUNT(CASE WHEN return_id IS NULL THEN 1 END) as records_without_return_id,
    COUNT(CASE WHEN identity_canonical_id IS NOT NULL THEN 1 END) as records_with_identity_canonical_id,
    COUNT(CASE WHEN user_canonical_id IS NOT NULL THEN 1 END) as records_with_user_canonical_id,
    ROUND(COUNT(CASE WHEN identity_canonical_id IS NOT NULL THEN 1 END) * 100.0 / COUNT(*), 2) as pct_with_identity_canonical_id
FROM tax_backroom.prep_tax_payments 

UNION ALL

SELECT 
    'Dev' as environment,
    COUNT(*) as total_records,
    COUNT(CASE WHEN return_id IS NOT NULL THEN 1 END) as records_with_return_id,
    COUNT(CASE WHEN return_id IS NULL THEN 1 END) as records_without_return_id,
    COUNT(CASE WHEN identity_canonical_id IS NOT NULL THEN 1 END) as records_with_identity_canonical_id,
    COUNT(CASE WHEN user_canonical_id IS NOT NULL THEN 1 END) as records_with_user_canonical_id,
    ROUND(COUNT(CASE WHEN identity_canonical_id IS NOT NULL THEN 1 END) * 100.0 / COUNT(*), 2) as pct_with_identity_canonical_id
FROM dev_moniga.prep_tax_payments
```

**Expected Output:**

### 🚀 Build Execution Summary
- **command_executed** → `dbt build --select prep_tax_payments stg_tax_payments fct_tax_payments`
- **execution_time** → 1m 47s  
- **models_built** → 3 models (3 successful, 0 warnings)
- **tests_run** → 8 tests (8 passed, 0 warnings)
- **overall_status** → ✅ SUCCESS

### 📊 Preset Reconciliation Results
| Model | Dev Records | Prod Records | Diff | Complete % | Identity % | Status |
|-------|-------------|--------------|------|------------|------------|--------|
| prep_tax_payments | 2,456,789 | 2,456,785 | +4 | 98.5% | 95.2% | 🟢 OK |
| stg_tax_payments | 2,456,789 | 2,456,785 | +4 | 98.5% | 95.2% | 🟢 OK |
| fct_tax_payments | 2,456,789 | 2,456,785 | +4 | 98.5% | 95.2% | 🟢 OK |

### 🔍 Detailed Differences
**Row Count Analysis:**
- **Total deviation**: +4 rows across all models (consistent)
- **Root cause**: 4 new orders in source system since last prod update
- **Status**: 🟢 Expected variance from recent source data

**Data Freshness Status:**
- **All models**: Updated within last 5 minutes
- **Status**: 🟢 Fresh data, no pipeline delays

### 🎯 Reconciliation Actions Required
- **Status**: ✅ ALL CLEAR - Ready for deployment
- **Confidence**: HIGH - All metrics within expected ranges

### 🛠️ Next Steps
1. ✅ **Proceed with deployment** - No blocking issues found
2. 📝 **Document change** - 4 new orders added since last deployment
3. 🔍 **Monitor post-deployment** - Track row counts in production

## ERROR HANDLING

### Build Failures
**If dbt build fails:**
1. Capture full error output
2. Identify failing model/test
3. Provide specific remediation steps
4. Block reconciliation until build succeeds

### Reconciliation Failures  
**If Preset reconciliation fails:**
1. Check MCP connection status
2. Verify model exists in both environments
3. Retry with exponential backoff
4. Document failure for manual review

### Critical Threshold Breaches
**If differences exceed acceptable limits:**
- **Row count variance > 1%**: Flag for review
- **Schema mismatches**: Block deployment
- **Data freshness > 4h**: Investigate pipeline

## CURSOR AGENT OPTIMIZATION NOTES

### For Seamless Execution:
1. **Always validate environment first** - prevent mid-execution failures
2. **Capture detailed metrics** - enable thorough analysis  
3. **Use clear visual indicators** - 🟢🟡🔴 for quick decision making
4. **Provide specific next steps** - eliminate guesswork
5. **Document variances** - maintain audit trail

### Error Prevention:
- Validate dbt project configuration before execution
- Check available disk space for build outputs
- Verify Preset connectivity before reconciliation
- Set reasonable timeouts for long-running builds
- Include rollback instructions for failed deployments

## AUTO-PUBLISH PATH

### Successful Reconciliation Chain
**After successful reconciliation with all green status, automatically trigger PR creation:**

```bash
# Step 1: Successful reconciliation
getReconcilePrompt(models={{ models }}) → 🟢 ALL CLEAR

# Step 2: Chain to PR creation
getCreatePRPrompt(
    title="{{ workflow_name | default('Data Workflow Implementation') }} – generated by MCP",
    reconciliation_results={{ reconciliation_summary }},
    models={{ models }}
  )
```

**Auto-Publish Workflow:**
1. ✅ **Reconciliation Complete** → All models show 🟢 status
2. 🔄 **Auto-Create PR** → `getCreatePRPrompt` with dynamically generated workflow title
3. 📝 **Generate PR Content** → Include reconciliation results and refactor context
4. 🔗 **Chain to Merge Guard** → `getMergeGuardPrompt` for final validation

**Chain Trigger Conditions:**
- **🟢 ALL GREEN**: Auto-chain to PR creation immediately
- **🟡 WARNINGS**: Prompt user to review before chaining
- **🔴 ISSUES**: Block auto-chain, require manual resolution

**Expected Output After Successful Chain:**
> 🎉 **Reconciliation successful - All systems green!**  
> 🚀 **Auto-creating pull request: "{{ detected_workflow_name }} – generated by MCP"**  
> 📋 **PR ready for review and merge**

### 🔄 NEXT MCP PROMPT
**After completing reconciliation:**
- **If 🟢 ALL GREEN**: Auto-chain to `getCreatePRPrompt` → `getMergeGuardPrompt` for deployment
- **If 🟡 WARNINGS**: Review results, then manually use `getCreatePRPrompt` if acceptable
- **If 🔴 ISSUES**: Use `getTestResultsPrompt` and `getFixupSuggestionsPrompt` to resolve critical problems first

### Integration Points
- **From**: `getRunTestsPrompt` → `getReconcilePrompt`
- **To**: `getReconcilePrompt` → `getCreatePRPrompt` → `getMergeGuardPrompt`
- **Dynamic PR Title**: "{{ workflow_name | detect_from_context }} – generated by MCP" (e.g., "Money-Movement Legacy Refactor", "Customer Data Pipeline Migration", etc.)

## CHANGELOG
### v0.1.0 - 2025-06-16
- Initial version with automated dbt build and Preset reconciliation
- Added comprehensive diff analysis and reporting
- Included clear decision matrix for deployment readiness
- Optimized for Cursor agent execution with detailed monitoring 