# Version: v0.1.0
# Last-Updated: 2025-06-16
# Owner: analytics-platform
# Description: Summarise dbt test outcomes

# Test Results Prompt

## Purpose
This prompt helps analyze and interpret dbt test results, providing clear insights into test failures, data quality issues, and recommended actions. It transforms raw test outputs into structured, actionable information.

## Usage
Use this prompt after running dbt tests to understand test results, identify issues, and determine appropriate next steps.

## Input Context
- dbt test output (logs or JSON artifacts)
- Information about the models being tested
- Test metadata and descriptions
- Project context and business rules
- Historical test performance

## Output Format
```json
{
  "test_summary": {
    "total_tests": 42,
    "passed_tests": 40,
    "failed_tests": 2,
    "error_tests": 0,
    "skipped_tests": 0,
    "execution_time": "45.2 seconds",
    "overall_status": "failed|passed|error",
    "summary": "Brief summary of test results"
  },
  "failed_tests": [
    {
      "test_name": "Name of the failed test",
      "test_type": "singular|generic|data|schema",
      "model_name": "Model associated with the test",
      "column_name": "Column associated with the test (if applicable)",
      "failure_count": 15,
      "severity": "error|warn",
      "error_message": "Error message from the test",
      "failure_sql": "SQL query that produced the failure",
      "failure_examples": [
        {
          "primary_key": "Identifier for the failing record",
          "values": {
            "column1": "value1",
            "column2": "value2"
          }
        }
      ],
      "impact_assessment": {
        "business_impact": "Description of business impact",
        "data_quality_impact": "Description of data quality impact",
        "affected_downstream_models": ["model1", "model2"],
        "affected_reports": ["report1", "report2"]
      }
    }
  ],
  "test_patterns": [
    {
      "pattern_type": "Type of pattern identified",
      "description": "Description of the pattern",
      "affected_models": ["model1", "model2"],
      "potential_cause": "Potential cause of the pattern",
      "recommendation": "Recommendation to address the pattern"
    }
  ],
  "recommendations": {
    "immediate_actions": [
      {
        "action": "Action to take immediately",
        "purpose": "Purpose of this action",
        "implementation": "How to implement this action"
      }
    ],
    "investigation_steps": [
      {
        "step": "Step to investigate issues",
        "purpose": "Purpose of this step",
        "query": "Query to help with investigation"
      }
    ],
    "long_term_improvements": [
      {
        "improvement": "Long-term improvement to consider",
        "rationale": "Why this improvement is valuable",
        "implementation_approach": "How to implement this improvement"
      }
    ]
  },
  "historical_context": {
    "test_trend": "improving|stable|degrading",
    "recurring_issues": [
      {
        "issue": "Description of recurring issue",
        "frequency": "How often this issue occurs",
        "last_occurrence": "When this issue last occurred",
        "resolution_status": "Status of resolution efforts"
      }
    ],
    "comparison_to_baseline": "Description of how current results compare to baseline"
  },
  "next_steps": {
    "suggested_workflow": [
      {
        "step": "Next step in the workflow",
        "rationale": "Why this step is recommended",
        "details": "Details about how to perform this step"
      }
    ],
    "decision_points": [
      {
        "decision": "Decision that needs to be made",
        "options": [
          {
            "option": "Option 1",
            "pros": ["Pro 1", "Pro 2"],
            "cons": ["Con 1", "Con 2"]
          }
        ],
        "recommendation": "Recommended option"
      }
    ]
  }
}
```

## Instructions

1. **Parse test results**
   - Extract key information from dbt test output
   - Identify passed, failed, and errored tests
   - Calculate summary statistics
   - Determine overall test status

2. **Analyze failed tests**
   - Categorize failures by type and severity
   - Extract error messages and failure SQL
   - Identify affected models and columns
   - Gather examples of failing records

3. **Assess impact**
   - Determine business impact of failures
   - Identify affected downstream models and reports
   - Evaluate data quality implications
   - Consider operational impacts

4. **Identify patterns**
   - Look for common themes across failures
   - Detect recurring issues
   - Identify potential root causes
   - Recognize patterns across models or test types

5. **Develop recommendations**
   - Suggest immediate actions to address failures
   - Outline investigation steps for deeper analysis
   - Propose long-term improvements
   - Prioritize recommendations based on impact

