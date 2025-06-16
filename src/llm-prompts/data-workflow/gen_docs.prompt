# Version: v0.1.0
# Last-Updated: 2025-06-16
# Owner: analytics-platform
# Description: Auto-write model & column docs

# Generate Documentation Prompt

## Purpose
This prompt helps create comprehensive documentation for dbt models, columns, and tests. It generates clear explanations of business logic, data lineage, and technical details to improve understanding and usability of data models.

## Usage
Use this prompt when you need to create or update documentation for data models, either as part of new development or to improve existing documentation.

## Input Context
- Model SQL code and structure
- Schema information for relevant tables
- Business context and requirements
- Existing documentation (if any)
- Data samples (if available)
- Project documentation standards

## Output Format
```json
{
  "documentation_generation": {
    "file_path": "Path to the documentation file",
    "file_type": "schema|markdown|other",
    "operation": "create|update",
    "summary": "Brief summary of the documentation changes"
  },
  "model_documentation": {
    "model_name": "Name of the model",
    "description": "Comprehensive description of the model's purpose and function",
    "business_context": "Explanation of the business context and use cases",
    "data_sources": [
      {
        "source_name": "Name of the source",
        "description": "Description of how this source is used"
      }
    ],
    "limitations": [
      "Limitation 1 of the model",
      "Limitation 2 of the model"
    ],
    "update_frequency": "How often the model is updated",
    "stakeholders": [
      "Stakeholder 1",
      "Stakeholder 2"
    ]
  },
  "column_documentation": [
    {
      "column_name": "Name of the column",
      "description": "Clear description of what the column represents",
      "business_definition": "Business-friendly definition of the column",
      "technical_details": {
        "data_type": "Column data type",
        "constraints": "Any constraints on the column",
        "transformations": "Transformations applied to the column"
      },
      "source": "Where this column comes from",
      "examples": [
        "Example value 1",
        "Example value 2"
      ]
    }
  ],
  "test_documentation": [
    {
      "test_name": "Name of the test",
      "description": "Description of what the test verifies",
      "rationale": "Why this test is important",
      "implementation": "How the test is implemented"
    }
  ],
  "lineage_documentation": {
    "upstream_dependencies": [
      {
        "model_name": "Name of upstream model",
        "relationship": "Description of the relationship"
      }
    ],
    "downstream_dependencies": [
      {
        "model_name": "Name of downstream model",
        "relationship": "Description of the relationship"
      }
    ]
  },
  "yaml_output": {
    "schema_yaml": "YAML content for schema.yml file",
    "model_yaml": "YAML content for model-specific documentation"
  },
  "markdown_output": {
    "model_markdown": "Markdown content for model documentation"
  }
}
```

## Instructions

1. **Analyze the model**
   - Understand the model's purpose and function
   - Identify key business concepts represented
   - Examine transformations and calculations
   - Note relationships to other models
   - Consider the model's role in the overall data architecture

2. **Document the model**
   - Provide a clear, concise description of the model's purpose
   - Explain the business context and use cases
   - Document data sources and transformations
   - Note any limitations or assumptions
   - Include update frequency and stakeholders

3. **Document columns**
   - Write clear descriptions for each column
   - Provide business-friendly definitions
   - Include technical details (data type, constraints, etc.)
   - Note the source of the data
   - Provide examples where helpful

4. **Document tests**
   - Explain what each test verifies
   - Provide rationale for why the test is important
   - Document how the test is implemented
   - Note any limitations of the test

5. **Document lineage**
   - Identify upstream dependencies
   - Identify downstream dependencies
   - Explain relationships between models
   - Note any important transformation steps

6. **Format for dbt**
   - Generate YAML for schema.yml files
   - Create markdown documentation if needed
   - Follow project documentation standards
   - Ensure consistency with existing documentation

## Schema.yml Entry Guidelines

