# Version: v0.2.0
# Last-Updated: 2025-01-16
# Owner: data-eng
# Description: Streamlined data validation - fast reconciliation workflow

# Reconcile Prompt

## PURPOSE
Automate comprehensive data validation between environments with clear, actionable results. **Focus on identifying differences and providing next steps quickly.**

## EXECUTION APPROACH
1. **dbt build validation** - Ensure local changes work correctly
2. **Environment comparison** - Compare dev vs production data
3. **Clear difference summary** - Table format showing what changed
4. **Next action decision** - Deploy, investigate, or fix

## OUTPUT FORMAT (Streamlined)

### 🚀 Build Validation
- **models_built** → 3 models completed successfully
- **tests_passed** → 25/25 tests passed ✅
- **build_time** → 4.2 minutes
- **ready_for_comparison** → true

### 📊 Preset Reconciliation Results
| Model | Dev Rows | Prod Rows | Row Diff | Schema Match | Data Fresh | Status |
|-------|----------|-----------|----------|--------------|------------|--------|
| dim_customers | 52,341 | 52,340 | +1 | ✅ MATCH | ✅ FRESH | 🟢 OK |
| fct_orders | 1,234,567 | 1,230,000 | +4,567 | ✅ MATCH | ✅ FRESH | 🟢 OK |
| fct_payments | 890,123 | 890,123 | 0 | ✅ MATCH | ✅ FRESH | 🟢 OK |

### 🔍 Schema Validation
| Model | Schema Changes | Compatibility | Risk | Status |
|-------|----------------|---------------|------|---------|
| dim_customers | Added: email_verified | Backward compatible | Low | ✅ Safe |
| fct_orders | None | Unchanged | None | ✅ Safe |

### 🎯 Reconciliation Result
- **overall_status** → ✅ READY FOR DEPLOYMENT
- **differences_expected** → true
- **schema_compatible** → true
- **recommendation** → Proceed with deployment

### 🔄 Next Action
**Deploy to production** - All validations passed, changes are safe

## EXAMPLES

### Example 1: Successful Reconciliation (Ready to Deploy)
**Input:** Compare dim_customers and fct_orders after adding customer_tier field

### 🚀 Build Validation
- **models_built** → 2 models completed successfully
- **tests_passed** → 18/18 tests passed ✅
- **build_time** → 2.8 minutes
- **ready_for_comparison** → true

### 📊 Data Comparison Summary
| Model | Dev Rows | Prod Rows | Difference | Status | Action |
|-------|----------|-----------|------------|---------|---------|
| dim_customers | 45,123 | 45,120 | +3 | ✅ Expected | Ready |
| fct_orders | 2,100,567 | 2,095,234 | +5,333 | ✅ Expected | Ready |

### 🔍 Schema Validation
| Model | Schema Changes | Compatibility | Risk | Status |
|-------|----------------|---------------|------|---------|
| dim_customers | Added: customer_tier (VARCHAR) | Backward compatible | Low | ✅ Safe |
| fct_orders | None | Unchanged | None | ✅ Safe |

### 🎯 Reconciliation Result
- **overall_status** → ✅ READY FOR DEPLOYMENT
- **differences_expected** → true (new customer records)
- **schema_compatible** → true
- **recommendation** → Proceed with deployment - changes look correct

### Example 2: Unexpected Differences (Investigate Required)
**Input:** Reconciliation shows unexpected row count drops

### 🚀 Build Validation
- **models_built** → 2 models completed successfully
- **tests_passed** → 15/18 tests passed ❌ (3 failures)
- **build_time** → 3.1 minutes
- **ready_for_comparison** → true (with warnings)

### 📊 Data Comparison Summary
| Model | Dev Rows | Prod Rows | Difference | Status | Action |
|-------|----------|-----------|------------|---------|---------|
| dim_customers | 45,120 | 45,670 | -550 | ⚠️ Unexpected drop | Investigate |
| fct_orders | 2,100,567 | 2,105,234 | -4,667 | ⚠️ Unexpected drop | Investigate |

