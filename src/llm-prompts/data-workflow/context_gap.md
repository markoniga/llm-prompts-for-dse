# Version: v0.2.0
# Last-Updated: 2025-01-16
# Owner: analytics-platform
# Description: Focused context gathering - get what's needed, move forward

# Context Gap Prompt

## PURPOSE
**Simple goal:** Identify missing information to complete the user's request. **Get what you need, then proceed.**

## EXECUTION APPROACH
1. **Quick assessment** - Is context complete enough? (0.7+ = proceed)
2. **Focus on blockers** - What specifically prevents moving forward?
3. **Ask targeted questions** - Max 3 essential questions
4. **Suggest queries** - Only if needed to gather schema/data info

## OUTPUT FORMAT (Streamlined)

### 📊 Context Assessment
- **completeness** → 0.0-1.0 
- **can_proceed** → true|false
- **blockers** → What's preventing progress (if any)

### 🔍 Missing Information (if needed)
**Schema gaps:**
- Model1: field types, relationships
- Model2: constraints, source columns

**Business logic gaps:**  
- Rule1: calculation method unclear
- Rule2: edge case handling

**Technical gaps:**
- Requirement1: performance expectations
- Requirement2: testing approach

### ❓ Essential Questions (max 3)
1. **CRITICAL:** Question about blocking information
2. **HIGH:** Important but not blocking  
3. **MEDIUM:** Nice to have for completeness

### 🔎 Suggested Discovery (if needed)
**Schema queries:**
```sql
-- Find schema patterns from actual usage
SELECT * FROM preset.audit_logs 
WHERE entity_type='urn:preset:ws:sqllab' 
AND details LIKE '%your_table_pattern%'
```

**Model discovery:**
```bash
dbt ls --select '*pattern*'
```

### 🛠️ Next Action
**If can_proceed = true:** Use `getGenerateCodePrompt` | Use `getGenDocsPrompt` | Use `getValidateRiskPrompt`
**If can_proceed = false:** Need answers to critical questions first

## EXAMPLES

### Example 1: Ready to Proceed
**Input:** "Add customer_tier VARCHAR(20) field to dim_customers, should be nullable, comes from stg_customers.tier"

### 📊 Context Assessment
- **completeness** → 0.8
- **can_proceed** → true  
- **blockers** → None - enough info to proceed

### 🛠️ Next Action
**Ready to proceed:** Use `getGenerateCodePrompt`

### Example 2: Need Clarification
**Input:** "Add promotion field to orders"

### 📊 Context Assessment
- **completeness** → 0.4
- **can_proceed** → false
- **blockers** → Unclear which orders model, field specification incomplete

### 🔍 Missing Information
**Schema gaps:**
- Orders: which model (stg_orders, fct_orders, dim_orders?)
- Promotion: data type, constraints, source column

**Technical gaps:**
- Testing: what validation needed
- Impact: downstream dependencies

### ❓ Essential Questions
1. **CRITICAL:** Which orders model needs the promotion field?
2. **HIGH:** What data type and constraints for the promotion field?
3. **MEDIUM:** Are there downstream models that reference this?

### 🔎 Suggested Discovery
**Find orders models:**
```bash
dbt ls --select '*order*'
```

### 🛠️ Next Action
**Need answers:** Cannot proceed until critical questions answered

## EFFICIENCY RULES
1. **Don't over-analyze** - If 70%+ complete, suggest proceeding
2. **Focus on blockers** - Only ask about info that prevents action
3. **Practical discovery** - Suggest actual queries that help
4. **Clear decisions** - Always say proceed or wait

## 🔄 NEXT MCP PROMPT
- **can_proceed = true + code request** → `getGenerateCodePrompt`
- **can_proceed = true + question** → `getGenDocsPrompt`  
- **can_proceed = true + risky change** → `getValidateRiskPrompt`
- **can_proceed = false** → Wait for user answers, then re-assess

Here's my analysis. If this looks right, respond **Proceed**; otherwise clarify.

## CHANGELOG
### v0.2.0 - 2025-01-16
- Simplified format for faster decision making
- Removed verbose analysis sections
- Added clear proceed/don't proceed logic
- Focused on essential questions only 