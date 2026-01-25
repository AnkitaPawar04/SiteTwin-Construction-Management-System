
# Real-Time Consumption Variance – Design & Implementation Guide

## Purpose
This module detects **material wastage or over-consumption** by comparing
**expected (theoretical) usage** with **actual material usage** from stock.

It provides **early alerts** to managers and owners to prevent theft and leakage.

---

## Core Concept

For each material:
```
Variance = Actual Consumption − Expected Consumption
```

If variance exceeds a defined tolerance, the system raises an alert.

---

## Data Required (Minimal)

### Material Standard (Theoretical Usage)
Represents expected material usage based on BOQ or norms.

```
MaterialStandard
- id
- project_id
- material_id
- expected_quantity
```

---

### Actual Consumption
Taken from stock issue records.

```
StockTransaction
- id
- project_id
- material_id
- quantity
- type (OUT)
- created_at
```

---

## Variance Calculation Logic

### Step 1: Calculate Expected Usage
Example:
```
Expected Cement Usage = 100 bags
```

### Step 2: Calculate Actual Usage
```
Actual Cement Used = Sum of Stock OUT = 120 bags
```

### Step 3: Calculate Variance
```
Variance = 120 − 100 = +20 bags
```

---

## Tolerance & Alert Rule

Define a tolerance percentage (example: 10%):

```
Allowed Usage = Expected × 1.10
```

If:
```
Actual Usage > Allowed Usage
```
→ Trigger **Wastage Alert**

---

## When to Run the Check (“Real-Time”)

- After each **Stock OUT** transaction
- OR once daily using a background job

No live streaming required.

---

## Roles & Visibility

| Role | Access |
|----|----|
| Worker | ❌ No |
| Engineer | 👀 View only |
| Manager | 🚨 Alerts & Details |
| Owner | 📊 Summary & Reports |

---

## Manager Dashboard View (Example)

```
Material: Cement
Expected: 100 bags
Used: 120 bags
Variance: +20 ⚠️
Status: Over-consumption
```

---

## What NOT to Implement

- AI-based prediction
- Sensor or IoT integration
- Flat-wise material tracking
- Complex analytics or graphs

---

## Why This Approach is Correct

- Matches Indian construction practices
- Simple and rule-based
- Uses existing stock data
- Easy to explain to judges
- Fast to implement for MVP

---

## One-Line Explanation (For Demo)

The system compares expected material usage with actual stock consumption and raises alerts when wastage crosses a threshold.

---

## Future Enhancements (Out of Scope)

- Phase-wise variance
- Trend analysis
- Auto penalty suggestions
- Integration with contractor rating

---

## Final Note

Keep this module **simple, transparent, and alert-driven**.
Focus on preventing wastage, not predicting it.
