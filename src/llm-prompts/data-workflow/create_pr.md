# Version: v0.2.0
# Last-Updated: 2025-01-16
# Owner: data-eng
# Description: Generate clear, comprehensive PR descriptions - streamlined format

# Create PR Prompt

## PURPOSE
Generate well-structured pull request descriptions that clearly communicate changes and impact. **Focus on reviewer experience and actionable information.**

## EXECUTION APPROACH
1. **Clear summary** - What was changed and why
2. **Impact assessment** - What this affects downstream
3. **Testing evidence** - Proof that changes work
4. **Reviewer guidance** - What to focus on during review

## OUTPUT FORMAT (Streamlined)

### 📝 PR Description Template

**Title:** `feat: [Brief description of main change]`

**Description:**
```markdown
## Summary
Brief description of what this PR accomplishes and why it was needed.

## Changes Made
### 🛠️ Model Changes
- **dim_customers**: Added `customer_tier` field from source data
- **fct_orders**: Updated join logic for improved performance

### 📊 Data Impact
| Model | Row Change | Schema Change | Risk Level |
|-------|------------|---------------|------------|
| dim_customers | +123 rows | Added 1 column | Low |
| fct_orders | No change | None | None |

### ✅ Testing Completed
- [x] All dbt tests pass (25/25)
- [x] Data reconciliation completed
- [x] Performance validated (<5min runtime)
- [x] Schema compatibility confirmed

## Review Focus
- Verify new `customer_tier` logic in `dim_customers.sql`
- Check test coverage for new field
- Confirm data quality checks are appropriate

## Deployment Notes
- Safe to deploy during business hours
- No downstream breaking changes
- Monitoring: Watch for customer tier distribution in dashboards
```

## EXAMPLES

### Example 1: Feature Addition (New Field)
**Input:** Added customer segmentation logic to dim_customers

**PR Title:** `feat: Add customer tier segmentation to dim_customers`

**PR Description:**
```markdown
## Summary
Adds customer tier logic to `dim_customers` to support marketing segmentation use cases. Tiers are calculated based on account balance and transaction history.

## Changes Made
### 🛠️ Model Changes
- **dim_customers**: Added `customer_tier` (BRONZE/SILVER/GOLD/PLATINUM) calculation
- **Updated logic**: Account balance + 90-day transaction volume determines tier
- **Dependencies**: No changes to upstream or downstream models

### 📊 Data Impact
| Model | Row Change | Schema Change | Risk Level |
|-------|------------|---------------|------------|
| dim_customers | 0 rows | Added 1 column | Low |

**Tier Distribution Preview:**
- BRONZE: ~60% of customers
- SILVER: ~25% of customers  
- GOLD: ~12% of customers
- PLATINUM: ~3% of customers

### ✅ Testing Completed
- [x] All dbt tests pass (18/18)
- [x] Data reconciliation: +0 rows, schema compatible
- [x] Tier logic validated with sample customers
- [x] Performance: 2.1 minutes (within baseline)

### 🧪 Test Results
```sql
-- Validation: All customers have valid tiers
SELECT customer_tier, COUNT(*) 
FROM dim_customers 
GROUP BY customer_tier;

-- BRONZE    27,456
-- SILVER    11,234  
-- GOLD       5,432
-- PLATINUM   1,234
```

## Review Focus
- **Business Logic**: Verify tier calculation in lines 45-65 of `dim_customers.sql`
- **Data Quality**: Check that all customers have non-null tiers
- **Performance**: Confirm query optimization (early filtering)

## Deployment Notes
- Safe for immediate deployment
- Marketing team expects this data for Q2 campaigns
- Monitor customer tier distribution in existing dashboards
```

### Example 2: Performance Optimization
**Input:** Optimized incremental strategy for fct_orders

**PR Title:** `perf: Optimize fct_orders incremental strategy for 50% faster builds`

**PR Description:**
```markdown
## Summary
Optimized `fct_orders` incremental strategy to reduce build time from 45 minutes to 22 minutes while maintaining data quality.

## Changes Made
### 🛠️ Model Changes
- **fct_orders**: Changed to `delete+insert` strategy with static timestamp
- **Optimization**: Early filtering before joins reduces processed rows by 70%
- **Clustering**: Added `order_date` clustering for faster reads

### 📊 Data Impact
| Model | Row Change | Schema Change | Risk Level |
|-------|------------|---------------|------------|
| fct_orders | 0 rows | None | Low |

**Performance Improvement:**
- Build time: 45min → 22min (51% faster)
- Rows processed: 15M → 4.5M (70% reduction)
- Resource usage: High → Medium

### ✅ Testing Completed
- [x] All dbt tests pass (22/22)  
- [x] Data reconciliation: Perfect match with production
- [x] Performance validated: 22 minutes vs 45 minutes baseline
- [x] Incremental strategy tested over 7-day period

### 📈 Performance Results
```bash
# Before optimization
dbt run --select fct_orders: 45min 23sec

