# Version: v0.1.0
# Last-Updated: 2025-06-16
# Owner: data-eng
# Description: Offer rollback scripts when risky

# Rollback Plan Prompt

## Purpose
This prompt helps create comprehensive rollback plans for risky data operations. It generates step-by-step instructions and SQL scripts to restore systems to their previous state if an operation fails or causes unexpected issues.

## Usage
Use this prompt when planning potentially risky data operations to ensure you have a clear path to recovery if something goes wrong.

## Input Context
- The operation being performed (SQL query, dbt model change, etc.)
- Current state of the affected systems and data
- Risk assessment from validate_risk prompt
- Available backup mechanisms
- Time constraints for recovery
- Business impact of extended downtime

## Output Format
```json
{
  "rollback_assessment": {
    "operation_summary": "Brief description of the original operation",
    "rollback_feasibility": "fully_recoverable|partially_recoverable|non_recoverable",
    "confidence": 0.0-1.0,
    "time_estimate": "Estimated time to complete rollback",
    "data_loss_risk": "none|minimal|significant|complete",
    "summary": "Brief summary of the rollback assessment"
  },
  "pre_execution_safeguards": [
    {
      "safeguard_type": "backup|snapshot|log|other",
      "description": "Description of the safeguard",
      "implementation": "How to implement this safeguard",
      "verification": "How to verify the safeguard is in place"
    }
  ],
  "rollback_plan": {
    "phases": [
      {
        "phase_name": "Name of the phase",
        "description": "Description of this phase",
        "steps": [
          {
            "step_number": 1,
            "description": "Description of the step",
            "command": "SQL command or other action to take",
            "verification": "How to verify this step was successful",
            "fallback": "What to do if this step fails"
          }
        ],
        "success_criteria": "How to determine if this phase was successful"
      }
    ],
    "verification_steps": [
      {
        "description": "Description of the verification step",
        "query": "Query to verify the rollback was successful",
        "expected_result": "Expected result of the verification query"
      }
    ]
  },
  "alternative_recovery_options": [
    {
      "option_name": "Name of the recovery option",
      "description": "Description of this recovery option",
      "when_to_use": "When this option should be used",
      "pros": ["Pro 1", "Pro 2"],
      "cons": ["Con 1", "Con 2"],
      "implementation": "How to implement this recovery option"
    }
  ],
  "post_rollback_actions": [
    {
      "action": "Action to take after rollback",
      "purpose": "Why this action is necessary",
      "implementation": "How to implement this action"
    }
  ],
  "communication_plan": {
    "stakeholders_to_notify": [
      {
        "group": "Stakeholder group",
        "when_to_notify": "When to notify this group",
        "message_template": "Template for the notification message"
      }
    ],
    "status_updates": {
      "frequency": "How often to provide status updates",
      "channels": ["Channel 1", "Channel 2"],
      "template": "Template for status updates"
    }
  }
}
```

## Instructions

1. **Analyze the operation**
   - Understand the nature and scope of the operation
   - Identify all affected systems and data
   - Determine the potential failure modes
   - Assess the criticality of the operation

2. **Determine rollback feasibility**
   - Evaluate if a complete rollback is possible
   - Identify any irreversible aspects of the operation
   - Assess potential data loss during rollback
   - Estimate time required for rollback

3. **Design pre-execution safeguards**
   - Identify appropriate backup mechanisms
   - Determine necessary snapshots or logs
   - Design verification steps for safeguards
   - Consider transaction boundaries

4. **Create a phased rollback plan**
   - Break the rollback into logical phases
   - Provide clear, sequential steps for each phase
   - Include specific commands or SQL queries
   - Add verification steps after each phase
   - Include fallback options for each step

5. **Develop verification procedures**
   - Create queries to verify data integrity
   - Design checks for system functionality
   - Establish success criteria for the rollback
   - Include comparison with pre-operation state

