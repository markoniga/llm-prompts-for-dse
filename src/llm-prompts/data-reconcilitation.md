# Instructions for Autonomous Data Schema Reconciliation MCP

**Version**: 2.2.0  
**Last Updated**: 2024-01-15T11:00:00Z  
**Changelog**: Fixed query formats to use schema.table instead of information_schema, added Preset audit logs context, improved data profiling queries

These instructions enable a Large Language Model (LLM) to autonomously reconcile a user's development schema with production schema in a dbt codebase. The LLM should proactively gather information, make intelligent assumptions, and execute the complete reconciliation flow with minimal user intervention.

> **IMPORTANT**: Prioritize data integrity while maintaining autonomous operation. Only stop for user confirmation on destructive operations that could cause data loss.

---

## AUTONOMOUS OPERATION PRINCIPLES

### Auto-Discovery Strategy
1. **Attempt multiple discovery methods** before asking for user input
2. **Make intelligent assumptions** based on common patterns
3. **Validate assumptions** through multiple data sources
4. **Continue processing** even with partial information
5. **Only pause** for critical confirmations or blocking errors

### Error Recovery
- If one method fails, automatically try alternative approaches
- Log all attempts and failures for transparency
- Use partial information to continue where possible
- Only escalate when all automated options are exhausted

---

## 1. AUTONOMOUS SCHEMA DISCOVERY

### Step 1.1: Auto-Detect Dev Schema
**Try these methods in order (don't ask user first):**

1. **Git Branch Analysis**: 
   - Check current git branch name for username patterns
   - Extract username from git config (`git config user.name`)
   - Construct schema as `dev_<first_initial><lastname>`

2. **Environment Variable Detection**:
   - Check `$USER`, `$USERNAME`, `$LOGNAME` environment variables
   - Check dbt profiles for target schema overrides

3. **Database Query Discovery**:
   - Query available schemas matching `dev_%` pattern
   - Use MCP database connections to list schemas
   - Cross-reference with likely username patterns

4. **File System Analysis**:
   - Check dbt profiles.yml for development targets
   - Look for schema overrides in environment files
   - Parse local dbt configurations

**Only if ALL methods fail**: Ask "I couldn't auto-detect your dev schema. Please provide it (e.g., 'dev_moniga'):"

### Step 1.2: Validate Schema Automatically
- Attempt to query the discovered schema directly
- If schema doesn't exist, note it and continue (don't block)
- Document the assumption and proceed with analysis

## 2. ENHANCED GITHUB INTEGRATION FOR CHANGE DETECTION

### Step 2.1: Comprehensive GitHub Branch Analysis
**Automatically execute GitHub MCP operations:**

1. **Branch Comparison Analysis**:
   ```javascript
   // Auto-execute GitHub MCP calls
   const currentBranch = await detectCurrentBranch();
   const changedFiles = await github.compareBranches({
     owner: 'wealthsimple', // or auto-detect organization
     repo: 'data-vault', // or auto-detect from git remote
     base: 'main',
     head: currentBranch
   });
   ```

2. **Pull Request Discovery**:
   - Search for open PRs from current branch to main
   - Analyze PR file changes and descriptions
   - Extract context from PR comments and reviews
   - Identify related tickets or issues

3. **File Diff Analysis**:
   - Get detailed diffs for .sql model files
   - Parse added/removed columns from SQL changes
   - Identify new models, modified models, deleted models
   - Extract schema changes from SELECT statements

4. **Commit History Analysis**:
   ```javascript
   // Analyze recent commits for context
   const commits = await github.listCommits({
     owner: org,
     repo: repo,
     sha: currentBranch,
     since: lastWeek
   });
   // Extract model changes from commit messages and diffs
   ```

### Step 2.2: Advanced Change Pattern Recognition
**Automatically categorize GitHub changes:**

- **Model Structure Changes**: New columns, dropped columns, type changes
- **Logic Changes**: Modified WHERE clauses, JOINs, aggregations  
- **Dependency Changes**: New ref() calls, changed source() references
- **Test Changes**: Modified data tests, new test cases
- **Documentation Changes**: Updated model descriptions, column docs