6. **Provide historical context**
   - Compare results to previous test runs
   - Identify trends in test performance
   - Highlight recurring issues
   - Assess progress on known issues

7. **Outline next steps**
   - Suggest a clear workflow for addressing issues
   - Identify decision points and options
   - Recommend appropriate next actions
   - Consider project context and priorities

## Examples

### Example 1: Multiple Test Failures in a Fact Table
Input: dbt test output showing 3 failures in the fct_orders model

Output:
```json
{
  "test_summary": {
    "total_tests": 35,
    "passed_tests": 32,
    "failed_tests": 3,
    "error_tests": 0,
    "skipped_tests": 0,
    "execution_time": "28.7 seconds",
    "overall_status": "failed",
    "summary": "3 tests failed on the fct_orders model, indicating potential issues with order data integrity"
  },
  "failed_tests": [
    {
      "test_name": "not_null_fct_orders_customer_id",
      "test_type": "generic",
      "model_name": "fct_orders",
      "column_name": "customer_id",
      "failure_count": 24,
      "severity": "error",
      "error_message": "not_null test failed on fct_orders.customer_id: 24 records with null values found",
      "failure_sql": "select * from fct_orders where customer_id is null",
      "failure_examples": [
        {
          "primary_key": "ORD-10045",
          "values": {
            "order_id": "ORD-10045",
            "customer_id": null,
            "order_date": "2025-06-10",
            "order_amount": 129.99
          }
        },
        {
          "primary_key": "ORD-10046",
          "values": {
            "order_id": "ORD-10046",
            "customer_id": null,
            "order_date": "2025-06-10",
            "order_amount": 79.95
          }
        }
      ],
      "impact_assessment": {
        "business_impact": "Orders without customer IDs cannot be attributed to customers, affecting customer analytics and personalization",
        "data_quality_impact": "Missing customer relationships break referential integrity and may cause joins to fail",
        "affected_downstream_models": ["fct_customer_lifetime_value", "rpt_customer_orders"],
        "affected_reports": ["Customer Segmentation Dashboard", "Sales Attribution Report"]
      }
    },
    {
      "test_name": "positive_value_fct_orders_order_amount",
      "test_type": "singular",
      "model_name": "fct_orders",
      "column_name": "order_amount",
      "failure_count": 3,
      "severity": "error",
      "error_message": "positive_value test failed on fct_orders.order_amount: 3 records with non-positive values found",
      "failure_sql": "select * from fct_orders where order_amount <= 0",
      "failure_examples": [
        {
          "primary_key": "ORD-10078",
          "values": {
            "order_id": "ORD-10078",
            "customer_id": "CUST-5582",
            "order_date": "2025-06-11",
            "order_amount": -45.00
          }
        }
      ],
      "impact_assessment": {
        "business_impact": "Negative order amounts may indicate refunds being incorrectly processed as orders",
        "data_quality_impact": "Negative values will skew aggregations and metrics in reports",
        "affected_downstream_models": ["fct_daily_sales", "rpt_sales_by_region"],
        "affected_reports": ["Executive Sales Dashboard", "Monthly Revenue Report"]
      }
    },
    {
      "test_name": "relationships_fct_orders_product_id__product_id__ref_dim_products_",
      "test_type": "generic",
      "model_name": "fct_orders",
      "column_name": "product_id",
      "failure_count": 12,
      "severity": "error",
      "error_message": "relationships test failed: 12 records in fct_orders have product_id values that do not exist in dim_products",
      "failure_sql": "select fct_orders.product_id from fct_orders left join dim_products on fct_orders.product_id = dim_products.product_id where dim_products.product_id is null",
      "failure_examples": [
        {
          "primary_key": "ORD-10052-PROD-885",
          "values": {
            "order_id": "ORD-10052",
            "product_id": "PROD-885",
            "quantity": 1
          }
        }
      ],
      "impact_assessment": {
        "business_impact": "Orders referencing non-existent products cannot be properly categorized or analyzed",
        "data_quality_impact": "Broken referential integrity affects joins and may cause missing data in reports",
        "affected_downstream_models": ["fct_product_sales", "rpt_category_performance"],
        "affected_reports": ["Product Performance Dashboard", "Inventory Planning Report"]
      }
    }
  ],
  "test_patterns": [
    {
      "pattern_type": "Data Integration Issue",
      "description": "Multiple integrity issues suggest problems with the order data integration process",
      "affected_models": ["fct_orders"],
      "potential_cause": "Recent changes to the order processing system may not be properly reflected in the ETL process",
      "recommendation": "Review the order data integration pipeline, particularly focusing on customer ID assignment and product validation"
    },
    {
      "pattern_type": "Missing Data Validation",
      "description": "Null customer IDs and invalid product IDs indicate insufficient validation in upstream processes",
      "affected_models": ["fct_orders", "stg_orders"],
      "potential_cause": "Lack of validation checks in the staging models or source data",
      "recommendation": "Add pre-load validation checks and implement error handling for invalid records"
    },
    {
      "pattern_type": "Business Logic Issue",
      "description": "Negative order amounts suggest confusion between orders and refunds",
      "affected_models": ["fct_orders"],
      "potential_cause": "Refund transactions may be incorrectly categorized as orders",
      "recommendation": "Review business logic for handling refunds and ensure they are properly categorized"
    }
  ],
  "recommendations": {
    "immediate_actions": [
      {
        "action": "Investigate null customer IDs",
        "purpose": "Determine the source of orders without customer IDs",
        "implementation": "Query source systems to identify when and how these orders were created"
      },
      {
        "action": "Fix negative order amounts",
        "purpose": "Correct the sign of order amounts or recategorize as refunds",
        "implementation": "Review the 3 affected orders and update the logic to properly handle refunds"
      },
      {
        "action": "Address missing product IDs",
        "purpose": "Ensure all referenced products exist in the product dimension",
        "implementation": "Check if products were recently removed or if new products are missing from the dimension table"
      }
    ],
    "investigation_steps": [
      {
        "step": "Analyze order source systems",
        "purpose": "Determine if specific order sources are causing the issues",
        "query": "SELECT source_system, COUNT(*) FROM stg_orders WHERE customer_id IS NULL GROUP BY source_system"
      },
      {
        "step": "Check for recent changes",
        "purpose": "Identify if recent code or system changes contributed to the issues",
        "query": "Review git history and deployment logs for changes to order processing in the last week"
      },
      {
        "step": "Validate dimension tables",
        "purpose": "Ensure dimension tables are being properly updated",
        "query": "SELECT MAX(updated_at) FROM dim_products"
      }
    ],
    "long_term_improvements": [
      {
        "improvement": "Implement data quality monitoring",
        "rationale": "Proactively detect and alert on data quality issues",
        "implementation_approach": "Set up automated monitoring for key metrics and data quality dimensions"
      },
      {
        "improvement": "Enhance pre-load validation",
        "rationale": "Catch issues before they enter the data warehouse",
        "implementation_approach": "Add validation checks in staging models and implement error handling"
      },
      {
        "improvement": "Improve documentation",
        "rationale": "Ensure clear understanding of business rules and data expectations",
        "implementation_approach": "Document expected values, relationships, and handling of edge cases"
      }
    ]
  },
  "historical_context": {
    "test_trend": "degrading",
    "recurring_issues": [
      {
        "issue": "Missing customer IDs",
        "frequency": "Increasing over the past week",
        "last_occurrence": "Yesterday's run had 15 failures",
        "resolution_status": "Unresolved, number of failures increasing"
      },
      {
        "issue": "Product relationship failures",
        "frequency": "First occurrence",
        "last_occurrence": "N/A",
        "resolution_status": "New issue"
      }
    ],
    "comparison_to_baseline": "Test failures have increased from 0 to 3 in the past week, with the customer_id not_null test showing a concerning trend of increasing failures"
  },
  "next_steps": {
    "suggested_workflow": [
      {
        "step": "Fix null customer IDs",
        "rationale": "Highest impact issue affecting customer analytics",
        "details": "Investigate the source of null customer IDs and implement a fix in the staging model"
      },
      {
        "step": "Address missing product references",
        "rationale": "Critical for maintaining data integrity",
        "details": "Update dim_products to include missing products or correct invalid references"
      },
      {
        "step": "Correct negative order amounts",
        "rationale": "Important for accurate financial reporting",
        "details": "Implement logic to properly handle refunds vs. orders"
      },
      {
        "step": "Re-run tests",
        "rationale": "Verify that fixes resolved the issues",
        "details": "Run 'dbt test --select fct_orders' after implementing fixes"
      }
    ],
    "decision_points": [
      {
        "decision": "How to handle orders with null customer IDs",
        "options": [
          {
            "option": "Assign to an 'unknown' customer",
            "pros": ["Maintains referential integrity", "Simple to implement"],
            "cons": ["Loses potential customer attribution", "Masks the root issue"]
          },
          {
            "option": "Exclude from customer analytics models",
            "pros": ["Prevents skewing customer metrics", "More accurate customer reporting"],
            "cons": ["Creates discrepancies between order totals and customer totals", "More complex implementation"]
          },
          {
            "option": "Fix at source",
            "pros": ["Addresses root cause", "Improves data quality at origin"],
            "cons": ["May take longer to implement", "Requires coordination with source system owners"]
          }
        ],
        "recommendation": "Fix at source while temporarily assigning to an 'unknown' customer for current reporting needs"
      }
    ]
  }
}
```

