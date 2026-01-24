## ✅ **PROMPT FOR AI CODING AGENT (PHASED, VERY IMPORTANT)**

> You are a senior system architect and full-stack engineer.
> The project scope has **changed** from task/DPR-based billing to a **purchase-order–driven construction procurement and cost management system**, aligned with **Indian GST and real construction practices**.
>
> You must **refactor and extend the existing system** (Laravel backend + Flutter app) **incrementally, phase by phase**, without breaking existing core features like attendance, stock, and offline sync.

---

## 🔹 **PHASE 1 – Core Role & Procurement Model (FOUNDATION)**

**Implement first, nothing else yet.**

1. **Introduce New Role**

   * Add **Purchase Manager** role
   * Permissions:

     * View material requests
     * View stock & inventory
     * Create & manage Purchase Orders (PO)
     * Upload vendor invoices

2. **Material Request Flow (Updated)**

   * Site Engineer raises material request
   * Request status: `PENDING → REVIEWED`
   * Purchase Manager reviews request
   * Purchase Manager decides:

     * Fulfill from existing stock OR
     * Create Purchase Order

3. **Remove / Disable**

   * Task/DPR-based invoice generation
   * Any billing logic tied to worker tasks

✅ Output of Phase 1:

* Stable procurement roles
* Material requests feeding procurement
* No billing logic yet

---

## 🔹 **PHASE 2 – Purchase Orders, GST & Non-GST Handling**

**Focus only on procurement correctness.**

1. **Product Classification**

   * Each product/material must be categorized as:

     * `GST`
     * `NON_GST`
   * Store GST percentage for GST products

2. **Purchase Order (PO) System**

   * Purchase Manager creates PO:

     * Linked to material request
     * Linked to vendor
   * **Rule:** GST and Non-GST items must NOT mix in same PO
   * PO statuses:

     * `CREATED → APPROVED → DELIVERED → CLOSED`

3. **Vendor Invoice Handling**

   * Upload vendor invoice against PO
   * Validate:

     * GST invoice for GST PO
     * Non-GST invoice for Non-GST PO

✅ Output of Phase 2:

* PO-based procurement
* GST-correct purchase flows
* Vendor invoice traceability

---

## 🔹 **PHASE 3 – Stock & Inventory Integration**

**Now connect procurement to inventory.**

1. **Stock IN**

   * Stock increases only when:

     * PO is approved
     * Vendor invoice is uploaded
   * Stock IN must reference:

     * PO ID
     * Invoice ID

2. **Stock OUT**

   * Stock issued against:

     * Site usage
     * Engineer requests
   * Prevent negative stock

3. **Inventory Reports**

   * Current stock per project
   * Stock IN / OUT history
   * GST vs Non-GST stock segregation

✅ Output of Phase 3:

* Fully auditable stock movement
* No unauthorized inventory changes

---

## 🔹 **PHASE 4 – Costing & Variance Analytics**

**Add intelligence, not billing.**

1. **Cost Calculation**

   * Project cost derived from:

     * Purchase Orders + Vendor invoices
   * No task/DPR billing

2. **Real-Time Consumption Variance**

   * Compare:

     * Theoretical consumption (BOQ / standard)
     * Actual stock usage
   * Trigger alerts if variance exceeds tolerance

3. **Flat / Unit Costing**

   * Total project cost ÷ total units
   * Show:

     * Sold unit cost
     * Unsold unit inventory value

✅ Output of Phase 4:

* Owner-ready cost dashboards
* Wastage & leakage visibility

---

## 🔹 **PHASE 5 – Advanced Field & Compliance Features**

**Implement after core system is stable.**

1. **Contractor Rating**

   * Rating (1–10) based on:

     * Delays
     * Defects
     * Wastage
     * Safety violations
   * Generate payment advice (hold / penalty)

2. **Face Recall for Daily Wagers**

   * Camera-based attendance
   * Wage calculation (no ID cards)

3. **Tool Library**

   * QR-based tool checkout & return
   * Accountability tracking

4. **OTP Permit-to-Work**

   * Safety officer OTP approval
   * Mandatory for dangerous tasks

5. **Petty Cash Wallet**

   * Geo-tagged expense receipts
   * Manager approval
   * GPS validation

✅ Output of Phase 5:

* Compliance-ready, enterprise-grade system

---

## 🔑 **GLOBAL RULES (MUST FOLLOW)**

* Procurement & cost are **PO-based**, not task-based
* GST & Non-GST flows are **strictly separated**
* Stock cannot change without PO or issue record
* Owner dashboards are **read-only**
* Offline support remains for:

  * Attendance
  * Material requests
  * Stock issue (queue & sync)

---

## 🧠 **One-Line Design Intent**

> “The system manages Indian construction procurement end-to-end — from site demand to GST-compliant purchase orders, inventory control, cost analytics, and compliance.”