6. **Provide alternative recovery options**
   - Identify alternative approaches to recovery
   - Compare pros and cons of each approach
   - Specify when each alternative should be used
   - Include implementation details

7. **Plan post-rollback actions**
   - Identify necessary cleanup steps
   - Determine how to resume normal operations
   - Consider performance optimization after rollback
   - Plan for addressing the original issue

8. **Create a communication plan**
   - Identify stakeholders to notify
   - Determine appropriate communication channels
   - Create message templates
   - Establish update frequency

## Examples

### Example 1: Rollback Plan for Schema Change
Input: ALTER TABLE customer_orders ADD COLUMN loyalty_tier VARCHAR(20)

Output:
```json
{
  "rollback_assessment": {
    "operation_summary": "Adding a new loyalty_tier column to the customer_orders table",
    "rollback_feasibility": "fully_recoverable",
    "confidence": 0.95,
    "time_estimate": "5-10 minutes",
    "data_loss_risk": "none",
    "summary": "This schema change can be fully rolled back with minimal risk and downtime"
  },
  "pre_execution_safeguards": [
    {
      "safeguard_type": "backup",
      "description": "Create a backup of the table structure before modification",
      "implementation": "SHOW CREATE TABLE customer_orders; -- Save the output",
      "verification": "Confirm the output is saved and readable"
    },
    {
      "safeguard_type": "snapshot",
      "description": "Take a database snapshot if available in your environment",
      "implementation": "Use database-specific snapshot mechanism or backup tool",
      "verification": "Confirm snapshot completed successfully and is accessible"
    },
    {
      "safeguard_type": "test",
      "description": "Test the schema change in a development environment",
      "implementation": "Execute the same ALTER TABLE statement in development first",
      "verification": "Verify applications work correctly with the new schema"
    }
  ],
  "rollback_plan": {
    "phases": [
      {
        "phase_name": "Preparation",
        "description": "Prepare for the rollback by ensuring no processes are writing to the table",
        "steps": [
          {
            "step_number": 1,
            "description": "Identify any active processes using the table",
            "command": "-- Check for active database processes (use database-specific tools, not information_schema)\n-- Example: SHOW PROCESSLIST; (MySQL) or SELECT * FROM pg_stat_activity; (PostgreSQL)",
            "verification": "Confirm no critical processes are actively writing to the table",
            "fallback": "If critical processes are active, coordinate with application teams before proceeding"
          },
          {
            "step_number": 2,
            "description": "Optionally pause application connections if possible",
            "command": "Application-specific command to pause connections",
            "verification": "Confirm no new connections are being made",
            "fallback": "Proceed with caution if connections cannot be paused"
          }
        ],
        "success_criteria": "No active processes are writing to the table or a maintenance window is established"
      },
      {
        "phase_name": "Column Removal",
        "description": "Remove the newly added column",
        "steps": [
          {
            "step_number": 1,
            "description": "Drop the loyalty_tier column",
            "command": "ALTER TABLE customer_orders DROP COLUMN loyalty_tier;",
            "verification": "Confirm the column has been removed",
            "fallback": "If the command fails, check for dependencies on the column and address them first"
          }
        ],
        "success_criteria": "The column is successfully removed from the table"
      },
      {
        "phase_name": "Verification",
        "description": "Verify the table structure is back to its original state",
        "steps": [
          {
            "step_number": 1,
            "description": "Check the table structure",
            "command": "DESCRIBE customer_orders;",
            "verification": "Compare with the saved table structure from before the change",
            "fallback": "If discrepancies exist, address them individually"
          },
          {
            "step_number": 2,
            "description": "Verify application functionality",
            "command": "Run application-specific tests or queries",
            "verification": "Confirm the application works correctly with the original schema",
            "fallback": "If issues persist, investigate application logs for errors"
          }
        ],
        "success_criteria": "Table structure matches the original and application functions correctly"
      }
    ],
    "verification_steps": [
      {
        "description": "Verify the loyalty_tier column no longer exists",
        "query": "-- Verify column removal using database-specific commands\n-- Example: DESCRIBE customer_orders; (MySQL) or \\d customer_orders; (PostgreSQL)",
        "expected_result": "No rows returned, confirming the column does not exist"
      },
      {
        "description": "Verify application queries execute successfully",
        "query": "-- Application-specific query that would normally access the customer_orders table",
        "expected_result": "Query executes without errors and returns expected results"
      }
    ]
  },
  "alternative_recovery_options": [
    {
      "option_name": "Restore from snapshot",
      "description": "Restore the entire database from the pre-change snapshot",
      "when_to_use": "When the column removal fails or causes unexpected issues",
      "pros": ["Complete restoration of the original state", "Addresses any unforeseen side effects"],
      "cons": ["Longer downtime", "Potential loss of other changes made since the snapshot", "Requires database administrator intervention"],
      "implementation": "Follow database-specific procedures for snapshot restoration"
    },
    {
      "option_name": "Recreate table structure",
      "description": "Drop and recreate the table with the original structure",
      "when_to_use": "When the column cannot be dropped due to unexpected constraints",
      "pros": ["Guarantees the exact original structure", "Can resolve hidden issues with table metadata"],
      "cons": ["Requires table data to be saved and restored", "Longer downtime", "More complex procedure"],
      "implementation": "1. Create a temporary table with the original structure\n2. Copy data from customer_orders to the temporary table\n3. Drop customer_orders\n4. Rename the temporary table to customer_orders\n5. Recreate any indexes and constraints"
    }
  ],
  "post_rollback_actions": [
    {
      "action": "Review application logs",
      "purpose": "Identify any errors that occurred during the schema change or rollback",
      "implementation": "Check application and database logs for errors related to customer_orders"
    },
    {
      "action": "Notify development team",
      "purpose": "Inform them of the rollback so they can adjust application code if needed",
      "implementation": "Send email or message with details of the rollback and current table structure"
    },
    {
      "action": "Document the issue",
      "purpose": "Record what happened for future reference and improvement",
      "implementation": "Create an incident report documenting the change, issues encountered, and rollback process"
    },
    {
      "action": "Reschedule the change",
      "purpose": "Plan for a future attempt if the change is still needed",
      "implementation": "Work with stakeholders to address issues and schedule a new change window"
    }
  ],
  "communication_plan": {
    "stakeholders_to_notify": [
      {
        "group": "Application Development Team",
        "when_to_notify": "Immediately when rollback begins",
        "message_template": "ALERT: Rolling back the addition of loyalty_tier column to customer_orders due to [ISSUE]. Please pause any related development work. Estimated completion time: [TIME]."
      },
      {
        "group": "Business Stakeholders",
        "when_to_notify": "After rollback decision is made",
        "message_template": "NOTICE: The planned enhancement to add customer loyalty tiers has encountered technical issues and is being rolled back. We will reschedule after addressing the issues. No customer impact is expected."
      },
      {
        "group": "Support Team",
        "when_to_notify": "Before and after rollback",
        "message_template": "ALERT: Database change to customer_orders is being rolled back from [START_TIME] to [END_TIME]. Please be aware of potential brief disruption to order processing."
      }
    ],
    "status_updates": {
      "frequency": "Every 15 minutes during rollback, or immediately upon completion",
      "channels": ["Email", "Slack #database-changes channel", "Incident management system"],
      "template": "UPDATE [TIMESTAMP]: Rollback of customer_orders schema change is [STATUS]. [DETAILS_IF_ANY]. Next update in 15 minutes or upon completion."
    }
  }
}
```

