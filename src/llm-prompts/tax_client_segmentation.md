# Version: v1.0.0
# Last-Updated: 2025-01-27
# Owner: analytics-platform
# Description: Tax Client Segmentation MCP

# Tax Client Segmentation MCP

## PURPOSE
This prompt helps analytics engineers and Cline agents convert natural-language client segment criteria (age ≥ 50, forms_used = t5008, etc.) into SQL queries, execute them via Preset MCP, and return results. It includes governance controls, cost management, and audit logging for compliant client segment analysis.

## EXECUTION CHECKLIST
Before using this prompt, ensure you have:
- [ ] Access to Preset MCP (database_id = 3)
- [ ] User's requester role (data_privileged or standard)
- [ ] Valid tax_year parameter
- [ ] Clear understanding of requested fields

## EXPECTED INPUT
```yaml
segment_request:
  name: "segment_name_for_logging"
  criteria: "Natural language description of client segment criteria"
  tax_year: 2023  # Required
  requester_role: "data_privileged|standard"  # Affects data exposure permissions
  fields_requested: ["field1", "field2"]  # Optional, defaults to safe field set
  max_rows: 50000  # Optional, defaults to 10000
```

**Example:**
```yaml
segment_request:
  name: "high_income_seniors_t5008"
  criteria: "Clients aged 50 or older who used T5008 forms and have total income > 150000"
  tax_year: 2023
  requester_role: "standard"
  fields_requested: ["client_id", "age", "total_income", "forms_used"]
  max_rows: 25000
```

## STEP-BY-STEP EXECUTION WORKFLOW

### Step 1: Parse and Validate Input
**Actions to take:**
1. Verify `tax_year` is provided and is a valid 4-digit year
2. Confirm `requester_role` is either "data_privileged" or "standard"
3. Check if requested fields require special permissions
4. Set default values: `max_rows = 10000` if not specified

**Validation Rules:**
- `tax_year` is REQUIRED - return error if missing
- `requester_role` defaults to "standard" if not provided
- `fields_requested` defaults to safe field set: `["client_id", "age", "province", "total_income"]`

### Step 2: Apply Governance Controls
**CRITICAL SECURITY CHECKS:**
- **FORBIDDEN FIELDS** (always block): `sin`, `address`, `postal_code`, `street_address`
- **RESTRICTED FIELDS** (require confirmation if requester_role != "data_privileged"): `email`, `phone_number`

**Implementation:**
```python
forbidden_fields = ["sin", "address", "postal_code", "street_address"]
restricted_fields = ["email", "phone_number"]

for field in fields_requested:
    if field in forbidden_fields:
        return {"status":"error","stage":"validation","message":f"Field '{field}' cannot be exposed in segment queries"}
    
    if field in restricted_fields and requester_role != "data_privileged":
        # Ask for explicit confirmation
        confirm = input(f"⚠️  Field '{field}' contains sensitive data. Confirm access? (yes/no): ")
        if confirm.lower() != "yes":
            return {"status":"error","stage":"validation","message":"Access to sensitive field denied"}
```

### Step 3: Build Base Query Structure
**Standard Table Aliases (REQUIRED):**
```sql
tax_app.parsed_tax_returns AS ptr
tax_backroom.prep_tax_returns AS fct  
business_summary.identity_profile AS id
```

**Non-negotiable WHERE clauses:**
```sql
WHERE fct.submitted_at IS NOT NULL
  AND fct.tax_year = {tax_year}
  AND id.is_ws_employee != 'true'
```

### Step 4: Translate Natural Language to SQL
**Common Translation Patterns:**
- Age ranges: `EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM id.birth_date) >= {age}`
- Income thresholds: `ptr.total_income > {amount}`
- Form types: `ptr.forms_used LIKE '%{form_type}%'` or `ptr.forms_used = '{form_type}'`
- Province filters: `id.province IN ('{prov1}', '{prov2}')`

### Step 5: Execute Cost Guardrail
**MANDATORY COST CHECK:**
```sql
EXPLAIN SELECT COUNT(*) FROM (
  -- Your generated query here without LIMIT
);
```

**Cost Decision Logic:**
- If estimated rows > 10M: **STOP** and prompt user to add more filters
- If estimated rows 1M-10M: **WARN** user about high volume
- If estimated rows < 1M: **PROCEED** with execution

