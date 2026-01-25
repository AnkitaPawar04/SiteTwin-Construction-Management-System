
# Contractor Rating – Design & Implementation Guide

## Design Decision (Important)
Contractors are **NOT system users**.
They do **not log in** and do **not rate themselves or their sub-contractors**.

All ratings are given by **Project Managers / Owners** to ensure:
- Unbiased evaluation
- Real-world Indian construction workflow
- Simple permissions and UI
- Faster implementation for MVP

---

## Core Concept

- One **Contractor** can have multiple **Trades (Sub-Contractors)**:
  - Plumbing
  - Electrical
  - Tiling
  - Painting
- Each trade is rated **independently**
- Ratings are based on:
  - **Speed (1–10)**
  - **Quality (1–10)**

---

## Data Model (Minimal & Required)

### Contractor
- id
- name

### ContractorTrade
- id
- contractor_id
- trade_type

### ContractorRating
- id
- contractor_id
- trade_id
- project_id
- speed (1–10)
- quality (1–10)
- created_at

---

## Rating Logic

### Trade Rating
trade_rating = (speed + quality) / 2

### Contractor Overall Rating
overall_rating = average of all trade_ratings

---

## Permissions

| Role    | Access |
|--------|--------|
| Worker | ❌ No |
| Engineer | ❌ No |
| Manager | ✅ Can rate |
| Owner | 👀 View only |

---

## UI Flow (Single Screen)

1. Select Project
2. Select Contractor
3. Display Trades list
4. For each trade:
   - Speed slider (1–10)
   - Quality slider (1–10)
5. Save Rating

---

## Explicit Non-Goals (Do NOT Implement)

- Contractor login or authentication
- Contractor self-rating
- Automated AI scoring
- Defect tracking
- Payment deduction logic
- Offline rating support

---

## Rationale (For Review / Judges)

Ratings must be unbiased and trustworthy.
Therefore, contractors are treated as data entities, and performance is evaluated only by project management.

---

## Future Enhancements (Out of Scope)

- Contractor self-feedback (read-only)
- Payment recommendations
- Historical trend analytics
- Multi-project rating aggregation

---

## Final Note

This module must be **simple, explainable, and finishable**.
Focus on correctness over complexity.