### Example 2: Single Critical Test Failure
Input: dbt test output showing a critical uniqueness test failure in a dimension table

Output:
```json
{
  "test_summary": {
    "total_tests": 28,
    "passed_tests": 27,
    "failed_tests": 1,
    "error_tests": 0,
    "skipped_tests": 0,
    "execution_time": "12.3 seconds",
    "overall_status": "failed",
    "summary": "Critical uniqueness test failure in dim_customers, indicating potential duplicate customer records"
  },
  "failed_tests": [
    {
      "test_name": "unique_dim_customers_customer_id",
      "test_type": "generic",
      "model_name": "dim_customers",
      "column_name": "customer_id",
      "failure_count": 15,
      "severity": "error",
      "error_message": "unique test failed on dim_customers.customer_id: 15 duplicate customer_id values found",
      "failure_sql": "select customer_id, count(*) from dim_customers group by customer_id having count(*) > 1",
      "failure_examples": [
        {
          "primary_key": "CUST-1042",
          "values": {
            "customer_id": "CUST-1042",
            "count": 2
          }
        },
        {
          "primary_key": "CUST-1043",
          "values": {
            "customer_id": "CUST-1043",
            "count": 2
          }
        }
      ],
      "impact_assessment": {
        "business_impact": "Duplicate customer records can lead to incorrect customer counts, misattributed orders, and inaccurate customer metrics",
        "data_quality_impact": "Violates primary key constraint and affects referential integrity across the data model",
        "affected_downstream_models": ["fct_orders", "fct_customer_interactions", "dim_customer_segments"],
        "affected_reports": ["Customer 360 Dashboard", "Marketing Segmentation Reports", "Customer Lifetime Value Analysis"]
      }
    }
  ],
  "test_patterns": [
    {
      "pattern_type": "Data Integration Issue",
      "description": "Duplicate customer IDs suggest a problem with the customer data integration process",
      "affected_models": ["dim_customers", "stg_customers"],
      "potential_cause": "Recent merge of customer data from multiple systems may have introduced duplicates",
      "recommendation": "Review the customer data integration process and implement deduplication logic"
    },
    {
      "pattern_type": "Primary Key Violation",
      "description": "Customer ID should be a unique identifier but contains duplicates",
      "affected_models": ["dim_customers"],
      "potential_cause": "Missing deduplication logic or improper handling of updates vs. inserts",
      "recommendation": "Implement proper SCD Type 2 logic or add deduplication step in the model"
    }
  ],
  "recommendations": {
    "immediate_actions": [
      {
        "action": "Identify duplicate patterns",
        "purpose": "Understand the nature of the duplicates to inform the fix",
        "implementation": "Query dim_customers to examine the duplicate records and identify patterns"
      },
      {
        "action": "Implement temporary deduplication",
        "purpose": "Quickly resolve the issue for downstream consumers",
        "implementation": "Add a ROW_NUMBER() window function to the model to select only one record per customer_id"
      }
    ],
    "investigation_steps": [
      {
        "step": "Examine duplicate records",
        "purpose": "Identify differences between duplicate records",
        "query": "SELECT * FROM dim_customers WHERE customer_id IN (SELECT customer_id FROM dim_customers GROUP BY customer_id HAVING COUNT(*) > 1) ORDER BY customer_id"
      },
      {
        "step": "Check source data",
        "purpose": "Determine if duplicates exist in source or are introduced during transformation",
        "query": "SELECT customer_id, COUNT(*) FROM stg_customers GROUP BY customer_id HAVING COUNT(*) > 1"
      },
      {
        "step": "Review recent changes",
        "purpose": "Identify if recent code changes contributed to the issue",
        "query": "Review git history for changes to dim_customers.sql and related models"
      }
    ],
    "long_term_improvements": [
      {
        "improvement": "Implement proper SCD Type 2 logic",
        "rationale": "Handle customer updates correctly while maintaining history",
        "implementation_approach": "Use dbt_utils.surrogate_key and effective dates to manage customer versions"
      },
      {
        "improvement": "Add data quality tests",
        "rationale": "Catch similar issues earlier",
        "implementation_approach": "Add tests for other potential duplicate scenarios and key business rules"
      },
      {
        "improvement": "Enhance monitoring",
        "rationale": "Proactively detect data quality issues",
        "implementation_approach": "Set up alerts for sudden changes in dimension table row counts or duplicate key violations"
      }
    ]
  },
  "historical_context": {
    "test_trend": "degrading",
    "recurring_issues": [
      {
        "issue": "Duplicate customer IDs",
        "frequency": "First occurrence at this scale",
        "last_occurrence": "Small number of duplicates (2-3) observed last month",
        "resolution_status": "Previous small-scale issue was resolved but has recurred with larger impact"
      }
    ],
    "comparison_to_baseline": "This is a significant degradation from the baseline. Customer ID uniqueness has been consistently maintained until this run."
  },
  "next_steps": {
    "suggested_workflow": [
      {
        "step": "Implement temporary fix",
        "rationale": "Quickly resolve the issue for downstream consumers",
        "details": "Add ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY updated_at DESC) and filter for row_num = 1"
      },
      {
        "step": "Investigate root cause",
        "rationale": "Prevent recurrence by addressing the underlying issue",
        "details": "Analyze source data and transformation logic to identify how duplicates are being introduced"
      },
      {
        "step": "Implement permanent solution",
        "rationale": "Ensure long-term data quality",
        "details": "Based on root cause analysis, implement proper deduplication or SCD Type 2 logic"
      },
      {
        "step": "Add preventive tests",
        "rationale": "Catch similar issues early",
        "details": "Add tests to verify uniqueness at various stages of the pipeline"
      }
    ],
    "decision_points": [
      {
        "decision": "How to handle existing duplicates",
        "options": [
          {
            "option": "Keep most recent record",
            "pros": ["Simple to implement", "Clear logic", "Preserves latest data"],
            "cons": ["May lose historical information", "Assumes latest is most accurate"]
          },
          {
            "option": "Merge duplicate records",
            "pros": ["Preserves all information", "More complete customer view"],
            "cons": ["More complex to implement", "Requires rules for resolving conflicts"]
          },
          {
            "option": "Implement full SCD Type 2",
            "pros": ["Proper handling of history", "Industry best practice"],
            "cons": ["Most complex option", "Requires more significant model changes"]
          }
        ],
        "recommendation": "Implement a short-term fix using 'keep most recent record' approach while developing a proper SCD Type 2 solution for the long term"
      }
    ]
  }
}
```