1. **File Location**
   - Place schema.yml entries in the same directory as the SQL file itself
   - If a schema.yml file doesn't exist in the directory, create it
   - Do not place model documentation in schema.yml files outside the model's directory

2. **Model Description**
   - Provide a clear overview of the model's purpose based on its SQL logic
   - Explain the business context and use cases
   - Document any important assumptions or limitations
   - Include information about update frequency and stakeholders

3. **Column Documentation**
   - Document all output columns with clear descriptions
   - For common fields defined in docs.md files, use the jinja template `{{ doc('FIELD_NAME') }}`
   - For example, if a field named `identity_canonical_id` is found in a docs.md file, use `{{ doc('identity_canonical_id') }}` as the description

4. **Documentation Format**
   - Use proper YAML indentation (2 spaces)
   - For multi-line descriptions, use the YAML block scalar indicator (|)
   - Include appropriate tests in the schema.yml file
   - Organize columns in a logical order (primary keys first, then grouped by category)

## Examples

### Example 1: Documenting a Fact Table
Input: Documentation needed for fct_orders model that aggregates order data from multiple sources.

Output:
```json
{
  "documentation_generation": {
    "file_path": "models/marts/core/schema.yml",
    "file_type": "schema",
    "operation": "update",
    "summary": "Added comprehensive documentation for fct_orders model and its columns"
  },
  "model_documentation": {
    "model_name": "fct_orders",
    "description": "This fact table contains order information at the order line item level, combining data from our e-commerce platform, in-store POS system, and phone orders. Each row represents a single line item within an order, with order-level information repeated across line items from the same order. This model is the source of truth for order analysis and reporting.",
    "business_context": "This model supports sales reporting, customer purchase analysis, inventory management, and financial reconciliation. It's used by the sales, finance, and product teams to track order performance and customer behavior across all sales channels.",
    "data_sources": [
      {
        "source_name": "stg_ecommerce_orders",
        "description": "Online orders from the e-commerce platform"
      },
      {
        "source_name": "stg_pos_transactions",
        "description": "In-store purchases from the point-of-sale system"
      },
      {
        "source_name": "stg_phone_orders",
        "description": "Orders placed through the call center"
      }
    ],
    "limitations": [
      "Historical data before 2023 may have inconsistent channel attribution",
      "Returns and exchanges are tracked in a separate model (fct_returns)",
      "Tax calculations for international orders use simplified rules",
      "Order modifications after placement are not tracked historically"
    ],
    "update_frequency": "Refreshed hourly with incremental updates",
    "stakeholders": [
      "Sales Team",
      "Finance Department",
      "Product Management",
      "Inventory Planning"
    ]
  },
  "column_documentation": [
    {
      "column_name": "order_item_id",
      "description": "Unique identifier for each order line item",
      "business_definition": "A distinct product or service purchased within an order",
      "technical_details": {
        "data_type": "varchar(64)",
        "constraints": "primary key, not null",
        "transformations": "Surrogate key generated from order_id and item_id using dbt_utils.surrogate_key()"
      },
      "source": "Generated",
      "examples": [
        "OI12345678",
        "OI98765432"
      ]
    },
    {
      "column_name": "order_id",
      "description": "Unique identifier for the order",
      "business_definition": "A customer purchase transaction that may contain multiple items",
      "technical_details": {
        "data_type": "varchar(32)",
        "constraints": "not null",
        "transformations": "Standardized across all source systems"
      },
      "source": "stg_ecommerce_orders.order_id, stg_pos_transactions.transaction_id, or stg_phone_orders.order_id",
      "examples": [
        "ORD-12345",
        "POS-67890"
      ]
    },
    {
      "column_name": "customer_id",
      "description": "Unique identifier for the customer who placed the order",
      "business_definition": "The individual or organization that made the purchase",
      "technical_details": {
        "data_type": "varchar(32)",
        "constraints": "foreign key to dim_customers",
        "transformations": "Mapped to canonical customer ID from various source systems"
      },
      "source": "stg_ecommerce_orders.customer_id, stg_pos_transactions.customer_id, or stg_phone_orders.customer_id",
      "examples": [
        "CUST-001234",
        "CUST-567890"
      ]
    },
    {
      "column_name": "order_date",
      "description": "Date when the order was placed",
      "business_definition": "The calendar date when the customer submitted the order",
      "technical_details": {
        "data_type": "date",
        "constraints": "not null",
        "transformations": "Converted to date from timestamp, standardized to UTC"
      },
      "source": "stg_ecommerce_orders.created_at, stg_pos_transactions.transaction_date, or stg_phone_orders.order_date",
      "examples": [
        "2025-01-15",
        "2025-02-28"
      ]
    },
    {
      "column_name": "order_timestamp",
      "description": "Exact time when the order was placed",
      "business_definition": "The precise moment when the customer submitted the order",
      "technical_details": {
        "data_type": "timestamp",
        "constraints": "not null",
        "transformations": "Standardized to UTC timezone"
      },
      "source": "stg_ecommerce_orders.created_at, stg_pos_transactions.transaction_timestamp, or stg_phone_orders.order_timestamp",
      "examples": [
        "2025-01-15 14:23:45",
        "2025-02-28 09:12:34"
      ]
    },
    {
      "column_name": "product_id",
      "description": "Unique identifier for the product ordered",
      "business_definition": "The specific item or service that was purchased",
      "technical_details": {
        "data_type": "varchar(32)",
        "constraints": "foreign key to dim_products",
        "transformations": "Standardized across all source systems"
      },
      "source": "stg_ecommerce_orders.product_id, stg_pos_transactions.item_id, or stg_phone_orders.product_id",
      "examples": [
        "PROD-5678",
        "PROD-9012"
      ]
    },
    {
      "column_name": "quantity",
      "description": "Number of units ordered for this line item",
      "business_definition": "How many of this product were purchased in this order",
      "technical_details": {
        "data_type": "integer",
        "constraints": "not null, > 0",
        "transformations": "None"
      },
      "source": "stg_ecommerce_orders.quantity, stg_pos_transactions.quantity, or stg_phone_orders.quantity",
      "examples": [
        "1",
        "5"
      ]
    },
    {
      "column_name": "unit_price",
      "description": "Price per unit for this product at time of purchase",
      "business_definition": "The price of a single unit of the product when it was ordered",
      "technical_details": {
        "data_type": "numeric(12,2)",
        "constraints": "not null, >= 0",
        "transformations": "Converted to standard currency (USD)"
      },
      "source": "stg_ecommerce_orders.unit_price, stg_pos_transactions.price, or stg_phone_orders.unit_price",
      "examples": [
        "29.99",
        "125.50"
      ]
    },
    {
      "column_name": "discount_amount",
      "description": "Discount applied to this line item",
      "business_definition": "The amount deducted from the regular price due to promotions or coupons",
      "technical_details": {
        "data_type": "numeric(12,2)",
        "constraints": ">= 0",
        "transformations": "Calculated as (regular_price - actual_price) * quantity"
      },
      "source": "Calculated",
      "examples": [
        "5.00",
        "25.00"
      ]
    },
    {
      "column_name": "tax_amount",
      "description": "Tax applied to this line item",
      "business_definition": "The amount of sales tax or VAT charged for this item",
      "technical_details": {
        "data_type": "numeric(12,2)",
        "constraints": ">= 0",
        "transformations": "Calculated based on applicable tax rates for the shipping location and product category"
      },
      "source": "Calculated",
      "examples": [
        "2.40",
        "10.50"
      ]
    },
    {
      "column_name": "line_item_total",
      "description": "Total amount for this line item including discounts and taxes",
      "business_definition": "The final price paid for this specific item in the order",
      "technical_details": {
        "data_type": "numeric(12,2)",
        "constraints": "not null",
        "transformations": "Calculated as (unit_price * quantity) - discount_amount + tax_amount"
      },
      "source": "Calculated",
      "examples": [
        "27.39",
        "111.00"
      ]
    },
    {
      "column_name": "sales_channel",
      "description": "Channel through which the order was placed",
      "business_definition": "The method or platform the customer used to make the purchase",
      "technical_details": {
        "data_type": "varchar(16)",
        "constraints": "not null",
        "transformations": "Standardized across source systems"
      },
      "source": "Derived from source system",
      "examples": [
        "online",
        "in_store",
        "phone"
      ]
    },
    {
      "column_name": "is_first_order",
      "description": "Flag indicating if this is the customer's first order",
      "business_definition": "Identifies new customers making their first purchase",
      "technical_details": {
        "data_type": "boolean",
        "constraints": "not null",
        "transformations": "Calculated by comparing order_date to customer's first_order_date"
      },
      "source": "Calculated",
      "examples": [
        "true",
        "false"
      ]
    }
  ],
  "test_documentation": [
    {
      "test_name": "unique_order_item_id",
      "description": "Verifies that each order item ID is unique",
      "rationale": "Ensures data integrity by confirming there are no duplicate order items",
      "implementation": "Standard dbt unique test on order_item_id column"
    },
    {
      "test_name": "not_null_order_id",
      "description": "Verifies that all order items have an order ID",
      "rationale": "Ensures all items are properly associated with an order",
      "implementation": "Standard dbt not_null test on order_id column"
    },
    {
      "test_name": "valid_customer_id",
      "description": "Verifies that all customer IDs exist in the customers dimension table",
      "rationale": "Ensures referential integrity between orders and customers",
      "implementation": "Standard dbt relationships test between customer_id and dim_customers.customer_id"
    },
    {
      "test_name": "valid_product_id",
      "description": "Verifies that all product IDs exist in the products dimension table",
      "rationale": "Ensures referential integrity between orders and products",
      "implementation": "Standard dbt relationships test between product_id and dim_products.product_id"
    },
    {
      "test_name": "positive_quantity",
      "description": "Verifies that all quantities are greater than zero",
      "rationale": "Ensures business logic that all order items must have at least one unit",
      "implementation": "Custom SQL test that checks quantity > 0"
    },
    {
      "test_name": "order_totals_match",
      "description": "Verifies that the sum of line item totals matches the order total",
      "rationale": "Ensures financial accuracy of order calculations",
      "implementation": "Custom SQL test that compares sum of line_item_total to order_total for each order_id"
    }
  ],
  "lineage_documentation": {
    "upstream_dependencies": [
      {
        "model_name": "stg_ecommerce_orders",
        "relationship": "Source of online order data"
      },
      {
        "model_name": "stg_pos_transactions",
        "relationship": "Source of in-store order data"
      },
      {
        "model_name": "stg_phone_orders",
        "relationship": "Source of phone order data"
      },
      {
        "model_name": "dim_customers",
        "relationship": "Source of customer attributes and canonical IDs"
      },
      {
        "model_name": "dim_products",
        "relationship": "Source of product attributes and categorization"
      }
    ],
    "downstream_dependencies": [
      {
        "model_name": "fct_daily_sales",
        "relationship": "Aggregates order data to daily sales metrics"
      },
      {
        "model_name": "fct_customer_lifetime_value",
        "relationship": "Uses order history to calculate customer LTV"
      },
      {
        "model_name": "rpt_product_performance",
        "relationship": "Uses order data to analyze product performance"
      },
      {
        "model_name": "rpt_sales_by_channel",
        "relationship": "Uses order data to compare sales across channels"
      }
    ]
  },
  "yaml_output": {
    "schema_yaml": "version: 2\n\nmodels:\n  - name: fct_orders\n    description: |\n      This fact table contains order information at the order line item level, combining data from our e-commerce platform, in-store POS system, and phone orders. Each row represents a single line item within an order, with order-level information repeated across line items from the same order. This model is the source of truth for order analysis and reporting.\n      \n      This model supports sales reporting, customer purchase analysis, inventory management, and financial reconciliation. It's used by the sales, finance, and product teams to track order performance and customer behavior across all sales channels.\n      \n      **Data Sources:**\n      - stg_ecommerce_orders: Online orders from the e-commerce platform\n      - stg_pos_transactions: In-store purchases from the point-of-sale system\n      - stg_phone_orders: Orders placed through the call center\n      \n      **Limitations:**\n      - Historical data before 2023 may have inconsistent channel attribution\n      - Returns and exchanges are tracked in a separate model (fct_returns)\n      - Tax calculations for international orders use simplified rules\n      - Order modifications after placement are not tracked historically\n      \n      **Update Frequency:** Refreshed hourly with incremental updates\n      \n      **Stakeholders:** Sales Team, Finance Department, Product Management, Inventory Planning\n    columns:\n      - name: order_item_id\n        description: Unique identifier for each order line item. A distinct product or service purchased within an order.\n        tests:\n          - unique\n          - not_null\n      - name: order_id\n        description: Unique identifier for the order. A customer purchase transaction that may contain multiple items.\n        tests:\n          - not_null\n      - name: customer_id\n        description: Unique identifier for the customer who placed the order. The individual or organization that made the purchase.\n        tests:\n          - relationships:\n              to: ref('dim_customers')\n              field: customer_id\n      - name: order_date\n        description: Date when the order was placed. The calendar date when the customer submitted the order.\n        tests:\n          - not_null\n      - name: order_timestamp\n        description: Exact time when the order was placed. The precise moment when the customer submitted the order.\n        tests:\n          - not_null\n      - name: product_id\n        description: Unique identifier for the product ordered. The specific item or service that was purchased.\n        tests:\n          - relationships:\n              to: ref('dim_products')\n              field: product_id\n      - name: quantity\n        description: Number of units ordered for this line item. How many of this product were purchased in this order.\n        tests:\n          - not_null\n          - custom_positive_quantity\n      - name: unit_price\n        description: Price per unit for this product at time of purchase. The price of a single unit of the product when it was ordered.\n        tests:\n          - not_null\n      - name: discount_amount\n        description: Discount applied to this line item. The amount deducted from the regular price due to promotions or coupons.\n      - name: tax_amount\n        description: Tax applied to this line item. The amount of sales tax or VAT charged for this item.\n      - name: line_item_total\n        description: Total amount for this line item including discounts and taxes. The final price paid for this specific item in the order.\n        tests:\n          - not_null\n      - name: sales_channel\n        description: Channel through which the order was placed. The method or platform the customer used to make the purchase.\n        tests:\n          - not_null\n          - accepted_values:\n              values: ['online', 'in_store', 'phone']\n      - name: is_first_order\n        description: Flag indicating if this is the customer's first order. Identifies new customers making their first purchase.\n        tests:\n          - not_null",
    "model_yaml": ""
  },
  "markdown_output": {
    "model_markdown": "# fct_orders\n\n## Overview\nThis fact table contains order information at the order line item level, combining data from our e-commerce platform, in-store POS system, and phone orders. Each row represents a single line item within an order, with order-level information repeated across line items from the same order. This model is the source of truth for order analysis and reporting.\n\n## Business Usage\nThis model supports sales reporting, customer purchase analysis, inventory management, and financial reconciliation. It's used by the sales, finance, and product teams to track order performance and customer behavior across all sales channels.\n\n## Data Sources\n- stg_ecommerce_orders: Online orders from the e-commerce platform\n- stg_pos_transactions: In-store purchases from the point-of-sale system\n- stg_phone_orders: Orders placed through the call center\n\n## Limitations\n- Historical data before 2023 may have inconsistent channel attribution\n- Returns and exchanges are tracked in a separate model (fct_returns)\n- Tax calculations for international orders use simplified rules\n- Order modifications after placement are not tracked historically\n\n## Update Frequency\nRefreshed hourly with incremental updates\n\n## Stakeholders\nSales Team, Finance Department, Product Management, Inventory Planning\n\n## Columns\n\n| Column Name | Description | Business Definition | Data Type | Source |\n|-------------|-------------|---------------------|-----------|--------|\n| order_item_id | Unique identifier for each order line item | A distinct product or service purchased within an order | varchar(64) | Generated |\n| order_id | Unique identifier for the order | A customer purchase transaction that may contain multiple items | varchar(32) | stg_ecommerce_orders.order_id, stg_pos_transactions.transaction_id, or stg_phone_orders.order_id |\n| customer_id | Unique identifier for the customer who placed the order | The individual or organization that made the purchase | varchar(32) | stg_ecommerce_orders.customer_id, stg_pos_transactions.customer_id, or stg_phone_orders.customer_id |\n| order_date | Date when the order was placed | The calendar date when the customer submitted the order | date | stg_ecommerce_orders.created_at, stg_pos_transactions.transaction_date, or stg_phone_orders.order_date |\n| order_timestamp | Exact time when the order was placed | The precise moment when the customer submitted the order | timestamp | stg_ecommerce_orders.created_at, stg_pos_transactions.transaction_timestamp, or stg_phone_orders.order_timestamp |\n| product_id | Unique identifier for the product ordered | The specific item or service that was purchased | varchar(32) | stg_ecommerce_orders.product_id, stg_pos_transactions.item_id, or stg_phone_orders.product_id |\n| quantity | Number of units ordered for this line item | How many of this product were purchased in this order | integer | stg_ecommerce_orders.quantity, stg_pos_transactions.quantity, or stg_phone_orders.quantity |\n| unit_price | Price per unit for this product at time of purchase | The price of a single unit of the product when it was ordered | numeric(12,2) | stg_ecommerce_orders.unit_price, stg_pos_transactions.price, or stg_phone_orders.unit_price |\n| discount_amount | Discount applied to this line item | The amount deducted from the regular price due to promotions or coupons | numeric(12,2) | Calculated |\n| tax_amount | Tax applied to this line item | The amount of sales tax or VAT charged for this item | numeric(12,2) | Calculated |\n| line_item_total | Total amount for this line item including discounts and taxes | The final price paid for this specific item in the order | numeric(12,2) | Calculated |\n| sales_channel | Channel through which the order was placed | The method or platform the customer used to make the purchase | varchar(16) | Derived from source system |\n| is_first_order | Flag indicating if this is the customer's first order | Identifies new customers making their first purchase | boolean | Calculated |\n\n## Tests\n- Unique order_item_id\n- Not null constraints on key fields\n- Referential integrity to dim_customers and dim_products\n- Positive quantities\n- Order totals match sum of line items\n\n## Lineage\n\n### Upstream Models\n- stg_ecommerce_orders\n- stg_pos_transactions\n- stg_phone_orders\n- dim_customers\n- dim_products\n\n### Downstream Models\n- fct_daily_sales\n- fct_customer_lifetime_value\n- rpt_product_performance\n- rpt_sales_by_channel\n\n## Example Queries\n\n```sql\n-- Get total sales by channel for the current month\nSELECT\n  sales_channel,\n  SUM(line_item_total) as total_sales\nFROM {{ ref('fct_orders') }}\nWHERE order_date >= DATE_TRUNC('month', CURRENT_DATE)\nGROUP BY 1\nORDER BY 2 DESC\n```\n\n```sql\n-- Find top selling products\nSELECT\n  p.product_name,\n  SUM(o.quantity) as units_sold,\n  SUM(o.line_item_total) as total_revenue\nFROM {{ ref('fct_orders') }} o\nJOIN {{ ref('dim_products') }} p ON o.product_id = p.product_id\nWHERE o.order_date >= DATEADD(day, -30, CURRENT_DATE)\nGROUP BY 1\nORDER BY 2 DESC\nLIMIT 10\n```"
  }
}
```