# After optimization  
dbt run --select fct_orders: 22min 14sec
```

## Review Focus
- **Incremental Logic**: Verify static timestamp approach in config block
- **Data Integrity**: Confirm delete+insert strategy preserves all data
- **Clustering**: Check that `order_date` clustering is appropriate

## Deployment Notes
- **Timing**: Deploy during off-peak hours for first run
- **Monitoring**: Watch build times and data freshness
- **Rollback**: Can revert to previous strategy if issues arise
```

### Example 3: Bug Fix (Data Quality)
**Input:** Fixed null handling in customer ID joins

**PR Title:** `fix: Resolve null customer_id causing 24 missing orders in fct_orders`

**PR Description:**
```markdown
## Summary
Fixes null customer_id handling that was causing 24 orders to be dropped from `fct_orders`, impacting revenue reporting accuracy.

## Changes Made
### 🛠️ Model Changes
- **fct_orders**: Added null handling for customer_id joins
- **Logic**: Orders with null customer_id now use 'UNKNOWN_CUSTOMER' placeholder
- **Audit**: Added logging for orders with missing customer associations

### 📊 Data Impact
| Model | Row Change | Schema Change | Risk Level |
|-------|------------|---------------|------------|
| fct_orders | +24 rows | None | Low |

**Fixed Issues:**
- Revenue underreporting: $1,234 in missing order value
- Customer metrics: More accurate order attribution
- Data completeness: 99.98% → 100% order capture

### ✅ Testing Completed
- [x] All dbt tests pass (25/25)
- [x] Data reconciliation: +24 rows as expected
- [x] Null handling validated with test cases
- [x] Downstream impact: Revenue reports updated correctly

### 🔍 Root Cause Analysis
- **Issue**: Source system allows orders without customer assignment
- **Impact**: 24 orders/week average with null customer_id
- **Solution**: COALESCE to 'UNKNOWN_CUSTOMER' with audit trail

## Review Focus
- **Null Handling**: Verify COALESCE logic preserves order data
- **Business Logic**: Confirm 'UNKNOWN_CUSTOMER' approach is acceptable
- **Tests**: Check new test coverage for null scenarios

## Deployment Notes
- **Immediate**: Critical for accurate revenue reporting
- **Impact**: Finance dashboards will show +$1,234 correction
- **Follow-up**: Work with source system team to reduce null customer_ids
```

## PR DESCRIPTION TEMPLATES

### Feature Addition Template
```markdown
## Summary
[What was added and why]

## Changes Made
### 🛠️ Model Changes
- **[model_name]**: [Specific change description]

### 📊 Data Impact
[Table showing row/schema changes]

### ✅ Testing Completed
[Checklist of completed validations]

## Review Focus
[What reviewers should pay attention to]

## Deployment Notes
[Important deployment considerations]
```

### Performance Optimization Template
```markdown
## Summary
[Performance improvement achieved and how]

## Changes Made
### 🛠️ Model Changes
[Technical changes made]

### 📈 Performance Results
[Before/after metrics]

## Review Focus
[Performance-specific review points]

## Deployment Notes
[Performance-related deployment considerations]
```

### Bug Fix Template
```markdown
## Summary
[Bug description and fix approach]

## Changes Made
### 🛠️ Model Changes
[Specific fixes implemented]

### 🔍 Root Cause Analysis
[Why the issue occurred and prevention]

## Review Focus
[Bug-specific review points]

## Deployment Notes
[Urgency and impact considerations]
```

## TITLE CONVENTIONS

### Prefix Standards
- `feat:` - New features or functionality
- `fix:` - Bug fixes or data corrections
- `perf:` - Performance improvements
- `refactor:` - Code restructuring without functional changes
- `test:` - Test additions or improvements
- `docs:` - Documentation updates only

### Title Examples
- `feat: Add customer lifetime value calculation to dim_customers`
- `fix: Correct duplicate handling in fct_transactions`
- `perf: Reduce dim_products build time by 60% with partitioning`
- `refactor: Standardize date logic across fact tables`

## REVIEWER GUIDANCE

### What to Include
- **Clear change summary** - What and why
- **Impact assessment** - Who/what this affects
- **Testing evidence** - Proof of validation
- **Review focus** - Where to spend attention
- **Deployment notes** - Timing and monitoring needs

### What to Avoid
- Overly technical implementation details
- Lengthy code explanations
- Redundant information
- Vague impact descriptions
- Missing test evidence

## 🔄 NEXT MCP PROMPT
- **After PR creation** → Use `getMergeGuardPrompt` to validate readiness for merge
- **If additional changes needed** → Use `getFixupSuggestionsPrompt` for improvements
- **If deployment planning** → Use deployment coordination tools
- **If documentation needed** → Use `getGenDocsPrompt` for comprehensive documentation

## CHANGELOG
### v0.2.0 - 2025-01-16
- Simplified PR description templates
- Added clear impact assessment tables
- Focused on reviewer experience
- Streamlined deployment guidance