### Example 3: All Tests Passing with Performance Concerns
Input: dbt test output showing all tests passing but with slow execution times

Output:
```json
{
  "test_summary": {
    "total_tests": 45,
    "passed_tests": 45,
    "failed_tests": 0,
    "error_tests": 0,
    "skipped_tests": 0,
    "execution_time": "187.5 seconds",
    "overall_status": "passed",
    "summary": "All tests passed successfully, but execution time is significantly higher than baseline"
  },
  "failed_tests": [],
  "test_patterns": [
    {
      "pattern_type": "Performance Degradation",
      "description": "Test execution time has increased by 150% compared to the baseline",
      "affected_models": ["fct_orders", "fct_inventory_movements", "fct_financial_transactions"],
      "potential_cause": "Recent data volume growth or inefficient test queries",
      "recommendation": "Optimize test queries and consider implementing test sampling for large fact tables"
    },
    {
      "pattern_type": "Resource Intensive Tests",
      "description": "Several tests on fact tables are consuming excessive resources",
      "affected_models": ["fct_orders", "fct_inventory_movements"],
      "potential_cause": "Full table scans on large tables without appropriate filtering",
      "recommendation": "Add appropriate filtering or use dbt_utils.limit_where_subquery pattern for resource-intensive tests"
    }
  ],
  "recommendations": {
    "immediate_actions": [
      {
        "action": "Identify slowest tests",
        "purpose": "Focus optimization efforts on the most impactful tests",
        "implementation": "Analyze test execution times from logs to identify the slowest tests"
      },
      {
        "action": "Review test query plans",
        "purpose": "Identify inefficient query patterns",
        "implementation": "Examine query plans for the slowest tests to identify optimization opportunities"
      }
    ],
    "investigation_steps": [
      {
        "step": "Analyze data volume growth",
        "purpose": "Determine if increased data volume is contributing to slower tests",
        "query": "SELECT COUNT(*) FROM fct_orders; -- Compare to historical counts"
      },
      {
        "step": "Review test implementations",
        "purpose": "Identify inefficient test patterns",
        "query": "Review the SQL generated for the slowest tests"
      },
      {
        "step": "Check for missing indexes",
        "purpose": "Identify if missing indexes are causing performance issues",
        "query": "Analyze query plans for the slowest tests to identify missing indexes"
      }
    ],
    "long_term_improvements": [
      {
        "improvement": "Implement test sampling",
        "rationale": "Reduce resource usage while maintaining test coverage",
        "implementation_approach": "Use dbt_utils.limit_where_subquery pattern for resource-intensive tests"
      },
      {
        "improvement": "Add performance testing",
        "rationale": "Proactively identify performance regressions",
        "implementation_approach": "Track and alert on test execution times as part of CI/CD"
      },
      {
        "improvement": "Optimize data model",
        "rationale": "Address root causes of performance issues",
        "implementation_approach": "Review and optimize the data model for testability and performance"
      }
    ]
  },
  "historical_context": {
    "test_trend": "stable for quality, degrading for performance",
    "recurring_issues": [
      {
        "issue": "Slow test execution",
        "frequency": "Gradually increasing over past month",
        "last_occurrence": "Previous run was 150 seconds",
        "resolution_status": "Unaddressed and worsening"
      }
    ],
    "comparison_to_baseline": "Test execution time has increased from an average of 75 seconds to 187.5 seconds over the past month, while test quality remains stable with all tests passing"
  },
  "next_steps": {
    "suggested_workflow": [
      {
        "step": "Optimize top 3 slowest tests",
        "rationale": "Address the most impactful performance issues first",
        "details": "Identify and optimize the 3 tests with the longest execution times"
      },
      {
        "step": "Implement test sampling for fact tables",
        "rationale": "Reduce resource usage while maintaining test coverage",
        "details": "Modify tests on large fact tables to use sampling techniques"
      },
      {
        "step": "Monitor performance impact",
        "rationale": "Verify effectiveness of optimizations",
        "details": "Track test execution times after implementing changes"
      }
    ],
    "decision_points": [
      {
        "decision": "Test optimization approach",
        "options": [
          {
            "option": "Optimize existing tests",
            "pros": ["Maintains full test coverage", "No changes to test logic"],
            "cons": ["May have limited performance impact", "More complex to implement"]
          },
          {
            "option": "Implement test sampling",
            "pros": ["Significant performance improvement", "Simpler implementation"],
            "cons": ["Reduced test coverage", "Potential for missed issues"]
          },
          {
            "option": "Hybrid approach",
            "pros": ["Balance of performance and coverage", "Targeted optimization"],
            "cons": ["More complex to manage", "Requires more analysis"]
          }
        ],
        "recommendation": "Implement a hybrid approach: optimize the SQL for critical tests and implement sampling for less critical, resource-intensive tests"
      }
    ]
  }
}
```

