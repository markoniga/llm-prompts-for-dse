# Version: v0.1.0
# Last-Updated: 2025-06-16
# Owner: analytics-platform
# Description: Ensure reviews & CI before merge

# Merge Guard Prompt

## Purpose
This prompt helps ensure that pull requests meet all requirements before being merged into the main branch. It verifies that necessary reviews, tests, and checks have been completed, and that the PR is ready for deployment according to project standards and best practices.

## Usage
Use this prompt when a PR has been approved and is ready to be merged, to ensure all requirements are met and to determine if it's safe to proceed with the merge.

## Input Context
- Pull request metadata and status
- Review status and comments
- CI/CD pipeline results
- Test results
- Deployment window information
- Project merge requirements
- Release schedule
- Dependency information

## Output Format
```json
{
  "merge_assessment": {
    "pr_id": "PR number or identifier",
    "pr_title": "PR title",
    "overall_status": "ready_to_merge|needs_attention|blocked",
    "confidence": 0.0-1.0,
    "summary": "Brief summary of the merge assessment"
  },
  "requirement_checks": {
    "required_checks": [
      {
        "check_name": "Name of the required check",
        "status": "passed|failed|pending|not_applicable",
        "details": "Details about the check result",
        "blocking": true|false,
        "recommendation": "Recommendation if the check failed"
      }
    ],
    "optional_checks": [
      {
        "check_name": "Name of the optional check",
        "status": "passed|failed|pending|not_applicable",
        "details": "Details about the check result",
        "recommendation": "Recommendation if the check failed"
      }
    ]
  },
  "risk_assessment": {
    "risk_level": "low|medium|high|critical",
    "risk_factors": [
      {
        "factor": "Risk factor description",
        "severity": "low|medium|high|critical",
        "mitigation": "How this risk can be mitigated"
      }
    ],
    "affected_areas": [
      "Area of the system affected by this change"
    ],
    "testing_coverage": "Assessment of testing coverage for the changes"
  },
  "deployment_readiness": {
    "deployment_window": {
      "next_available_window": "Next available deployment window",
      "recommended_window": "Recommended deployment window",
      "blackout_periods": [
        "Periods when deployment is not allowed"
      ]
    },
    "dependencies": {
      "blocking_dependencies": [
        {
          "dependency": "Description of blocking dependency",
          "status": "Status of the dependency",
          "resolution_path": "How to resolve this dependency"
        }
      ],
      "related_prs": [
        {
          "pr_id": "Related PR number or identifier",
          "status": "Status of the related PR",
          "relationship": "How this PR relates to the current one"
        }
      ]
    },
    "rollout_strategy": {
      "recommended_approach": "Recommended rollout approach",
      "rationale": "Rationale for the recommended approach",
      "steps": [
        "Step 1 of the rollout",
        "Step 2 of the rollout"
      ]
    }
  },
  "reviewer_feedback": {
    "approvals": [
      {
        "reviewer": "Reviewer name or ID",
        "role": "Reviewer's role",
        "approval_type": "Type of approval",
        "comments": "Key comments from the reviewer"
      }
    ],
    "requested_changes": [
      {
        "reviewer": "Reviewer name or ID",
        "concerns": "Concerns raised by the reviewer",
        "resolution_status": "Status of resolving the concerns"
      }
    ],
    "missing_reviews": [
      {
        "required_role": "Role that needs to review",
        "potential_reviewers": ["Potential reviewer 1", "Potential reviewer 2"]
      }
    ]
  },
  "next_steps": {
    "if_ready": [
      "Step to take if ready to merge"
    ],
    "if_not_ready": [
      {
        "issue": "Issue preventing merge",
        "resolution": "How to resolve the issue"
      }
    ],
    "post_merge_actions": [
      "Action to take after merging"
    ]
  },
  "merge_recommendation": {
    "recommendation": "merge|wait|do_not_merge",
    "rationale": "Rationale for the recommendation",
    "conditions": [
      "Condition that must be met before merging"
    ]
  }
}
```

