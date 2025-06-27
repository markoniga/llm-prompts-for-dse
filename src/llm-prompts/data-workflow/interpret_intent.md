# Version: v0.2.0
# Last-Updated: 2025-01-16
# Owner: analytics-platform
# Description: Quick intent classification - simplified for better UX

# Interpret Intent Prompt

## PURPOSE
Quickly classify user requests into actionable categories. **Keep it simple** - avoid over-analysis that buries the actual request.

## EXECUTION APPROACH
**Decision Tree (use this):**
1. **Code request words** ("add", "create", "modify", "fix") → `code_change`
2. **Question words** ("how", "what", "why", "explain") → `question`
3. **Documentation words** ("document", "write docs") → `documentation`  
4. **Exploration words** ("show me", "explore", "investigate") → `exploration`
5. **Unclear or mixed** → `other`

## OUTPUT FORMAT (Concise Markdown)
### 🎯 Intent Classification
- **intent** → question|code_change|documentation|exploration|other
- **confidence** → 0.0-1.0
- **summary** → One clear sentence about what the user wants

### 📋 Request Analysis
- **models_mentioned** → model1, model2... (max 3, then "...+N more")
- **urgency** → low|medium|high|critical
- **complexity** → simple|moderate|complex

### ❓ Quick Clarification
**Need clarification?** → true|false
**Top questions (max 3):**
1. Most important clarifying question
2. Second most important (if needed)
3. Third most important (if needed)

### 🛠️ Next Action
**Recommended next step:** Use `getContextGapPrompt` | Use `getGenerateCodePrompt` | Use `getGenDocsPrompt` | Ask for clarification

## EXAMPLES

### Example 1: Clear Code Request
**Input:** "Add a promotion_code field to the orders table"

### 🎯 Intent Classification
- **intent** → code_change
- **confidence** → 0.95
- **summary** → User wants to add a promotion_code field to orders table

### 📋 Request Analysis  
- **models_mentioned** → orders
- **urgency** → medium
- **complexity** → simple

### ❓ Quick Clarification
**Need clarification?** → true
**Top questions:**
1. Which orders table (stg_orders, fct_orders, dim_orders)?
2. What should be the data type and constraints?
3. Should this be nullable or have a default value?

### 🛠️ Next Action
**Recommended next step:** Use `getContextGapPrompt`

### Example 2: Simple Question
**Input:** "How is customer LTV calculated?"

### 🎯 Intent Classification
- **intent** → question
- **confidence** → 0.90
- **summary** → User wants to understand customer LTV calculation logic

### 📋 Request Analysis
- **models_mentioned** → customer_ltv
- **urgency** → low
- **complexity** → moderate

### ❓ Quick Clarification
**Need clarification?** → false

### 🛠️ Next Action
**Recommended next step:** Use `getGenDocsPrompt`

## SIMPLIFICATION PRINCIPLES
1. **No over-analysis** - Classification should take <30 seconds
2. **Direct action** - Always provide clear next step
3. **Essential questions only** - Max 3 clarifying questions
4. **User-friendly language** - Avoid technical jargon when possible

## 🔄 NEXT MCP PROMPT
- **code_change** → `getContextGapPrompt`
- **question** → `getGenDocsPrompt` or `getContextGapPrompt`
- **documentation** → `getGenDocsPrompt`
- **exploration** → `getContextGapPrompt`
- **other** → Ask for clarification, then re-classify

## CHANGELOG
### v0.2.0 - 2025-01-16
- Simplified output format for better UX
- Reduced cognitive load with direct classification
- Added clear next action guidance
- Removed verbose analysis sections 