## Safety Guardrails
- Always prioritize data integrity and quality over performance
- Recommend thorough investigation before implementing fixes
- Suggest testing fixes in development before applying to production
- Consider business impact when prioritizing issues
- Recommend appropriate communication to stakeholders
- Suggest backup or snapshot steps before implementing changes
- Consider the impact on downstream processes and reports
- Recommend verification steps after implementing fixes
- Suggest monitoring for recurrence of issues
- Always provide clear next steps and decision points

## Schema Reconciliation Validation

After tests pass, determine if schema reconciliation is needed:

### Reconciliation Triggers
- **Changes to Existing Models**: When tests pass for models that modify existing schemas
- **Schema Modifications**: When column additions, removals, or type changes are detected
- **Critical Data Models**: When changes affect core business entities or metrics
- **Production Deployment Preparation**: Before merging changes to production

### Reconciliation Assessment
```json
"reconciliation_assessment": {
  "reconciliation_needed": true|false,
  "confidence": 0.0-1.0,
  "rationale": "Explanation of why reconciliation is or isn't needed",
  "risk_level": "high|medium|low",
  "affected_models": ["model1", "model2"]
}
```

### Reconciliation Checks
- **Schema Comparison**:
  - Compare development schema with production
  - Identify added, removed, and modified columns
  - Detect data type changes and potential compatibility issues

