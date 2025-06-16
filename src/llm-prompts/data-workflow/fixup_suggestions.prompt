# Version: v0.1.0
# Last-Updated: 2025-06-16
# Owner: analytics-platform
# Description: Suggest code fixes after failures

# Fixup Suggestions Prompt

## Purpose
This prompt helps generate targeted code fixes for failed tests, data quality issues, or performance problems in dbt models. It provides specific, actionable code changes to resolve identified issues while following project standards and best practices.

## Usage
Use this prompt after test failures or performance issues have been identified to get specific code suggestions to fix the problems.

## Input Context
- Test failure details from test_results prompt
- The current model code that needs fixing
- Project coding standards and patterns
- Database-specific considerations
- Performance metrics and requirements
- Business rules and data quality expectations

## Output Format
```json
{
  "issue_summary": {
    "model_name": "Name of the model with issues",
    "issue_type": "test_failure|performance|data_quality|other",
    "severity": "low|medium|high|critical",
    "description": "Brief description of the issue",
    "impact": "Description of the business or technical impact"
  },
  "root_cause_analysis": {
    "identified_cause": "Description of the root cause",
    "affected_code": "Specific part of the code causing the issue",
    "contributing_factors": [
      "Factor 1 contributing to the issue",
      "Factor 2 contributing to the issue"
    ],
    "detection_method": "How the root cause was identified"
  },
  "proposed_fixes": [
    {
      "fix_id": "unique_identifier_for_this_fix",
      "fix_type": "code_change|config_change|schema_change|other",
      "description": "Description of the proposed fix",
      "current_code": "Current problematic code",
      "suggested_code": "Suggested fixed code",
      "file_path": "Path to the file that needs to be modified",
      "confidence": 0.0-1.0,
      "expected_outcome": "What this fix is expected to accomplish",
      "potential_side_effects": [
        "Potential side effect 1",
        "Potential side effect 2"
      ]
    }
  ],
  "implementation_plan": {
    "steps": [
      {
        "step_number": 1,
        "description": "Description of this step",
        "action": "Specific action to take",
        "verification": "How to verify this step was successful"
      }
    ],
    "testing_approach": {
      "test_strategy": "How to test the fix",
      "verification_queries": [
        {
          "purpose": "Purpose of this verification query",
          "query": "SQL query to verify the fix",
          "expected_result": "Expected result of the query"
        }
      ]
    },
    "rollback_plan": {
      "rollback_steps": [
        "Step 1 to rollback the changes",
        "Step 2 to rollback the changes"
      ]
    }
  },
  "alternative_approaches": [
    {
      "approach": "Description of an alternative approach",
      "pros": ["Pro 1", "Pro 2"],
      "cons": ["Con 1", "Con 2"],
      "implementation": "How to implement this alternative approach"
    }
  ],
  "best_practices": [
    {
      "practice": "Best practice to follow",
      "rationale": "Why this practice is important",
      "implementation": "How to implement this best practice"
    }
  ],
  "learning_opportunities": {
    "patterns_to_avoid": [
      "Pattern 1 to avoid in the future",
      "Pattern 2 to avoid in the future"
    ],
    "recommended_patterns": [
      "Pattern 1 to adopt",
      "Pattern 2 to adopt"
    ],
    "educational_resources": [
      {
        "title": "Title of the resource",
        "description": "Description of the resource",
        "link": "Link to the resource (if applicable)"
      }
    ]
  }
}
```

## Instructions

1. **Analyze the issue**
   - Understand the nature and scope of the problem
   - Identify the specific model and code causing the issue
   - Determine the severity and impact of the issue
   - Consider business context and requirements

2. **Identify the root cause**
   - Examine the test failure details or performance metrics
   - Analyze the current code to find problematic patterns
   - Consider database-specific factors
   - Look for common anti-patterns or mistakes

3. **Develop targeted fixes**
   - Create specific code changes to address the root cause
   - Ensure fixes follow project standards and patterns
   - Consider performance implications
   - Address both immediate issues and underlying causes

4. **Create an implementation plan**
   - Break down the fix into clear, sequential steps
   - Include verification steps to confirm the fix works
   - Provide a rollback plan in case of issues
   - Consider dependencies and potential side effects