### Step 2.3: Cross-Reference with dbt State
**Integrate GitHub findings with dbt analysis:**
```bash
# Auto-execute after GitHub analysis
dbt ls --select state:modified --state path/to/prod/manifest.json
dbt diff --state path/to/prod/manifest.json
```

## 3. PRESET MCP INTEGRATION FOR DATA ANALYSIS

### Step 3.1: Automated Database Connection Discovery
**Use Preset MCP to identify available databases:**

```javascript
// Auto-execute Preset MCP operations
const databases = await preset.getDatabaseConnections();
const prodDatabase = databases.find(db => 
  db.name.includes('prod') || 
  db.name.includes('warehouse') ||
  db.name.includes('analytics')
);
```

### CRITICAL: Query Format Requirements
**⚠️ ALWAYS use direct schema.table format, NEVER use information_schema.columns:**

```sql
-- ✅ CORRECT: Direct table queries
SELECT COUNT(*) FROM production_schema.users;
SELECT * FROM dev_moniga.orders LIMIT 10;

-- ❌ INCORRECT: Avoid information_schema
-- SELECT * FROM information_schema.columns WHERE table_name = 'users';

-- ✅ CORRECT: Compare schemas directly  
SELECT 'production' as env, COUNT(*) as row_count FROM production.users
UNION ALL
SELECT 'development' as env, COUNT(*) as row_count FROM dev_moniga.users;
```

### Step 3.2: Comprehensive Data Profiling
**For each changed model, automatically execute:**

1. **Production Data Analysis**:
   ```sql
   -- Auto-generate and execute via Preset MCP
   -- Use actual schema.table format, not information_schema
   SELECT 
     COUNT(*) as total_rows,
     COUNT(DISTINCT *) as unique_rows,
     MIN(created_at) as oldest_record,
     MAX(created_at) as newest_record
   FROM {{ prod_schema }}.{{ model_name }};
   
   -- Get basic table statistics
   SELECT 
     '{{ model_name }}' as table_name,
     COUNT(*) as row_count,
     MAX(updated_at) as last_updated
   FROM {{ prod_schema }}.{{ model_name }};
   ```

2. **Column-Level Data Profiling**:
   ```sql
   -- Execute for key columns in changed models  
   -- Note: Use actual column names, not dynamic column references
   SELECT 
     COUNT(*) as total_records,
     COUNT(DISTINCT id) as unique_ids,
     COUNT(CASE WHEN email IS NOT NULL THEN 1 END) as non_null_emails,
     MIN(created_at) as earliest_record,
     MAX(created_at) as latest_record
   FROM {{ schema }}.{{ model_name }};
   
   -- For numeric columns, get statistical summary
   SELECT 
     AVG(numeric_column) as avg_value,
     MIN(numeric_column) as min_value,
     MAX(numeric_column) as max_value,
     COUNT(DISTINCT numeric_column) as distinct_values
   FROM {{ schema }}.{{ model_name }}
   WHERE numeric_column IS NOT NULL;
   ```

3. **Development Data Analysis**:
   ```sql
   -- Compare development version with same queries
   -- Execute via Preset MCP against dev schema
   ```

### Step 3.3: Automated Data Quality Validation
**Execute data quality checks automatically:**

```sql
-- Data consistency checks using direct table queries
SELECT 
  'duplicate_records' as check_type,
  COUNT(*) as issue_count
FROM (
  SELECT *, COUNT(*) OVER (PARTITION BY primary_key) as dup_count
  FROM {{ schema }}.{{ model_name }}
) WHERE dup_count > 1

UNION ALL

SELECT 
  'null_primary_keys' as check_type,
  COUNT(*) as issue_count  
FROM {{ schema }}.{{ model_name }}
WHERE primary_key IS NULL;
```

### Step 3.4: Preset Audit Logs Context
**For additional context on Preset operations and changes:**

```sql
-- Query Preset audit logs for recent activity
-- Use this to understand recent changes, user actions, and system events
SELECT * FROM preset.audit_logs
WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'
  AND (
    action LIKE '%query%' OR 
    action LIKE '%dashboard%' OR 
    action LIKE '%dataset%'
  )
ORDER BY created_at DESC
LIMIT 100;

-- Filter audit logs for specific table/schema changes
SELECT * FROM preset.audit_logs
WHERE created_at >= CURRENT_DATE - INTERVAL '24 hours'
  AND details LIKE '%{{ model_name }}%'
ORDER BY created_at DESC;
```