- **Data Integrity Validation**:
  - Verify referential integrity across environments
  - Check for data truncation or conversion issues
  - Validate business rule consistency

- **Downstream Impact Analysis**:
  - Identify affected downstream models
  - Assess impact on reports and dashboards
  - Evaluate API and integration dependencies

### Reconciliation Output
- **Schema Comparison Tables**:
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

- **Data Volume Impact**:
  ```markdown
  ## 📈 DATA VOLUME ANALYSIS
  
  | Model | Production Rows | Dev Rows | Difference | % Change | Last Updated |
  |-------|-----------------|----------|------------|----------|--------------|
  | users | 2,456,789 | 2,456,790 | +1 | +0.00% | 2025-01-15 |
  | orders | 15,678,432 | 15,680,123 | +1,691 | +0.01% | 2025-01-15 |
  | payments | 8,234,567 | 8,234,567 | 0 | 0.00% | 2025-01-14 |
  
  **Total Impact**: 23,369,788 production rows • +1,692 new rows • 0.007% overall change
  ```

- **Dependency Impact**:
  ```markdown
  ## 🔗 DOWNSTREAM IMPACT ANALYSIS
  
  | Affected Model | Type | Relationship | Risk Level | Users/Systems | Action Required |
  |----------------|------|--------------|------------|---------------|-----------------|
  | user_metrics | View | Direct ref() | 🔴 HIGH | 12 dashboards | Schema update needed |
  | daily_summary | Table | Indirect | 🟡 MEDIUM | 3 reports | Monitor for changes |
  | user_segments | Materialized | Direct ref() | 🔴 HIGH | ML pipeline | Coordinate deployment |
  
  **Impact Summary**: 3 downstream models • 2 high-risk • 15 total affected systems
  ```

