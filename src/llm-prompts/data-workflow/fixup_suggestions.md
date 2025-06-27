# Version: v0.2.0
# Last-Updated: 2025-01-16
# Owner: data-eng
# Description: Targeted code fixes - specific solutions, fast implementation

# Fixup Suggestions Prompt

## PURPOSE
Generate specific, implementable code fixes for dbt test failures or performance issues. **Focus on working code, not lengthy explanations.**

## EXECUTION APPROACH
1. **Identify root cause** - What's actually broken?
2. **Provide working code** - Copy-paste ready solutions
3. **Validate logic** - Ensure fix addresses the issue
4. **Test verification** - How to confirm it works

## OUTPUT FORMAT (Solution-Focused)

### 🎯 Problem Analysis
- **issue_type** → null_values|duplicates|performance|business_logic|referential_integrity
- **affected_model** → models/marts/core/model_name.sql
- **test_failing** → specific test name
- **root_cause** → Brief description of actual problem

### 💻 Recommended Fix
```sql
-- Clear, working SQL code
-- Comments explaining the fix logic
-- Copy-paste ready for implementation
```

### 🔧 Alternative Solutions
| Approach | Complexity | Performance | Data Quality | Recommendation |
|----------|------------|-------------|--------------|----------------|
| Option A | Low | Good | High | ✅ **Recommended** |
| Option B | Medium | Excellent | Medium | 🔄 Alternative |
| Option C | High | Excellent | High | 🟡 If needed |

### ✅ Verification Steps
1. **Test the fix**: `dbt test --select model_name`
2. **Check results**: Specific validation query
3. **Monitor impact**: What to watch for

### 🔄 Next Action
**Immediate**: Apply the fix and re-run tests
**Follow-up**: Monitor for any downstream impact

## EXAMPLES

### Example 1: Null Value Fix (Critical)
**Input:** not_null test failing on fct_orders.customer_id (24 null values)

### 🎯 Problem Analysis
- **issue_type** → null_values
- **affected_model** → models/marts/core/fct_orders.sql
- **test_failing** → not_null_fct_orders_customer_id
- **root_cause** → Source orders have missing customer associations

### 💻 Recommended Fix
```sql
-- Add null filtering with audit trail
WITH source_orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
),

-- Track null customer_ids for monitoring
null_audit AS (
    SELECT COUNT(*) AS null_customer_orders
    FROM source_orders
    WHERE customer_id IS NULL
),

-- Clean orders with valid customer associations
clean_orders AS (
    SELECT
        order_id
        , customer_id
        , order_date
        , order_amount
        , status
        , created_at
        , updated_at
        
    FROM source_orders
    WHERE customer_id IS NOT NULL
        AND order_id IS NOT NULL
        AND order_date IS NOT NULL
)

SELECT * FROM clean_orders
```

### 🔧 Alternative Solutions
| Approach | Complexity | Performance | Data Quality | Recommendation |
|----------|------------|-------------|--------------|----------------|
| Filter nulls | Low | Good | High | ✅ **Recommended** |
| Default customer | Low | Good | Medium | 🔄 Alternative |
| Fix upstream | High | Excellent | High | 🟡 Long-term |

### ✅ Verification Steps
1. **Test the fix**: `dbt test --select fct_orders`
2. **Check results**: `SELECT COUNT(*) FROM {{ ref('fct_orders') }} WHERE customer_id IS NULL`
3. **Monitor impact**: Track row count change in downstream reports

### Example 2: Duplicate Resolution (Critical)
**Input:** unique test failing on dim_customers.customer_id (15 duplicates)

### 🎯 Problem Analysis
- **issue_type** → duplicates
- **affected_model** → models/marts/core/dim_customers.sql
- **test_failing** → unique_dim_customers_customer_id
- **root_cause** → Multiple records per customer due to update logic

### 💻 Recommended Fix
```sql
-- Deduplicate customers keeping most recent version
WITH source_customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
),

deduplicated_customers AS (
    SELECT
        customer_id
        , customer_name
        , email
        , phone
        , tier
        , created_at
        , updated_at
        
    FROM source_customers
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY customer_id 
        ORDER BY updated_at DESC, created_at DESC
    ) = 1
)

SELECT * FROM deduplicated_customers
```

### 🔧 Alternative Solutions
| Approach | Complexity | Performance | Data Quality | Recommendation |
|----------|------------|-------------|--------------|----------------|
| QUALIFY deduplication | Low | Good | High | ✅ **Recommended** |
| GROUP BY MAX approach | Medium | Poor | High | 🔄 Alternative |
| SCD Type 2 | High | Good | Excellent | 🟡 If history needed |

### Example 3: Performance Optimization (Medium Priority)
**Input:** Incremental model taking 45+ minutes to run

### 🎯 Problem Analysis
- **issue_type** → performance
- **affected_model** → models/marts/core/fct_orders.sql
- **test_failing** → Not a test failure - execution time issue
- **root_cause** → Inefficient incremental strategy and join conditions

