### ✅ **Automated GST Billing – Instructions for Coding AI Agent**

**Goal:**
Implement **automatic, system-generated GST billing** strictly based on **approved completed work**, with **no manual billing input by field users**.

---

### **Required Billing Logic**

1. **Task Configuration**

   * Each task (or task type) must have:

     * Unit rate (₹)
     * GST percentage
   * Rates are predefined in the system (admin/manager configured).

2. **Work Execution**

   * Worker completes assigned task.
   * Worker submits **DPR** with:

     * Work description
     * Photos
     * GPS location
   * Worker must **not** enter:

     * Rates
     * Amounts
     * GST values

3. **Approval Step**

   * Manager reviews DPR.
   * Manager approves or rejects DPR.
   * Only **approved DPRs** are eligible for billing.

4. **Invoice Auto-Generation**

   * Upon DPR approval:

     * System calculates:

       * Amount = task quantity × predefined unit rate
       * GST amount = amount × GST %
     * System generates a **GST-ready invoice** automatically.
   * Invoice must include:

     * Invoice number
     * Line items (task/work reference)
     * Taxable amount
     * GST percentage per item
     * Total GST
     * Grand total

5. **Access Rules**

   * Workers: ❌ cannot see or edit invoices
   * Managers: ❌ cannot manually create invoices
   * Owners: ✅ read-only access to invoices and financial summaries

---

### **Strict Rules to Enforce**

* ❌ No invoice generation before approval
* ❌ No manual invoice creation
* ❌ No GST or pricing input by workers
* ❌ No billing from unapproved work
* ✅ All invoices must be traceable to:

  * Task → DPR → Approval → Invoice

---

### **End-to-End Flow (Must Match Exactly)**

```
Task created with rate & GST
→ Worker completes task + submits DPR
→ Manager approves DPR
→ System auto-generates GST invoice
→ Owner views invoice
```

---

### **Design Intent**

> Billing must be **automatic, approval-driven, auditable, and GST-compliant**, matching real construction workflows and the hackathon problem statement.