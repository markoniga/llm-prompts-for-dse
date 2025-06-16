# Semantic Commit Notepad

**Version**: 2.0.0  
**Last Updated**: 2024-01-15T10:30:00Z  
**Changelog**: Added comprehensive reconciliation commit templates, metadata integration, structured reconciliation information

## What is Semantic Commit?

Semantic commit messages follow a structured format that helps communicate the **intent** of a change. This makes it easier to understand the history of a project, automate releases, and generate changelogs.

## Basic Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

- **type**: The kind of change (see below for common types)
- **scope**: (optional) The part of the codebase affected (e.g., `api`, `auth`, `ui`, `schema`, `models`)
- **description**: A short summary of the change (imperative, lower case)
- **body**: (optional) More detailed explanation
- **footer**: (optional) Issues closed, breaking changes, etc.

---

## Common Types

- **feat**: A new feature
- **fix**: A bug fix
- **docs**: Documentation only changes
- **style**: Changes that do not affect meaning (formatting, missing semi-colons, etc.)
- **refactor**: Code change that neither fixes a bug nor adds a feature
- **perf**: Performance improvement
- **test**: Adding or correcting tests
- **chore**: Changes to the build process or auxiliary tools
- **schema**: Database schema changes (migrations, model updates)
- **data**: Data-related changes (reconciliation, backfills, corrections)
- **reconcile**: Schema/data reconciliation between environments

---

## Examples

### 1. Feature
```
feat(auth): add JWT authentication middleware
```

### 2. Bug Fix
```
fix(api): handle null user in getProfile endpoint
```

### 3. Documentation
```
docs(readme): update installation instructions
```

### 4. Refactor
```
refactor(user-service): simplify user lookup logic
```

### 5. Chore
```
chore(deps): update dependency eslint to v8.0.0
```

### 6. Breaking Change
```
feat(api): remove deprecated /v1/users endpoint

BREAKING CHANGE: The /v1/users endpoint has been removed. Use /v2/users instead.
```

### 7. Closing an Issue
```
fix(login): correct password validation

Closes #123
```

---

## RECONCILIATION COMMIT TEMPLATES

When committing reconciliation changes, use these structured templates to capture comprehensive information:

### Full Reconciliation Commit Template
```
reconcile({{ scope }}): {{ reconciliation_summary }}

RECONCILIATION REPORT:
{{ reconciliation_table_summary }}

CHANGES APPLIED:
{{ detailed_changes }}

IMPACT ASSESSMENT:
{{ impact_metrics }}

VALIDATION RESULTS:
{{ validation_summary }}

{{ optional_footers }}
```

### Schema Reconciliation Example
```
reconcile(schema): sync dev_moniga with production schema

RECONCILIATION REPORT:
- Models Analyzed: 12 models
- Schema Changes: 8 modifications detected
- Data Impact: 2.4M rows across 3 tables
- Risk Level: MEDIUM (2 breaking changes)

CHANGES APPLIED:
✅ users: Added email_verified column (VARCHAR(10))
✅ orders: Modified order_total type INT→DECIMAL(10,2)  
⚠️  payments: Removed deprecated legacy_id column
🆕 user_preferences: New model added (156K rows)

IMPACT ASSESSMENT:
- Downstream Models: 5 models require updates
- Data Volume: +156K new rows, -0 deleted rows
- Performance: Query time improved by 15%
- Breaking Changes: legacy_id removal affects user_analytics

VALIDATION RESULTS:
- Data Quality: ✅ All checks passed
- Referential Integrity: ✅ Maintained
- Row Count Validation: ✅ dev_moniga matches expected
- Downstream Tests: ✅ 45/45 tests passing

Production Ready: Requires coordination with analytics team
Related: DEV-789, JIRA-456
```

### Data Migration Reconciliation
```
reconcile(data): migrate customer data to new schema structure  

RECONCILIATION REPORT:
- Migration Scope: customer_profiles, customer_preferences
- Records Migrated: 1.2M customer records
- Data Validation: 100% success rate
- Downtime: 15 minutes scheduled maintenance

CHANGES APPLIED:
✅ customer_profiles: Migrated to normalized structure
✅ customer_preferences: Split preferences into separate table
✅ Referential integrity: All foreign keys maintained
✅ Indexes: Recreated for optimal performance

IMPACT ASSESSMENT:
- Storage Reduction: 25% space savings (180GB → 135GB)
- Query Performance: 40% improvement on customer lookups
- Application Updates: 3 services require configuration changes
- Dashboard Impact: 2 BI dashboards need minor updates

VALIDATION RESULTS:
- Pre-migration row count: 1,234,567
- Post-migration row count: 1,234,567  
- Data integrity checks: ✅ PASSED
- Performance benchmarks: ✅ IMPROVED
- Rollback plan: ✅ VERIFIED

BREAKING CHANGE: customer_profile.preferences column removed
Migration executed: 2024-01-15 02:00 UTC
Rollback available until: 2024-01-22 02:00 UTC
```