## 4. STRUCTURED TABLE OUTPUT FORMATS

### Step 4.1: Schema Comparison Table
**Auto-generate this comparison table for each model:**

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

### Step 4.2: Data Volume Impact Table
**Auto-generate volume analysis:**

```markdown
## 📈 DATA VOLUME ANALYSIS

| Model | Production Rows | Dev Rows | Difference | % Change | Last Updated |
|-------|-----------------|----------|------------|----------|--------------|
| users | 2,456,789 | 2,456,790 | +1 | +0.00% | 2024-01-15 |
| orders | 15,678,432 | 15,680,123 | +1,691 | +0.01% | 2024-01-15 |
| payments | 8,234,567 | 8,234,567 | 0 | 0.00% | 2024-01-14 |

**Total Impact**: 23,369,788 production rows • +1,692 new rows • 0.007% overall change
```

### Step 4.3: Dependency Impact Table
**Auto-generate downstream impact analysis:**

```markdown
## 🔗 DOWNSTREAM IMPACT ANALYSIS

| Affected Model | Type | Relationship | Risk Level | Users/Systems | Action Required |
|----------------|------|--------------|------------|---------------|-----------------|
| user_metrics | View | Direct ref() | 🔴 HIGH | 12 dashboards | Schema update needed |
| daily_summary | Table | Indirect | 🟡 MEDIUM | 3 reports | Monitor for changes |
| user_segments | Materialized | Direct ref() | 🔴 HIGH | ML pipeline | Coordinate deployment |

**Impact Summary**: 3 downstream models • 2 high-risk • 15 total affected systems
```

### Step 4.4: Change Summary Table  
**Auto-generate executive summary:**

```markdown
## 📋 RECONCILIATION SUMMARY

| Category | Count | Details | Status |
|----------|-------|---------|---------|
| 🔄 Modified Models | 3 | users, orders, payments | ✅ Analyzed |
| 🆕 New Models | 1 | user_preferences | ✅ Ready |
| 🗑️ Deprecated Models | 0 | - | - |
| ⚠️ Breaking Changes | 2 | Column deletions | 🔍 Review needed |
| 📊 Data Quality Issues | 0 | - | ✅ Clean |
| 🔗 Dependency Updates | 5 | Downstream models | 📋 Planned |

**Overall Status**: 🟡 READY WITH CAUTIONS • 2 items need confirmation
```

## 5. ENHANCED AUTONOMOUS DATA ANALYSIS

### Step 5.1: Automated Cross-Environment Comparison
**Execute comprehensive comparison automatically:**

```python
# Pseudo-code for enhanced analysis
async def autonomous_data_analysis(model_name):
    # Get GitHub changes
    github_changes = await analyze_github_changes(model_name)
    
    # Query production data via Preset MCP
    # Use direct table queries instead of information_schema
    prod_data = await preset.query(f"""
        SELECT 
            COUNT(*) as row_count,
            MAX(updated_at) as last_updated,
            '{{prod_schema}}.{{model_name}}' as table_ref
        FROM {{prod_schema}}.{{model_name}}
    """)
    
    # Query development data via Preset MCP  
    dev_data = await preset.query(f"""
        SELECT 
            COUNT(*) as row_count,
            MAX(updated_at) as last_updated,
            '{{dev_schema}}.{{model_name}}' as table_ref
        FROM {{dev_schema}}.{{model_name}}
    """)
    
    # Generate comparison tables
    return generate_comparison_tables(github_changes, prod_data, dev_data)
```

### Step 5.2: Automated Data Sample Comparison
**For changed models, automatically compare sample data:**

```sql
-- Execute via Preset MCP for each changed model
WITH prod_sample AS (
  SELECT * FROM {{ prod_schema }}.{{ model_name }} 
  ORDER BY RANDOM() LIMIT 10
),
dev_sample AS (
  SELECT * FROM {{ dev_schema }}.{{ model_name }} 
  ORDER BY RANDOM() LIMIT 10  
)
SELECT 
  'production' as source, *
FROM prod_sample
UNION ALL
SELECT 
  'development' as source, *
FROM dev_sample;
```

## 6. COMPREHENSIVE AUTONOMOUS RECONCILIATION

