## ✅ **PROMPT FOR AI CODING AGENT – FLUTTER APP (PHASED UPDATE)**

> You are a senior **Flutter mobile architect**.
> The backend has been **completely refactored** to a **purchase-order–driven construction procurement system** (Indian GST-compliant).
>
> Your task is to **update the existing Flutter app** to align with the new backend **in phases**, keeping the app **offline-first, low-bandwidth, and role-based**.
>
> Do **NOT** implement everything at once. Follow the phases strictly.

---

## 🔹 **PHASE 1 – Role & Navigation Restructuring (FOUNDATION)**

**Goal:** Make the app reflect new roles and responsibilities.

### Implement:

1. **Add new role: Purchase Manager**
2. Update role-based navigation:

   * Worker
   * Site Engineer
   * Purchase Manager
   * Project Manager
   * Safety Officer
   * Owner
3. Show/hide screens strictly based on role
4. Remove or hide:

   * Task/DPR-based billing screens
   * Any invoice creation UI tied to work/tasks

✅ Output of Phase 1:

* Correct role-based home dashboards
* Clean navigation per role
* No broken or unused screens

---

## 🔹 **PHASE 2 – Material Request & Procurement UI**

**Goal:** Connect site demand to procurement.

### Implement:

1. **Material Request (Site Engineer)**

   * Create material request
   * Offline creation supported
   * Status: Pending / Reviewed
2. **Purchase Manager Views**

   * View incoming material requests
   * View current stock
   * Decide:

     * Fulfill from stock OR
     * Create Purchase Order
3. Read-only request history for Engineers

🚫 Do NOT implement PO creation UI yet.

✅ Output of Phase 2:

* Material demand captured correctly
* Procurement decision visible
* Offline-first for engineers

---

## 🔹 **PHASE 3 – Purchase Order & Vendor UI**

**Goal:** Enable procurement execution.

### Implement:

1. **Purchase Order Screens (Purchase Manager)**

   * Create PO from material request
   * Select vendor
   * Enforce rule:

     * GST and Non-GST items cannot mix
2. **Vendor Invoice Upload**

   * Upload invoice image/PDF
   * Validate GST vs Non-GST PO type
3. PO Status Tracking:

   * Created → Approved → Delivered → Closed

🚫 No offline PO creation (online-only is OK).

✅ Output of Phase 3:

* Fully usable procurement UI
* GST-compliant PO handling

---

## 🔹 **PHASE 4 – Stock & Inventory UI**

**Goal:** Visualize and control inventory.

### Implement:

1. **Stock IN**

   * Triggered after PO + invoice
   * Read-only for most roles
2. **Stock OUT**

   * Issue material to site
   * Linked to engineer request
3. **Inventory Screens**

   * Current stock per project
   * Stock history (IN / OUT)
   * GST vs Non-GST segregation

📌 Offline support:

* Stock OUT can be queued offline
* Stock IN stays online-only

✅ Output of Phase 4:

* Transparent inventory visibility
* No unauthorized stock movement

---

## 🔹 **PHASE 5 – Costing, Analytics & Owner Views**

**Goal:** Owner-level intelligence.

### Implement:

1. **Cost Dashboard (Owner / Project Manager)**

   * Project cost derived from POs & invoices
   * No task-based billing
2. **Consumption Variance UI**

   * Theoretical vs actual usage
   * Highlight wastage alerts
3. **Unit / Flat Costing**

   * Cost per flat
   * Sold vs unsold unit view

🚫 Read-only dashboards only.

✅ Output of Phase 5:

* Decision-ready dashboards
* Real-time cost awareness

---

## 🔹 **PHASE 6 – Advanced Compliance & Field Features**

**Goal:** Finish high-impact features.

### Implement:

1. **Contractor Rating**

   * Rating display (1–10)
   * Payment advice indicators
2. **Face Recall Attendance**

   * Camera-based daily wager check-in
3. **Tool Library**

   * QR scan → checkout → return
4. **OTP Permit-to-Work**

   * OTP verification via Safety Officer
5. **Petty Cash Wallet**

   * Expense entry
   * Receipt upload
   * GPS validation

🚫 These can be online-first initially.

✅ Output of Phase 6:

* Enterprise-grade construction app
* Strong demo value

---

## 🔑 **GLOBAL MOBILE RULES (NON-NEGOTIABLE)**

* Flutter + Material 3
* Android-first
* Offline-first where specified
* Low-bandwidth optimized
* Clear “Pending Sync / Synced” indicators
* Role-based access everywhere
* Backend is the single source of truth

---

## 🧠 **One-Line Product Intent**

> “The mobile app digitizes Indian construction procurement and site operations — from material demand to GST-compliant purchasing, inventory control, cost analytics, and compliance.”