### Example 2: Rollback Plan for Data Migration
Input: INSERT INTO customer_orders_new SELECT * FROM customer_orders WHERE order_date >= '2024-01-01'

Output:
```json
{
  "rollback_assessment": {
    "operation_summary": "Migrating recent customer orders (from 2024 onwards) to a new table",
    "rollback_feasibility": "fully_recoverable",
    "confidence": 0.9,
    "time_estimate": "15-30 minutes",
    "data_loss_risk": "minimal",
    "summary": "This data migration can be rolled back by truncating the target table, with minimal risk of data loss"
  },
  "pre_execution_safeguards": [
    {
      "safeguard_type": "backup",
      "description": "Verify the source data is backed up",
      "implementation": "Confirm recent backup of customer_orders table exists",
      "verification": "Check backup logs or repository to confirm backup completion and validity"
    },
    {
      "safeguard_type": "snapshot",
      "description": "Take a snapshot of the target table before insertion",
      "implementation": "CREATE TABLE customer_orders_new_backup AS SELECT * FROM customer_orders_new;",
      "verification": "SELECT COUNT(*) FROM customer_orders_new_backup; -- Should match current count in customer_orders_new"
    },
    {
      "safeguard_type": "count",
      "description": "Count the expected number of rows to be migrated",
      "implementation": "SELECT COUNT(*) FROM customer_orders WHERE order_date >= '2024-01-01';",
      "verification": "Save this count for later verification"
    }
  ],
  "rollback_plan": {
    "phases": [
      {
        "phase_name": "Preparation",
        "description": "Prepare for the rollback by ensuring no processes are using the new table",
        "steps": [
          {
            "step_number": 1,
            "description": "Identify any processes using the new table",
            "command": "-- Check for active database processes using the table (use database-specific tools)\n-- Example: SHOW PROCESSLIST; (MySQL) or SELECT * FROM pg_stat_activity WHERE query LIKE '%customer_orders_new%'; (PostgreSQL)",
            "verification": "Confirm no critical processes are using the table",
            "fallback": "If processes are found, coordinate with application teams to stop them"
          },
          {
            "step_number": 2,
            "description": "Verify the original data is intact",
            "command": "SELECT COUNT(*) FROM customer_orders WHERE order_date >= '2024-01-01';",
            "verification": "Confirm count matches the pre-execution count",
            "fallback": "If counts don't match, investigate discrepancies before proceeding"
          }
        ],
        "success_criteria": "No active processes are using the new table and source data is verified intact"
      },
      {
        "phase_name": "Data Removal",
        "description": "Remove the migrated data from the target table",
        "steps": [
          {
            "step_number": 1,
            "description": "Truncate the target table to remove all migrated data",
            "command": "TRUNCATE TABLE customer_orders_new;",
            "verification": "SELECT COUNT(*) FROM customer_orders_new; -- Should return 0",
            "fallback": "If truncate fails, use DELETE FROM customer_orders_new;"
          },
          {
            "step_number": 2,
            "description": "Restore any pre-existing data if needed",
            "command": "INSERT INTO customer_orders_new SELECT * FROM customer_orders_new_backup;",
            "verification": "SELECT COUNT(*) FROM customer_orders_new; -- Should match backup count",
            "fallback": "If insert fails, investigate table structure or constraints"
          }
        ],
        "success_criteria": "Target table is either empty or restored to its pre-migration state"
      },
      {
        "phase_name": "Verification",
        "description": "Verify the rollback was successful",
        "steps": [
          {
            "step_number": 1,
            "description": "Verify the target table state",
            "command": "SELECT COUNT(*) FROM customer_orders_new;",
            "verification": "Count should match pre-migration count (likely 0 or the backup count)",
            "fallback": "If counts don't match, investigate and reconcile differences"
          },
          {
            "step_number": 2,
            "description": "Verify source data is unchanged",
            "command": "SELECT COUNT(*) FROM customer_orders WHERE order_date >= '2024-01-01';",
            "verification": "Count should match pre-execution count",
            "fallback": "If source data appears changed, restore from backup if necessary"
          }
        ],
        "success_criteria": "Both source and target tables are in their expected states"
      }
    ],
    "verification_steps": [
      {
        "description": "Verify target table has correct row count",
        "query": "SELECT COUNT(*) FROM customer_orders_new;",
        "expected_result": "Count matches pre-migration state (likely 0 or the backup count)"
      },
      {
        "description": "Verify no orphaned data exists",
        "query": "SELECT COUNT(*) FROM customer_orders_new WHERE order_id NOT IN (SELECT order_id FROM customer_orders_new_backup);",
        "expected_result": "0 rows, confirming no unexpected data remains"
      }
    ]
  },
  "alternative_recovery_options": [
    {
      "option_name": "Selective deletion",
      "description": "Delete only the newly migrated records instead of truncating",
      "when_to_use": "When the target table contained important data before the migration",
      "pros": ["Preserves pre-existing data", "More surgical approach", "Can be more selective about what to remove"],
      "cons": ["More complex", "Slower than truncate", "Requires careful identification of migrated records"],
      "implementation": "DELETE FROM customer_orders_new WHERE order_id IN (SELECT order_id FROM customer_orders WHERE order_date >= '2024-01-01');"
    },
    {
      "option_name": "Table rename approach",
      "description": "Rename tables to quickly restore previous state",
      "when_to_use": "When the new table has replaced the old one in production",
      "pros": ["Very quick execution", "Minimal downtime", "Simple to implement"],
      "cons": ["Requires both tables to exist", "May require application changes", "Doesn't address data quality issues"],
      "implementation": "RENAME TABLE customer_orders_new TO customer_orders_temp, customer_orders TO customer_orders_new, customer_orders_temp TO customer_orders;"
    }
  ],
  "post_rollback_actions": [
    {
      "action": "Clean up backup tables",
      "purpose": "Remove temporary backup tables created during the rollback",
      "implementation": "DROP TABLE IF EXISTS customer_orders_new_backup;"
    },
    {
      "action": "Document the migration failure",
      "purpose": "Record what happened for future attempts",
      "implementation": "Document the issues encountered, rollback process, and lessons learned"
    },
    {
      "action": "Analyze root cause",
      "purpose": "Understand why the migration needed to be rolled back",
      "implementation": "Review logs, data quality issues, or application errors that prompted the rollback"
    },
    {
      "action": "Update migration plan",
      "purpose": "Improve the migration approach for the next attempt",
      "implementation": "Revise the migration strategy based on lessons learned"
    }
  ],
  "communication_plan": {
    "stakeholders_to_notify": [
      {
        "group": "Data Team",
        "when_to_notify": "Immediately when rollback begins",
        "message_template": "ALERT: Rolling back the customer orders migration to customer_orders_new due to [ISSUE]. Please pause any related work. Estimated completion time: [TIME]."
      },
      {
        "group": "Application Teams",
        "when_to_notify": "Before rollback if they're using the new table",
        "message_template": "URGENT: We need to roll back the recent customer orders migration. Please stop using the customer_orders_new table by [TIME]. The rollback will begin at [START_TIME] and is expected to complete by [END_TIME]."
      },
      {
        "group": "Business Stakeholders",
        "when_to_notify": "After rollback decision is made",
        "message_template": "NOTICE: The customer orders data migration has encountered issues and is being rolled back. We will reschedule after addressing the issues. No customer impact is expected."
      }
    ],
    "status_updates": {
      "frequency": "At the completion of each phase",
      "channels": ["Email", "Slack #data-migrations channel", "Incident management system"],
      "template": "UPDATE [TIMESTAMP]: Rollback of customer orders migration is [STATUS]. Completed phase: [PHASE_NAME]. [DETAILS_IF_ANY]. Next phase: [NEXT_PHASE]."
    }
  }
}
```

