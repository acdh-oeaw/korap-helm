# KorAP Helm Chart v1.0.0 - Release Notes

## Version Update

- **Chart Version**: 1.0.0 (updated from 1.0.5)
- **App Version**: 1.0.0 (updated from 1.0.5)
- **Release Date**: February 17, 2026

## What's New

### 1. Rancher Integration - Interactive UI Configuration

The chart now includes **questions.yaml** for seamless Rancher integration. When installing the chart via Rancher UI, you'll see:

✅ **Interactive Form Fields** - All 50+ configuration options with:
- Clear labels and descriptions
- Type validation (string, integer, boolean, enum)
- Min/max constraints for numeric fields
- Default values pre-populated
- Conditional visibility (show/hide fields based on profile selection)

✅ **Logical Grouping** - Configuration options organized into sections:
- General Configuration
- Global Settings
- Service Configuration
- Kalamar/Kustvakt Configuration (Lite & Full)
- Example Container
- Volumes & Storage
- Ingress Configuration
- Full Profile Settings
- Security Configuration
- Pod Configuration

### 2. Comprehensive Values Documentation

New **VALUES.md** file provides:
- **Quick Lookup Table** - All parameters with type, default, and description
- **Detailed Configuration Groups** - 15 sections with in-depth explanations
- **Common Configuration Examples** - Copy-paste ready setups
- **Link to upstream documentation**

## Using the Helm Chart in Rancher

### Step 1: Navigate to Charts
1. Open Rancher Dashboard
2. Go to **Apps → Charts**
3. Search for **korap** or navigate to the repository

### Step 2: View Configuration UI
1. Click on **KorAP** chart
2. Click **Install** or **Upgrade**
3. **Rancher automatically displays the interactive form** based on questions.yaml

### Step 3: Configure Parameters
The form will show:

**Example - General Configuration Group:**
```
─────────────────────────────────────────
General Configuration
─────────────────────────────────────────

Deployment Profile *      [Dropdown: lite ▼ / full]
  "Choose between lite (minimal setup) or 
   full (enterprise with authentication)"

─────────────────────────────────────────
Global Settings
─────────────────────────────────────────

Image Pull Policy *       [Dropdown: IfNotPresent ▼]
  "Policy for pulling container images 
   from registry"

─────────────────────────────────────────
Service Configuration
─────────────────────────────────────────

Kalamar Port *            [64543] (integer, min: 1, max: 65535)
  "Port for Kalamar web interface 
   (default: 64543)"

Kalamar Service Type *    [Dropdown: ClusterIP ▼]
  "Kubernetes service type for Kalamar"

... (and 40+ more fields)
```

### Step 4: Smart Validation
- **Type checking** - Only allows valid input types
- **Range validation** - Integer fields respect min/max
- **Enum validation** - Dropdowns restrict to valid options
- **Conditional fields** - Form adapts based on your selections
  - Enable "Full Profile" → Additional fields appear
  - Enable "Ingress" → Ingress config fields appear
  - Enable "Data Volumes" → Volume detail fields appear

### Step 5: Install
1. Review your configuration
2. Click **Next** → **Install**
3. Rancher validates and deploys your chart

---

## Rancher Form Structure

The **questions.yaml** file defines:

### Question Properties
```yaml
- variable: parameter.name         # Values.yaml path
  default: value                    # Default value
  type: enum/string/int/boolean    # Input type
  label: "Display Label"            # User-friendly label
  description: "Help text"          # Detailed description
  group: "Section Name"             # Form section
  show_if: "condition"              # Conditional visibility
  options: [opt1, opt2, ...]        # For enum/select types
  required: true/false              # Validation
  min: N / max: N                   # For numeric types
  multiline: true                   # For text areas
```

### Example: Conditional Field

When user selects `kalamarFull.enabled: true`, these fields appear:
```yaml
- variable: kalamarFull.image
  show_if: "kalamarFull.enabled=true"
  # Only visible when kalamarFull.enabled is true
```

---

## Configuration Examples via Rancher UI

### Example 1: Quick Start (Lite Profile)
1. Leave defaults
2. Click Install
3. Result: Basic KorAP with Kalamar + Kustvakt

### Example 2: Full Profile with Authentication
1. Set `Deployment Profile` → `full`
2. Set `Enable Full Profile` → `true` (checkbox)
3. Additional fields appear for:
   - `Enable Kalamar Full Profile` → `true`
   - `Enable Kustvakt Full Profile` → `true`
   - `Super Client Info Secret Name` → `korap-auth`
   - `Enable Kalamar Data Volume` → `true`
4. Click Install
5. Result: Enterprise KorAP with authentication

### Example 3: With Ingress
1. Set `Enable Ingress` → `true`
2. Set `Ingress Class Name` → `nginx`
3. Configure `Ingress Hosts`:
   ```yaml
   - host: korap.example.com
     paths:
       - path: /
         pathType: Prefix
   ```
4. Click Install

---

## Files Updated/Added

| File | Action | Purpose |
|------|--------|---------|
| `Chart.yaml` | ✏️ Updated | Version: 1.0.0, appVersion: 1.0.0 |
| `questions.yaml` | ➕ Created | Rancher interactive form definition (50+ fields) |
| `VALUES.md` | ➕ Created | Comprehensive reference table and examples |

---

## File Sizes

- **questions.yaml**: 13 KB (50+ configuration options with descriptions)
- **VALUES.md**: 14 KB (Complete reference with examples)

---

## Backward Compatibility

✅ **Fully Compatible** with previous versions
- All existing values.yaml files still work
- questions.yaml is optional (for Rancher UI only)
- Helm CLI installations unaffected

---

## How Rancher Uses questions.yaml

1. **Discovery** - Rancher scans chart directory for questions.yaml
2. **Parsing** - Reads and validates question definitions
3. **Rendering** - Displays grouped form fields based on definitions
4. **Validation** - Enforces types, ranges, required fields
5. **Substitution** - Maps form inputs to values.yaml parameters
6. **Installation** - Passes merged values to Helm install

---

## Comparison: Helm CLI vs Rancher UI

| Task | Helm CLI | Rancher UI |
|------|----------|-----------|
| Install | `helm install korap ./korap` | Click form buttons |
| Configure | `--set key=value` flags | Interactive fields |
| Validate | Manual checking | Automatic validation |
| Conditional fields | Manual management | Auto-hide/show |
| Dropdowns | Manual options entry | Pre-populated lists |
| Documentation | Read README/values | Built-in descriptions |

---

## Testing the Chart

### Helm CLI Testing (unchanged)
```bash
helm lint charts/korap/                    # Validate syntax
helm template korap charts/korap/          # Preview rendering
helm install korap charts/korap/ -n korap  # Install
```

### Rancher UI Testing
1. Add chart repository to Rancher
2. Navigate to Charts
3. Find KorAP chart
4. Click Install
5. Verify form displays all fields with correct groups
6. Test field validation (try entering invalid values)
7. Test conditional visibility (enable/disable features)

---

## Additional Resources

- [README.md](../README.md) - Installation and usage guide
- [VALUES.md](VALUES.md) - Complete parameter reference
- [IMPLEMENTATION.md](../IMPLEMENTATION.md) - Architecture and features
- [Rancher Documentation](https://rancher.com/docs/) - Official Rancher docs
- [Helm Chart Guide](https://helm.sh/docs/chart_best_practices/) - Best practices

---

## Support

For issues or questions:
1. Check [VALUES.md](VALUES.md) for parameter descriptions
2. Review [README.md](../README.md) for installation examples
3. Open an issue on [GitHub](https://github.com/acdh-oeaw/korap-helm/issues)