### Step 6.1: Multi-Source Integration Workflow
```python
async def execute_full_reconciliation():
    # Phase 1: Discovery
    dev_schema = await auto_detect_dev_schema()
    prod_schema = await infer_production_schema(dev_schema)
    
    # Phase 2: GitHub Analysis  
    github_changes = await analyze_github_branch_diff()
    changed_models = extract_models_from_changes(github_changes)
    
    # Phase 3: Database Analysis via Preset MCP
    database_id = await get_preset_database_connection()
    
    comparison_results = []
    for model in changed_models:
        prod_analysis = await preset.query(database_id, get_prod_query(model))
        dev_analysis = await preset.query(database_id, get_dev_query(model))
        
        comparison = generate_model_comparison_table(
            model, github_changes[model], prod_analysis, dev_analysis
        )
        comparison_results.append(comparison)
    
    # Phase 4: Generate comprehensive report with tables
    return generate_final_report_with_tables(comparison_results)
```

### Step 6.2: Enhanced Risk Assessment
**Automatically calculate detailed risk metrics:**

- **Data Loss Risk**: Rows affected by column deletions
- **Performance Impact**: Query time changes based on schema modifications  
- **Downstream Breakage**: Models that reference changed columns
- **User Impact**: Dashboards and reports affected
- **Rollback Complexity**: Steps needed to reverse changes

## 7. AUTOMATED REPORTING WITH STRUCTURED TABLES

### Step 7.1: Complete Reconciliation Report Template
**Auto-generate this comprehensive report:**

```markdown
# 🤖 AUTONOMOUS DATA SCHEMA RECONCILIATION REPORT
**Generated**: {{ timestamp }} | **Branch**: {{ branch_name }} | **User**: {{ username }}

---

## 🔍 DISCOVERY RESULTS

**Development Schema**: `{{ dev_schema }}` (detected via {{ detection_method }})
**Production Schema**: `{{ prod_schema }}` (confidence: {{ confidence_percentage }}%)
**GitHub Branch**: `{{ current_branch }}` vs `main` 
**Models Analyzed**: {{ total_models }} | **Changes Found**: {{ total_changes }}

---

{{ schema_comparison_tables }}

---

{{ data_volume_tables }}

---

{{ dependency_impact_tables }}

---

## 🚨 CRITICAL ACTIONS REQUIRED

{{ critical_confirmations_table }}

---

## ✅ AUTOMATED ACTIONS COMPLETED

| Action | Model | Result | Duration |
|--------|-------|--------|----------|
{{ completed_actions_table }}

---

## 🎯 NEXT STEPS

1. **Review Critical Items**: {{ critical_count }} items need confirmation
2. **Execute Safe Changes**: {{ safe_count }} changes ready for deployment
3. **Coordinate Dependencies**: {{ dependency_count }} downstream updates needed

**Estimated Deployment Time**: {{ estimated_time }}
```

### Step 7.2: Interactive Confirmation Table
**For high-risk changes, generate specific confirmation prompts:**

```markdown
## ⚠️ CONFIRMATION REQUIRED

| Change | Impact | Affected Rows | Confirm Action |
|--------|--------|---------------|----------------|
| Drop column `old_email` from `users` | Data loss | 2,456,789 | Type 'CONFIRM DELETE' |
| Modify `order_total` type INT→DECIMAL | Precision change | 15,678,432 | Type 'CONFIRM MODIFY' |

**Instructions**: Type the exact confirmation text for each change you approve.
```

## 8. SUCCESS METRICS FOR ENHANCED AUTONOMOUS OPERATION

- **Complete GitHub Integration**: Auto-analyze branch diffs and PR context
- **Full Database Profiling**: Use Preset MCP for comprehensive data analysis  
- **Structured Table Outputs**: Every result in organized, readable tables
- **<2 User Interactions**: Only for critical confirmations
- **95%+ Automation**: From discovery through analysis to reporting
- **Zero Manual Queries**: All database operations via MCP integration