**Suggested filters for high volume:**
- Add age ranges (e.g., "between 25 and 65")
- Add income brackets (e.g., "income between 50000 and 200000")
- Add province restrictions (e.g., "in Ontario and British Columbia")
- Add specific form types (e.g., "only T4 forms")

### Step 6: Execute Query and Log
**Query Execution:**
1. Run the final query via Preset MCP with `database_id = 3`
2. Capture execution time and row count
3. Format results appropriately

**Mandatory Logging:**
```sql
INSERT INTO analytics_logs.client_segment_runs 
VALUES (
  '{segment_name}',
  current_user,
  current_timestamp,
  md5('{sql_query}'),
  {row_count}
);
```

## FAIL-SAFE ERROR HANDLING

**Error Response Format (ALWAYS use this structure):**
```json
{
  "status": "error",
  "stage": "<parsing|validation|query_building|execution|logging>",
  "message": "<human-readable error description>",
  "suggested_action": "<specific action user should take>"
}
```

**Common Error Scenarios and Responses:**
```json
// Missing tax_year
{"status":"error","stage":"validation","message":"tax_year is required for all client segment queries","suggested_action":"Add tax_year parameter (e.g., tax_year: 2023)"}

// Forbidden field request
{"status":"error","stage":"validation","message":"SIN and address fields cannot be exposed in segment queries","suggested_action":"Remove sensitive fields and use client_id for identification"}

// High volume estimate  
{"status":"error","stage":"query_building","message":"Estimated 15M rows exceeds 10M limit","suggested_action":"Add filters like: age range (25-65), income brackets (50k-200k), or specific provinces"}

// Query timeout
{"status":"error","stage":"execution","message":"Query timed out after 300 seconds","suggested_action":"Reduce date range, add more selective filters, or limit result set"}
```

## COMPLETE EXAMPLE EXECUTION

**Input:**
```yaml
segment_request:
  name: "seniors_with_rrsp_withdrawals"
  criteria: "Clients over 65 years old who had RRSP withdrawals greater than 10000 in tax year 2023"
  tax_year: 2023
  requester_role: "standard"
  fields_requested: ["client_id", "age", "rrsp_withdrawal_amount", "province"]
  max_rows: 5000
```

**Generated SQL:**
```sql
WITH client_segment AS (
  SELECT 
    id.client_id,
    EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM id.birth_date) AS age,
    ptr.rrsp_withdrawal_amount,
    id.province
  FROM tax_backroom.prep_tax_returns fct
  JOIN tax_app.parsed_tax_returns ptr ON fct.return_id = ptr.return_id
  JOIN business_summary.identity_profile id ON fct.client_id = id.client_id
  WHERE fct.submitted_at IS NOT NULL
    AND fct.tax_year = 2023
    AND id.is_ws_employee != 'true'
    AND EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM id.birth_date) > 65
    AND ptr.rrsp_withdrawal_amount > 10000
  LIMIT 5000
)
SELECT * FROM client_segment;
```

**Success Response:**
```json
{
  "status": "success",
  "segment_name": "seniors_with_rrsp_withdrawals",
  "query_executed": "WITH client_segment AS (...)",
  "row_count": 1247,
  "execution_time_ms": 2340,
  "cost_estimate": "Low (under 1M rows estimated)",
  "governance_checks": "Passed - no sensitive fields requested",
  "results": [
    {"client_id": "c123", "age": 67, "rrsp_withdrawal_amount": 15000, "province": "ON"},
    {"client_id": "c456", "age": 71, "rrsp_withdrawal_amount": 12500, "province": "BC"}
  ]
}
```

## CURSOR AGENT OPTIMIZATION NOTES

**For seamless Cursor execution:**
1. **Always validate inputs first** - don't proceed with invalid data
2. **Use the exact error format** provided above for consistency
3. **Include cost estimates** in all responses for transparency
4. **Show the actual SQL** generated for debugging
5. **Log every execution** for audit compliance
6. **Use structured responses** - avoid plain text outputs

## CHANGELOG

### v1.0.0 - 2025-01-27
- Initial version with core client segmentation functionality
- Implemented governance controls for sensitive data
- Added cost guardrails and audit logging
- Established standard table aliases and required WHERE clauses
- Optimized for Cursor agent execution with step-by-step workflow 