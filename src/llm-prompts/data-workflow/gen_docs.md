# Version: v0.2.0
# Last-Updated: 2025-01-16
# Owner: data-eng
# Description: Generate clear, comprehensive documentation - streamlined approach

# Generate Documentation Prompt

## PURPOSE
Generate clear, comprehensive documentation for dbt models, columns, and tests. **Focus on user understanding and maintenance clarity.**

## EXECUTION APPROACH
1. **Model purpose** - What this model does and why it exists
2. **Column descriptions** - Business meaning and usage
3. **Test coverage** - What validations are in place
4. **Usage guidance** - How to use this model effectively

## OUTPUT FORMAT (Streamlined)

### 📋 Model Documentation Template
```yaml
version: 2

models:
  - name: model_name
    description: |
      Brief, clear description of what this model contains and its business purpose.
      
      **Key Use Cases:**
      - Primary use case description
      - Secondary use case description
      
      **Update Frequency:** Daily/Hourly/Real-time
      **Data Freshness:** Updated within X hours of source
      
    columns:
      - name: column_name
        description: Business meaning and usage context
        tests:
          - not_null
          - unique
      
      - name: another_column
        description: Clear explanation of what this represents
        tests:
          - not_null
          - accepted_values:
              values: ['value1', 'value2', 'value3']

    tests:
      - dbt_utils.unique_combination_of_columns:
          combination_of_columns:
            - column1
            - column2
```

## EXAMPLES

### Example 1: Dimension Table Documentation
**Input:** Document dim_customers model with customer data

**Generated Documentation:**
```yaml
version: 2

models:
  - name: dim_customers
    description: |
      Customer dimension containing core customer profile information and attributes.
      
      **Key Use Cases:**
      - Customer segmentation and analysis
      - Order attribution and customer journey tracking
      - Marketing campaign targeting
      
      **Update Frequency:** Daily at 6 AM UTC
      **Data Freshness:** Updated within 2 hours of customer profile changes
      
      **Business Logic:**
      - One row per unique customer
      - Includes both active and inactive customers
      - Customer tier calculated based on 90-day transaction volume
      
    columns:
      - name: customer_id
        description: Unique identifier for each customer (surrogate key)
        tests:
          - not_null
          - unique
          
      - name: customer_email
        description: Primary email address used for customer communication
        tests:
          - not_null
          - unique
          
      - name: customer_name
        description: Full name of the customer (first + last name)
        tests:
          - not_null
          
      - name: customer_tier
        description: |
          Customer value tier based on 90-day transaction volume:
          - BRONZE: $0-$1,000
          - SILVER: $1,001-$5,000  
          - GOLD: $5,001-$15,000
          - PLATINUM: $15,000+
        tests:
          - not_null
          - accepted_values:
              values: ['BRONZE', 'SILVER', 'GOLD', 'PLATINUM']
              
      - name: account_status
        description: Current status of customer account
        tests:
          - not_null
          - accepted_values:
              values: ['ACTIVE', 'SUSPENDED', 'CLOSED']
              
      - name: created_at
        description: Timestamp when customer account was first created
        tests:
          - not_null
          
      - name: updated_at
        description: Timestamp when customer record was last modified
        tests:
          - not_null

    tests:
      - dbt_expectations.expect_table_row_count_to_be_between:
          min_value: 40000
          max_value: 60000
```

### Example 2: Fact Table Documentation
**Input:** Document fct_orders model with transaction data

**Generated Documentation:**
```yaml
version: 2

models:
  - name: fct_orders
    description: |
      Order fact table containing all customer order transactions and related metrics.
      
      **Key Use Cases:**
      - Revenue analysis and reporting
      - Customer purchase behavior analysis
      - Product performance tracking
      
      **Update Frequency:** Near real-time (every 15 minutes)
      **Data Freshness:** Updated within 30 minutes of order placement
      
      **Business Logic:**
      - One row per order (not order line item)
      - Includes cancelled and refunded orders
      - Order amounts in USD, before taxes and fees
      
    columns:
      - name: order_id
        description: Unique identifier for each order (business key)
        tests:
          - not_null
          - unique
          
      - name: customer_id
        description: Foreign key to dim_customers table
        tests:
          - not_null
          - relationships:
              to: ref('dim_customers')
              field: customer_id
              
      - name: order_date
        description: Date when order was placed (customer timezone)
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: '2020-01-01'
              max_value: '{{ var("max_date") }}'
              
      - name: order_amount
        description: Total order value in USD, excluding taxes and shipping
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 10000
              
      - name: order_status
        description: Current status of the order
        tests:
          - not_null
          - accepted_values:
              values: ['PENDING', 'CONFIRMED', 'SHIPPED', 'DELIVERED', 'CANCELLED', 'REFUNDED']
              
      - name: payment_method
        description: Method used for order payment
        tests:
          - accepted_values:
              values: ['CREDIT_CARD', 'DEBIT_CARD', 'BANK_TRANSFER', 'DIGITAL_WALLET']
              
      - name: created_at
        description: Timestamp when order record was created in warehouse
        tests:
          - not_null
          
      - name: updated_at
        description: Timestamp when order record was last updated
        tests:
          - not_null

    tests:
      - dbt_expectations.expect_table_row_count_to_be_between:
          min_value: 2000000
          max_value: 3000000
      - dbt_utils.expression_is_true:
          expression: "order_amount >= 0"
          config:
            severity: error
```

