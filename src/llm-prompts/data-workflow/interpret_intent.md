# Version: v0.1.0
# Last-Updated: 2025-06-16
# Owner: analytics-platform
# Description: Classify & clarify user ask

# Interpret Intent Prompt

## PURPOSE
This prompt helps clarify user goals and classify data workflow intents. It determines whether a user is asking a question, requesting a code change, or needing documentation updates, and structures this understanding for downstream processing.

## CURSOR AGENT EXECUTION GUIDE
**Use this prompt as the FIRST STEP** in any data workflow to understand what the user wants before taking action.

### Quick Classification Decision Tree
1. **Does the user mention specific code changes?** → `code_change`
2. **Are they asking "how", "what", "why" about existing data?** → `question`  
3. **Do they want documentation created/updated?** → `documentation`
4. **Are they exploring data without specific goals?** → `exploration`
5. **Unclear or multiple intents?** → `other`

## EXECUTION CHECKLIST
Before analyzing user intent:
- [ ] Read the complete user request carefully
- [ ] Identify key entities (models, tables, fields) mentioned
- [ ] Note any urgency indicators ("urgent", "ASAP", "today")
- [ ] Consider the user's likely role and expertise level

## INPUT CONTEXT REQUIREMENTS
**Gather these details about the user request:**
- User's original request or question (required)
- Available context about the data environment (optional)
- User's role and typical needs (optional)
- Project structure and conventions (optional)

## MANDATORY OUTPUT FORMAT
**Use this compact Markdown format (use `render_dict_safely` macro for complex structures):**

### 🎯 Intent Classification
- **primary_intent** → question|code_change|documentation|exploration|other
- **confidence** → 0.0-1.0 
- **summary** → One sentence summary of the user's intent

### 📋 Request Details  
- **subject_area** → The main subject area or domain
- **models_referenced** → model1, model2... (if > 3 models, show count)
- **time_scope** → historical|current|future|not_applicable
- **urgency** → low|medium|high|critical
- **complexity** → simple|moderate|complex

### ❓ Clarification Needed
- **is_needed** → true|false
- **questions** → 
  <details>
  <summary>📝 <strong>Clarifying Questions</strong> ({{ questions | length }} items)</summary>
  
  1. Question 1 to clarify the request
  2. Question 2 to clarify the request
  
  </details>
- **missing_context** → Type 1, Type 2... (abbreviated list)

### 🛠️ Suggested Approach
- **next_steps** → Step 1, Step 2... (first 2 steps, then "...and N more")
- **tools_to_use** → Tool1, Tool2
- **estimated_effort** → minutes|hours|days
- **potential_challenges** → Challenge1, Challenge2... (abbreviated)

### 🔄 NEXT MCP PROMPT
**After completing intent analysis, always proceed to:**
> **Use `getContextGapPrompt`** to identify missing information needed to address this request

## STEP-BY-STEP ANALYSIS PROCESS

### Step 1: Analyze User Request
**Look for these intent indicators:**

**Question Intent Signals:**
- "How does...", "What is...", "Why does...", "Can you explain..."
- "I need to understand...", "Help me figure out..."
- References to existing models/data without change requests

**Code Change Intent Signals:**
- "Add a field", "Create a new model", "Modify the...", "Fix the..."
- "We need to...", "Can you build...", "Update the..."
- Specific technical requirements or specifications

**Documentation Intent Signals:**
- "Document the...", "Create documentation for...", "Explain how..."
- "The team is confused about...", "We need better docs..."
- Requests for explanations that others will use

**Exploration Intent Signals:**
- "What data do we have about...", "Show me...", "I want to see..."
- "Explore the relationship between...", "Investigate..."

### Step 2: Classify Primary Intent
**Decision Logic:**
```python
if "create" in request or "add" in request or "modify" in request:
    primary_intent = "code_change"
    confidence = 0.9
elif "how" in request or "what" in request or "explain" in request:
    if "document" in request or "documentation" in request:
        primary_intent = "documentation"
        confidence = 0.8
    else:
        primary_intent = "question" 
        confidence = 0.8
elif "explore" in request or "show me" in request:
    primary_intent = "exploration"
    confidence = 0.7
else:
    primary_intent = "other"
    confidence = 0.5
```

### Step 3: Extract Request Details
**Subject Area Mapping:**
- Keywords → Subject Area
- "revenue", "sales", "orders" → "Revenue & Sales"
- "customer", "user", "client" → "Customer Analytics"
- "marketing", "campaign", "ads" → "Marketing"
- "finance", "cost", "budget" → "Finance"
- "product", "feature", "usage" → "Product Analytics"

**Urgency Assessment:**
- "urgent", "ASAP", "today", "emergency" → "critical"
- "soon", "this week", "priority" → "high"
- "when possible", "eventually", "nice to have" → "low"
- Default → "medium"

### Step 4: Identify Missing Information
**Common Missing Context Types:**
- "Exact model names" - when user says "the orders model" but multiple exist
- "Business logic requirements" - when technical change requested without business context
- "Data schema details" - when field names or data types unclear
- "Performance requirements" - when no volume/performance context given
- "Testing requirements" - when changes requested without test specifications