**Enhanced Goal Conversation:**
```
User: "Reconcile my schema changes"
AI: [Analyzes GitHub branch diff automatically]
AI: [Queries production/dev data via Preset MCP]
AI: [Generates comprehensive tables and analysis]
AI: "Analysis complete! Found 4 changes across 3 models:

📊 SCHEMA CHANGES SUMMARY
| Model | Changes | Risk | Action |
|-------|---------|------|--------|
| users | +1 column, -1 column | HIGH | Confirm deletion |
| orders | type change | MEDIUM | Auto-deploy |
| payments | new model | LOW | Auto-deploy |

⚠️ CONFIRMATION NEEDED: Drop column 'legacy_id' from 'users' (affects 2.4M rows)
Confirm? (type 'CONFIRM DELETE')"

User: "CONFIRM DELETE"
AI: [Completes reconciliation with full deployment plan]
AI: "✅ Reconciliation complete! All changes deployed successfully."
```

---

## 9. PRESET MCP QUERY TEMPLATES

### Step 9.1: Standard Analysis Queries
**Auto-execute these via Preset MCP for each changed model:**

```sql
-- Direct Table Analysis Query (avoid information_schema)
-- Query actual table structure and data
SELECT 
    '{{ prod_schema }}' as schema_name,
    '{{ model_name }}' as table_name,
    COUNT(*) as total_rows,
    MAX(updated_at) as last_updated,
    MIN(created_at) as earliest_record
FROM {{ prod_schema }}.{{ model_name }};

-- Compare with development schema
SELECT 
    '{{ dev_schema }}' as schema_name,
    '{{ model_name }}' as table_name,
    COUNT(*) as total_rows,
    MAX(updated_at) as last_updated,
    MIN(created_at) as earliest_record
FROM {{ dev_schema }}.{{ model_name }};

-- Data Volume Query  
SELECT 
    table_schema,
    table_name,
    COUNT(*) as total_rows,
    COUNT(DISTINCT *) as unique_rows,
    MIN(updated_at) as oldest_update,
    MAX(updated_at) as newest_update
FROM {{ schema }}.{{ model_name }}
GROUP BY table_schema, table_name;

-- Data Quality Query
SELECT 
    '{{ model_name }}' as model,
    COUNT(*) as total_rows,
    SUM(CASE WHEN {{ primary_key }} IS NULL THEN 1 ELSE 0 END) as null_pks,
    COUNT(DISTINCT {{ primary_key }}) as unique_pks,
    COUNT(*) - COUNT(DISTINCT {{ primary_key }}) as duplicate_pks
FROM {{ schema }}.{{ model_name }};
```

### Step 9.2: Advanced Comparison Queries
**Execute sophisticated data comparisons:**

```sql
-- Column-by-column comparison
WITH prod_stats AS (
    SELECT 
        column_name,
        COUNT(*) as total_count,
        COUNT(DISTINCT column_name) as distinct_count,
        COUNT(column_name) as non_null_count
    FROM {{ prod_schema }}.{{ model_name }}
    GROUP BY column_name
),
dev_stats AS (
    SELECT 
        column_name,
        COUNT(*) as total_count,
        COUNT(DISTINCT column_name) as distinct_count,  
        COUNT(column_name) as non_null_count
    FROM {{ dev_schema }}.{{ model_name }}
    GROUP BY column_name
)
SELECT 
    COALESCE(p.column_name, d.column_name) as column_name,
    p.total_count as prod_total,
    d.total_count as dev_total,
    p.distinct_count as prod_distinct,
    d.distinct_count as dev_distinct,
    ABS(COALESCE(p.total_count, 0) - COALESCE(d.total_count, 0)) as row_diff
FROM prod_stats p
FULL OUTER JOIN dev_stats d ON p.column_name = d.column_name
ORDER BY row_diff DESC;
```

This enhanced version now provides:
1. **Comprehensive GitHub integration** for branch comparison and change detection
2. **Full Preset MCP integration** for automated database querying and analysis  
3. **Structured table outputs** for all reconciliation results
4. **Advanced data profiling** with automated quality checks
5. **Enhanced autonomous workflows** that minimize user interaction while maximizing insight

---

## 10. AUTOMATED GIT COMMIT MESSAGE GENERATION

### Step 10.1: Generate Semantic Commit Message
**After completing reconciliation analysis, automatically generate commit message:**

Using the git-commit-instructions prompt, create a comprehensive commit message that includes:

