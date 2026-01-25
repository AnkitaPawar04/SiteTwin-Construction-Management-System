
# OTP Permit-to-Work (Supervisor-Based) – Design & Implementation Guide

## Purpose
This module ensures **worker safety for high-risk tasks** by enforcing a
**Supervisor-led safety approval flow** using an **OTP-based Permit-to-Work system**.

Workers can start work **only after supervisor confirmation**.

---

## Key Design Change

> OTP permits are handled by the **Supervisor**, not individual workers.

This matches real construction site hierarchy and accountability.

---

## Roles & Responsibilities

### 👷 Worker
- Does not request permit
- Does not enter OTP
- Starts work only after supervisor approval

---

### 🧑‍🔧 Supervisor
- Requests permit for high-risk work
- Selects:
  - Project
  - Task type (Height, Electrical, Welding, etc.)
- Enters OTP
- Starts work for all workers under supervision

---

### 🦺 Safety Officer
- Reviews permit requests
- Approves work
- Uses **fixed OTP** (for current MVP)

---

### 👨‍💼 Manager
- View-only access
- Sees permit logs and status

---

### 🧑‍💼 Owner
- Read-only access
- Audit and compliance visibility

---

## High-Risk Tasks (Examples)

- Working at height
- Electrical work
- Welding / cutting
- Confined space work

Only these tasks require OTP permit.

---

## Workflow

### Step 1: Permit Request (Supervisor)
- Supervisor selects:
  - Project
  - Task type
- Clicks **Request Permit**
- Permit status = `PENDING`

---

### Step 2: Safety Officer Approval
- Safety Officer reviews request
- Approves work
- **Fixed OTP is used** (e.g. `123456`)

_No OTP generation or SMS logic required in MVP._

---

### Step 3: OTP Verification (Supervisor)
- Supervisor enters OTP
- System validates OTP

If correct:
```
Permit status = APPROVED
```

---

### Step 4: Work Start Confirmation
- Supervisor marks **Work Started**
- Workers under supervisor can begin work

Workers cannot start work without this confirmation.

---

## Data Model (Minimal)

### PermitToWork
- id
- project_id
- task_type
- supervisor_id
- status (PENDING / APPROVED)
- otp_code (fixed value)
- approved_at
- work_started_at

---

## Rules & Constraints

- OTP entered only by supervisor
- Workers inherit supervisor’s permit
- Permit is project- and task-specific
- Managers and owners are view-only

---

## What NOT to Implement (For Now)

- Dynamic OTP generation
- SMS or email OTP delivery
- Worker-level OTP handling
- Multi-level approval chains

These are **Phase-2 enhancements**.

---

## Why This Approach is Correct

- Matches real site safety hierarchy
- Supervisor accountability ensured
- Simple MVP logic
- Easy to demo and explain
- Extendable later

---

## One-Line Explanation (For Demo)

Supervisors obtain a safety permit via OTP for high-risk work, and workers operate only after supervisor clearance.

---

## Future Enhancements (Out of Scope)

- Dynamic OTP
- Safety checklist before approval
- Auto-expiry of permits
- Photo proof before and after work

---

## Final Note

This module focuses on **safety enforcement through hierarchy**, not communication complexity.
Keep implementation **simple, controlled, and auditable**.