## Instructions

1. **Analyze PR metadata**
   - Review the PR title, description, and labels
   - Check the branch name and target branch
   - Identify the type of change (feature, bug fix, etc.)
   - Determine the scope and impact of the changes

2. **Verify required reviews**
   - Check if all required reviewers have approved
   - Verify that reviewers from appropriate teams have signed off
   - Ensure any requested changes have been addressed
   - Identify any missing reviews from key stakeholders

3. **Validate CI/CD status**
   - Confirm all required CI checks are passing
   - Verify test coverage meets project standards
   - Check for any test failures or warnings
   - Ensure performance tests show acceptable results

4. **Assess deployment readiness**
   - Determine if the PR can be deployed immediately
   - Identify the next appropriate deployment window
   - Check for any blackout periods or freeze windows
   - Consider dependencies on other PRs or changes

5. **Evaluate risks**
   - Identify potential risks associated with the changes
   - Assess the impact on critical business processes
   - Consider data migration or backward compatibility issues
   - Evaluate the rollback plan

6. **Determine next steps**
   - Provide clear guidance on whether to merge
   - Outline any remaining tasks before merging
   - Specify post-merge actions if applicable
   - Recommend a deployment strategy

7. **Make a recommendation**
   - Provide a clear merge recommendation
   - Explain the rationale for the recommendation
   - Specify any conditions that must be met
   - Suggest timing for the merge if applicable

## Examples

### Example 1: Ready to Merge Feature PR
Input: PR #123 "Add customer segmentation model" with all approvals and passing tests

Output:
```json
{
  "merge_assessment": {
    "pr_id": "PR-123",
    "pr_title": "feat(marts): Add dim_customer_segments model",
    "overall_status": "ready_to_merge",
    "confidence": 0.95,
    "summary": "This PR is ready to merge with all requirements met. It adds a new dimension model for customer segmentation with appropriate tests and documentation."
  },
  "requirement_checks": {
    "required_checks": [
      {
        "check_name": "Code Review Approvals",
        "status": "passed",
        "details": "2/2 required approvals received from @data-team-lead and @customer-analytics-owner",
        "blocking": true,
        "recommendation": null
      },
      {
        "check_name": "CI Pipeline",
        "status": "passed",
        "details": "All CI checks passing: dbt compile, dbt test, SQL linting, documentation generation",
        "blocking": true,
        "recommendation": null
      },
      {
        "check_name": "Test Coverage",
        "status": "passed",
        "details": "Tests added for all critical logic including segment exclusivity and completeness",
        "blocking": true,
        "recommendation": null
      },
      {
        "check_name": "Documentation",
        "status": "passed",
        "details": "Model and column descriptions added to schema.yml",
        "blocking": true,
        "recommendation": null
      }
    ],
    "optional_checks": [
      {
        "check_name": "Performance Testing",
        "status": "passed",
        "details": "Model builds in ~2 minutes, within acceptable range for dimension tables",
        "recommendation": null
      },
      {
        "check_name": "Impact Analysis",
        "status": "passed",
        "details": "No negative impact on existing models or processes",
        "recommendation": null
      }
    ]
  },
  "risk_assessment": {
    "risk_level": "low",
    "risk_factors": [
      {
        "factor": "New model with no downstream dependencies yet",
        "severity": "low",
        "mitigation": "No specific mitigation needed; standard deployment process is sufficient"
      },
      {
        "factor": "Segmentation logic may need tuning over time",
        "severity": "low",
        "mitigation": "Segment distribution is monitored and thresholds are configurable in dbt_project.yml"
      }
    ],
    "affected_areas": [
      "Customer Analytics",
      "Marketing Segmentation"
    ],
    "testing_coverage": "Comprehensive testing with data integrity checks and segment distribution validation"
  },
  "deployment_readiness": {
    "deployment_window": {
      "next_available_window": "Today after 3:00 PM ET",
      "recommended_window": "Today after 3:00 PM ET",
      "blackout_periods": [
        "None currently in effect"
      ]
    },
    "dependencies": {
      "blocking_dependencies": [],
      "related_prs": []
    },
    "rollout_strategy": {
      "recommended_approach": "Standard deployment",
      "rationale": "Low-risk addition with no downstream dependencies",
      "steps": [
        "Merge PR to main branch",
        "Run dbt build --select dim_customer_segments+ in production",
        "Verify segment distributions match expectations",
        "Update documentation portal with new model information"
      ]
    }
  },
  "reviewer_feedback": {
    "approvals": [
      {
        "reviewer": "@data-team-lead",
        "role": "Data Engineering Lead",
        "approval_type": "Required",
        "comments": "Clean implementation with good test coverage. Approved."
      },
      {
        "reviewer": "@customer-analytics-owner",
        "role": "Customer Analytics Owner",
        "approval_type": "Required",
        "comments": "Segmentation logic matches our requirements. Approved."
      }
    ],
    "requested_changes": [],
    "missing_reviews": []
  },
  "next_steps": {
    "if_ready": [
      "Merge the PR",
      "Deploy to production using the steps in the deployment plan",
      "Notify the marketing team that the new segmentation model is available"
    ],
    "if_not_ready": [],
    "post_merge_actions": [
      "Update documentation portal with new model information",
      "Share segment distribution metrics with the marketing team",
      "Schedule a follow-up to review segment effectiveness in 2 weeks"
    ]
  },
  "merge_recommendation": {
    "recommendation": "merge",
    "rationale": "All requirements are met, tests are passing, and the change is low risk with no downstream dependencies",
    "conditions": []
  }
}
```

