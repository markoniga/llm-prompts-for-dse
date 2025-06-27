# Version: v0.1.0
# Last-Updated: 2025-06-16
# Owner: data-eng
# Description: Detect dangerous SQL & large costs

# Validate Risk Prompt

## Purpose
This prompt helps assess risks in proposed data operations, particularly SQL queries and dbt model changes. It evaluates potential impacts on data integrity, performance, and cost, providing guidance on safe execution.

## Usage
Use this prompt before executing potentially risky data operations to identify potential issues and determine appropriate safeguards.

## Input Context
- SQL query or dbt model code to be executed
- Information about the data environment (tables, volumes, etc.)
- Current system load and usage patterns
- Business criticality of the data
- Execution context (development, testing, production)

## MANDATORY OUTPUT FORMAT
**CRITICAL: Always use this exact compact Markdown table format - NEVER use verbose JSON:**

### ⚠️ Risk Assessment Summary
| Risk | Severity | Safeguard | Owner | Status |
|------|----------|-----------|-------|--------|
| Data Loss | HIGH | Backup required | Data Eng | 🔴 CRITICAL |
| Performance | MEDIUM | Off-hours scheduling | DevOps | 🟡 MODERATE |
| Cost | LOW | Monitor usage | Analytics | 🟢 ACCEPTABLE |
| Compliance | HIGH | Document changes | Governance | 🔴 CRITICAL |
| Security | MEDIUM | Access controls | Security | 🟡 MODERATE |

**Maximum 5 rows in risk table - prioritize most critical risks only**

### 📊 Operation Analysis
- **operation_type** → select|insert|update|delete|create|drop|alter|merge|other
- **target_objects** → table1, table2... ({{ target_objects | length }} objects)
- **estimated_rows_affected** → 1,000,000 rows
- **estimated_data_volume** → 10MB
- **execution_time_estimate** → 5 minutes
- **resource_utilization** → CPU: high, Memory: medium, I/O: high, Network: low

### 🔍 Code Review
- **problematic_patterns** →
  <details>
  <summary>⚠️ <strong>Issues Found</strong> ({{ problematic_patterns | length }} patterns)</summary>
  
  **Pattern**: Description | **Location**: Line/section | **Fix**: Recommendation
  
  </details>
- **missing_safeguards** → WHERE clause needed, LIMIT missing, Transaction recommended

### 🎯 Recommendations  
- **proceed** → true|false
- **suggested_approach** → Brief description of recommended approach
- **required_safeguards** → Safeguard 1, Safeguard 2... (first 2, then count)
- **alternative_solutions** →
  <details>
  <summary>💡 <strong>Alternative Approaches</strong> ({{ alternatives | length }} options)</summary>
  
  **Option 1**: Description | **Pros**: Pro1, Pro2 | **Cons**: Con1, Con2
  
  </details>

### 📋 Execution Plan
- **pre_execution_steps** → Step 1, Step 2... (first 2 steps)
- **monitoring_guidance** → Monitor transaction log, Watch for lock contention
- **rollback_plan** → possible: true|false | Steps: Step1, Step2...

## Instructions

1. **Analyze the operation**
   - Identify the type of operation (SELECT, INSERT, UPDATE, DELETE, etc.)
   - Determine the target objects (tables, views, etc.)
   - Estimate the scope of the operation (rows affected, data volume)
   - Consider the execution context (dev, test, prod)

2. **Identify potential risks**
   - Look for operations that could cause data loss (DELETE, DROP, TRUNCATE)
   - Identify performance risks (missing WHERE clauses, large joins, etc.)
   - Assess cost implications (large data scans, expensive operations)
   - Consider security and compliance risks
   - Evaluate impact on downstream processes

3. **Review code quality**
   - Look for problematic patterns (cartesian products, implicit conversions)
   - Identify missing safeguards (WHERE clauses, LIMIT, transactions)
   - Check for proper error handling
   - Assess code readability and maintainability

4. **Estimate resource utilization**
   - Predict CPU, memory, I/O, and network usage
   - Consider impact on concurrent operations
   - Assess potential for resource contention
   - Estimate execution time

5. **Provide recommendations**
   - Determine if the operation should proceed
   - Suggest required safeguards
   - Propose alternative approaches if needed
   - Outline pre-execution steps and monitoring guidance
   - Develop a rollback plan