### Example Reconciliation Assessment
```json
"reconciliation_assessment": {
  "reconciliation_needed": true,
  "confidence": 0.95,
  "rationale": "Schema changes detected in fct_orders with potential data loss risk",
  "risk_level": "high",
  "affected_models": ["fct_orders", "fct_order_items", "rpt_sales_by_region"]
}
```

### Example Reconciliation Recommendation
```json
"reconciliation_recommendation": {
  "recommended_actions": [
    "Execute schema comparison between dev_username.fct_orders and prod.fct_orders",
    "Validate data integrity for modified columns",
    "Prepare rollback plan for high-risk changes",
    "Coordinate deployment with downstream system owners"
  ],
  "sql_queries": [
    "SELECT 'production' as env, COUNT(*) as row_count FROM prod.fct_orders UNION ALL SELECT 'development' as env, COUNT(*) as row_count FROM dev_username.fct_orders",
    "SELECT column_name, data_type FROM dev_username.fct_orders EXCEPT SELECT column_name, data_type FROM prod.fct_orders"
  ],
  "verification_steps": [
    "Compare row counts before and after deployment",
    "Validate referential integrity after deployment",
    "Verify downstream reports show consistent results"
  ]
}
```

### 🔄 NEXT MCP PROMPT
**After analyzing test results:**
- **If tests pass and quality good**: Use `getReconcilePrompt` if schema changes detected, otherwise ready for deployment
- **If tests fail**: Use `getFixupSuggestionsPrompt` to get specific code fixes for the identified failures
- **If performance issues only**: Consider optimization, then use `getReconcilePrompt` to proceed with deployment