### Example 2: Documenting a Dimension Table
Input: Documentation needed for dim_customers model that consolidates customer data from multiple sources.

Output:
```json
{
  "documentation_generation": {
    "file_path": "models/marts/core/schema.yml",
    "file_type": "schema",
    "operation": "update",
    "summary": "Added comprehensive documentation for dim_customers model and its columns"
  },
  "model_documentation": {
    "model_name": "dim_customers",
    "description": "This dimension table contains consolidated customer information from multiple source systems, providing a single source of truth for customer attributes. Each row represents a unique customer with their current attributes and status. Historical changes to customer attributes are tracked in a separate SCD Type 2 model (dim_customers_history).",
    "business_context": "This model supports customer segmentation, personalization, marketing campaigns, and customer service. It provides a unified view of customers across all channels and touchpoints, enabling consistent customer experiences and accurate reporting.",
    "data_sources": [
      {
        "source_name": "stg_crm_customers",
        "description": "Primary customer information from the CRM system"
      },
      {
        "source_name": "stg_ecommerce_users",
        "description": "Online account information from the e-commerce platform"
      },
      {
        "source_name": "stg_loyalty_members",
        "description": "Loyalty program information from the loyalty system"
      }
    ],
    "limitations": [
      "Customer preferences are updated in near real-time, but demographic data may lag by up to 24 hours",
      "Some legacy customers may have incomplete profiles",
      "Free text fields like notes and custom attributes are not standardized",
      "GDPR-deleted customers are removed completely rather than anonymized"
    ],
    "update_frequency": "Refreshed hourly with incremental updates",
    "stakeholders": [
      "Marketing Team",
      "Customer Service",
      "Sales Department",
      "Product Management"
    ]
  },
  "column_documentation": [
    {
      "column_name": "customer_id",
      "description": "Unique identifier for the customer",
      "business_definition": "The primary identifier used to reference a customer across all systems",
      "technical_details": {
        "data_type": "varchar(32)",
        "constraints": "primary key, not null",
        "transformations": "Uses the CRM ID as the canonical ID when available, otherwise uses the e-commerce user ID"
      },
      "source": "stg_crm_customers.customer_id or stg_ecommerce_users.user_id",
      "examples": [
        "CUST-001234",
        "CUST-567890"
      ]
    },
    {
      "column_name": "email",
      "description": "Customer's primary email address",
      "business_definition": "The main email address used for communications with the customer",
      "technical_details": {
        "data_type": "varchar(255)",
        "constraints": "unique, not null",
        "transformations": "Converted to lowercase, trimmed whitespace"
      },
      "source": "stg_crm_customers.email_address or stg_ecommerce_users.email",
      "examples": [
        "customer@example.com",
        "jane.doe@company.org"
      ]
    },
    {
      "column_name": "first_name",
      "description": "Customer's first name",
      "business_definition": "The customer's given name or first name",
      "technical_details": {
        "data_type": "varchar(50)",
        "constraints": "none",
        "transformations": "Proper case applied, trimmed whitespace"
      },
      "source": "stg_crm_customers.first_name or stg_ecommerce_users.first_name",
      "examples": [
        "John",
        "Maria"
      ]
    },
    {
      "column_name": "last_name",
      "description": "Customer's last name",
      "business_definition": "The customer's family name or surname",
      "technical_details": {
        "data_type": "varchar(50)",
        "constraints": "none",
        "transformations": "Proper case applied, trimmed whitespace"
      },
      "source": "stg_crm_customers.last_name or stg_ecommerce_users.last_name",
      "examples":
