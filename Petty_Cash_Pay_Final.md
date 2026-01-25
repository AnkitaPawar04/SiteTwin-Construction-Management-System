
# Petty Cash Pay – Worker-Based Expense & Receipt Verification System

## Purpose
This module allows **workers to submit petty cash expenses** directly from the site,
while ensuring **receipt authenticity, location validation, and manager approval**
before any money is deducted from the project wallet.

This feature is designed to **prevent fake or reused receipts** without complex AI or OCR.

---

## Core Principle

> Petty cash is verified using **proof + context + human approval**, not automated bill reading.

---

## Roles & Responsibilities

### 👷 Worker
- Submit petty cash expense
- Upload receipt photo
- Enter amount and short description
- Cannot approve or edit after submission

---

### 🧑‍🔧 Supervisor (Optional)
- Oversees workers
- Helps ensure correct submissions

---

### 👨‍💼 Manager
- Reviews receipts and validation flags
- Approves or rejects expenses
- Controls wallet balance

---

### 🧑‍💼 Owner
- View-only access
- Sees expense summaries and reports

---

## Workflow (End-to-End)

### Step 1: Expense Submission (Worker)
Worker submits:
- Expense amount
- Description
- Receipt photo

System automatically captures:
- GPS location
- Timestamp

Expense status = `PENDING`

---

### Step 2: Automatic Verification (System)

The system performs **three lightweight checks**:

#### 1️⃣ GPS Validation
- Compare receipt location with project geofence
- Mark:
  - `ON_SITE`
  - `OUTSIDE_SITE` (flagged, not blocked)

---

#### 2️⃣ Time Validation
- Submission time must be within reasonable window of purchase
- Large delays are flagged

---

#### 3️⃣ Duplicate Receipt Detection
- Generate hash of receipt image
- Compare with previous uploads
- If match found → flag as duplicate

---

### Step 3: Manager Review
Manager sees:
```
₹ 450 – Electrical nails
📍 Location: ON_SITE
🕒 Time: Same Day
📷 Receipt Image
⚠ Duplicate: No
```
Manager:
- Approves ✅
- Rejects ❌
- Optional comment

---

### Step 4: Wallet Update
- If approved:
  - Wallet balance decreases
- If rejected:
  - No balance change

---

## Data Model (Minimal)

### PettyCashWallet
- id
- project_id
- balance

### PettyCashTransaction
- id
- wallet_id
- user_id
- amount
- description
- receipt_image
- image_hash
- latitude
- longitude
- gps_status (ON_SITE / OUTSIDE_SITE)
- duplicate_flag (true/false)
- status (PENDING / APPROVED / REJECTED)
- created_at

---

## Security & Control Rules

- Workers cannot:
  - Approve expenses
  - Edit after submission
  - Delete records
- Wallet balance updates only after approval
- All actions are logged

---

## What NOT to Implement

- OCR or bill text reading
- GST verification
- Auto approval
- AI fraud detection
- Bank or UPI integration

---

## Why This Approach is Correct

- Matches real construction site behavior
- Prevents receipt reuse
- Low implementation complexity
- Easy to explain to judges
- Human approval ensures trust

---

## One-Line Explanation (For Demo)

Workers submit petty cash expenses with receipt and GPS proof, and managers approve them after system validation.

---

## Future Enhancements (Out of Scope)

- OCR-based receipt reading
- Vendor categorization
- Monthly expense limits
- Advanced analytics

---

## Final Note

This module prioritizes **practical fraud prevention**, not accounting automation.
Keep it **simple, fast, and approval-driven**.