```python
async def generate_reconciliation_commit_message(reconciliation_results):
    """
    Generate semantic commit message with full reconciliation information
    """
    
    # Extract key metrics from reconciliation results
    models_changed = len(reconciliation_results.changed_models)
    total_rows_affected = sum([model.rows_affected for model in reconciliation_results.models])
    breaking_changes = len([model for model in reconciliation_results.models if model.risk_level == 'HIGH'])
    
    # Determine commit type and scope
    commit_type = determine_commit_type(reconciliation_results)
    commit_scope = determine_commit_scope(reconciliation_results)
    
    # Generate commit message using semantic format
    commit_message = f"""
{commit_type}({commit_scope}): {generate_commit_summary(reconciliation_results)}

RECONCILIATION REPORT:
- Models Analyzed: {models_changed} models
- Schema Changes: {reconciliation_results.total_changes} modifications detected
- Data Impact: {format_number(total_rows_affected)} rows across {len(reconciliation_results.affected_tables)} tables
- Risk Level: {reconciliation_results.overall_risk_level} ({breaking_changes} breaking changes)

CHANGES APPLIED:
{generate_changes_list(reconciliation_results)}

IMPACT ASSESSMENT:
{generate_impact_assessment(reconciliation_results)}

VALIDATION RESULTS:
{generate_validation_results(reconciliation_results)}

🤖 AUTO-RECONCILIATION COMPLETE
Generated: {datetime.now().isoformat()}
Source Schema: {reconciliation_results.dev_schema}
Target Schema: {reconciliation_results.prod_schema}
Branch: {reconciliation_results.git_branch}
User: {reconciliation_results.username}
"""
    
    return commit_message
```

### Step 10.2: Commit Message Templates by Reconciliation Type

**Schema Reconciliation Commit:**
```
reconcile(schema): sync {{ dev_schema }} with production

RECONCILIATION REPORT:
{{ reconciliation_summary_table }}

CHANGES APPLIED:
{{ schema_changes_with_emojis }}

IMPACT ASSESSMENT:
{{ impact_metrics_table }}

VALIDATION RESULTS:
{{ validation_status_checklist }}

{{ reconciliation_metadata }}
```

**Model Reconciliation Commit:**
```
reconcile(models): align dbt models between dev and production

RECONCILIATION REPORT:
{{ models_comparison_table }}

CHANGES APPLIED:
{{ model_changes_detailed }}

IMPACT ASSESSMENT:
{{ performance_and_dependency_impact }}

VALIDATION RESULTS:
{{ dbt_tests_and_validation }}

{{ deployment_readiness_status }}
{{ reconciliation_metadata }}
```

**Data Migration Reconciliation Commit:**
```
reconcile(data): migrate data structures post-reconciliation

RECONCILIATION REPORT:
{{ migration_summary_table }}

CHANGES APPLIED:
{{ data_migration_steps }}

IMPACT ASSESSMENT:
{{ data_volume_and_performance_impact }}

VALIDATION RESULTS:
{{ data_integrity_validation }}

{{ migration_metadata }}
{{ reconciliation_metadata }}
```

### Step 10.3: Dynamic Commit Content Generation

**Auto-populate commit sections based on reconciliation analysis:**

```python
def generate_changes_list(reconciliation_results):
    """Generate emoji-formatted changes list"""
    changes = []
    
    for model in reconciliation_results.models:
        if model.status == 'added':
            changes.append(f"🆕 {model.name}: New model added ({format_number(model.row_count)} rows)")
        elif model.status == 'modified':
            if model.breaking_changes:
                changes.append(f"⚠️  {model.name}: {model.change_description}")
            else:
                changes.append(f"✅ {model.name}: {model.change_description}")
        elif model.status == 'removed':
            changes.append(f"🗑️ {model.name}: Model removed ({model.impact_description})")
    
    return '\n'.join(changes)

def generate_impact_assessment(reconciliation_results):
    """Generate impact assessment section"""
    return f"""
- Downstream Models: {reconciliation_results.downstream_models_count} models {['require updates' if reconciliation_results.downstream_models_count > 0 else 'unaffected']}
- Data Volume: +{reconciliation_results.rows_added} new rows, -{reconciliation_results.rows_removed} deleted rows
- Performance: Query time {'improved' if reconciliation_results.performance_delta > 0 else 'degraded'} by {abs(reconciliation_results.performance_delta)}%
- Breaking Changes: {reconciliation_results.breaking_changes_description}
"""

def generate_validation_results(reconciliation_results):
    """Generate validation results checklist"""
    return f"""
- Data Quality: {'✅' if reconciliation_results.data_quality_passed else '❌'} {reconciliation_results.data_quality_status}
- Referential Integrity: {'✅' if reconciliation_results.referential_integrity_passed else '❌'} {reconciliation_results.referential_integrity_status}
- Row Count Validation: {'✅' if reconciliation_results.row_count_validated else '❌'} {reconciliation_results.row_count_status}
- Downstream Tests: {'✅' if reconciliation_results.downstream_tests_passed else '❌'} {reconciliation_results.tests_passed}/{reconciliation_results.total_tests} tests passing
"""
```

