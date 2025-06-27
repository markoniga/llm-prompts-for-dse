# Jinja Macros for Data Workflow Prompts

## render_dict_safely
**Purpose**: Convert complex JSON structures into readable Markdown lists to reduce noise in LLM outputs.

**Usage**: `{{ render_dict_safely(data_dict, max_depth=2) }}`

**Template**:
```jinja2
{% macro render_dict_safely(obj, max_depth=2, current_depth=0) %}
{% if current_depth >= max_depth and obj is mapping %}
<details>
<summary>📋 <strong>{{ obj.keys() | length }} items</strong> (click to expand)</summary>

{% for key, value in obj.items() %}
- **{{ key }}** → {{ value | string | truncate(60) }}
{% endfor %}

</details>
{% elif obj is mapping %}
{% for key, value in obj.items() %}
- **{{ key }}** → {{ render_dict_safely(value, max_depth, current_depth + 1) }}
{% endfor %}
{% elif obj is sequence and obj is not string %}
{% if obj | length > 3 %}
- {{ obj[:3] | join(", ") }}... ({{ obj | length }} total items)
{% else %}
- {{ obj | join(", ") }}
{% endif %}
{% else %}
{{ obj }}
{% endif %}
{% endmacro %}
```

**Example**:
```
Input: {"risk_level": "high", "details": {"severity": "critical", "impact": "data_loss"}}
Output: 
- **risk_level** → high
- **details** → 
  <details>
  <summary>📋 <strong>2 items</strong> (click to expand)</summary>
  
  - **severity** → critical
  - **impact** → data_loss
  
  </details>
``` 