### 💻 Recommended Fix
```sql
{{ config(
    materialized='incremental',
    unique_key='order_id',
    incremental_strategy='delete+insert',
    cluster_by=['order_date']
) }}

-- Use static timestamp for better index usage
{% if is_incremental() %}
    {% set max_updated_query %}
        SELECT MAX(updated_at)::VARCHAR FROM {{ this }}
    {% endset %}
    {% set max_updated_timestamp = run_query(max_updated_query).columns[0][0] %}
{% endif %}

WITH source_orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
    {% if is_incremental() %}
        -- Static timestamp enables index usage
        WHERE updated_at > '{{ max_updated_timestamp }}'
    {% endif %}
),

-- Early filtering before expensive joins
filtered_orders AS (
    SELECT *
    FROM source_orders
    WHERE order_date >= '2020-01-01'  -- Business rule filter
        AND status IN ('completed', 'pending', 'refunded')
),

enriched_orders AS (
    SELECT
        o.order_id
        , o.customer_id
        , o.order_date
        , o.order_amount
        , c.customer_tier
        , p.product_category
        , o.created_at
        , o.updated_at
        
    FROM filtered_orders o
    LEFT JOIN {{ ref('dim_customers') }} c
        ON o.customer_id = c.customer_id
    LEFT JOIN {{ ref('dim_products') }} p
        ON o.product_id = p.product_id
)

SELECT * FROM enriched_orders
```

### 🔧 Alternative Solutions
| Approach | Complexity | Performance | Data Quality | Recommendation |
|----------|------------|-------------|--------------|----------------|
| Static timestamp + clustering | Medium | Excellent | High | ✅ **Recommended** |
| Partitioning strategy | High | Excellent | High | 🔄 If volume high |
| Merge strategy | Low | Good | High | 🟡 Fallback option |

## COMMON FIX PATTERNS

### 1. Null Value Handling
```sql
-- Pattern: Filter null values
WHERE column_name IS NOT NULL

-- Pattern: Default values for nulls  
COALESCE(column_name, 'DEFAULT') AS column_name

-- Pattern: Conditional logic for nulls
CASE 
    WHEN column_name IS NULL THEN 'Unknown'
    ELSE column_name 
END AS column_name
```

### 2. Duplicate Resolution
```sql
-- Pattern: Window function deduplication
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY unique_key 
    ORDER BY priority_column DESC
) = 1

-- Pattern: Aggregation approach
GROUP BY unique_key
HAVING COUNT(*) = 1
```

### 3. Performance Optimization
```sql
-- Pattern: Early filtering
WITH early_filter AS (
    SELECT * FROM source
    WHERE filter_condition
),

-- Pattern: Static timestamps in incremental
{% if is_incremental() %}
    WHERE updated_at > '{{ static_timestamp }}'
{% endif %}

-- Pattern: Efficient joins
LEFT JOIN dimension d
    ON fact.key = d.key
    AND d.is_current = TRUE  -- Filter before join
```

### 4. Business Rule Validation
```sql
-- Pattern: Data quality filters
WHERE amount > 0
    AND status IN ('valid', 'statuses')
    AND date_column >= '2020-01-01'

-- Pattern: Accepted values
WHERE column_name IN (
    'accepted', 'values', 'list'
)
```

### 5. Referential Integrity
```sql
-- Pattern: Inner join for required relationships
INNER JOIN required_dimension rd
    ON fact.key = rd.key

-- Pattern: Check for orphaned records
WHERE fact.foreign_key IN (
    SELECT primary_key FROM dimension
)
```

## TESTING FIXES

### After Applying Fix
```bash
# Test specific model
dbt test --select model_name

# Test downstream impact
dbt test --select model_name+

# Full test if critical model
dbt test
```

### Validation Queries
```sql
-- Check row counts
SELECT 
    'before' AS period, COUNT(*) AS row_count
FROM previous_version
UNION ALL
SELECT 
    'after' AS period, COUNT(*) AS row_count
FROM current_version;

-- Verify fix worked
SELECT COUNT(*) AS remaining_issues
FROM model_name
WHERE problem_condition;
```

## ROLLBACK PLAN

### If Fix Doesn't Work
1. **Revert changes**: `git checkout model_name.sql`
2. **Run original version**: `dbt run --select model_name`
3. **Investigate further**: Use `getValidateRiskPrompt` for deeper analysis

### If Downstream Issues
1. **Check immediate dependencies**: `dbt test --select model_name+1`
2. **Monitor key metrics**: Run downstream validation queries
3. **Communication**: Alert affected teams if needed

## 🔄 NEXT MCP PROMPT
- **After fix applied** → Use `getRunDbtPrompt` to test implementation
- **If fix unsuccessful** → Use `getGenerateCodePrompt` for alternative approach
- **If ready for deployment** → Use `getReconcilePrompt` to validate changes

## CHANGELOG
### v0.2.0 - 2025-01-16
- Focused on working code solutions over explanations
- Added clear alternative solution comparisons
- Simplified verification steps
- Emphasized copy-paste ready implementations
