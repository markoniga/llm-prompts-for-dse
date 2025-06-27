# Version: v0.2.0
# Last-Updated: 2025-01-16
# Owner: data-eng
# Description: Simplified test results analysis - get to solutions faster

# Test Results Prompt

## PURPOSE
Quickly analyze dbt test results and provide clear, actionable next steps. **Focus on solutions, not lengthy explanations.**

## EXECUTION APPROACH
1. **Quick scan** - Pass/Fail counts and critical issues
2. **Prioritize failures** - Most critical first
3. **Actionable fixes** - Specific solutions, not abstract advice
4. **Clear next steps** - What to do immediately

## OUTPUT FORMAT (Streamlined)

### 📊 Test Summary
- **total_tests** → 45 tests
- **passed** → 38 ✅
- **failed** → 7 ❌
- **error_rate** → 15.6%
- **critical_failures** → 2 🔴 (data quality issues)

### ❌ Failed Tests Analysis
| Test | Model | Type | Severity | Fix | Status |
|------|-------|------|----------|-----|---------|
| not_null_orders_customer_id | fct_orders | data_quality | HIGH | Add WHERE filter | 🔴 CRITICAL |
| unique_customers_email | dim_customers | uniqueness | HIGH | Dedupe logic needed | 🔴 CRITICAL |
| positive_values_amount | fct_orders | business_rule | MEDIUM | Add validation | 🟡 REVIEW |

**Maximum 10 rows - focus on most critical failures**

### 🎯 Priority Actions
1. **CRITICAL** → Fix not_null failures (blocking deployment)
2. **HIGH** → Address uniqueness violations (data integrity)
3. **MEDIUM** → Review business rule failures (if time permits)

### 💡 Quick Fixes
- **Add null filters**: `WHERE customer_id IS NOT NULL`
- **Dedupe logic**: `QUALIFY ROW_NUMBER() OVER (PARTITION BY email ORDER BY created_at DESC) = 1`
- **Validation rules**: `WHERE order_amount > 0`

### 🔄 Next Action
**If critical failures:** Fix immediately before deployment
**If medium failures only:** Use `getFixupSuggestionsPrompt` for specific solutions
**If all pass:** Proceed with deployment

## EXAMPLES

### Example 1: Critical Failures (Must Fix)
**Input:** dbt test results showing null values and duplicate records

### 📊 Test Summary
- **total_tests** → 25 tests
- **passed** → 20 ✅
- **failed** → 5 ❌
- **error_rate** → 20%
- **critical_failures** → 3 🔴 (blocking deployment)

### ❌ Failed Tests Analysis
| Test | Model | Type | Severity | Fix | Status |
|------|-------|------|----------|-----|---------|
| not_null_customer_id | fct_orders | data_quality | HIGH | Add WHERE customer_id IS NOT NULL | 🔴 CRITICAL |
| unique_order_id | fct_orders | uniqueness | HIGH | Remove duplicate logic | 🔴 CRITICAL |
| not_null_order_date | fct_orders | data_quality | HIGH | Handle NULL dates | 🔴 CRITICAL |
| positive_amount | fct_orders | business_rule | MEDIUM | Add amount > 0 filter | 🟡 REVIEW |
| valid_status | fct_orders | business_rule | LOW | Update status mapping | 🟢 ACCEPTABLE |

### 🎯 Priority Actions
1. **CRITICAL** → Fix NULL value handling in fct_orders (3 tests failing)
2. **MEDIUM** → Add business rule validation for amount
3. **LOW** → Update status mapping when convenient

### 💡 Quick Fixes
- **NULL handling**: Add `WHERE customer_id IS NOT NULL AND order_date IS NOT NULL`
- **Duplicate prevention**: Review upstream data or add `DISTINCT`
- **Amount validation**: Add `WHERE order_amount > 0`

### Example 2: All Tests Passing (Ready to Deploy)
**Input:** Clean test run with no failures

### 📊 Test Summary
- **total_tests** → 32 tests
- **passed** → 32 ✅
- **failed** → 0 ❌
- **error_rate** → 0%
- **critical_failures** → 0 🟢

### 🎯 Priority Actions
✅ **ALL TESTS PASSED** - Ready for deployment

### 🔄 Next Action
Proceed with deployment - all data quality checks passed

### Example 3: Mixed Results (Some Action Needed)
**Input:** Most tests pass, few business rule violations

### 📊 Test Summary
- **total_tests** → 18 tests
- **passed** → 15 ✅
- **failed** → 3 ❌
- **error_rate** → 16.7%
- **critical_failures** → 0 🟢 (no blockers)

### ❌ Failed Tests Analysis
| Test | Model | Type | Severity | Fix | Status |
|------|-------|------|----------|-----|---------|
| accepted_values_status | dim_orders | business_rule | MEDIUM | Update status values | 🟡 REVIEW |
| relationships_customer | fct_orders | referential | MEDIUM | Check customer cleanup | 🟡 REVIEW |
| reasonable_dates | fct_orders | business_rule | LOW | Review date logic | 🟢 ACCEPTABLE |

### 🎯 Priority Actions
1. **MEDIUM** → Review status value mapping and customer references
2. **LOW** → Date logic review can be scheduled separately

### 💡 Quick Fixes
- **Status mapping**: Add missing status values to accepted list
- **Customer refs**: Check if customer cleanup affected foreign keys
- **Date validation**: Review business logic for date reasonableness

## TEST CATEGORIZATION

### 🔴 CRITICAL (Must Fix Before Deploy)
- **not_null** tests on primary keys
- **unique** tests on business keys
- **data_quality** tests for core fields
- **relationships** tests for critical foreign keys

### 🟡 MEDIUM (Should Fix Soon)
- **accepted_values** for enum fields
- **relationships** for non-critical references
- **business_rule** validations
- **custom** tests for data logic

### 🟢 LOW (Nice to Fix)
- **freshness** tests (unless SLA critical)
- **format** validation tests
- **documentation** tests
- **performance** tests

## COMMON FIXES

### Null Value Handling
```sql
-- Add null filters
WHERE column_name IS NOT NULL

-- Or use COALESCE for defaults
COALESCE(column_name, 'DEFAULT_VALUE') AS column_name
```

### Duplicate Resolution
```sql
-- Remove duplicates with window function
QUALIFY ROW_NUMBER() OVER (PARTITION BY key_field ORDER BY updated_at DESC) = 1

-- Or use DISTINCT for simple cases
SELECT DISTINCT column1, column2, ...
```

### Business Rule Validation
```sql
-- Add validation filters
WHERE amount > 0
  AND status IN ('active', 'pending', 'completed')
  AND date_field >= '2020-01-01'
```

## EFFICIENCY PRINCIPLES
1. **Fast triage** - Identify critical vs. non-critical failures quickly
2. **Specific fixes** - Provide exact SQL solutions where possible
3. **Priority ordering** - Critical issues first, nice-to-haves last
4. **Actionable guidance** - Clear next steps, not abstract advice

## 🔄 NEXT MCP PROMPT
- **Critical failures** → Fix immediately, then re-run tests
- **Medium failures** → Use `getFixupSuggestionsPrompt` for detailed solutions
- **All passed** → Proceed with deployment using `getRunDbtPrompt`
- **Need help with fixes** → Use `getGenerateCodePrompt` for specific implementations

## CHANGELOG
### v0.2.0 - 2025-01-16
- Simplified to table-based failure analysis
- Added clear severity classification
- Focused on actionable fixes over explanations
- Streamlined output format for faster decision-making