### Model Development Reconciliation
```
reconcile(models): align dbt models between dev and production

RECONCILIATION REPORT:
- Branch: feature/customer-analytics vs main  
- Models Changed: 4 models modified, 2 models added
- dbt Build Status: ✅ All models compiled successfully
- Test Coverage: 18/18 data tests passing

CHANGES APPLIED:
🔄 customer_lifetime_value: Updated calculation logic
🔄 monthly_revenue: Added region segmentation  
🔄 churn_prediction: Improved feature engineering
🆕 customer_cohorts: New cohort analysis model
🆕 retention_metrics: New retention tracking model
🗑️ temp_customer_analysis: Removed temporary model

IMPACT ASSESSMENT:
- Computation Time: Reduced by 22% (45min → 35min)
- Data Freshness: Improved to hourly updates
- Storage Impact: +2.3GB for new models
- Query Dependencies: 8 downstream models verified

VALIDATION RESULTS:
- Model Compilation: ✅ SUCCESS  
- Data Tests: ✅ 18/18 PASSED
- Documentation: ✅ All models documented
- Performance Tests: ✅ Within SLA limits
- Cross-environment Validation: ✅ PASSED

Ready for production deployment
dbt Cloud Job: #2847 queued for execution
```

### Emergency Reconciliation Rollback
```
reconcile(rollback): emergency rollback of schema changes

RECONCILIATION REPORT:
- Incident: Production query failures after schema deployment
- Affected Models: user_analytics, customer_segments  
- Downtime: 23 minutes
- Recovery Method: Schema rollback + data restoration

CHANGES APPLIED:
⏪ users table: Restored legacy_id column
⏪ orders table: Reverted order_total to INT type
⏪ dbt models: Rolled back to previous manifest
⏪ Materialization: Restored incremental strategy

IMPACT ASSESSMENT:
- Service Recovery: All systems operational
- Data Loss: 0 records lost
- Query Performance: Restored to baseline
- Downstream Services: All dependencies restored

VALIDATION RESULTS:
- Data Integrity: ✅ VERIFIED
- Application Health: ✅ ALL SERVICES UP
- Dashboard Functionality: ✅ RESTORED  
- Alert Status: ✅ ALL CLEAR

INCIDENT RESOLUTION:
- Root Cause: Insufficient downstream impact analysis
- Prevention: Enhanced pre-deployment validation
- Monitoring: Added schema change alerting
- Documentation: Updated rollback procedures

Incident: INC-2024-001
Post-mortem: Due 2024-01-20
```

---

## RECONCILIATION INFORMATION INTEGRATION

When using automated reconciliation tools, include this structured information:

### Required Reconciliation Metadata
```
RECONCILIATION METADATA:
- Source Schema: {{ dev_schema }}
- Target Schema: {{ production_schema }}  
- Reconciliation Tool: {{ tool_name }}
- Execution Time: {{ duration }}
- User: {{ username }}
- Branch: {{ git_branch }}
- Commit Hash: {{ git_hash }}
```

### Reconciliation Tables in Commit Body
Include key reconciliation tables directly in commit messages:

```
SCHEMA COMPARISON SUMMARY:
| Model | Production | Development | Status | Risk |
|-------|------------|-------------|---------|------|
| users | 2.4M rows | 2.4M rows | ✅ MATCH | LOW |
| orders | 15.6M rows | 15.7M rows | ⚠️ DIFF | MED |
| payments | 8.2M rows | 8.2M rows | ✅ MATCH | LOW |

CHANGE IMPACT MATRIX:
| Change Type | Count | Affected Rows | Downstream Impact |
|-------------|-------|---------------|-------------------|
| Column Added | 3 | 26M+ | 5 models require updates |
| Type Modified | 2 | 15.6M | 2 models need validation |
| Column Removed | 1 | 2.4M | 1 model breaking change |
```

### Automated Reconciliation Footer
```
🤖 AUTO-RECONCILIATION COMPLETE
Generated: {{ timestamp }}
Validation: {{ validation_status }}
Deployment: {{ deployment_readiness }}
```

