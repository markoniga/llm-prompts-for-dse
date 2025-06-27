# Version: v0.2.0
# Last-Updated: 2025-01-16
# Owner: analytics-platform
# Description: Generate optimized dbt code - query optimization first, macros last

# Generate Code Prompt

## PURPOSE
Generate high-quality dbt code that follows best practices. **CRITICAL:** Always optimize queries first - macro creation is a last resort.

## QUERY OPTIMIZATION FIRST PRINCIPLE
**⚠️ MANDATORY APPROACH - Try these in order:**

### 1. **Optimize the SQL Query** (FIRST CHOICE)
- **Performance**: Index-friendly WHERE clauses, efficient JOINs, early filtering
- **Simplicity**: Break complex logic into clear CTEs, reduce CASE complexity
- **Database-specific**: Use native functions, appropriate materializations

### 2. **Only Consider Macros When:**
- Same logic appears in 3+ different models
- User explicitly requests reusable component
- Complex business rule needs consistency across models

### 3. **Decision Matrix:**
```
Performance Issue? → Optimize query → Only suggest macro if truly reusable
Complex Logic? → Simplify query → Only suggest macro if used 3+ places
Repetitive Code? → Refactor query → Only suggest macro if >3 uses
```

## OUTPUT FORMAT (Streamlined)

### 🛠️ Implementation Plan
- **approach** → Query optimization | Schema change | New model | Documentation
- **target_file** → models/marts/core/model_name.sql
- **operation** → create|modify|optimize
- **complexity** → simple|moderate|complex

### 💻 Generated Code
```sql
-- Clear, optimized SQL code here
-- Focus on performance and readability
-- Comments explaining business logic
```

### 🔍 Key Optimizations Applied
- **optimization1** → Specific technique used (e.g., "Early filtering in CTE")
- **optimization2** → Another technique (e.g., "Static timestamp in WHERE clause")
- **optimization3** → Performance improvement (e.g., "Index-friendly join condition")

### 📋 Schema Changes
| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| new_field | VARCHAR(50) | NOT NULL | Business purpose |

### 🧪 Suggested Tests
- **not_null**: field_name (ensures data quality)
- **unique**: primary_key (prevents duplicates)
- **relationships**: foreign_key → ref('other_table') (referential integrity)

### 🛠️ Next Steps
1. **Review code** - Validate approach and SQL logic
2. **Create file** - Save to target location  
3. **Run tests** - Use `getRunDbtPrompt` to execute
4. **Validate** - Use `getValidateRiskPrompt` if high-impact changes

## IMPLEMENTATION EXAMPLES

### Example 1: Simple Field Addition
**Input:** "Add customer_tier field to dim_customers from stg_customers.tier"

### 🛠️ Implementation Plan
- **approach** → Query optimization
- **target_file** → models/marts/core/dim_customers.sql
- **operation** → modify
- **complexity** → simple

### 💻 Generated Code
```sql
WITH source_customers AS (
    SELECT * FROM {{ ref('stg_customers') }}
),

enriched_customers AS (
    SELECT
        customer_id
        , customer_name
        , email
        , phone
        , UPPER(COALESCE(tier, 'STANDARD')) AS customer_tier  -- New field
        , created_at
        , updated_at
        
    FROM source_customers
    WHERE customer_id IS NOT NULL
        AND email IS NOT NULL
)

SELECT * FROM enriched_customers
```

### 🔍 Key Optimizations Applied
- **Data cleaning** → UPPER() for consistency, COALESCE() for null handling
- **Early filtering** → WHERE clause eliminates invalid records upfront
- **Clear naming** → Descriptive CTEs and logical field grouping

### 📋 Schema Changes
| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| customer_tier | VARCHAR(20) | NOT NULL | Customer tier level (STANDARD, PREMIUM, VIP) |

### Example 2: Performance Optimization
**Input:** "Optimize the incremental logic in fct_orders - it's taking too long"

