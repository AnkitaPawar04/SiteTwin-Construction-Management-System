### ✅ **SINGLE-PHASE PROMPT – MIXED GST & NON-GST PO + INVOICE + STOCK**

> You are a senior backend and mobile system engineer.
> Implement support for **a single Purchase Order and a single system-generated Vendor Invoice that can contain BOTH GST and Non-GST items**, following real Indian construction procurement practices.
>
> **Business Rules (Must Follow Exactly):**
>
> * Each product/material has:
>
>   * name, unit
>   * `is_gst_applicable`
>   * `gst_percentage` (0% for non-GST items)
> * A Purchase Order can contain mixed items (GST + Non-GST).
> * GST must be calculated **per line item**, not at PO level.
>
> **Invoice Logic (Automatic):**
>
> * System auto-generates one invoice from the PO.
> * Invoice must show per item:
>
>   * product name
>   * quantity
>   * unit price
>   * GST %
>   * GST amount
>   * line total (price + GST)
> * Invoice summary must show:
>
>   * subtotal (without GST)
>   * total GST
>   * grand total (GST + Non-GST combined)
> * Vendor-uploaded invoice (PDF/image) is for reference only.
>
> **Stock & Inventory Sync:**
>
> * Stock IN must happen **only after invoice generation**.
> * For each invoice line item:
>
>   * increase stock quantity
>   * link stock entry to PO ID and Invoice ID
> * GST affects cost reporting only, **not stock quantity**.
>
> **Cost & Reporting:**
>
> * Project cost must be derived from invoice line totals.
> * GST and Non-GST amounts must be reportable separately.
>
> **Strict Constraints:**
>
> * ❌ No manual GST entry
> * ❌ No stock update without invoice
> * ❌ No invoice without PO
> * ✅ Mixed GST + Non-GST items allowed in one invoice
> * ✅ Full traceability: PO → Invoice → Stock → Cost
>
> **End-to-End Flow:**
>
> ```
> Material Request
> → Purchase Order (mixed items)
> → System-generated Invoice
> → Vendor Invoice Upload
> → Stock IN (per item)
> → Cost & GST Reports
> ```
>
> Implement this end-to-end without breaking existing procurement, inventory, or reporting logic.

---

### 🧠 One-line explanation (for mentors/judges)

> “Our system mirrors real Indian vendor invoices by supporting mixed GST and non-GST items in a single purchase order, with automatic invoicing and inventory-linked costing.”