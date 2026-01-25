# Purchase Order to Stock Workflow

## ✅ Correct Workflow for Adding Stock

**Stock is ONLY added when you APPROVE a PO that has an invoice uploaded.**

### Step-by-Step Process:

1. **Create Purchase Order**
   - Status: `CREATED`
   - Add items with quantities
   - Select vendor and project
   - ⚠️ Stock NOT added yet

2. **Upload Vendor Invoice** ⭐ REQUIRED
   - Click "Upload Invoice" button
   - Select PDF/JPG/PNG file (max 5MB)
   - Enter invoice number
   - Select invoice type (GST/Non-GST - must match PO type)
   - ⚠️ Stock NOT added yet

3. **Approve Purchase Order** ⭐ STOCK ADDED HERE
   - Click "Approve PO" button
   - Backend creates stock transactions automatically
   - Stock becomes visible in "Stocks & Inventory" screen
   - ✅ Stock is NOW in the system

4. **Mark as Delivered** (Optional)
   - Status: `DELIVERED`
   - Indicates physical delivery received
   - Stock already added in step 3

5. **Close PO** (Optional)
   - Status: `CLOSED`
   - Closes the PO workflow
   - Stock already added in step 3

---

## ❌ Common Mistakes

### Mistake 1: Skipping Invoice Upload
- **Problem**: Clicking "Approve" without uploading invoice
- **Result**: App shows warning: "Please upload invoice before approving PO"
- **Fix**: Upload invoice first, then approve

### Mistake 2: Expecting Stock After Delivery
- **Problem**: Marking PO as "Delivered" expecting stock to appear
- **Result**: Stock NOT added because approval creates stock, not delivery
- **Fix**: Stock should already be in inventory after approval (step 3)

### Mistake 3: Wrong Invoice Type
- **Problem**: Uploading Non-GST invoice for GST PO (or vice versa)
- **Result**: Backend rejects with error: "Invoice type mismatch"
- **Fix**: Invoice type MUST match PO type exactly

---

## 🔍 How to Verify Stock Was Added

After approving PO, check:

1. **Go to Stocks & Inventory Screen**
   - Navigate via sidebar
   - Expand the project materials
   - Verify quantities increased

2. **Check PO Detail Screen**
   - Status should show `APPROVED` (blue badge)
   - Invoice section should display invoice info
   - Success message: "PO approved! Stock added to inventory."

3. **Backend Verification** (for admins)
   ```sql
   SELECT * FROM stock_transactions 
   WHERE reference_type = 'purchase_order' 
   AND reference_id = [PO_ID]
   ORDER BY created_at DESC;
   ```

---

## 🎯 Quick Reference

| Action | When | Stock Impact | Status Change |
|--------|------|--------------|---------------|
| Create PO | Initial | ❌ No | `CREATED` |
| Upload Invoice | Before Approval | ❌ No | `CREATED` |
| Approve PO | After Invoice | ✅ YES - Stock Added | `APPROVED` |
| Mark Delivered | After Approval | ❌ No | `DELIVERED` |
| Close PO | After Delivery | ❌ No | `CLOSED` |

---

## 🚀 New Features Added

### 1. Upload Invoice Button
- **Location**: PO Detail Screen (when status = CREATED)
- **Button**: Orange FAB labeled "Upload Invoice"
- **Function**: Allows file picker for PDF/JPG/PNG
- **Dialog**: Asks for invoice number and type
- **Validation**: Warns if type doesn't match PO

### 2. Invoice Upload Validation
- **Check**: Before approval, verifies invoice exists
- **Warning**: "Please upload invoice before approving PO"
- **Visual**: Approve button greyed out if no invoice
- **Label**: Shows "Re-upload Invoice" if invoice already exists

### 3. Clear User Feedback
- **Success**: "Invoice uploaded successfully! You can now approve the PO."
- **Approval**: "PO approved! Stock added to inventory."
- **Confirmation**: "Approving this PO will automatically add stock to inventory. Continue?"

---

## 📱 Mobile App Changes

### Files Modified:
1. `mobile/lib/presentation/screens/purchase_order/purchase_order_detail_screen.dart`
   - Added `_uploadInvoice()` method
   - Updated `_updateStatus()` to check for invoice before approval
   - Modified `_buildActionButton()` to show both upload and approve buttons
   - Added `_InvoiceUploadDialog` widget

2. `mobile/pubspec.yaml`
   - Added `file_picker: ^8.0.0+1` dependency

### Backend Files:
3. `backend/app/Policies/InvoicePolicy.php`
   - Updated to allow purchase managers to view invoices
   - Changed from owner-only to `isOwner() || isPurchaseManager()`

---

## 🎓 Technical Details

### Backend Stock Creation Logic
Location: `backend/app/Services/StockService.php`

```php
public function createStockInFromPurchaseOrder(
    PurchaseOrder $purchaseOrder,
    string $invoiceId,
    int $performedBy
): array {
    // Validates PO is approved
    if ($purchaseOrder->status !== PurchaseOrder::STATUS_APPROVED) {
        throw new Exception('Purchase Order must be approved...');
    }

    // Creates stock transactions for each item
    foreach ($purchaseOrder->items as $item) {
        $transaction = $this->createStockTransaction(
            materialId: $item->material_id,
            projectId: $purchaseOrder->project_id,
            transactionType: StockTransaction::TYPE_IN,
            quantity: $item->quantity,
            ...
        );
    }
}
```

### Stock Calculation
- Stock is NOT stored in a static table
- Calculated dynamically from `stock_transactions` table
- Uses `balance_after_transaction` from latest transaction
- See: `backend/app/Models/Material.php::getCurrentStock()`

---

## 📞 Support

If stock still doesn't appear after approval:
1. Check backend logs for errors
2. Verify invoice was uploaded successfully
3. Confirm PO status changed to APPROVED
4. Check `stock_transactions` table in database
5. Verify material IDs match between PO items and materials table