6. **Consider business context**
   - Assess business criticality of the data
   - Consider timing (business hours vs. off-hours)
   - Evaluate impact on reporting and analytics
   - Consider SLAs and compliance requirements

## Examples

### Example 1: High-Risk DELETE Operation
Input: DELETE FROM customer_orders WHERE order_date < '2025-01-01'

Output:

### ⚠️ Risk Assessment Summary
| Risk | Severity | Impact | Safeguard | Status |
|------|----------|---------|-----------|--------|
| Data Loss | HIGH | 5M rows permanent deletion | Backup required | 🔴 CRITICAL |
| Performance | MEDIUM | 30-45min execution | Off-hours scheduling | 🟡 MODERATE |
| Compliance | HIGH | Regulatory data retention | Document justification | 🔴 CRITICAL |

### 📊 Operation Analysis
- **operation_type** → delete
- **target_objects** → customer_orders (1 object)
- **estimated_rows_affected** → 5,000,000 rows
- **estimated_data_volume** → 2GB
- **execution_time_estimate** → 30-45 minutes
- **resource_utilization** → CPU: high, Memory: medium, I/O: high, Network: low

### 🔍 Code Review
- **problematic_patterns** →
  <details>
  <summary>⚠️ <strong>Issues Found</strong> (2 patterns)</summary>
  
  **Bulk deletion without LIMIT** | **Location**: Entire query | **Fix**: Add LIMIT clause or implement batched deletion approach
  **Missing transaction** | **Location**: Entire query | **Fix**: Wrap operation in transaction with proper error handling
  
  </details>
- **missing_safeguards** → Backup needed, Row limit missing, Additional WHERE constraints recommended

### 🎯 Recommendations  
- **proceed** → false
- **suggested_approach** → Implement safer, batched deletion process with proper backups and verification steps
- **required_safeguards** → Create backup table, Implement batched approach...and 3 more
- **alternative_solutions** →
  <details>
  <summary>💡 <strong>Alternative Approaches</strong> (2 options)</summary>
  
  **Archive data instead** | **Pros**: Preserves data, Lower risk, Reversible | **Cons**: Additional storage, May not address root issue
  **Data retention policy** | **Pros**: Sustainable long-term, Better performance, Automated lifecycle | **Cons**: More upfront work, Schema changes needed
  
  </details>

### 📋 Execution Plan
- **pre_execution_steps** → Create backup table, Verify backup data...and 3 more
- **monitoring_guidance** → Monitor transaction log growth, Watch for lock contention, Track system performance
- **rollback_plan** → possible: true | Steps: Stop deletion process, Restore from backup, Verify data integrity

### Example 2: Medium-Risk Model Change
Input: Modify fct_orders model to use a full refresh instead of incremental updates

Output:

### ⚠️ Risk Assessment Summary
| Risk | Severity | Safeguard | Owner | Status |
|------|----------|-----------|-------|--------|
| Performance | HIGH | Off-hours scheduling | DevOps | 🔴 CRITICAL |
| Cost | MEDIUM | Monitor usage + alerts | Analytics | 🟡 MODERATE |
| Availability | MEDIUM | Notify stakeholders | Data Eng | 🟡 MODERATE |
| Data Consistency | LOW | Validation tests | Data Eng | 🟢 ACCEPTABLE |

### Example 3: Low-Risk SELECT Query
Input: SELECT customer_id, SUM(order_total) FROM fct_orders WHERE order_date >= '2025-01-01' GROUP BY customer_id

Output:

### ⚠️ Risk Assessment Summary
| Risk | Severity | Safeguard | Owner | Status |
|------|----------|-----------|-------|--------|
| Performance | LOW | Monitor during peak hours | Analytics | 🟢 ACCEPTABLE |

## Safety Guardrails
- Always prioritize data integrity and safety over performance or convenience
- Flag any operations that could result in data loss without proper safeguards
- Recommend appropriate backups before destructive operations
- Suggest testing in non-production environments first
- Encourage proper error handling and transaction management
- Recommend batched approaches for large-scale operations
- Consider business hours and system load when scheduling operations
- Evaluate compliance and regulatory implications of data changes
- Suggest appropriate monitoring and alerting during execution
- Always provide a rollback plan for risky operations

## Schema Reconciliation Risk Assessment

When changes are made to existing data pipelines, assess the risk of schema misalignment between development and production:

### Step 1: Identify Schema Changes
- **Column Modifications**:
  - Additions: New columns added to existing tables
  - Removals: Columns deleted from existing tables
  - Type Changes: Data type modifications (e.g., INT → DECIMAL)
  - Size Changes: Field size modifications (e.g., VARCHAR(50) → VARCHAR(100))

- **Table Structure Changes**:
  - New Tables: Addition of entirely new models
  - Removed Tables: Deprecation of existing models
  - Table Renames: Changes to model names
  - Partition Changes: Modifications to partitioning strategies

- **Key Modifications**:
  - Primary Key Changes: Modifications to unique identifiers
  - Foreign Key Changes: Modifications to relationship definitions
  - Index Changes: Additions or removals of indexes

### Step 2: Quantify Impact
- **Row Impact Assessment**:
  ```json
  "row_impact": {
    "total_rows_affected": 1234567,
    "percentage_of_total": 0.05,
    "tables_affected": ["table1", "table2"],
    "data_volume_change": "+2GB"
  }
  ```

- **Downstream Dependency Analysis**:
  ```json
  "dependency_impact": {
    "direct_dependencies": ["model1", "model2"],
    "indirect_dependencies": ["report1", "dashboard2"],
    "critical_paths_affected": true|false,
    "user_facing_impacts": ["dashboard1", "API2"]
  }
  ```

- **Data Loss Potential**:
  ```json
  "data_loss_risk": {
    "risk_level": "high|medium|low|none",
    "affected_columns": ["column1", "column2"],
    "recoverable": true|false,
    "historical_data_impact": "Description of impact on historical data"
  }
  ```

### Step 3: Risk Classification
- **🔴 HIGH Risk Changes**:
  - Column deletions in existing models
  - Type changes with potential data loss (e.g., DECIMAL → INT)
  - Primary key modifications
  - Changes affecting critical business metrics

- **🟡 MEDIUM Risk Changes**:
  - Type modifications with compatible conversions (e.g., INT → BIGINT)
  - Column renames
  - Adding non-nullable columns to existing tables
  - Changes to aggregation logic

- **🟢 LOW Risk Changes**:
  - Adding nullable columns
  - Documentation changes
  - Adding new models without modifying existing ones
  - Index optimizations

### Step 4: Reconciliation Recommendation
- **Generate Reconciliation Tables**:
  ```json
  "reconciliation_tables": {
    "schema_comparison": "Markdown table comparing schemas",
    "data_volume_impact": "Markdown table showing row counts",
    "dependency_impact": "Markdown table of affected dependencies"
  }
  ```

- **Recommend Reconciliation Actions**:
  ```json
  "reconciliation_actions": {
    "recommended_actions": [
      "Backup affected tables before deployment",
      "Run schema comparison queries",
      "Validate data integrity post-change"
    ],
    "required_confirmations": [
      "Confirm deletion of column X (affects 1.2M rows)"
    ],
    "automated_checks": [
      "Compare row counts between environments",
      "Validate referential integrity"
    ]
  }
  ```

### Example Schema Comparison Table
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

### Example Data Volume Impact Table
```markdown
## 📈 DATA VOLUME ANALYSIS

| Model | Production Rows | Dev Rows | Difference | % Change | Last Updated |
|-------|-----------------|----------|------------|----------|--------------|
| users | 2,456,789 | 2,456,790 | +1 | +0.00% | 2025-01-15 |
| orders | 15,678,432 | 15,680,123 | +1,691 | +0.01% | 2025-01-15 |
| payments | 8,234,567 | 8,234,567 | 0 | 0.00% | 2025-01-14 |

**Total Impact**: 23,369,788 production rows • +1,692 new rows • 0.007% overall change
```

### Example Dependency Impact Table
```markdown
## 🔗 DOWNSTREAM IMPACT ANALYSIS

| Affected Model | Type | Relationship | Risk Level | Users/Systems | Action Required |
|----------------|------|--------------|------------|---------------|-----------------|
| user_metrics | View | Direct ref() | 🔴 HIGH | 12 dashboards | Schema update needed |
| daily_summary | Table | Indirect | 🟡 MEDIUM | 3 reports | Monitor for changes |
| user_segments | Materialized | Direct ref() | 🔴 HIGH | ML pipeline | Coordinate deployment |

**Impact Summary**: 3 downstream models • 2 high-risk • 15 total affected systems
```