### Step 5: Suggest Next Steps
**Based on Primary Intent:**

**For `question` intent:**
1. Search existing documentation
2. Examine relevant models/code
3. Provide comprehensive explanation
4. Tools: `context_gap`, `gen_docs`

**For `code_change` intent:**
1. Gather technical requirements
2. Assess impact and risks
3. Generate code implementation
4. Tools: `context_gap`, `validate_risk`, `generate_code`

**For `documentation` intent:**
1. Understand documentation needs
2. Review existing content
3. Create comprehensive documentation
4. Tools: `context_gap`, `gen_docs`

## EXAMPLE EXECUTIONS

### Example 1: Question About Data Lineage
**Input:** "How does customer LTV get calculated in our models? I need to understand the inputs and logic."

**Analysis Process:**
1. Intent signals: "How does", "I need to understand" → question
2. Subject area: "customer LTV" → Customer Analytics
3. Models referenced: Inferred LTV-related models
4. Missing context: User's technical level, specific use case

**Output:**

### 🎯 Intent Classification
- **primary_intent** → question
- **confidence** → 0.95
- **summary** → User wants to understand the calculation logic and inputs for customer LTV models

### 📋 Request Details  
- **subject_area** → Customer Analytics
- **models_referenced** → dim_customers, fct_orders, customer_ltv
- **time_scope** → current
- **urgency** → medium
- **complexity** → moderate

### ❓ Clarification Needed
- **is_needed** → true
- **questions** → 
  <details>
  <summary>📝 <strong>Clarifying Questions</strong> (3 items)</summary>
  
  1. Are you interested in the technical SQL implementation or the business logic?
  2. Do you need this for a specific customer segment or all customers?
  3. Is this for your own understanding or to explain to others?
  
  </details>
- **missing_context** → User's technical familiarity, Specific use case, Documentation output needs

### 🛠️ Suggested Approach
- **next_steps** → Use context_gap prompt, Examine customer_ltv model...and 2 more
- **tools_to_use** → context_gap, gen_docs
- **estimated_effort** → hours
- **potential_challenges** → Complex logic spans multiple models, Business rules vary by segment

### Example 2: Code Change Request
**Input:** "We need to add a new field to track promotion codes in the orders model. The field should be nullable and come from the source_orders.promo_code column."

**Analysis Process:**
1. Intent signals: "add a new field", "We need to" → code_change
2. Specific requirements: field name, nullability, source column
3. High confidence due to clear technical specifications

**Output:**

### 🎯 Intent Classification
- **primary_intent** → code_change
- **confidence** → 0.98
- **summary** → User wants to add a promotion code field to the orders model from source data

### 📋 Request Details  
- **subject_area** → Orders & Promotions
- **models_referenced** → orders, source_orders
- **time_scope** → future
- **urgency** → medium
- **complexity** → simple

### ❓ Clarification Needed
- **is_needed** → true
- **questions** → 
  <details>
  <summary>📝 <strong>Clarifying Questions</strong> (4 items)</summary>
  
  1. Which specific orders model needs the change (stg_orders, fct_orders, etc.)?
  2. Should any validation be applied to the promotion codes?
  3. Are there downstream models that will need to reference this new field?
  4. What testing is required for this change?
  
  </details>
- **missing_context** → Exact model name, Data validation requirements, Downstream impact, Testing requirements

### 🛠️ Suggested Approach
- **next_steps** → Use context_gap prompt, Use validate_risk prompt...and 2 more
- **tools_to_use** → context_gap, validate_risk, generate_code
- **estimated_effort** → hours
- **potential_challenges** → Multiple orders models exist, Downstream updates needed, Historical data handling

## CURSOR AGENT BEST PRACTICES

### For Optimal Execution:
1. **Always classify intent BEFORE taking action** - don't assume what the user wants
2. **Set confidence thresholds** - if confidence < 0.7, ask for clarification
3. **Use the suggested tools** in the order provided for best results
4. **Include effort estimates** to help users understand the scope
5. **Anticipate challenges** to provide proactive solutions

### Error Prevention:
- Never skip the clarification step if `is_needed: true`
- Always provide specific next steps, not vague instructions
- Include relevant tool names that actually exist in the system
- Match urgency assessment to user's language and context

## SAFETY GUARDRAILS
- Avoid making assumptions about business logic without clarification
- Flag requests that might impact critical financial or customer data
- Recommend appropriate testing for any code changes
- Suggest documentation updates alongside code changes
- Identify potential downstream impacts of changes
- Recognize when a request might require subject matter expert input
- Suggest breaking complex requests into manageable steps
- Highlight potential data governance or compliance considerations

## CHANGELOG
### v0.1.0 - 2025-06-16
- Initial version with intent classification capability
- Added confidence scoring and clarification logic
- Included comprehensive examples and safety guardrails
- Optimized for Cursor agent execution workflow 