### Example 2: Performance Optimization PR with Deployment Window Constraints
Input: PR #456 "Optimize incremental logic in fct_transactions" with approvals but deployment window constraints

Output:
```json
{
  "merge_assessment": {
    "pr_id": "PR-456",
    "pr_title": "perf(marts): Optimize incremental logic in fct_transactions",
    "overall_status": "ready_to_merge",
    "confidence": 0.9,
    "summary": "This PR is ready to merge but should be deployed during the next maintenance window due to the need for a full refresh of a critical model."
  },
  "requirement_checks": {
    "required_checks": [
      {
        "check_name": "Code Review Approvals",
        "status": "passed",
        "details": "3/2 required approvals received from @data-engineering-lead, @performance-team, and @data-architect",
        "blocking": true,
        "recommendation": null
      },
      {
        "check_name": "CI Pipeline",
        "status": "passed",
        "details": "All CI checks passing: dbt compile, dbt test, SQL linting",
        "blocking": true,
        "recommendation": null
      },
      {
        "check_name": "Test Coverage",
        "status": "passed",
        "details": "Performance tests show 70% improvement in build time",
        "blocking": true,
        "recommendation": null
      },
      {
        "check_name": "Data Integrity Verification",
        "status": "passed",
        "details": "Output data matches between old and new implementations",
        "blocking": true,
        "recommendation": null
      }
    ],
    "optional_checks": [
      {
        "check_name": "Query Plan Analysis",
        "status": "passed",
        "details": "Query plans show proper index usage and reduced full table scans",
        "recommendation": null
      },
      {
        "check_name": "Documentation Updates",
        "status": "passed",
        "details": "Added notes about incremental strategy and partitioning",
        "recommendation": null
      }
    ]
  },
  "risk_assessment": {
    "risk_level": "medium",
    "risk_factors": [
      {
        "factor": "Requires full refresh of a large fact table",
        "severity": "medium",
        "mitigation": "Schedule during maintenance window with extended time allocation"
      },
      {
        "factor": "Changes to incremental strategy",
        "severity": "medium",
        "mitigation": "Comprehensive testing completed in development; original model preserved as backup"
      },
      {
        "factor": "Critical model for financial reporting",
        "severity": "medium",
        "mitigation": "Data integrity verification shows matching results between implementations"
      }
    ],
    "affected_areas": [
      "Financial Reporting",
      "Transaction Analytics",
      "Data Pipeline Performance"
    ],
    "testing_coverage": "Extensive testing with performance benchmarks and data integrity verification"
  },
  "deployment_readiness": {
    "deployment_window": {
      "next_available_window": "Saturday 2:00 AM - 6:00 AM ET (Maintenance Window)",
      "recommended_window": "Saturday 2:00 AM - 6:00 AM ET (Maintenance Window)",
      "blackout_periods": [
        "End-of-month financial reporting (June 28-30)",
        "Daily during business hours (8:00 AM - 6:00 PM ET)"
      ]
    },
    "dependencies": {
      "blocking_dependencies": [],
      "related_prs": [
        {
          "pr_id": "PR-442",
          "status": "merged",
          "relationship": "Added monitoring for incremental build performance"
        }
      ]
    },
    "rollout_strategy": {
      "recommended_approach": "Scheduled deployment during maintenance window",
      "rationale": "Requires full refresh of a critical model that takes ~65 minutes to build",
      "steps": [
        "Merge PR to main branch now",
        "Schedule deployment for Saturday maintenance window",
        "Run dbt run --select fct_transactions --full-refresh in production",
        "Monitor the build to ensure it completes successfully",
        "Verify data integrity with comparison queries",
        "Update performance monitoring thresholds for the model"
      ]
    }
  },
  "reviewer_feedback": {
    "approvals": [
      {
        "reviewer": "@data-engineering-lead",
        "role": "Data Engineering Lead",
        "approval_type": "Required",
        "comments": "Excellent optimization work. Approved with the condition that this is deployed during a maintenance window."
      },
      {
        "reviewer": "@performance-team",
        "role": "Performance Engineer",
        "approval_type": "Required",
        "comments": "Query optimizations look good. Static timestamp approach will significantly improve index usage."
      },
      {
        "reviewer": "@data-architect",
        "role": "Data Architect",
        "approval_type": "Optional",
        "comments": "Partitioning strategy is appropriate for this data pattern."
      }
    ],
    "requested_changes": [],
    "missing_reviews": []
  },
  "next_steps": {
    "if_ready": [
      "Merge the PR now",
      "Schedule the deployment for Saturday's maintenance window",
      "Prepare the deployment plan with detailed steps",
      "Notify stakeholders about the scheduled performance improvement"
    ],
    "if_not_ready": [],
    "post_merge_actions": [
      "Update the deployment calendar with the scheduled maintenance",
      "Prepare monitoring dashboard for the deployment",
      "Document the performance improvements for the quarterly review"
    ]
  },
  "merge_recommendation": {
    "recommendation": "merge",
    "rationale": "All requirements are met and the code is ready, but deployment should be scheduled for the maintenance window",
    "conditions": [
      "Deployment must occur during the Saturday maintenance window",
      "Ensure no financial reporting is scheduled immediately after deployment"
    ]
  }
}
```