---

## Data Reconciliation & Schema Changes

When working with data reconciliation, dbt models, and schema changes, use these patterns:

### Schema Changes
```
schema(users): add email_verified column to users table

- Added NOT NULL constraint with default false
- Updated dbt model to include new field
- Ran reconciliation against dev_schema
```

### Model Reconciliation
```
feat(models): reconcile customer_metrics model with production

- Added quarterly_revenue calculation
- Fixed date_created type mismatch (timestamp -> date)
- Verified downstream dependency compatibility

Reconciliation Plan: DEV-456
```

### Data Migration
```
data(reconciliation): migrate user preferences to new schema

- Backfilled 50K user records
- Validated data integrity post-migration
- Zero data loss confirmed

BREAKING CHANGE: Old preferences table will be deprecated in v2.1
```

### dbt Model Updates
```
feat(dbt): add incremental loading to transaction_summary

- Changed materialization from table to incremental
- Added updated_at column for incremental strategy
- Reduces build time from 45min to 8min
```

### Production Schema Sync
```
schema(sync): reconcile dev_moniga schema with production

- Added 3 new models: user_cohorts, revenue_metrics, churn_analysis
- Modified customer_lifetime_value column types
- Removed deprecated temp_analytics table

Production Deployment: Ready for merge
```

### Data Quality Fixes
```
fix(data): correct null handling in customer_segments model

- Added COALESCE for segment_type column
- Fixed join logic causing duplicate records
- Validated against production row counts

Data Impact: 0 records affected, logic improvement only
```

### Schema Rollback
```
revert(schema): rollback user_preferences table changes

- Reverted column type change timestamp -> varchar
- Restored original dbt materialization strategy
- Emergency rollback due to downstream model failures

Incident: INC-789
```

---

## Data-Specific Scopes

When committing data and schema-related changes, consider these scope options:

- **models**: dbt model changes
- **schema**: Database schema modifications
- **reconciliation**: Schema/data reconciliation activities
- **migration**: Data migration scripts
- **dbt**: dbt-specific configuration changes
- **warehouse**: Data warehouse structural changes
- **etl**: ETL pipeline modifications
- **sources**: Source table or data ingestion changes

### Examples with Data Scopes
```
feat(models): implement customer segmentation model
fix(reconciliation): resolve column type mismatch in orders table
chore(dbt): update dbt-core to v1.6.0
perf(warehouse): add indexing to improve query performance
docs(models): add documentation for new revenue models
```

---

## RECONCILIATION COMMIT BEST PRACTICES

### 1. Always Include Impact Assessment
```
IMPACT ASSESSMENT:
- Data Volume: X rows affected across Y tables
- Downstream Dependencies: Z models require updates  
- Performance Impact: Query time change of N%
- Risk Level: [LOW|MEDIUM|HIGH|CRITICAL]
```

### 2. Document Validation Results
```
VALIDATION RESULTS:
- Row Count Verification: ✅/❌
- Data Quality Checks: ✅/❌  
- Referential Integrity: ✅/❌
- Performance Benchmarks: ✅/❌
```

### 3. Include Deployment Readiness
```
DEPLOYMENT STATUS:
- Production Ready: [YES|NO|CONDITIONAL]
- Coordination Required: [List teams/systems]
- Rollback Plan: [VERIFIED|PENDING]
- Estimated Downtime: [Duration]
```

### 4. Reference Related Work
```
RELATED WORK:
- Jira Ticket: DEV-123
- Pull Request: #456  
- Reconciliation Report: Link
- Dependencies: List related commits
```

---

## Tips

- Keep the **description** concise (ideally under 72 characters).
- Use the **imperative mood** ("add", not "added" or "adds").
- Use **scope** to clarify what part of the code is affected.
- Use **body** for context or reasoning behind the change.
- Use **footer** for breaking changes or referencing issues.

### Data-Specific Tips

- **Always include impact assessment** for schema changes in the body
- **Reference reconciliation plans** when applicable (e.g., "Reconciliation Plan: DEV-123")
- **Specify data volume** for large migrations (e.g., "Migrated 2.5M records")
- **Note production readiness** status (e.g., "Production Deployment: Ready for merge")
- **Include rollback information** for high-risk changes
- **Validate downstream dependencies** and document in commit body
- **Use reconciliation tables** to provide clear change summaries
- **Include automated validation results** from reconciliation tools
- **Document coordination requirements** with other teams/systems

---

**Happy committing with comprehensive reconciliation information!**
