# Version: v0.1.0
# Last-Updated: 2025-06-16
# Owner: analytics-platform
# Description: Execute dbt build and pytest tests

# Run Tests Prompt

## PURPOSE
This prompt runs `dbt build --select {{ models }}` followed by `pytest tests/prompt_formatting` to ensure both data models and prompt formatting are validated. It provides comprehensive testing workflow with clear success/failure reporting.

## CURSOR AGENT EXECUTION GUIDE
**Use this prompt AFTER code generation** to validate both dbt models and prompt formatting before reconciliation.

### Pre-Execution Checklist
- [ ] Target models are clearly identified
- [ ] dbt project is properly configured  
- [ ] pytest environment is set up
- [ ] All dependencies are installed

## EXECUTION WORKFLOW

### Step 1: Execute dbt Build
**Command pattern:**
```bash
dbt build --select {{ models }}
```

**This command will:**
- Compile and run the selected models
- Execute all associated tests
- Validate data quality and integrity
- Check for any schema issues

### Step 2: Execute pytest Validation
**Command pattern:**
```bash
pytest tests/prompt_formatting -v
```

**This will validate:**
- Prompt formatting consistency
- Template structure compliance
- Required sections presence
- Output format validation

## MANDATORY OUTPUT FORMAT
**Use this compact Markdown format:**

### 🧪 Test Execution Summary
- **dbt_command** → `dbt build --select model1 model2...`
- **dbt_execution_time** → 1m 23s
- **dbt_status** → ✅ PASSED | ⚠️ WARNING | ❌ FAILED
- **dbt_models_built** → 3 models (3 successful, 0 failed)
- **dbt_tests_run** → 12 tests (11 passed, 1 warning)

### 🐍 Pytest Results Summary  
- **pytest_command** → `pytest tests/prompt_formatting -v`
- **pytest_execution_time** → 0m 15s
- **pytest_status** → ✅ PASSED | ❌ FAILED
- **tests_discovered** → 25 tests
- **tests_results** → 24 passed, 1 failed

### 📊 Combined Test Results
| Test Suite | Status | Duration | Tests Run | Passed | Failed | Warnings |
|------------|--------|----------|-----------|--------|--------|----------|
| dbt build | ✅ PASSED | 1m 23s | 12 | 11 | 0 | 1 |
| pytest formatting | ✅ PASSED | 0m 15s | 25 | 24 | 1 | 0 |
| **OVERALL** | ⚠️ WARNING | 1m 38s | 37 | 35 | 1 | 1 |

### 🔍 Detailed Results
**dbt Build Issues:**
<details>
<summary>⚠️ <strong>Warnings Found</strong> (1 warning)</summary>

- **fct_orders**: Performance warning - query execution > 30s
  - **Impact**: Model builds slowly but successfully  
  - **Action**: Consider optimization in future iteration

</details>

**pytest Failures:**
<details>
<summary>❌ <strong>Test Failures</strong> (1 failure)</summary>

- **test_prompt_format_consistency**: prompt_validation.py::test_mandatory_sections
  - **Error**: Missing USER APPROVAL CHECKPOINT section in validate_risk.md
  - **Action**: Add required section to pass validation

</details>

### 🎯 Next Steps
**If all tests pass (🟢):** 
- ✅ Proceed to reconciliation step
- 🔄 Chain to `getReconcilePrompt`

**If warnings only (🟡):**
- ⚠️ Review warnings but can proceed
- 📝 Document acceptable variances  
- 🔄 Proceed to reconciliation with notes

**If failures exist (🔴):**
- ❌ Address failing tests before proceeding
- 🛠️ Fix issues and re-run tests
- ⏸️ Block reconciliation until all tests pass

## STEP-BY-STEP EXECUTION PROCESS

### Step 1: Validate Environment Setup
```bash
# Check dbt installation and project
dbt --version
dbt debug

# Check pytest installation  
pytest --version
python -m pytest --collect-only tests/prompt_formatting
```

### Step 2: Execute dbt Build with Monitoring
```bash
# Run dbt build with detailed output
dbt build --select {{ models }} --profiles-dir ~/.dbt --log-level info
```

**Monitor for:**
- Compilation errors
- Model build failures  
- Test execution failures
- Performance warnings
- Resource usage

### Step 3: Execute pytest Validation
```bash
# Run pytest with verbose output
pytest tests/prompt_formatting -v --tb=short
```

**Monitor for:**
- Test discovery issues
- Formatting validation failures
- Template compliance errors
- Missing required sections

### Step 4: Analyze Combined Results
**Success criteria:**
- All dbt models build successfully
- All dbt tests pass (warnings acceptable)
- All pytest formatting tests pass
- No critical errors in either test suite

## OPTIMIZED EXAMPLE EXECUTION