### 🔍 Schema Validation
| Model | Schema Changes | Compatibility | Risk | Status |
|-------|----------------|---------------|------|---------|
| dim_customers | Removed: inactive_flag | Breaking change | High | ❌ Risky |
| fct_orders | Modified: order_date (DATE → TIMESTAMP) | Data type change | Medium | ⚠️ Review |

### 🎯 Reconciliation Result
- **overall_status** → ❌ INVESTIGATION REQUIRED
- **differences_expected** → false (unexpected drops)
- **schema_compatible** → false (breaking changes)
- **recommendation** → STOP - investigate row count drops and schema compatibility

### 🔄 Next Action
**Investigate issues** - Fix row count drops and schema breaks before deployment

### Example 3: Schema-Only Changes (Safe Deploy)
**Input:** Documentation and test updates with no data changes

### 🚀 Build Validation
- **models_built** → 3 models completed successfully
- **tests_passed** → 22/22 tests passed ✅
- **build_time** → 1.9 minutes
- **ready_for_comparison** → true

### 📊 Data Comparison Summary
| Model | Dev Rows | Prod Rows | Difference | Status | Action |
|-------|----------|-----------|------------|---------|---------|
| dim_customers | 45,670 | 45,670 | 0 | ✅ Perfect match | Ready |
| fct_orders | 2,105,234 | 2,105,234 | 0 | ✅ Perfect match | Ready |
| dim_products | 15,432 | 15,432 | 0 | ✅ Perfect match | Ready |

### 🔍 Schema Validation
| Model | Schema Changes | Compatibility | Risk | Status |
|-------|----------------|---------------|------|---------|
| dim_customers | None (doc updates only) | Unchanged | None | ✅ Safe |
| fct_orders | None (test additions) | Unchanged | None | ✅ Safe |
| dim_products | None (doc updates only) | Unchanged | None | ✅ Safe |

### 🎯 Reconciliation Result
- **overall_status** → ✅ SAFE FOR DEPLOYMENT
- **differences_expected** → true (no data changes expected)
- **schema_compatible** → true
- **recommendation** → Fast-track deployment - documentation/test changes only

## VALIDATION WORKFLOW

### Step 1: Build Validation
```bash
# Run dbt build for selected models
dbt build --select {{ models }}

# Capture build results
echo "Build completed at $(date)"
echo "Models: {{ models }}"
echo "Status: $?"
```

### Step 2: Preset Reconciliation
```bash
# Execute Preset reconciliation via MCP
preset.reconcile('{{ models }}')
```

### Step 3: Generate Results
Generate comprehensive reconciliation report in Markdown table format showing differences between environments.

### Step 2: Row Count Comparison
```sql
-- Query Used (Dev Environment):
SELECT 
    '{{ model_name }}' as model_name,
    'development' as environment,
    COUNT(*) as row_count,
    MAX(updated_at) as latest_update
FROM dev_{{ username }}.{{ model_name }}

UNION ALL

-- Query Used (Production Environment):
SELECT 
    '{{ model_name }}' as model_name,
    'production' as environment, 
    COUNT(*) as row_count,
    MAX(updated_at) as latest_update
FROM {{ prod_schema }}.{{ model_name }}
```