5. **Consider alternative approaches**
   - Identify different ways to solve the problem
   - Compare pros and cons of each approach
   - Recommend the most appropriate solution
   - Explain the rationale for the recommendation

6. **Highlight best practices**
   - Identify patterns to avoid in the future
   - Suggest better approaches and patterns
   - Provide educational resources
   - Connect the specific issue to broader principles

## Examples

### Example 1: Fixing Null Customer IDs in a Fact Table
Input: not_null test failure on fct_orders.customer_id with 24 null values

Output:
```json
{
  "issue_summary": {
    "model_name": "fct_orders",
    "issue_type": "test_failure",
    "severity": "high",
    "description": "not_null test failed on fct_orders.customer_id with 24 null values",
    "impact": "Orders without customer IDs break referential integrity and affect customer analytics, potentially causing incorrect metrics and failed joins in downstream models"
  },
  "root_cause_analysis": {
    "identified_cause": "The stg_orders model is not properly handling guest checkout orders, which have null customer_id values in the source data",
    "affected_code": "The JOIN between stg_orders and stg_customers in the fct_orders model is dropping guest checkout orders",
    "contributing_factors": [
      "No validation or handling for null customer_ids in the staging model",
      "No business logic to assign guest orders to an 'unknown' customer",
      "Recent increase in guest checkout orders due to website changes"
    ],
    "detection_method": "Analysis of failing records showed they all came from the e-commerce system with guest checkout flag enabled"
  },
  "proposed_fixes": [
    {
      "fix_id": "fix_null_customer_ids_001",
      "fix_type": "code_change",
      "description": "Modify the stg_orders model to assign a standard 'GUEST' customer_id to guest checkout orders",
      "current_code": "SELECT\n  order_id,\n  customer_id,\n  order_date,\n  order_amount\nFROM source_orders",
      "suggested_code": "SELECT\n  order_id,\n  CASE\n    WHEN customer_id IS NULL THEN 'GUEST'\n    ELSE customer_id\n  END AS customer_id,\n  order_date,\n  order_amount\nFROM source_orders",
      "file_path": "models/staging/stg_orders.sql",
      "confidence": 0.9,
      "expected_outcome": "All orders will have a valid customer_id, either their actual ID or 'GUEST' for guest checkouts",
      "potential_side_effects": [
        "Customer metrics will now include a 'GUEST' customer that needs to be handled appropriately in analytics",
        "Historical data comparisons may show a shift in customer distributions"
      ]
    },
    {
      "fix_id": "fix_null_customer_ids_002",
      "fix_type": "schema_change",
      "description": "Add a 'GUEST' customer record to the dim_customers table",
      "current_code": "-- No existing code for this guest customer",
      "suggested_code": "-- Add this to the dim_customers model\nUNION ALL\nSELECT\n  'GUEST' AS customer_id,\n  'Guest Checkout' AS customer_name,\n  NULL AS email,\n  'guest' AS customer_type,\n  '1900-01-01' AS first_order_date,\n  CURRENT_TIMESTAMP AS created_at,\n  CURRENT_TIMESTAMP AS updated_at",
      "file_path": "models/marts/core/dim_customers.sql",
      "confidence": 0.85,
      "expected_outcome": "The dim_customers table will include a record for guest checkouts, maintaining referential integrity",
      "potential_side_effects": [
        "Analytics teams need to be informed about the special 'GUEST' customer for proper interpretation"
      ]
    }
  ],
  "implementation_plan": {
    "steps": [
      {
        "step_number": 1,
        "description": "Modify the stg_orders model",
        "action": "Update the stg_orders.sql file with the CASE statement to handle null customer_ids",
        "verification": "Run 'dbt run --select stg_orders' and verify the output has no null customer_ids"
      },
      {
        "step_number": 2,
        "description": "Add the GUEST customer to dim_customers",
        "action": "Update the dim_customers.sql file to include the GUEST customer record",
        "verification": "Run 'dbt run --select dim_customers' and verify the GUEST customer exists"
      },
      {
        "step_number": 3,
        "description": "Rebuild the fct_orders model",
        "action": "Run 'dbt run --select fct_orders'",
        "verification": "Verify that the model builds successfully"
      },
      {
        "step_number": 4,
        "description": "Run tests",
        "action": "Run 'dbt test --select fct_orders'",
        "verification": "Verify that the not_null test on customer_id now passes"
      }
    ],
    "testing_approach": {
      "test_strategy": "Run targeted tests on the modified models and verify data integrity",
      "verification_queries": [
        {
          "purpose": "Verify no null customer_ids in stg_orders",
          "query": "SELECT COUNT(*) FROM stg_orders WHERE customer_id IS NULL",
          "expected_result": "0"
        },
        {
          "purpose": "Verify GUEST customer exists in dim_customers",
          "query": "SELECT COUNT(*) FROM dim_customers WHERE customer_id = 'GUEST'",
          "expected_result": "1"
        },
        {
          "purpose": "Verify no null customer_ids in fct_orders",
          "query": "SELECT COUNT(*) FROM fct_orders WHERE customer_id IS NULL",
          "expected_result": "0"
        },
        {
          "purpose": "Verify guest orders are preserved",
          "query": "SELECT COUNT(*) FROM fct_orders WHERE customer_id = 'GUEST'",
          "expected_result": "Should match the count of guest orders in the source data"
        }
      ]
    },
    "rollback_plan": {
      "rollback_steps": [
        "Revert changes to stg_orders.sql",
        "Revert changes to dim_customers.sql",
        "Run 'dbt run --select stg_orders dim_customers fct_orders' to rebuild the models"
      ]
    }
  },
  "alternative_approaches": [
    {
      "approach": "Filter out guest orders from fct_orders",
      "pros": ["Simpler implementation", "No need to modify dimension tables", "Cleaner customer analytics"],
      "cons": ["Loses guest order data in the fact table", "Creates discrepancies between order totals and customer order totals", "Doesn't address the root issue"],
      "implementation": "Add a WHERE customer_id IS NOT NULL filter to the fct_orders model"
    },
    {
      "approach": "Create a separate fact table for guest orders",
      "pros": ["Keeps guest and registered customer data separate", "Allows specialized analysis of guest behavior", "Maintains clean customer analytics"],
      "cons": ["More complex to maintain", "Requires changes to downstream models", "Complicates aggregations across all orders"],
      "implementation": "Create a new fct_guest_orders model and split the logic between the two fact tables"
    }
  ],
  "best_practices": [
    {
      "practice": "Handle null values explicitly in staging models",
      "rationale": "Addressing data quality issues early in the pipeline prevents cascading problems downstream",
      "implementation": "Use COALESCE, CASE statements, or similar constructs to provide default values or explicit handling for nulls"
    },
    {
      "practice": "Document special values and their meaning",
      "rationale": "Special values like 'GUEST' need to be understood by all data consumers",
      "implementation": "Add documentation in the schema.yml file explaining the meaning and handling of special values"
    },
    {
      "practice": "Add tests for business rules",
      "rationale": "Tests should verify both technical constraints and business rules",
      "implementation": "Add custom tests that verify business-specific data quality rules"
    }
  ],
  "learning_opportunities": {
    "patterns_to_avoid": [
      "Implicit assumptions about non-null values",
      "Lack of handling for edge cases like guest checkouts",
      "Missing validation in staging models"
    ],
    "recommended_patterns": [
      "Explicit null handling in staging models",
      "Documentation of special values and their business meaning",
      "Comprehensive testing that covers business rules"
    ],
    "educational_resources": [
      {
        "title": "dbt Best Practices: Staging Layer",
        "description": "Guidelines for building robust staging models",
        "link": "https://docs.getdbt.com/best-practices/how-we-structure/staging"
      },
      {
        "title": "Handling Special Values in Data Models",
        "description": "Techniques for managing special values like 'UNKNOWN' or 'GUEST'",
        "link": "https://docs.getdbt.com/blog/handling-special-values"
      }
    ]
  }
}
```

