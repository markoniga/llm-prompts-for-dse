# Version: v0.1.0
# Last-Updated: 2025-06-16
# Owner: analytics-platform
# Description: Create/modify dbt models/tests

# Generate Code Prompt

## PURPOSE
This prompt helps generate high-quality dbt code for models, macros, tests, and other artifacts. It creates SQL code that follows best practices and project standards, ensuring consistency and maintainability.

## CURSOR AGENT EXECUTION GUIDE
**Use this prompt AFTER gathering requirements** via context_gap prompt to ensure you have all necessary information.

### Pre-Execution Checklist
- [ ] Requirements are completely understood
- [ ] Target model/file is clearly identified
- [ ] Schema information is available
- [ ] Business logic is fully defined
- [ ] Testing requirements are specified
- [ ] Performance considerations are understood

## EXECUTION WORKFLOW

### Step 1: Validate Requirements Completeness
**Check for these REQUIRED inputs:**
- Target file path and type (model/macro/test/schema)
- Operation type (create/modify/delete)
- Field specifications (names, types, descriptions)
- Business logic and transformations
- Testing and validation requirements

### Step 2: Apply Code Standards
**Non-negotiable formatting rules:**
- Leading commas on column lists
- 4-space indentation
- Meaningful table aliases (not single letters)
- Capitalized SQL keywords
- CTE documentation for complex logic

### Step 3: Generate Complete Implementation
**Must include ALL of these components:**
- Complete SQL code
- Schema.yml entries with tests
- Field documentation
- Performance considerations
- Validation queries

## MANDATORY OUTPUT FORMAT
**ALWAYS return this exact JSON structure:**
```json
{
  "code_generation": {
    "file_path": "Path to the file being created or modified",
    "file_type": "model|macro|test|schema|other",
    "operation": "create|modify|delete",
    "summary": "Brief summary of the code changes"
  },
  "implementation_details": {
    "approach": "Description of the implementation approach",
    "key_techniques": [
      "Technique 1 used in the implementation",
      "Technique 2 used in the implementation"
    ],
    "assumptions": [
      "Assumption 1 made during implementation",
      "Assumption 2 made during implementation"
    ],
    "limitations": [
      "Limitation 1 of the implementation",
      "Limitation 2 of the implementation"
    ]
  },
  "code": {
    "content": "The full content of the generated code",
    "highlights": [
      {
        "line_numbers": "Line number or range",
        "description": "Description of the highlighted code section",
        "rationale": "Explanation of why this approach was chosen"
      }
    ]
  },
  "schema_changes": {
    "new_fields": [
      {
        "name": "Field name",
        "type": "Field data type",
        "description": "Field description",
        "tests": ["test1", "test2"]
      }
    ],
    "modified_fields": [
      {
        "name": "Field name",
        "changes": "Description of changes to the field",
        "rationale": "Reason for the changes"
      }
    ],
    "removed_fields": [
      {
        "name": "Field name",
        "rationale": "Reason for removal"
      }
    ]
  },
  "testing_strategy": {
    "data_tests": [
      {
        "test_type": "Type of test (unique, not_null, etc.)",
        "target": "Field or model being tested",
        "description": "Description of what the test verifies"
      }
    ],
    "edge_cases": [
      {
        "scenario": "Description of the edge case",
        "handling": "How the code handles this edge case"
      }
    ],
    "validation_queries": [
      {
        "purpose": "Purpose of the validation query",
        "query": "SQL query for validation",
        "expected_result": "Expected result of the query"
      }
    ]
  },
  "performance_considerations": {
    "expected_volume": "Expected data volume",
    "optimization_techniques": [
      "Technique 1 used for optimization",
      "Technique 2 used for optimization"
    ],
    "indexes_or_partitioning": "Description of any indexing or partitioning strategies",
    "potential_bottlenecks": [
      "Potential bottleneck 1",
      "Potential bottleneck 2"
    ]
  },
  "documentation": {
    "model_description": "Description of the model's purpose and function",
    "field_descriptions": {
      "field_name": "Field description",
      "another_field": "Another field description"
    },
    "usage_examples": [
      "Example 1 of how to use this model",
      "Example 2 of how to use this model"
    ]
  },
  "next_steps": [
    "Step 1 to implement this code",
    "Step 2 to test and validate",
    "Step 3 to deploy and monitor"
  ]
}
```

## CODING STANDARDS (STRICTLY ENFORCED)

### MACRO STYLE GUARDRAILS (STRICTLY ENFORCED)
**Mandatory Requirements for all dbt macros:**
- **<300 LOC per macro** - Break large macros into smaller, focused components
- **2-space indentation** - Consistent with project standards  
- **Jinja lint passes** - All Jinja code must pass linting checks