### Step 3: Schema Comparison
```sql
-- Query Used (Schema Comparison):
SELECT 
    column_name,
    CASE 
        WHEN dev.column_name IS NULL THEN 'REMOVED'
        WHEN prod.column_name IS NULL THEN 'ADDED'
        WHEN dev.data_type != prod.data_type THEN 'TYPE_CHANGED'
        ELSE 'UNCHANGED'
    END as change_status,
    COALESCE(prod.data_type, 'N/A') as prod_type,
    COALESCE(dev.data_type, 'N/A') as dev_type
FROM 
    (SELECT column_name, data_type FROM information_schema.columns 
     WHERE table_name = '{{ model_name }}' AND table_schema = 'dev_{{ username }}') dev
FULL OUTER JOIN
    (SELECT column_name, data_type FROM information_schema.columns 
     WHERE table_name = '{{ model_name }}' AND table_schema = '{{ prod_schema }}') prod
ON dev.column_name = prod.column_name
WHERE change_status != 'UNCHANGED'
ORDER BY change_status, column_name
```

### Step 4: Data Quality Verification
```sql
-- Query Used (Key Metrics Validation):
SELECT 
    'dev' as environment,
    COUNT(DISTINCT {{ primary_key }}) as unique_keys,
    COUNT(*) as total_rows,
    COUNT(*) - COUNT({{ primary_key }}) as null_keys
FROM dev_{{ username }}.{{ model_name }}

UNION ALL

SELECT 
    'prod' as environment,
    COUNT(DISTINCT {{ primary_key }}) as unique_keys,
    COUNT(*) as total_rows,
    COUNT(*) - COUNT({{ primary_key }}) as null_keys
FROM {{ prod_schema }}.{{ model_name }}
```

## RISK ASSESSMENT RULES

### ✅ SAFE TO DEPLOY
- Row counts match or show expected growth
- Schema changes are additive only (new nullable columns)
- All tests pass in both environments
- Data quality metrics are consistent

### ⚠️ REVIEW REQUIRED
- Row count differences >5% from expected
- Schema changes modify existing columns
- Some tests failing but not critical
- Data types changed but compatible

### ❌ INVESTIGATION REQUIRED
- Unexpected row count drops >10%
- Schema breaking changes (column removal, type conflicts)
- Critical test failures
- Data quality degradation detected

## COMMON RECONCILIATION PATTERNS

### Expected Growth Patterns
```sql
-- New customer records (expected daily)
-- Expected difference: +50-200 customers/day
SELECT COUNT(*) FROM dim_customers 
WHERE created_date >= CURRENT_DATE

-- New order records (expected hourly)
-- Expected difference: +100-500 orders/hour
SELECT COUNT(*) FROM fct_orders 
WHERE order_date >= CURRENT_DATE
```

### Schema Evolution Patterns
```sql
-- Safe additions (nullable columns)
ALTER TABLE {{ model_name }} 
ADD COLUMN new_field VARCHAR(100)

-- Safe modifications (increase size)  
ALTER TABLE {{ model_name }}
ALTER COLUMN existing_field TYPE VARCHAR(200)

-- Risky changes (data loss potential)
-- DO NOT DEPLOY without investigation
ALTER TABLE {{ model_name }}
DROP COLUMN existing_field
```

## AUTOMATED VALIDATION CHECKS

### Row Count Validation
- **Growth within bounds**: 0-20% increase expected
- **No unexpected drops**: <5% decrease needs investigation
- **Historical comparison**: Compare to same day last week/month

### Schema Validation
- **Backward compatibility**: No column removals or type downgrades
- **Additive changes**: New columns should be nullable or have defaults
- **Constraint validation**: Primary keys and relationships maintained

### Data Quality Validation
- **Referential integrity**: Foreign key relationships preserved
- **Business rules**: Domain constraints still valid
- **Null constraints**: Required fields still populated

## 🔄 NEXT MCP PROMPT
- **If ready for deployment** → Proceed with production deployment
- **If investigation required** → Use `getFixupSuggestionsPrompt` for specific solutions
- **If schema issues** → Use `getValidateRiskPrompt` for impact assessment
- **If successful deployment** → Document changes and notify stakeholders

## CHANGELOG
### v0.2.0 - 2025-01-16
- Simplified to clear table-based comparison format
- Added automated risk assessment rules
- Focused on actionable next steps
- Streamlined validation workflow 