### Example 2: Fixing a Performance Issue in a Large Fact Table
Input: Slow-running incremental model fct_transactions taking over 2 hours to build

Output:
```json
{
  "issue_summary": {
    "model_name": "fct_transactions",
    "issue_type": "performance",
    "severity": "high",
    "description": "The fct_transactions incremental model is taking over 2 hours to build, causing pipeline delays",
    "impact": "Extended build times delay data availability, increase compute costs, and risk pipeline timeouts"
  },
  "root_cause_analysis": {
    "identified_cause": "The incremental predicate is inefficient, causing full table scans instead of using available indexes",
    "affected_code": "The incremental materialization config and WHERE clause in the fct_transactions model",
    "contributing_factors": [
      "Using updated_at > (select max(updated_at) from {{ this }}) which prevents index usage",
      "Lack of partitioning on the large fact table",
      "Rapidly growing data volume (now over 500M rows)",
      "Multiple complex joins without proper filtering"
    ],
    "detection_method": "Query plan analysis showed full table scans and lack of index usage in the incremental predicate"
  },
  "proposed_fixes": [
    {
      "fix_id": "fix_transaction_perf_001",
      "fix_type": "code_change",
      "description": "Optimize the incremental predicate to use a static timestamp and enable index usage",
      "current_code": "{{ config(\n  materialized='incremental',\n  unique_key='transaction_id'\n) }}\n\nSELECT\n  /* columns */\nFROM stg_transactions t\nJOIN stg_accounts a ON t.account_id = a.account_id\nJOIN stg_products p ON t.product_id = p.product_id\n{% if is_incremental() %}\nWHERE t.updated_at > (SELECT MAX(updated_at) FROM {{ this }})\n{% endif %}",
      "suggested_code": "{{ config(\n  materialized='incremental',\n  unique_key='transaction_id',\n  incremental_strategy='delete+insert'\n) }}\n\n{% if is_incremental() %}\n  {% set max_loaded_at = \"(SELECT MAX(updated_at) FROM \" ~ this ~ \")\" %}\n  {% set max_loaded_at_value = run_query(max_loaded_at).columns[0][0] %}\n{% endif %}\n\nSELECT\n  /* columns */\nFROM stg_transactions t\nJOIN stg_accounts a ON t.account_id = a.account_id\nJOIN stg_products p ON t.product_id = p.product_id\n{% if is_incremental() %}\nWHERE t.updated_at > '{{ max_loaded_at_value }}'\n{% endif %}",
      "file_path": "models/marts/core/fct_transactions.sql",
      "confidence": 0.9,
      "expected_outcome": "The incremental build will use a static timestamp value that can leverage indexes, significantly reducing build time",
      "potential_side_effects": [
        "The first run after this change will need to be a full refresh",
        "The delete+insert strategy may cause momentary data unavailability during builds"
      ]
    },
    {
      "fix_id": "fix_transaction_perf_002",
      "fix_type": "code_change",
      "description": "Add date-based partitioning to improve query performance",
      "current_code": "{{ config(\n  materialized='incremental',\n  unique_key='transaction_id'\n) }}",
      "suggested_code": "{{ config(\n  materialized='incremental',\n  unique_key='transaction_id',\n  incremental_strategy='delete+insert',\n  partition_by={\n    'field': 'transaction_date',\n    'data_type': 'date',\n    'granularity': 'day'\n  }\n) }}",
      "file_path": "models/marts/core/fct_transactions.sql",
      "confidence": 0.85,
      "expected_outcome": "The table will be partitioned by transaction_date, allowing for more efficient queries and incremental builds",
      "potential_side_effects": [
        "Requires a full refresh to implement partitioning",
        "May require database-specific syntax adjustments"
      ]
    },
    {
      "fix_id": "fix_transaction_perf_003",
      "fix_type": "code_change",
      "description": "Optimize joins by filtering early in CTEs",
      "current_code": "SELECT\n  /* columns */\nFROM stg_transactions t\nJOIN stg_accounts a ON t.account_id = a.account_id\nJOIN stg_products p ON t.product_id = p.product_id\n{% if is_incremental() %}\nWHERE t.updated_at > (SELECT MAX(updated_at) FROM {{ this }})\n{% endif %}",
      "suggested_code": "{% if is_incremental() %}\n  {% set max_loaded_at = \"(SELECT MAX(updated_at) FROM \" ~ this ~ \")\" %}\n  {% set max_loaded_at_value = run_query(max_loaded_at).columns[0][0] %}\n{% endif %}\n\nWITH filtered_transactions AS (\n  SELECT * FROM stg_transactions\n  {% if is_incremental() %}\n  WHERE updated_at > '{{ max_loaded_at_value }}'\n  {% endif %}\n),\n\nfiltered_accounts AS (\n  SELECT * FROM stg_accounts\n  WHERE account_id IN (SELECT DISTINCT account_id FROM filtered_transactions)\n),\n\nfiltered_products AS (\n  SELECT * FROM stg_products\n  WHERE product_id IN (SELECT DISTINCT product_id FROM filtered_transactions)\n)\n\nSELECT\n  /* columns */\nFROM filtered_transactions t\nJOIN filtered_accounts a ON t.account_id = a.account_id\nJOIN filtered_products p ON t.product_id = p.product_id",
      "file_path": "models/marts/core/fct_transactions.sql",
      "confidence": 0.8,
      "expected_outcome": "Joins will be more efficient by filtering dimension tables to only the relevant rows before joining",
      "potential_side_effects": [
        "More complex SQL that may be harder to maintain",
        "Potential for different query plans depending on data distribution"
      ]
    }
  ],
  "implementation_plan": {
    "steps": [
      {
        "step_number": 1,
        "description": "Implement the static timestamp fix",
        "action": "Update the fct_transactions.sql file with the optimized incremental predicate",
        "verification": "Review the SQL to ensure the static timestamp is correctly implemented"
      },
      {
        "step_number": 2,
        "description": "Add partitioning configuration",
        "action": "Update the model configuration to include partition_by",
        "verification": "Ensure the partition configuration is appropriate for your database"
      },
      {
        "step_number": 3,
        "description": "Optimize join structure",
        "action": "Implement the CTE-based filtering approach",
        "verification": "Review the SQL to ensure the filtering logic is correct"
      },
      {
        "step_number": 4,
        "description": "Test in development",
        "action": "Run a full refresh in the development environment",
        "verification": "Verify the model builds successfully and check the execution time"
      },
      {
        "step_number": 5,
        "description": "Test incremental build",
        "action": "Make a small change and run an incremental build",
        "verification": "Verify the incremental build is faster and uses indexes properly"
      },
      {
        "step_number": 6,
        "description": "Deploy to production",
        "action": "Deploy the changes to production during a maintenance window",
        "verification": "Monitor the production build to ensure it completes successfully and performs as expected"
      }
    ],
    "testing_approach": {
      "test_strategy": "Test performance improvements in development before deploying to production",
      "verification_queries": [
        {
          "purpose": "Verify data integrity after optimization",
          "query": "SELECT COUNT(*) FROM fct_transactions_new MINUS SELECT COUNT(*) FROM fct_transactions",
          "expected_result": "0 (no difference in row counts)"
        },
        {
          "purpose": "Check execution plan for index usage",
          "query": "EXPLAIN ANALYZE SELECT * FROM stg_transactions WHERE updated_at > '2025-06-01'",
          "expected_result": "Should show index usage on updated_at column"
        },
        {
          "purpose": "Verify partitioning",
          "query": "-- Database-specific query to check partitioning",
          "expected_result": "Should show partitions by transaction_date"
        }
      ]
    },
    "rollback_plan": {
      "rollback_steps": [
        "Keep the original model as fct_transactions_old",
        "If issues arise, revert to the original model file",
        "Run a full refresh to rebuild the model with the original code"
      ]
    }
  },
  "alternative_approaches": [
    {
      "approach": "Implement a time-window based incremental strategy",
      "pros": ["Limits the scope of each incremental run", "Can be more predictable", "Works well with date-based data"],
      "cons": ["May miss updates to historical data", "Requires additional tracking of processed windows", "More complex implementation"],
      "implementation": "Process data in fixed time windows (e.g., one day at a time) rather than based on updated_at"
    },
    {
      "approach": "Switch to a merge materialization strategy",
      "pros": ["More efficient for updates to existing rows", "Maintains data availability during builds", "Often better for slowly changing dimensions"],
      "cons": ["May not be more efficient for this use case", "Not supported in all databases", "Can be more complex to debug"],
      "implementation": "Change incremental_strategy to 'merge' and adjust the unique key and merge condition"
    },
    {
      "approach": "Implement table partitioning at the database level",
      "pros": ["May offer better performance than dbt-managed partitioning", "More control over partition management", "Database-native optimizations"],
      "cons": ["Requires database administrator involvement", "Less portable across databases", "More complex to manage"],
      "implementation": "Work with a DBA to implement native table partitioning for the fct_transactions table"
    }
  ],
  "best_practices": [
    {
      "practice": "Use static values in incremental predicates",
      "rationale": "Allows the query optimizer to use indexes effectively",
      "implementation": "Extract the comparison value before the main query and use it as a literal"
    },
    {
      "practice": "Consider partitioning for large fact tables",
      "rationale": "Improves query performance and maintenance operations",
      "implementation": "Use dbt's partition_by configuration or database-native partitioning"
    },
    {
      "practice": "Filter early in the query",
      "rationale": "Reduces the amount of data processed in joins",
      "implementation": "Use CTEs to filter tables before joining them"
    },
    {
      "practice": "Monitor model performance over time",
      "rationale": "Catch performance degradation early",
      "implementation": "Track and alert on build times for critical models"
    }
  ],
  "learning_opportunities": {
    "patterns_to_avoid": [
      "Subqueries in WHERE clauses that prevent index usage",
      "Joining large tables without appropriate filtering",
      "Neglecting to consider query plan implications",
      "Ignoring the impact of data volume growth on performance"
    ],
    "recommended_patterns": [
      "Static values in predicates to enable index usage",
      "Appropriate partitioning for large tables",
      "Early filtering before joins",
      "Regular performance monitoring and optimization"
    ],
    "educational_resources": [
      {
        "title": "dbt Incremental Models Best Practices",
        "description": "Guidelines for efficient incremental model implementation",
        "link": "https://docs.getdbt.com/docs/building-a-dbt-project/building-models/incremental-models"
      },
      {
        "title": "Query Optimization Techniques",
        "description": "Common techniques for optimizing SQL queries",
        "link": "https://docs.getdbt.com/blog/sql-query-optimization"
      },
      {
        "title": "Table Partitioning Strategies",
        "description": "Different approaches to table partitioning and their benefits",
        "link": "https://docs.getdbt.com/blog/partitioning-strategies"
      }
    ]
  }
}
```

