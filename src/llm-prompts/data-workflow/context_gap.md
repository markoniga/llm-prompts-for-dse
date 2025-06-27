# Version: v0.1.0
# Last-Updated: 2025-06-16
# Owner: analytics-platform
# Description: Ask follow-up & gather schema context

# Context Gap Prompt

## PURPOSE
This prompt helps identify missing information needed to address a data workflow request. It analyzes context gaps and gathers necessary schema information, business logic, and other relevant details to ensure a complete understanding of the task.

## CURSOR AGENT EXECUTION GUIDE
**Use this prompt AFTER intent classification** to gather all missing context before proceeding with code generation or documentation.

### Context Assessment Checklist
- [ ] Schema details are complete (models, fields, relationships)
- [ ] Business logic is fully defined
- [ ] Technical requirements are clear
- [ ] Sample data has been examined where relevant
- [ ] Downstream impacts have been considered

## EXECUTION WORKFLOW

### Step 1: Rapid Context Assessment
**Rate completeness on 0.0-1.0 scale:**
- 0.0-0.3: Critical gaps, cannot proceed
- 0.4-0.6: Moderate gaps, clarification needed  
- 0.7-0.9: Minor gaps, can proceed with assumptions
- 1.0: Complete, ready to execute

### Step 2: Identify Missing Information Types
**Schema Gaps:**
- Model names unclear or ambiguous
- Field data types unknown
- Relationships undefined
- Primary/foreign keys unspecified

**Business Logic Gaps:**
- Calculations undefined
- Edge cases not specified
- Validation rules unknown
- Exception handling unclear

**Technical Gaps:**
- Performance requirements unknown
- Testing specifications missing
- Deployment constraints unclear

## MANDATORY OUTPUT FORMAT
**Use this compact Markdown format (use `render_dict_safely` macro for nested data):**

### 📊 Context Assessment
- **completeness** → 0.0-1.0 
- **critical_gaps** → Gap1, Gap2... (abbreviated list)
- **summary** → Brief summary of the context status
- **can_proceed** → true|false

### 🔍 Information Needed
- **schema_details** →
  <details>
  <summary>📋 <strong>Schema Details</strong> ({{ schema_details | length }} models)</summary>
  
  **model_name**: fields_needed, relationship_details_needed
  
  </details>
- **business_logic** → Logic rule 1, Logic rule 2... (first 2, then count)
- **technical_requirements** → Requirement 1, Requirement 2... (first 2, then count)
- **sample_data_needed** → true|false

### ❓ Follow-up Questions
- **Priority: CRITICAL**
  1. Question (Purpose: Why needed | Impact: What happens if missing)
- **Priority: HIGH** 
  1. Question (Purpose: Why needed)
- **Priority: MEDIUM**
  1. Question (Purpose: Why needed)

### 🔎 Suggested Queries
1. **Purpose** → Query description → Expected insights
2. **Purpose** → Query description → Expected insights

### 📚 Available Context
- **models_found** → model1 (type), model2 (type)... ({{ models_found | length }} total)
- **relevant_documentation** →
  <details>
  <summary>📖 <strong>Documentation Found</strong> ({{ relevant_documentation | length }} items)</summary>
  
  - **doc_type** @ location: key_points
  
  </details>
- **sample_data** → available: true|false

## STEP-BY-STEP ANALYSIS PROCESS

### Step 1: Assess Available Context
**Review systematically:**
1. User's original request (what exactly do they want?)
2. Intent classification (question/code_change/documentation/exploration)
3. Mentioned entities (models, tables, fields, metrics)
4. Technical requirements (performance, testing, deployment)
5. Business context (purpose, urgency, stakeholders)

### Step 2: Identify Schema Information Needs
**For each mentioned model/table:**
- Does it exist? Which schema?
- What are the key fields and their types?
- What are the relationships to other models?
- Are there any constraints or business rules?

**Common Schema Gaps:**
- "orders model" → Which one? (stg_orders, fct_orders, dim_orders?)
- "customer data" → Which fields specifically?
- "recent data" → How recent? (last day, week, month?)

### Step 3: Identify Business Logic Gaps
**Look for undefined concepts:**
- Metrics without clear calculation logic
- Business terms without definitions
- Edge cases without handling rules
- Validation rules without criteria

**Examples:**
- "Revenue" → Recognized revenue? Gross? Net?
- "Active customer" → What defines active? Time period?
- "Valid transaction" → What validation criteria?

### Step 4: Formulate Strategic Follow-up Questions
**Question Priority Framework:**
- **Critical**: Cannot proceed without this information
- **High**: Significantly impacts the approach or quality
- **Medium**: Affects implementation details
- **Low**: Nice-to-have for completeness

**Question Quality Criteria:**
- Specific and actionable
- Clear purpose explained
- Easy for user to answer
- Prioritized by impact

### Step 5: Design Exploratory Queries
**Query Categories:**
1. **Discovery queries**: Find relevant models/data
2. **Validation queries**: Check assumptions
3. **Quality queries**: Assess data completeness/accuracy
4. **Pattern queries**: Understand data distributions

**Query Best Practices:**
- Order by execution priority
- Include expected insights
- Limit resource usage
- Focus on specific questions

## OPTIMIZED EXAMPLE EXECUTIONS

### Example 1: Adding Promotion Code Field
**Input:** "Add promotion code tracking to orders"

**Context Assessment Process:**
1. Multiple orders models likely exist → Need clarification
2. No data type specified → Need schema details
3. No testing requirements → Need quality standards
4. No business rules → Need validation logic