**Macro Quality Standards:**
```jinja2
-- ✅ CORRECT: Clean, concise macro under 300 LOC
{% macro calculate_customer_metrics(customer_table, orders_table) %}
  
  {% if execute %}
    {% set metrics_query %}
      SELECT 
        customer_id
        , COUNT(*) AS total_orders
        , SUM(order_amount) AS lifetime_value
      FROM {{ orders_table }}
      GROUP BY customer_id
    {% endset %}
    
    {{ return(metrics_query) }}
  {% endif %}
  
{% endmacro %}

-- ❌ WRONG: Overly complex macro exceeding LOC limits
{% macro massive_transformation_macro() %}
  -- 400+ lines of complex logic here
  -- Should be broken into smaller, focused macros
{% endmacro %}
```

### SQL Formatting Rules
```sql
-- ✅ CORRECT: Leading commas, meaningful aliases, proper indentation
WITH source_orders AS (
    
    SELECT * FROM {{ source('ecommerce', 'orders') }}
    
),

enriched_orders AS (
    /* 
    Add customer and product information to orders
    for comprehensive order analysis
    */
    SELECT
        orders.order_id
        , orders.customer_id
        , orders.order_date
        , orders.total_amount
        , customers.customer_name
        , customers.customer_tier
        
    FROM source_orders AS orders
    LEFT JOIN {{ ref('dim_customers') }} AS customers
        ON orders.customer_id = customers.customer_id
    
    WHERE orders.order_date >= '2023-01-01'
        AND orders.status != 'cancelled'
)

SELECT * FROM enriched_orders

-- ❌ WRONG: Trailing commas, single letter aliases, poor formatting
with o as (select * from {{ source('ecommerce', 'orders') }})
select o.order_id,o.customer_id,o.order_date,o.total_amount,c.customer_name,c.customer_tier from o left join {{ ref('dim_customers') }} c on o.customer_id=c.customer_id where o.order_date>='2023-01-01' and o.status!='cancelled'
```

### CTE Documentation Requirements
```sql
-- ✅ CORRECT: Clear purpose and logic explanation
WITH customer_lifetime_metrics AS (
    /*
    Calculate customer lifetime value and purchase frequency
    using all historical transactions since account creation.
    Excludes refunded transactions and corporate accounts.
    */
    SELECT
        customer_id
        , COUNT(order_id) AS total_orders
        , SUM(order_amount) AS lifetime_value
        , MAX(order_date) AS last_order_date
    FROM {{ ref('fct_orders') }}
    WHERE order_status = 'completed'
        AND customer_type != 'corporate'
    GROUP BY customer_id
)

-- ❌ WRONG: No documentation for complex logic
WITH clm AS (
    SELECT customer_id, COUNT(order_id), SUM(order_amount), MAX(order_date)
    FROM {{ ref('fct_orders') }}
    WHERE order_status = 'completed' AND customer_type != 'corporate'
    GROUP BY customer_id
)
```

### Schema.yml Generation
**Always generate complete schema entries:**
```yaml
version: 2

models:
  - name: fct_orders
    description: >
      Order fact table containing all completed transactions with customer
      and product dimensions. Updated nightly from operational systems.
    
    columns:
      - name: order_id
        description: "Unique identifier for each order"
        tests:
          - unique
          - not_null
      
      - name: customer_id
        description: "Foreign key to dim_customers"
        tests:
          - not_null
          - relationships:
              to: ref('dim_customers')
              field: customer_id
      
      - name: order_date
        description: "Date when the order was placed"
        tests:
          - not_null
      
      - name: total_amount
        description: "Total order amount in USD"
        tests:
          - not_null
          - dbt_utils.accepted_range:
              min_value: 0
              max_value: 100000
```

## OPTIMIZED EXAMPLE IMPLEMENTATIONS

### Example 1: Adding Promotion Code Field
**Scenario:** Add promotion_code field to stg_orders model

**Requirements Analysis:**
- Target: stg_orders model (staging layer)
- Source: source_orders.promo_code
- Data type: VARCHAR(50) (from context analysis)
- Nullable: Yes (not all orders have promo codes)
- Tests: Basic validation for format