### Example 3: Rollback Plan for Model Configuration Change
Input: Change fct_orders materialization from incremental to table

Output:
```json
{
  "rollback_assessment": {
    "operation_summary": "Changing fct_orders dbt model from incremental to table materialization",
    "rollback_feasibility": "fully_recoverable",
    "confidence": 0.95,
    "time_estimate": "10-15 minutes",
    "data_loss_risk": "none",
    "summary": "This configuration change can be fully rolled back by reverting the code change and rebuilding the model"
  },
  "pre_execution_safeguards": [
    {
      "safeguard_type": "backup",
      "description": "Backup the current model file",
      "implementation": "git checkout -b rollback-fct-orders-materialization; cp models/marts/core/fct_orders.sql models/marts/core/fct_orders.sql.bak",
      "verification": "Confirm backup file exists: ls -la models/marts/core/fct_orders.sql.bak"
    },
    {
      "safeguard_type": "snapshot",
      "description": "Create a snapshot of the current table data",
      "implementation": "dbt snapshot --select fct_orders",
      "verification": "Confirm snapshot was created successfully"
    },
    {
      "safeguard_type": "test",
      "description": "Run tests on the current model",
      "implementation": "dbt test --select fct_orders",
      "verification": "Confirm all tests pass on the current implementation"
    },
    {
      "safeguard_type": "documentation",
      "description": "Document the current configuration",
      "implementation": "Extract and save the current config block from the model file",
      "verification": "Confirm the config block is saved for reference"
    }
  ],
  "rollback_plan": {
    "phases": [
      {
        "phase_name": "Preparation",
        "description": "Prepare for the rollback by ensuring no processes are actively using the model",
        "steps": [
          {
            "step_number": 1,
            "description": "Check for running dbt processes",
            "command": "ps aux | grep dbt",
            "verification": "Confirm no dbt processes are running that might conflict",
            "fallback": "If processes are running, wait for them to complete or coordinate stopping them"
          },
          {
            "step_number": 2,
            "description": "Check for active queries on the table",
            "command": "-- Database-specific command to check for active queries",
            "verification": "Confirm no critical queries are running against the table",
            "fallback": "If queries are running, coordinate with users before proceeding"
          }
        ],
        "success_criteria": "No conflicting processes are active"
      },
      {
        "phase_name": "Code Reversion",
        "description": "Revert the model file to use incremental materialization",
        "steps": [
          {
            "step_number": 1,
            "description": "Restore the original model file",
            "command": "cp models/marts/core/fct_orders.sql.bak models/marts/core/fct_orders.sql",
            "verification": "Confirm file contents show incremental materialization",
            "fallback": "If backup file is missing, manually edit the file to restore incremental config"
          },
          {
            "step_number": 2,
            "description": "Verify the model configuration",
            "command": "grep -A 5 'config' models/marts/core/fct_orders.sql",
            "verification": "Confirm the config block includes 'materialized='incremental''",
            "fallback": "If config is incorrect, manually edit the file"
          }
        ],
        "success_criteria": "Model file is restored with incremental materialization"
      },
      {
        "phase_name": "Model Rebuild",
        "description": "Rebuild the model with the original incremental configuration",
        "steps": [
          {
            "step_number": 1,
            "description": "Run the model with full refresh",
            "command": "dbt run --select fct_orders --full-refresh",
            "verification": "Confirm the model builds successfully",
            "fallback": "If build fails, check logs for errors and address them"
          },
          {
            "step_number": 2,
            "description": "Run tests on the rebuilt model",
            "command": "dbt test --select fct_orders",
            "verification": "Confirm all tests pass on the rebuilt model",
            "fallback": "If tests fail, investigate and fix issues"
          }
        ],
        "success_criteria": "Model is rebuilt with incremental materialization and passes all tests"
      }
    ],
    "verification_steps": [
      {
        "description": "Verify model materialization",
        "query": "-- Database-specific command to check table properties or metadata",
        "expected_result": "Confirmation that the table is set up for incremental updates"
      },
      {
        "description": "Verify data integrity",
        "query": "SELECT COUNT(*) FROM fct_orders;",
        "expected_result": "Count matches expected number of records"
      },
      {
        "description": "Verify incremental functionality",
        "query": "-- Make a small change to source data and run incremental update: dbt run --select fct_orders",
        "expected_result": "Only changed records are processed, not the entire dataset"
      }
    ]
  },
  "alternative_recovery_options": [
    {
      "option_name": "Git reversion",
      "description": "Use git to revert the commit that changed the materialization",
      "when_to_use": "When the change was committed to version control and other changes should be preserved",
      "pros": ["Clean reversion in version control", "Preserves history", "Can be more selective about what to revert"],
      "cons": ["Requires git knowledge", "May be complex if other changes were made in the same commit"],
      "implementation": "git revert <commit-hash> -- models/marts/core/fct_orders.sql"
    },
    {
      "option_name": "Temporary table approach",
      "description": "Create a new version of the model with incremental materialization alongside the table version",
      "when_to_use": "When you need to compare both approaches or can't immediately replace the current model",
      "pros": ["Allows side-by-side comparison", "No disruption to current model", "Can validate before switching"],
      "cons": ["Requires additional storage", "Requires managing two versions temporarily", "May confuse users"],
      "implementation": "Create fct_orders_incremental as a copy with incremental materialization, validate, then swap"
    }
  ],
  "post_rollback_actions": [
    {
      "action": "Clean up backup files",
      "purpose": "Remove temporary backup files created during the rollback",
      "implementation": "rm models/marts/core/fct_orders.sql.bak"
    },
    {
      "action": "Document the rollback",
      "purpose": "Record what happened for future reference",
      "implementation": "Document the issues encountered with table materialization and the rollback process"
    },
    {
      "action": "Review incremental logic",
      "purpose": "Ensure the incremental logic is working as expected",
      "implementation": "Review the incremental logic and test with various data change scenarios"
    },
    {
      "action": "Update documentation",
      "purpose": "Ensure documentation reflects the current materialization strategy",
      "implementation": "Update any documentation that may have been changed to reference table materialization"
    }
  ],
  "communication_plan": {
    "stakeholders_to_notify": [
      {
        "group": "Data Engineering Team",
        "when_to_notify": "Immediately when rollback begins",
        "message_template": "ALERT: Rolling back fct_orders materialization change from table to incremental due to [ISSUE]. Please pause any related work. Estimated completion time: [TIME]."
      },
      {
        "group": "Analytics Users",
        "when_to_notify": "Before rollback if they're actively using the model",
        "message_template": "NOTICE: We need to roll back a recent change to the fct_orders model. Brief disruption expected between [START_TIME] and [END_TIME]. Please save your work and avoid running queries against this model during this window."
      },
      {
        "group": "Development Team",
        "when_to_notify": "After rollback is complete",
        "message_template": "UPDATE: The fct_orders model has been reverted to incremental materialization. The issues encountered were [ISSUES]. Please update your local copies accordingly."
      }
    ],
    "status_updates": {
      "frequency": "At the completion of each phase",
      "channels": ["Slack #dbt-deployments channel", "Email"],
      "template": "UPDATE [TIMESTAMP]: Rollback of fct_orders materialization change is [STATUS]. Completed phase: [PHASE_NAME]. [DETAILS_IF_ANY]. Next phase: [NEXT_PHASE]."
    }
  }
}
```

## Safety Guardrails
- Always prioritize data integrity over speed of rollback
- Recommend testing rollback procedures in non-production environments first
- Suggest appropriate backups before executing the original operation
- Encourage verification steps at each phase of the rollback
- Consider business impact and timing of rollback operations
- Provide clear communication templates and stakeholder notifications
- Include fallback options for each step in case of issues
- Recommend post-rollback verification to ensure system integrity
- Consider compliance and regulatory implications of data changes
- Always provide alternative recovery options as a contingency