### Example 3: Bug Fix PR with Missing Requirements
Input: PR #789 "Fix null customer IDs in fct_orders" with missing approvals and test failures

Output:
```json
{
  "merge_assessment": {
    "pr_id": "PR-789",
    "pr_title": "fix(marts): Handle null customer IDs in fct_orders",
    "overall_status": "needs_attention",
    "confidence": 0.6,
    "summary": "This PR addresses a critical issue but is missing a required approval and has a failing test that needs to be resolved before merging."
  },
  "requirement_checks": {
    "required_checks": [
      {
        "check_name": "Code Review Approvals",
        "status": "failed",
        "details": "1/2 required approvals received. Missing approval from @customer-analytics-owner",
        "blocking": true,
        "recommendation": "Request review from @customer-analytics-owner or another team member with appropriate permissions"
      },
      {
        "check_name": "CI Pipeline",
        "status": "failed",
        "details": "1 failing test: 'test_customer_metrics_total_matches_orders_total'",
        "blocking": true,
        "recommendation": "Fix the failing test by ensuring the customer metrics total matches the orders total"
      },
      {
        "check_name": "Documentation",
        "status": "passed",
        "details": "Documentation added for the 'GUEST' customer ID in schema.yml",
        "blocking": true,
        "recommendation": null
      },
      {
        "check_name": "Impact Analysis",
        "status": "passed",
        "details": "Impact on customer metrics documented and communicated",
        "blocking": true,
        "recommendation": null
      }
    ],
    "optional_checks": [
      {
        "check_name": "Performance Testing",
        "status": "passed",
        "details": "No significant performance impact",
        "recommendation": null
      }
    ]
  },
  "risk_assessment": {
    "risk_level": "medium",
    "risk_factors": [
      {
        "factor": "Changes to core customer data model",
        "severity": "medium",
        "mitigation": "Comprehensive testing and careful review by customer analytics team"
      },
      {
        "factor": "Affects customer metrics in dashboards",
        "severity": "medium",
        "mitigation": "Communicate changes to analytics users and update documentation"
      },
      {
        "factor": "Failing test indicates potential issue",
        "severity": "high",
        "mitigation": "Resolve the failing test before merging"
      }
    ],
    "affected_areas": [
      "Customer Analytics",
      "Order Processing",
      "Marketing Dashboards"
    ],
    "testing_coverage": "Good coverage for data integrity, but one failing test needs resolution"
  },
  "deployment_readiness": {
    "deployment_window": {
      "next_available_window": "Today after 3:00 PM ET",
      "recommended_window": "After fixing failing test and getting required approval",
      "blackout_periods": [
        "None currently in effect"
      ]
    },
    "dependencies": {
      "blocking_dependencies": [],
      "related_prs": []
    },
    "rollout_strategy": {
      "recommended_approach": "Standard deployment after fixing issues",
      "rationale": "Critical bug fix that should be deployed promptly once requirements are met",
      "steps": [
        "Fix failing test",
        "Get approval from customer analytics owner",
        "Merge PR to main branch",
        "Run dbt run --select stg_orders dim_customers fct_orders",
        "Verify customer metrics in dashboards"
      ]
    }
  },
  "reviewer_feedback": {
    "approvals": [
      {
        "reviewer": "@data-quality-lead",
        "role": "Data Quality Lead",
        "approval_type": "Required",
        "comments": "Good approach to handling guest orders. Approved."
      }
    ],
    "requested_changes": [],
    "missing_reviews": [
      {
        "required_role": "Customer Analytics Owner",
        "potential_reviewers": ["@customer-analytics-owner", "@customer-analytics-manager"]
      }
    ]
  },
  "next_steps": {
    "if_ready": [],
    "if_not_ready": [
      {
        "issue": "Failing test: 'test_customer_metrics_total_matches_orders_total'",
        "resolution": "Debug and fix the test to ensure customer metrics total matches orders total"
      },
      {
        "issue": "Missing required approval from Customer Analytics Owner",
        "resolution": "Request review from @customer-analytics-owner or @customer-analytics-manager"
      }
    ],
    "post_merge_actions": [
      "Notify analytics users about the fix and potential changes in metrics",
      "Monitor customer metrics dashboards to ensure they reflect the correct data",
      "Document the 'GUEST' customer ID pattern in the data dictionary"
    ]
  },
  "merge_recommendation": {
    "recommendation": "wait",
    "rationale": "Critical issues need to be resolved before merging: failing test and missing required approval",
    "conditions": [
      "Fix the failing test 'test_customer_metrics_total_matches_orders_total'",
      "Obtain approval from Customer Analytics Owner"
    ]
  }
}
```