### 🛠️ Implementation Plan
- **approach** → Query optimization
- **target_file** → models/marts/core/fct_orders.sql
- **operation** → optimize
- **complexity** → moderate

### 💻 Generated Code
```sql
{{ config(
    materialized='incremental',
    unique_key='order_id',
    incremental_strategy='delete+insert'
) }}

{% if is_incremental() %}
    {% set max_updated_at %}
        SELECT MAX(updated_at) FROM {{ this }}
    {% endset %}
    {% set max_timestamp = run_query(max_updated_at).columns[0][0] %}
{% endif %}

WITH source_orders AS (
    SELECT * FROM {{ ref('stg_orders') }}
    {% if is_incremental() %}
        -- Use static timestamp for index efficiency
        WHERE updated_at > '{{ max_timestamp }}'
    {% endif %}
),

enriched_orders AS (
    SELECT
        o.order_id
        , o.customer_id
        , o.order_date
        , o.order_amount
        , c.customer_tier
        , p.product_category
        
    FROM source_orders o
    LEFT JOIN {{ ref('dim_customers') }} c
        ON o.customer_id = c.customer_id
    LEFT JOIN {{ ref('dim_products') }} p
        ON o.product_id = p.product_id
)

SELECT * FROM enriched_orders
```

### 🔍 Key Optimizations Applied
- **Static timestamp** → Enables index usage vs dynamic subquery
- **Early filtering** → Filter source before expensive joins
- **Efficient strategy** → delete+insert performs better for this use case

## CODING STANDARDS

### SQL Formatting
```sql
-- ✅ CORRECT: Leading commas, meaningful aliases, 2-space indent
WITH clean_data AS (
    
    SELECT
        orders.order_id
        , orders.customer_id
        , orders.order_amount
        , customers.customer_name
        
    FROM {{ ref('stg_orders') }} AS orders
    LEFT JOIN {{ ref('dim_customers') }} AS customers
        ON orders.customer_id = customers.customer_id
    
    WHERE orders.order_date >= '2024-01-01'
        AND orders.status = 'completed'
)

-- ❌ WRONG: Trailing commas, unclear aliases, poor formatting
select o.order_id,o.customer_id,o.order_amount,c.customer_name from {{ ref('stg_orders') }} o left join {{ ref('dim_customers') }} c on o.customer_id=c.customer_id where o.order_date>='2024-01-01'
```

### Schema.yml Generation
```yaml
version: 2

models:
  - name: model_name
    description: Clear purpose of this model
    columns:
      - name: field_name
        description: What this field represents
        tests:
          - not_null
          - unique
```

## ANTI-PATTERNS TO AVOID

### ❌ Don't Create Unnecessary Macros
```sql
-- ❌ WRONG: Macro for simple logic
{% macro format_phone(phone_field) %}
  REPLACE(REPLACE({{ phone_field }}, '-', ''), ' ', '')
{% endmacro %}

-- ✅ CORRECT: Simple inline logic
REPLACE(REPLACE(phone, '-', ''), ' ', '') AS clean_phone
```

### ❌ Don't Over-Engineer Simple Changes
```sql
-- ❌ WRONG: Complex CTE structure for simple addition
WITH step1 AS (...),
     step2 AS (...),
     step3 AS (...)

-- ✅ CORRECT: Direct approach
SELECT 
    existing_field,
    new_field,
    ...
FROM source
```

## 🔄 NEXT MCP PROMPT
**After code generation:**
- **For simple changes** → `getRunDbtPrompt` to test implementation
- **For risky changes** → `getValidateRiskPrompt` first, then `getRunDbtPrompt`
- **For complex logic** → `getValidateRiskPrompt` for safety assessment

Here's my analysis. If this looks right, respond **Proceed**; otherwise clarify.

## CHANGELOG
### v0.2.0 - 2025-01-16
- Emphasized query optimization over macro creation
- Simplified output format for better UX
- Added clear optimization examples
- Reduced complexity and cognitive load 