### Example 3: Fixing a Referential Integrity Issue
Input: relationships test failure between fct_orders.product_id and dim_products.product_id

Output:
```json
{
  "issue_summary": {
    "model_name": "fct_orders",
    "issue_type": "test_failure",
    "severity": "high",
    "description": "relationships test failed: 12 records in fct_orders have product_id values that do not exist in dim_products",
    "impact": "Broken referential integrity affects joins and may cause missing data in reports and dashboards"
  },
  "root_cause_analysis": {
    "identified_cause": "New products are being added to the orders system but not being properly synchronized to the product dimension table",
    "affected_code": "The dim_products model is missing logic to capture all products referenced in orders",
    "contributing_factors": [
      "No validation in the ETL process to ensure products exist before orders are created",
      "Separate data sources for products and orders with different update frequencies",
      "Recent addition of new product lines not yet added to the product catalog"
    ],
    "detection_method": "Analysis of failing records showed they all had recently added product IDs not present in the product dimension"
  },
  "proposed_fixes": [
    {
      "fix_id": "fix_product_refs_001",
      "fix_type": "code_change",
      "description": "Update dim_products to include products referenced in orders even if they don't exist in the product catalog",
      "current_code": "SELECT\n  product_id,\n  product_name,\n  category,\n  price,\n  created_at,\n  updated_at\nFROM stg_product_catalog",
      "suggested_code": "WITH product_catalog AS (\n  SELECT\n    product_id,\n    product_name,\n    category,\n    price,\n    created_at,\n    updated_at\n  FROM stg_product_catalog\n),\n\nproducts_from_orders AS (\n  SELECT DISTINCT\n    product_id,\n    'Unknown' AS product_name,\n    'Uncategorized' AS category,\n    NULL AS price,\n    MIN(created_at) AS created_at,\n    CURRENT_TIMESTAMP AS updated_at\n  FROM stg_orders\n  WHERE product_id IS NOT NULL\n  AND product_id NOT IN (SELECT product_id FROM product_catalog)\n  GROUP BY product_id\n)\n\nSELECT * FROM product_catalog\nUNION ALL\nSELECT * FROM products_from_orders",
      "file_path": "models/marts/core/dim_products.sql",
      "confidence": 0.9,
      "expected_outcome": "All products referenced in orders will exist in the dimension table, even if they're not in the product catalog",
      "potential_side_effects": [
        "Some products will have placeholder values for name, category, etc.",
        "May mask underlying data quality issues in the product catalog"
      ]
    },
    {
      "fix_id": "fix_product_refs_002",
      "fix_type": "code_change",
      "description": "Add data quality tests to alert on unknown products",
      "current_code": "# No existing test for unknown products",
      "suggested_code": "version: 2\n\nmodels:\n  - name: dim_products\n    columns:\n      - name: product_name\n        tests:\n          - not_equal_to:\n              value: \"'Unknown'\"\n              config:\n                severity: warn\n                where: \"created_at > CURRENT_DATE - 7\"",
      "file_path": "models/marts/core/schema.yml",
      "confidence": 0.85,
      "expected_outcome": "Tests will warn when new unknown products are detected, prompting investigation",
      "potential_side_effects": [
        "Will generate warnings in the test output that need to be monitored"
      ]
    },
    {
      "fix_id": "fix_product_refs_003",
      "fix_type": "code_change",
      "description": "Add a source freshness check to ensure product catalog is up to date",
      "current_code": "version: 2\n\nsources:\n  - name: product_catalog\n    tables:\n      - name: products",
      "suggested_code": "version: 2\n\nsources:\n  - name: product_catalog\n    tables:\n      - name: products\n        freshness:\n          warn_after: {count: 1, period: day}\n          error_after: {count: 3, period: day}",
      "file_path": "models/staging/sources.yml",
      "confidence": 0.8,
      "expected_outcome": "Source freshness tests will alert when the product catalog data is stale, prompting investigation",
      "potential_side_effects": [
        "May cause test failures if the source system has legitimate delays in updates",
        "Requires monitoring and tuning of freshness thresholds"
      ]
    }
  ],
  "implementation_plan": {
    "steps": [
      {
        "step_number": 1,
        "description": "Update dim_products model",
        "action": "Modify dim_products.sql to include products referenced in orders",
        "verification": "Run 'dbt run --select dim_products' and verify that all product IDs from orders are now present"
      },
      {
        "step_number": 2,
        "description": "Add data quality tests",
        "action": "Update schema.yml to add tests for unknown products",
        "verification": "Run 'dbt test --select dim_products' and verify that the tests run correctly"
      },
      {
        "step_number": 3,
        "description": "Add source freshness check",
        "action": "Update sources.yml to add freshness checks for the product catalog",
        "verification": "Run 'dbt source freshness' and verify that the checks run correctly"
      },
      {
        "step_number": 4,
        "description": "Rebuild and test fct_orders",
        "action": "Run 'dbt run --select fct_orders' followed by 'dbt test --select fct_orders'",
        "verification": "Verify that the relationships test now passes"
      }
    ],
    "testing_approach": {
      "test_strategy": "Run targeted tests to verify referential integrity and data quality",
      "verification_queries": [
        {
          "purpose": "Verify all products in orders exist in dim_products",
          "query": "SELECT COUNT(*) FROM fct_orders o LEFT JOIN dim_products p ON o.product_id = p.product_id WHERE p.product_id IS NULL",
          "expected_result": "0"
        },
        {
          "purpose": "Identify unknown products",
          "query": "SELECT COUNT(*) FROM dim_products WHERE product_name = 'Unknown'",
          "expected_result": "Should match the count of products missing from the catalog"
        },
        {
          "purpose": "Verify source freshness",
          "query": "-- Run dbt source freshness",
          "expected_result": "Source freshness checks should pass"
        }
      ]
    },
    "rollback_plan": {
      "rollback_steps": [
        "Revert changes to dim_products.sql",
        "Revert changes to schema.yml",
        "Revert changes to sources.yml",
        "Run 'dbt run --select dim_products fct_orders' to rebuild the models"
      ]
    }
  },
  "alternative_approaches": [
    {
      "approach": "Filter out orders with invalid product IDs",
      "pros": ["Simpler implementation", "Maintains clean product dimension", "Avoids placeholder values"],
      "cons": ["Loses order data", "Creates discrepancies in order totals", "Doesn't address the root issue"],
      "implementation": "Add a WHERE EXISTS (SELECT 1 FROM dim_products p WHERE p.product_id = o.product_id) filter to the fct_orders model"
    },
    {
      "approach": "Implement a data quality alerting system",
      "pros": ["Addresses the root cause", "Proactive rather than reactive", "Prevents issues before they reach the data warehouse"],
      "cons": ["More complex implementation", "Requires coordination with source system owners", "Takes longer to implement"],
      "implementation": "Set up a process to validate new products in the source system and alert when products are missing from the catalog"
    },
    {
      "approach": "Create a separate fact table for orders with invalid products",
      "pros": ["Maintains clean data in the main fact table", "Preserves all order data", "Facilitates investigation of data issues"],
      "cons": ["More complex to maintain", "Requires changes to downstream models", "Complicates aggregations across all orders"],
      "implementation": "Split orders into fct_orders and fct_orders_invalid based on product ID validity"
    }
  ],
  "best_practices": [
    {
      "practice": "Implement resilient dimension modeling",
      "rationale": "Fact tables should be able to reference dimensions even when source data is imperfect",
      "implementation": "Include logic to handle unknown or missing dimension members"
    },
    {
      "practice": "Add data quality monitoring",
      "rationale": "Detect and alert on data quality issues before they cause downstream problems",
      "implementation": "Use tests with warning severity to flag potential issues without failing the pipeline"
    },
    {
      "practice": "Document special values and their meaning",
      "rationale": "Ensure data consumers understand the meaning of placeholder values",
      "implementation": "Add documentation in the schema.yml file explaining the meaning of 'Unknown' product names"
    },
    {
      "practice": "Monitor source data freshness",
      "rationale": "Ensure dimension tables are updated in a timely manner",
      "implementation": "Use dbt source freshness checks to monitor update frequency"
    }
  ],
  "learning_opportunities": {
    "patterns_to_avoid": [
      "Strict referential integrity without handling for missing values",
      "Assuming perfect synchronization between source systems",
      "Lack of monitoring for data quality issues",
      "Missing documentation for special values and edge cases"
    ],
    "recommended_patterns": [
      "Resilient dimension modeling with unknown member handling",
      "Comprehensive data quality testing",
      "Source freshness monitoring",
      "Clear documentation of special values and their meaning"
    ],
    "educational_resources": [
      {
        "title": "Kimball Dimensional Modeling Techniques",
        "description": "Guidelines for handling unknown and missing dimension members",
        "link": "https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/"
      },
      {
        "title": "dbt Testing Best Practices",
        "description": "Approaches to comprehensive data quality testing",
        "link": "https://docs.getdbt.com/best-practices/testing"
      },
      {
        "title": "Source Freshness Monitoring",
        "description": "How to implement and tune source freshness checks",
        "link": "https://docs.getdbt.com/docs/building-a-dbt-project/using-sources"
      }
    ]
  }
}
```

## Safety Guardrails
- Always prioritize data integrity and quality over performance
- Recommend thorough testing before implementing fixes in production
- Consider business impact when prioritizing fixes
- Suggest backup or snapshot steps before implementing changes
- Consider the impact on downstream processes and reports
- Recommend appropriate documentation updates
- Suggest monitoring for recurrence of issues
- Always provide a rollback plan
- Consider database-specific factors when suggesting SQL changes
- Recommend validation steps to ensure fixes work as expected