## Safety Guardrails
- Never recommend merging a PR with failing required checks
- Always verify that all required approvals have been received
- Consider the impact of changes on critical business processes
- Respect deployment windows and blackout periods
- Ensure data integrity is maintained through proper testing
- Verify that documentation has been updated appropriately
- Consider the rollback plan in case of issues
- Assess the risk level based on the scope and impact of changes
- Recommend appropriate post-merge actions and monitoring
- Provide clear conditions that must be met before merging

## Reconciliation Verification

Before approving merge to production for PRs that modify existing data models:

### Reconciliation Checklist
Add these items to the required checks:

```json
{
  "requirement_checks": {
    "required_checks": [
      {
        "check_name": "Schema Reconciliation",
        "status": "passed|failed|pending",
        "details": "Schema reconciliation between development and production environments",
        "blocking": true,
        "recommendation": "Complete schema reconciliation before merging"
      },
      {
        "check_name": "Data Volume Impact",
        "status": "passed|failed|pending",
        "details": "Assessment of data volume changes and performance impact",
        "blocking": true,
        "recommendation": "Analyze data volume impact before merging"
      },
      {
        "check_name": "Downstream Dependency Analysis",
        "status": "passed|failed|pending",
        "details": "Analysis of impact on downstream models and reports",
        "blocking": true,
        "recommendation": "Complete dependency analysis before merging"
      }
    ]
  }
}
```

