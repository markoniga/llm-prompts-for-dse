# Version: v0.2.0
# Last-Updated: 2025-01-16
# Owner: data-eng
# Description: Execute dbt commands safely - streamlined approach

# Run dbt Prompt

## PURPOSE
Execute dbt commands safely and efficiently with clear guidance. **Focus on getting things done without unnecessary complexity.**

## EXECUTION APPROACH
1. **Risk assessment** - Quick check for safety
2. **Command selection** - Right command for the task
3. **Clear execution** - Step-by-step approach
4. **Result validation** - Verify success

## OUTPUT FORMAT (Streamlined)

### 🎯 Execution Plan
- **command** → `dbt build --select model_name`
- **risk_level** → low|medium|high
- **estimated_time** → 5 minutes
- **resources_needed** → CPU: medium, Memory: low

### 🚀 Execution Steps
```bash
# Step 1: Navigate to project
cd /path/to/dbt/project

# Step 2: Execute command
dbt build --select model_name --rebuild

# Step 3: Validate results
dbt test --select model_name
```

### 📊 Expected Outcome
- **success_criteria** → All models complete successfully
- **row_counts** → Approximately 1.2M rows
- **validation** → All tests should pass

### 🔍 Monitor For
- **Performance** → Execution time, resource usage
- **Errors** → SQL errors, connection issues
- **Data quality** → Row counts, test results

### 🔄 Next Action
**If successful:** Proceed with testing or deployment
**If errors:** Check logs and apply fixes

## EXAMPLES

### Example 1: Simple Model Run (Low Risk)
**Input:** Run the dim_customers model after adding new field

### 🎯 Execution Plan
- **command** → `dbt run --select dim_customers`
- **risk_level** → low
- **estimated_time** → 2 minutes
- **resources_needed** → CPU: low, Memory: low

### 🚀 Execution Steps
```bash
# Navigate to project
cd /path/to/dbt/project

# Run specific model
dbt run --select dim_customers

# Test the model
dbt test --select dim_customers

# Check row counts
dbt run-operation print_row_count --args '{table_name: dim_customers}'
```

### 📊 Expected Outcome
- **success_criteria** → 1 model completed successfully
- **row_counts** → ~50K customer records
- **validation** → not_null and unique tests pass

### Example 2: Incremental Model Update (Medium Risk)
**Input:** Run fct_orders incremental model with recent changes

### 🎯 Execution Plan
- **command** → `dbt run --select fct_orders --full-refresh`
- **risk_level** → medium
- **estimated_time** → 15 minutes
- **resources_needed** → CPU: high, Memory: medium

### 🚀 Execution Steps
```bash
# Navigate to project
cd /path/to/dbt/project

# Check current state
dbt run --select fct_orders --full-refresh

# Monitor progress
tail -f logs/dbt.log

# Validate after completion
dbt test --select fct_orders
dbt test --select fct_orders+1  # Test downstream models
```

### 📊 Expected Outcome
- **success_criteria** → Incremental update completes without errors
- **row_counts** → +10K new rows added
- **validation** → All data quality tests pass

### 🔍 Monitor For
- **Performance** → Should complete within 15 minutes
- **Errors** → Incremental strategy errors, key conflicts
- **Data quality** → Row count consistency, duplicate detection

### Example 3: Full Model Refresh (High Risk)
**Input:** Full refresh of multiple fact tables

### 🎯 Execution Plan
- **command** → `dbt run --select +fct_orders --full-refresh`
- **risk_level** → high
- **estimated_time** → 45 minutes
- **resources_needed** → CPU: very high, Memory: high

### 🚀 Execution Steps
```bash
# Navigate to project
cd /path/to/dbt/project

# Backup current state (recommended)
dbt snapshot --select snapshot_fct_orders

# Execute full refresh during off-hours
dbt run --select +fct_orders --full-refresh

# Monitor progress closely
watch -n 30 'dbt ls --resource-type model --output name | wc -l'

# Comprehensive validation
dbt test --select +fct_orders
dbt run-operation validate_row_counts --args '{models: [fct_orders]}'
```

### 📊 Expected Outcome
- **success_criteria** → All models complete within time limit
- **row_counts** → Consistent with previous full refresh
- **validation** → All downstream tests pass

### 🔍 Monitor For
- **Performance** → Resource usage, execution time
- **Errors** → Memory errors, timeout issues
- **Data quality** → Referential integrity, business rules

## COMMAND PATTERNS

### Single Model
```bash
# Run one model
dbt build --select model_name

# Run with dependencies
dbt build --select +model_name

# Run with downstream
dbt build --select model_name+
```

### Multiple Models
```bash
# Run by tag
dbt build --select tag:daily

# Run by folder
dbt build --select marts.core

# Run by pattern
dbt build --select fct_*

# Run by mentioning 
dbt build --select <model1> <model2> <modelx>..
```

### Safety Commands
```bash
# Test before run
dbt test --select model_name

# Run with validation
dbt run --select model_name && dbt test --select model_name

# Incremental with full-refresh option
dbt run --select model_name --full-refresh
```

## ERROR HANDLING

### Common Errors & Solutions

#### 1. SQL Compilation Error
```bash
# Check syntax
dbt compile --select model_name

# View compiled SQL
cat target/compiled/project/models/model_name.sql
```

#### 2. Connection Issues
```bash
# Test connection
dbt debug

# Check profiles
cat ~/.dbt/profiles.yml
```

#### 3. Memory/Resource Errors
```bash
# Run with smaller batches
dbt run --select model_name --threads 1

# Use partial refresh
dbt run --select model_name --vars '{days_back: 7}'
```

#### 4. Data Quality Issues
```bash
# Check row counts before/after
dbt run-operation print_audit_table

# Validate specific columns
dbt test --select model_name --vars '{audit_mode: true}'
```

## SAFETY CHECKLIST

### Pre-Execution
- [ ] **Backup critical data** (if full refresh)
- [ ] **Check resource availability** (CPU, memory)
- [ ] **Validate connection** (`dbt debug`)
- [ ] **Review SQL changes** (`dbt compile --select model`)

### During Execution
- [ ] **Monitor progress** (logs, resource usage)
- [ ] **Watch for errors** (SQL errors, timeouts)
- [ ] **Check estimated completion** (based on progress)

### Post-Execution
- [ ] **Validate results** (`dbt test --select model`)
- [ ] **Check row counts** (compare to expected)
- [ ] **Test downstream impact** (`dbt test --select model+1`)
- [ ] **Monitor for issues** (performance, data quality)

## PERFORMANCE OPTIMIZATION

### For Slow Models
```bash
# Use threading
dbt run --select model_name --threads 4

# Profile execution
dbt run --select model_name --profile

# Use vars for optimization
dbt run --select model_name --vars '{optimize: true}'
```

### For Large Datasets
```bash
# Incremental strategy
dbt run --select model_name --full-refresh false

# Partition-based runs
dbt run --select model_name --vars '{partition_date: "2024-01-01"}'

# Resource-conscious execution
dbt run --select model_name --threads 1 --no-partial-parse
```

## 🔄 NEXT MCP PROMPT
- **If successful** → Use `getTestResultsPrompt` to analyze test outcomes
- **If errors** → Use `getFixupSuggestionsPrompt` for specific solutions
- **If ready for deployment** → Use `getReconcilePrompt` to validate changes
- **If need rollback** → Use `getRollbackPlanPrompt` for safety procedures

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

## CHANGELOG
### v0.2.0 - 2025-01-16
- Simplified execution steps format
- Added clear risk assessment
- Focused on practical command patterns
- Streamlined error handling guidance
