# Version: v0.2.0
# Last-Updated: 2025-01-16
# Owner: data-eng
# Description: Quick risk assessment - streamlined for better decision making

# Validate Risk Prompt

## PURPOSE
Quickly assess risks in data operations to determine if they're safe to proceed. **Focus on actionable decisions, not lengthy analysis.**

## EXECUTION APPROACH
1. **Quick risk scan** - Identify top 3-5 critical risks
2. **Simple severity** - HIGH/MEDIUM/LOW only
3. **Clear decision** - Proceed/Wait/Block
4. **Practical safeguards** - What specific actions to take

## OUTPUT FORMAT (Mandatory Table Format)

### ⚠️ Risk Assessment Summary
| Risk | Severity | Impact | Safeguard | Status |
|------|----------|---------|-----------|--------|
| Data Loss | HIGH | 2M rows affected | Backup required | 🔴 CRITICAL |
| Performance | MEDIUM | 30min execution | Off-hours scheduling | 🟡 MODERATE |
| Cost | LOW | <$50 | Monitor usage | 🟢 ACCEPTABLE |

**Maximum 5 rows - focus on most critical risks only**

### 📊 Quick Analysis
- **operation** → DELETE|INSERT|UPDATE|CREATE|ALTER|SELECT
- **scope** → 1.2M rows, 500MB data
- **time_estimate** → 15 minutes
- **resource_impact** → CPU: high, Memory: medium

### 🎯 Decision
- **proceed** → true|false
- **confidence** → 0.8
- **recommendation** → Brief action recommendation
- **required_safeguards** → Backup, Off-hours execution, Monitoring

### 🔄 Next Action
**If proceed = true:** Use `getRunDbtPrompt`
**If proceed = false:** Use `getRollbackPlanPrompt` or address critical risks first

## EXAMPLES

### Example 1: High-Risk Operation (Recommend Block)
**Input:** `DELETE FROM orders WHERE order_date < '2024-01-01'`

### ⚠️ Risk Assessment Summary
| Risk | Severity | Impact | Safeguard | Status |
|------|----------|---------|-----------|--------|
| Data Loss | HIGH | 5M rows permanent deletion | Backup + verification | 🔴 CRITICAL |
| Compliance | HIGH | Regulatory data retention | Legal approval needed | 🔴 CRITICAL |
| Performance | MEDIUM | 45min execution time | Off-hours scheduling | 🟡 MODERATE |

### 📊 Quick Analysis
- **operation** → DELETE
- **scope** → 5M rows, 2GB data
- **time_estimate** → 45 minutes
- **resource_impact** → CPU: high, Memory: high

### 🎯 Decision
- **proceed** → false
- **confidence** → 0.95
- **recommendation** → Create archive strategy instead of deletion
- **required_safeguards** → Full backup, Legal approval, Batched approach, Verification queries

### Example 2: Medium-Risk Operation (Proceed with Caution)
**Input:** Change fct_orders materialization from incremental to table

### ⚠️ Risk Assessment Summary
| Risk | Severity | Impact | Safeguard | Status |
|------|----------|---------|-----------|--------|
| Performance | HIGH | 2+ hour rebuild time | Off-hours deployment | 🔴 CRITICAL |
| Availability | MEDIUM | Model unavailable during build | Notify users | 🟡 MODERATE |
| Cost | LOW | Higher compute usage | Monitor spend | 🟢 ACCEPTABLE |

### 📊 Quick Analysis
- **operation** → ALTER (materialization)
- **scope** → 15M rows, 8GB data
- **time_estimate** → 2 hours
- **resource_impact** → CPU: very high, Memory: high

### 🎯 Decision
- **proceed** → true
- **confidence** → 0.8
- **recommendation** → Schedule during maintenance window with stakeholder notification
- **required_safeguards** → Maintenance window, User notification, Resource monitoring

### Example 3: Low-Risk Operation (Safe to Proceed)
**Input:** `SELECT customer_id, SUM(order_total) FROM orders GROUP BY customer_id`

### ⚠️ Risk Assessment Summary
| Risk | Severity | Impact | Safeguard | Status |
|------|----------|---------|-----------|--------|
| Performance | LOW | <5min execution | Monitor during peak | 🟢 ACCEPTABLE |

### 📊 Quick Analysis
- **operation** → SELECT
- **scope** → Read-only aggregation
- **time_estimate** → 2 minutes
- **resource_impact** → CPU: low, Memory: low

### 🎯 Decision
- **proceed** → true
- **confidence** → 0.95
- **recommendation** → Safe to execute immediately
- **required_safeguards** → None required

## RISK CLASSIFICATION RULES

### 🔴 HIGH Risk (Block/Require Safeguards)
- Any DELETE/DROP/TRUNCATE operations
- Schema changes affecting >1M rows
- Operations without WHERE clauses
- Changes to critical business tables
- Operations during business hours on prod

### 🟡 MEDIUM Risk (Proceed with Caution)
- Large UPDATE operations
- Performance-intensive queries
- Schema changes with backcompat issues
- New model deployments
- Operations affecting reporting

### 🟢 LOW Risk (Safe to Proceed)
- SELECT queries
- Small data modifications (<10K rows)
- Documentation updates
- Adding nullable columns
- Development environment changes

## EFFICIENCY PRINCIPLES
1. **Quick decisions** - Assessment should take <2 minutes
2. **Action-focused** - Always provide clear next step
3. **Essential risks only** - Max 5 risks in summary table
4. **Practical safeguards** - Specific, implementable actions

## 🔄 NEXT MCP PROMPT
- **proceed = true + low risk** → `getRunDbtPrompt`
- **proceed = true + medium/high risk** → `getRollbackPlanPrompt` then `getRunDbtPrompt`
- **proceed = false** → Address critical risks or use `getRollbackPlanPrompt`

## CHANGELOG
### v0.2.0 - 2025-01-16
- Simplified to table-based risk assessment
- Focused on actionable decisions
- Reduced analysis time and cognitive load
- Added clear risk classification rules