### Example 3: Staging Table Documentation
**Input:** Document stg_customers staging model

**Generated Documentation:**
```yaml
version: 2

models:
  - name: stg_customers
    description: |
      Staging table for customer data with basic cleaning and standardization.
      
      **Key Use Cases:**
      - Intermediate processing for dim_customers
      - Data quality validation before transformation
      - Source system integration testing
      
      **Update Frequency:** Hourly
      **Data Freshness:** Updated within 1 hour of source changes
      
      **Data Transformations:**
      - Email addresses normalized to lowercase
      - Phone numbers standardized to E164 format
      - Null values handled with appropriate defaults
      
    columns:
      - name: customer_id
        description: Raw customer ID from source system (business key)
        tests:
          - not_null
          - unique
          
      - name: email
        description: Customer email address (normalized to lowercase)
        tests:
          - not_null
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
              
      - name: first_name
        description: Customer first name (trimmed whitespace)
        tests:
          - not_null
          
      - name: last_name
        description: Customer last name (trimmed whitespace)
        tests:
          - not_null
          
      - name: phone
        description: Phone number in E164 format (+1234567890)
        tests:
          - dbt_expectations.expect_column_values_to_match_regex:
              regex: '^\+[1-9]\d{1,14}$'
              
      - name: created_date
        description: Date when customer account was created (date only)
        tests:
          - not_null
          
      - name: source_system
        description: System where customer record originated
        tests:
          - not_null
          - accepted_values:
              values: ['WEB_APP', 'MOBILE_APP', 'CALL_CENTER', 'PARTNER_API']

    tests:
      - dbt_expectations.expect_table_row_count_to_be_between:
          min_value: 45000
          max_value: 55000
```

## DOCUMENTATION TEMPLATES

### Dimension Table Template
```yaml
models:
  - name: dim_[entity_name]
    description: |
      [Entity] dimension containing [brief description].
      
      **Key Use Cases:**
      - [Primary use case]
      - [Secondary use case]
      
      **Update Frequency:** [Daily/Hourly/etc.]
      **Data Freshness:** [SLA description]
      
    columns:
      - name: [entity]_id
        description: Unique identifier for [entity]
        tests:
          - not_null
          - unique
```

### Fact Table Template
```yaml
models:
  - name: fct_[process_name]
    description: |
      [Process] fact table containing [transaction description].
      
      **Key Use Cases:**
      - [Analytics use case]
      - [Reporting use case]
      
      **Update Frequency:** [Real-time/Batch]
      **Data Freshness:** [SLA description]
      
    columns:
      - name: [process]_id
        description: Unique identifier for [process]
        tests:
          - not_null
          - unique
```

### Staging Table Template
```yaml
models:
  - name: stg_[source_name]
    description: |
      Staging table for [source] with [transformation description].
      
      **Data Transformations:**
      - [Transformation 1]
      - [Transformation 2]
      
    columns:
      - name: [key_field]
        description: [Business meaning]
        tests:
          - not_null
```

## COLUMN DESCRIPTION GUIDELINES

### Good Descriptions
- **customer_tier**: "Customer value tier based on 90-day transaction volume (BRONZE/SILVER/GOLD/PLATINUM)"
- **order_amount**: "Total order value in USD, excluding taxes and shipping fees"
- **is_active**: "True if customer account is currently active and able to place orders"

### Avoid These
- **customer_tier**: "The tier of the customer" ❌
- **order_amount**: "Amount field" ❌
- **is_active**: "Active flag" ❌

## TEST COVERAGE STANDARDS

### Required Tests (All Models)
- **Primary Key**: `not_null` + `unique`
- **Foreign Keys**: `not_null` + `relationships`
- **Required Fields**: `not_null`

### Recommended Tests
- **Enums**: `accepted_values`
- **Ranges**: `dbt_expectations.expect_column_values_to_be_between`
- **Formats**: `dbt_expectations.expect_column_values_to_match_regex`
- **Business Rules**: `dbt_utils.expression_is_true`

### Table-Level Tests
- **Row Counts**: `dbt_expectations.expect_table_row_count_to_be_between`
- **Uniqueness**: `dbt_utils.unique_combination_of_columns`
- **Relationships**: `dbt_utils.equal_rowcount`

## DOCUMENTATION BEST PRACTICES

### Model Descriptions
1. **Start with purpose** - What business need does this solve?
2. **Include use cases** - How will people use this data?
3. **Specify freshness** - When is data updated?
4. **Document logic** - Any important business rules?

### Column Descriptions
1. **Business meaning** - What does this represent?
2. **Format/units** - Currency, date format, etc.
3. **Constraints** - Valid values or ranges
4. **Relationships** - How it connects to other data

### Test Documentation
1. **Critical validations** - Data quality requirements
2. **Business rules** - Domain-specific constraints
3. **Performance tests** - Row count expectations
4. **Relationship validation** - Foreign key integrity

## 🔄 NEXT MCP PROMPT
- **After documentation** → Use `getValidateRiskPrompt` to assess documentation completeness
- **For model deployment** → Use `getCreatePRPrompt` to include documentation in changes
- **For test validation** → Use `getRunTestsPrompt` to verify documented tests work
- **For comprehensive review** → Use `getMergeGuardPrompt` to validate documentation quality

## CHANGELOG
### v0.2.0 - 2025-01-16
- Simplified documentation templates
- Added clear test coverage standards
- Focused on business value and usage
- Streamlined column description guidelines