**Generated Output:**
```json
{
  "code_generation": {
    "file_path": "models/staging/ecommerce/stg_orders.sql",
    "file_type": "model",
    "operation": "modify",
    "summary": "Added promotion_code field to stg_orders model with format validation"
  },
  "implementation_details": {
    "approach": "Add promotion_code field to existing SELECT statement, apply basic format cleaning",
    "key_techniques": [
      "UPPER() transformation for consistent formatting",
      "NULLIF() to convert empty strings to NULL",
      "Field positioning following existing column groups"
    ],
    "assumptions": [
      "Promotion codes should be uppercase for consistency",
      "Empty strings in source should be treated as NULL",
      "No referential integrity validation needed at staging level"
    ],
    "limitations": [
      "No validation against active promotions table",
      "No format validation beyond basic pattern checking",
      "Historical data patterns not analyzed for edge cases"
    ]
  },
  "code": {
    "content": "WITH source AS (\n\n    SELECT * FROM {{ source('ecommerce', 'orders') }}\n\n),\n\nstandardized AS (\n\n    SELECT\n        -- Primary key\n        id AS order_id\n        \n        -- Foreign keys\n        , customer_id\n        , product_id\n        \n        -- Order attributes\n        , order_date\n        , order_status\n        , UPPER(NULLIF(TRIM(promo_code), '')) AS promotion_code\n        \n        -- Financial metrics\n        , subtotal_amount\n        , tax_amount\n        , shipping_amount\n        , total_amount\n        \n        -- Metadata\n        , created_at\n        , updated_at\n        \n    FROM source\n    WHERE order_date >= '2020-01-01'\n        AND order_status IS NOT NULL\n\n)\n\nSELECT * FROM standardized",
    "highlights": [
      {
        "line_numbers": "15",
        "description": "Added promotion_code field with data cleaning",
        "rationale": "UPPER() ensures consistent formatting, NULLIF() converts empty strings to NULL for clean data model"
      },
      {
        "line_numbers": "12-14",
        "description": "Positioned in order attributes section",
        "rationale": "Logical grouping with other order-level attributes like status and date"
      }
    ]
  },
  "schema_changes": {
    "new_fields": [
      {
        "name": "promotion_code",
        "type": "varchar(50)",
        "description": "Promotion code applied to the order, standardized to uppercase",
        "tests": ["accepted_values", "dbt_utils.not_empty_string"]
      }
    ],
    "modified_fields": [],
    "removed_fields": []
  },
  "testing_strategy": {
    "data_tests": [
      {
        "test_type": "dbt_utils.not_empty_string",
        "target": "promotion_code",
        "description": "Ensures promotion codes are not empty strings when present"
      },
      {
        "test_type": "dbt_utils.accepted_range",
        "target": "promotion_code",
        "description": "Validates promotion code length is reasonable"
      }
    ],
    "edge_cases": [
      {
        "scenario": "Orders without promotion codes",
        "handling": "Field will be NULL, which is expected and valid"
      },
      {
        "scenario": "Malformed promotion codes",
        "handling": "Basic cleaning applied (trim, uppercase), but no validation against active codes"
      }
    ],
    "validation_queries": [
      {
        "purpose": "Check promotion code distribution",
        "query": "SELECT promotion_code, COUNT(*) as usage_count FROM {{ ref('stg_orders') }} WHERE promotion_code IS NOT NULL GROUP BY 1 ORDER BY 2 DESC LIMIT 20",
        "expected_result": "Should show realistic distribution of promotion codes"
      },
      {
        "purpose": "Validate data completeness",
        "query": "SELECT COUNT(*) as total_orders, COUNT(promotion_code) as orders_with_promo, ROUND(100.0 * COUNT(promotion_code) / COUNT(*), 2) as promo_percentage FROM {{ ref('stg_orders') }}",
        "expected_result": "Should show reasonable percentage of orders with promotion codes"
      }
    ]
  },
  "performance_considerations": {
    "expected_volume": "No significant change to existing model performance",
    "optimization_techniques": [
      "Simple field addition with minimal transformation overhead",
      "No additional joins or complex calculations"
    ],
    "indexes_or_partitioning": "No changes needed",
    "potential_bottlenecks": [
      "None expected from this simple field addition"
    ]
  },
  "documentation": {
    "model_description": "Staging model for order data with standardized field names and basic cleaning",
    "field_descriptions": {
      "promotion_code": "Promotion code applied to the order, converted to uppercase and null if empty"
    },
    "usage_examples": [
      "Analyze promotion code effectiveness: SELECT promotion_code, AVG(total_amount) FROM {{ ref('stg_orders') }} GROUP BY 1",
      "Join with promotions table for campaign analysis",
      "Track promotion usage over time for marketing insights"
    ]
  },
  "next_steps": [
    "Update models/staging/ecommerce/stg_orders.sql with the new code",
    "Add the promotion_code field to models/staging/ecommerce/schema.yml",
    "Run dbt test to validate the new field",
    "Check downstream models that reference stg_orders for needed updates",
    "Deploy to development environment and validate with sample data"
  ]
}
```

## CURSOR AGENT OPTIMIZATION NOTES

### For Seamless Execution:
1. **Always generate complete, runnable code** - include all necessary components
2. **Provide specific next steps** - clear action items for implementation
3. **Include validation queries** - help verify correctness immediately
4. **Follow project conventions strictly** - ensure code passes style checks
5. **Consider downstream impacts** - identify models that might need updates

### Error Prevention:
- Always validate that source fields exist before referencing them
- Include appropriate tests for new fields based on data type and business logic
- Consider NULL handling for new fields
- Check for naming conflicts with existing fields
- Validate that transformations preserve data integrity

## USER APPROVAL CHECKPOINT
**After providing your code generation analysis above, always end with:**

> Here's my analysis. If this looks right, respond **Proceed**; otherwise clarify.

## CHANGELOG
### v0.1.0 - 2025-06-16
- Initial version with comprehensive code generation
- Added strict formatting standards and validation
- Included complete testing strategy framework
- Optimized for Cursor agent execution with clear next steps 