### Reconciliation Blockers
Include these potential blockers in the risk assessment:

```json
{
  "risk_assessment": {
    "risk_factors": [
      {
        "factor": "Unresolved schema conflicts between environments",
        "severity": "high",
        "mitigation": "Complete schema reconciliation and document all changes"
      },
      {
        "factor": "Missing reconciliation documentation",
        "severity": "medium",
        "mitigation": "Add schema comparison tables to PR description"
      },
      {
        "factor": "Unaddressed data quality issues",
        "severity": "high",
        "mitigation": "Resolve data quality issues identified during reconciliation"
      },
      {
        "factor": "Unprepared downstream dependencies",
        "severity": "high",
        "mitigation": "Coordinate with owners of affected downstream models"
      }
    ]
  }
}
```

### Final Reconciliation Approval
Add reconciliation verification to the merge recommendation:

```json
{
  "merge_recommendation": {
    "conditions": [
      "Schema reconciliation completed and documented",
      "Data volume impact assessed and within acceptable limits",
      "Downstream dependencies identified and owners notified",
      "Breaking changes properly documented with migration plans"
    ]
  }
}
```

### Example Reconciliation Verification
```json
{
  "requirement_checks": {
    "required_checks": [
      {
        "check_name": "Schema Reconciliation",
        "status": "passed",
        "details": "Schema reconciliation completed. 3 columns added, 0 removed, 0 modified.",
        "blocking": true,
        "recommendation": null
      },
      {
        "check_name": "Data Volume Impact",
        "status": "passed",
        "details": "Impact assessed: +1,691 rows (0.01%) in fct_orders",
        "blocking": true,
        "recommendation": null
      },
      {
        "check_name": "Downstream Dependency Analysis",
        "status": "passed",
        "details": "3 downstream models affected, all owners notified",
        "blocking": true,
        "recommendation": null
      }
    ]
  },
  "risk_assessment": {
    "risk_factors": [
      {
        "factor": "Schema changes to critical model",
        "severity": "medium",
        "mitigation": "Changes are additive only (3 columns added) with no data loss risk"
      },
      {
        "factor": "Downstream dashboard dependencies",
        "severity": "low",
        "mitigation": "Dashboard owners notified and changes are backward compatible"
      }
    ]
  },
  "merge_recommendation": {
    "recommendation": "merge",
    "rationale": "Schema reconciliation complete with low risk changes",
    "conditions": [
      "Deploy during standard deployment window",
      "Verify downstream models build successfully after deployment"
    ]
  }
}
```

### 🔄 WORKFLOW COMPLETE
**After completing merge guard validation:**
- **If ready to merge**: Proceed with PR merge and deployment according to the deployment plan
- **If not ready**: Address the identified issues and return to the appropriate previous step
- **Post-merge**: Monitor deployment success and notify stakeholders as outlined in the post-merge actions

✅ **End of MCP Prompt Chain** - The money-movement legacy refactor workflow is complete!