**Optimized Output:**

### 📊 Context Assessment
- **completeness** → 0.4
- **critical_gaps** → Target model unclear, Data type unspecified, Business rules undefined
- **summary** → Clear intent but missing critical implementation details
- **can_proceed** → false

### 🔍 Information Needed
- **schema_details** →
  <details>
  <summary>📋 <strong>Schema Details</strong> (1 model)</summary>
  
  **orders (specific model unclear)**: promo_code data type, promo_code constraints, current order fields | Relationships: Is there a promotions table for validation?
  
  </details>
- **business_logic** → What format should promotion codes follow?, How should invalid codes be handled?...and 1 more
- **technical_requirements** → Which specific orders model to modify, Required tests for new field...and 1 more
- **sample_data_needed** → true

### ❓ Follow-up Questions
- **Priority: CRITICAL**
  1. Which orders model should get the promotion code field: stg_orders, int_orders, fct_orders, or dim_orders? (Purpose: Identify exact model | Impact: Might modify wrong model)
  2. What should the data type be for promotion_code (varchar length, format constraints)? (Purpose: Define proper field specification | Impact: Field might be incorrectly typed)
- **Priority: HIGH** 
  1. Is there an existing promotions table this should reference, or is it standalone? (Purpose: Determine if foreign key constraints are needed)
- **Priority: MEDIUM**
  1. What tests should validate the new field (format, referential integrity, etc.)? (Purpose: Ensure data quality for new field)

### 🔎 Suggested Queries
1. **Identify available orders models** → `dbt ls --select '*order*'` → Complete list of order-related models to choose from
2. **Check source data for promo codes** → `SELECT COUNT(*) as total, COUNT(promo_code) as with_promo...` → Confirms field exists, population rate, and length requirements
3. **Examine promo code patterns** → `SELECT promo_code, COUNT(*) FROM source_orders...` → Common formats and patterns for validation rules

### 📚 Available Context
- **models_found** → source_orders (source)... (1 total)
- **relevant_documentation** →
  <details>
  <summary>📖 <strong>Documentation Found</strong> (0 items)</summary>
  
  No documentation found
  
  </details>
- **sample_data** → available: false

### Example 2: Revenue Recognition Question
**Input:** "How is revenue recognized in our models?"

**Context Assessment Process:**
1. Broad question → Need specificity
2. Multiple revenue models likely → Need focus
3. Technical vs business explanation unclear → Need audience
4. No time scope specified → Need context

**Optimized Output:**

### 📊 Context Assessment
- **completeness** → 0.3
- **critical_gaps** → Specific revenue types, Explanation purpose, Technical depth needed
- **summary** → Broad question needs focusing before providing useful answer
- **can_proceed** → false

### 🔍 Information Needed
- **schema_details** →
  <details>
  <summary>📋 <strong>Schema Details</strong> (1+ models)</summary>
  
  **revenue models (multiple likely)**: Revenue fields of interest, Recognition date fields | Relationships: Revenue to orders relationship, Time dimension usage
  
  </details>
- **business_logic** → Which revenue recognition standards apply (GAAP, IFRS)?, Specific revenue types of interest...and 1 more
- **technical_requirements** → Level of technical detail needed (SQL logic vs business overview), Specific use case...and 1 more
- **sample_data_needed** → false

### ❓ Follow-up Questions
- **Priority: CRITICAL**
  1. Which revenue types are you interested in: subscription, one-time sales, refunds, or all types? (Purpose: Focus explanation on relevant revenue streams | Impact: Explanation might be too broad or miss relevant details)
  2. Do you need the technical SQL implementation details or a business logic overview? (Purpose: Determine appropriate depth and format | Impact: Wrong level of detail provided)
- **Priority: HIGH** 
  1. What's the purpose: troubleshooting an issue, onboarding, compliance review, or general understanding? (Purpose: Tailor explanation to actual need)

### 🔎 Suggested Queries
1. **Map revenue model landscape** → `dbt ls --select '*revenue*' '*recognize*'` → All revenue-related models in the project
2. **Understand revenue recognition timing** → `SELECT AVG(DATEDIFF(day, order_date...` → Recognition patterns by revenue type

### 📚 Available Context
- **models_found** → fct_revenue (fact)... (1 total)
- **relevant_documentation** →
  <details>
  <summary>📖 <strong>Documentation Found</strong> (1 items)</summary>
  
  - **readme** @ models/marts/finance/README.md: Revenue recognition follows GAAP standards, Different rules for subscription vs one-time
  
  </details>
- **sample_data** → available: false

## CURSOR AGENT OPTIMIZATION NOTES

### For Seamless Execution:
1. **Always assess completeness first** - don't proceed if critical gaps exist
2. **Prioritize questions by impact** - focus on blockers first
3. **Order queries by logical dependency** - discovery before validation
4. **Include execution guidance** - specify dbt commands vs SQL queries
5. **Set clear proceed/don't proceed flags** - guide next steps

### Error Prevention:
- Never assume model names without confirmation
- Always check for multiple models with similar names
- Include resource usage considerations in query suggestions
- Flag potential security/privacy concerns with sample data
- Consider downstream impacts of any changes

## USER APPROVAL CHECKPOINT
**After providing your analysis above, always end with:**

> Here's my analysis. If this looks right, respond **Proceed**; otherwise clarify.

## CHANGELOG
### v0.1.0 - 2025-06-16
- Initial version with context gap analysis
- Added systematic assessment framework
- Included prioritized questioning approach
- Optimized for Cursor agent execution workflow 