### Example: Testing Orders Pipeline Updates
**Models:** `stg_orders`, `fct_orders`

**Execution Commands:**
```bash
dbt build --select stg_orders fct_orders
pytest tests/prompt_formatting -v
```

**Expected Output:**

### 🧪 Test Execution Summary
- **dbt_command** → `dbt build --select stg_orders fct_orders`
- **dbt_execution_time** → 45s
- **dbt_status** → ✅ PASSED
- **dbt_models_built** → 2 models (2 successful, 0 failed)
- **dbt_tests_run** → 8 tests (8 passed, 0 warnings)

### 🐍 Pytest Results Summary  
- **pytest_command** → `pytest tests/prompt_formatting -v`
- **pytest_execution_time** → 12s
- **pytest_status** → ✅ PASSED
- **tests_discovered** → 25 tests
- **tests_results** → 25 passed, 0 failed

### 📊 Combined Test Results
| Test Suite | Status | Duration | Tests Run | Passed | Failed | Warnings |
|------------|--------|----------|-----------|--------|--------|----------|
| dbt build | ✅ PASSED | 45s | 8 | 8 | 0 | 0 |
| pytest formatting | ✅ PASSED | 12s | 25 | 25 | 0 | 0 |
| **OVERALL** | ✅ PASSED | 57s | 33 | 33 | 0 | 0 |

### 🎯 Next Steps
**Status: ✅ ALL TESTS PASSED**
- 🚀 Ready to proceed to reconciliation
- 📋 All validations successful
- ⏭️ Chaining to `getReconcilePrompt`

## ERROR HANDLING

### dbt Build Failures
**Common failure scenarios:**
- **Compilation errors**: Check SQL syntax and dbt syntax
- **Missing dependencies**: Ensure upstream models exist  
- **Test failures**: Review data quality issues
- **Connection issues**: Verify database connectivity

**Resolution steps:**
1. Review detailed error logs
2. Fix identified SQL/config issues
3. Re-run with `--debug` flag for more detail
4. Address upstream dependency issues

### pytest Failures
**Common failure scenarios:**
- **Missing sections**: Add required prompt sections
- **Format inconsistencies**: Standardize prompt formatting
- **Template violations**: Follow prescribed template structure
- **Import errors**: Check test file dependencies

**Resolution steps:**
1. Review specific test failure details
2. Update prompt files to meet requirements
3. Re-run pytest with `-x` flag to stop on first failure
4. Validate fixes with targeted test runs

### Combined Validation Strategy
**If either test suite fails:**
- ❌ Block progression to reconciliation
- 📝 Provide specific remediation steps
- 🔄 Require re-execution after fixes
- ⚠️ Document any acceptable variances

## AUTOMATION CHAIN INTEGRATION

### Chain Flow: `getRunDbtPrompt` → `getRunTestsPrompt` → `getReconcilePrompt`

**Entry conditions:**
- Code generation completed
- Models ready for testing
- Environment properly configured

**Exit conditions:**
- **✅ SUCCESS**: Chain to `getReconcilePrompt` automatically
- **⚠️ WARNING**: Prompt user to review before chaining  
- **❌ FAILURE**: Block chain, require remediation

**Chain triggers:**
```bash
# Successful completion automatically triggers:
getReconcilePrompt(models={{ models }})
```

### Auto-Progression Logic
**All tests pass:** → Auto-chain to reconciliation
**Warnings only:** → Prompt for user confirmation
**Any failures:** → Stop chain, require manual intervention

## CURSOR AGENT OPTIMIZATION NOTES

### For Seamless Execution:
1. **Parallel test execution** when possible
2. **Clear failure categorization** (critical vs warning)
3. **Specific remediation guidance** for each failure type
4. **Automated chain progression** on success
5. **Comprehensive logging** for debugging

### Error Prevention:
- Validate environment before test execution
- Check for required dependencies upfront
- Set appropriate timeouts for long-running tests
- Provide rollback instructions for partial failures
- Include retry logic for transient failures

### 🔄 NEXT MCP PROMPT
**After completing test execution:**
- **If all tests pass (🟢)**: Use `getReconcilePrompt` to reconcile with production systems
- **If failures exist (🔴)**: Use `getTestResultsPrompt` to analyze failures and get fix recommendations  
- **If warnings only (🟡)**: Use `getReconcilePrompt` but include warning context in reconciliation

## USER APPROVAL CHECKPOINT
**After providing your test results above, always end with:**

> Here's the draft plan. Respond **Proceed** to continue or **Revise** to change course.

## CHANGELOG
### v0.1.0 - 2025-06-16
- Initial version with dbt build and pytest execution
- Added comprehensive test result reporting
- Included automated chain progression logic
- Optimized for Cursor agent execution workflow 