### Step 10.4: Commit Message Finalization

**Complete autonomous commit message generation workflow:**

```python
async def finalize_reconciliation_commit():
    """
    Final step: Generate and optionally execute commit with reconciliation info
    """
    
    # Generate comprehensive commit message
    commit_message = await generate_reconciliation_commit_message(reconciliation_results)
    
    # Include reconciliation tables in commit body
    commit_message += f"""

{generate_schema_comparison_table(reconciliation_results)}

{generate_data_volume_impact_table(reconciliation_results)}

{generate_dependency_impact_table(reconciliation_results)}

RECONCILIATION METADATA:
- Reconciliation Tool: Autonomous Schema Reconciliation MCP v2.0
- Execution Time: {reconciliation_results.execution_duration}
- Validation Method: GitHub MCP + Preset MCP Integration  
- Automation Level: 95% (user confirmation: {reconciliation_results.user_confirmations_count} items)
"""
    
    # Present commit message to user
    print("🎯 GENERATED COMMIT MESSAGE:")
    print("=" * 80)
    print(commit_message)
    print("=" * 80)
    
    # Optional: Auto-commit if low risk
    if reconciliation_results.overall_risk_level in ['LOW', 'MEDIUM'] and reconciliation_results.user_confirmations_count == 0:
        confirmation = input("Execute commit automatically? (y/n): ")
        if confirmation.lower() == 'y':
            execute_git_commit(commit_message)
            print("✅ Commit executed successfully!")
    else:
        print("⚠️  High-risk changes detected. Manual commit recommended.")
        print("📋 Copy the generated commit message above for manual execution.")
```

## 11. ENHANCED SUCCESS METRICS WITH COMMIT INTEGRATION

### Final Enhanced Workflow Goals:
- **Complete Automation**: From discovery through commit message generation
- **Semantic Commit Integration**: Every reconciliation generates proper semantic commit
- **Comprehensive Documentation**: All reconciliation details captured in git history
- **Zero Information Loss**: Full traceability from reconciliation to deployment
- **Production Ready Commits**: Include all necessary deployment information

### Enhanced Success Conversation:
```
User: "Reconcile my schema changes"

AI: [Executes full autonomous reconciliation workflow]
AI: [Analyzes GitHub, queries databases, generates tables]
AI: [Creates comprehensive reconciliation report]
AI: [Generates semantic commit message with full details]

AI: "✅ RECONCILIATION COMPLETE!

📊 ANALYSIS SUMMARY:
- 4 models analyzed (users, orders, payments, user_preferences)
- 3 schema changes detected
- 2.4M rows affected across 3 tables
- MEDIUM risk level (1 breaking change)

🎯 GENERATED COMMIT MESSAGE:
reconcile(schema): sync dev_moniga with production schema

RECONCILIATION REPORT:
- Models Analyzed: 4 models
- Schema Changes: 3 modifications detected
- Data Impact: 2.4M rows across 3 tables
- Risk Level: MEDIUM (1 breaking change)

CHANGES APPLIED:
✅ users: Added email_verified column (VARCHAR(10))
⚠️  orders: Modified order_total type INT→DECIMAL(10,2)
🆕 user_preferences: New model added (156K rows)

[Full impact assessment and validation results included...]

Execute commit automatically? (y/n)"

User: "y"
AI: "✅ Commit executed successfully! Ready for production deployment."
```

This integration ensures that every reconciliation automatically generates a comprehensive, semantically correct commit message that captures all the analysis details, making the git history a complete record of data schema evolution.