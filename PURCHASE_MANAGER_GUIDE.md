# Purchase Manager Role - Complete Guide

## 🎯 Overview

The **Purchase Manager** is a dedicated procurement role introduced in Phase 1 of the system transformation. This role is responsible for converting material demands from the field into actionable purchase orders while maintaining GST compliance and inventory accuracy.

---

## 🔐 Access & Authentication

### Test Credentials
- **Phone**: `9876543215`
- **Name**: Raj Kumar
- **Role**: `purchase_manager`

### Login API
```http
POST /api/login
Content-Type: application/json

{
  "phone": "9876543215"
}
```

---

## 📋 Core Responsibilities

### 1. Material Request Review
- **View** all pending material requests from Engineers
- **Review** requests to validate demand
- **Mark as Reviewed** to signal procurement readiness
- **Workflow**: PENDING → REVIEWED (by Purchase Manager) → APPROVED (by Manager)

### 2. Purchase Order Management
- **Create POs** from reviewed material requests
- **Select vendors** based on material type and pricing
- **Enforce GST/Non-GST separation** (cannot mix in same PO)
- **Track PO status**: Created → Approved → Delivered → Closed

### 3. Invoice & Stock Integration
- **Upload vendor invoices** (image/PDF)
- **Validate invoice** against PO items
- **Trigger stock-in** automatically on PO approval + invoice upload
- **Maintain audit trail** of all transactions

### 4. Inventory Oversight
- **View real-time stock levels** across all projects
- **Monitor stock movements** (IN/OUT)
- **Prevent negative stock** through validation
- **Track stock by GST type** (GST vs Non-GST materials)

---

## 🚀 Key Features & Permissions

### ✅ Can Do
- ✅ Review material requests
- ✅ Create purchase orders
- ✅ Manage vendors
- ✅ Upload invoices
- ✅ Update PO status
- ✅ View all stock/inventory
- ✅ View all projects (procurement context)
- ✅ Access procurement analytics

### ❌ Cannot Do
- ❌ Approve material requests (final approval by Manager)
- ❌ Create/assign tasks
- ❌ Approve/reject DPRs
- ❌ Mark attendance
- ❌ Modify project details
- ❌ Access owner-level financial dashboards

---

## 🔌 API Endpoints

### Material Request Review
```http
POST /api/material-requests/{id}/review
Authorization: Bearer {token}

Response:
{
  "success": true,
  "message": "Material request marked as reviewed",
  "data": {
    "id": 1,
    "status": "reviewed",
    ...
  }
}
```

### Purchase Order Creation
```http
POST /api/purchase-orders
Authorization: Bearer {token}
Content-Type: application/json

{
  "project_id": 1,
  "vendor_id": 5,
  "material_request_id": 10,
  "items": [
    {
      "material_id": 3,
      "quantity": 100,
      "unit": "bags",
      "rate": 450
    }
  ]
}
```

### View Purchase Orders
```http
GET /api/purchase-orders?project_id=1&status=approved
Authorization: Bearer {token}
```

### Upload Invoice
```http
POST /api/purchase-orders/{id}/invoice
Authorization: Bearer {token}
Content-Type: multipart/form-data

{
  "invoice": <file>,
  "invoice_number": "INV-2026-001",
  "invoice_date": "2026-01-25"
}
```

### View Stock Inventory
```http
GET /api/stock?project_id=1
Authorization: Bearer {token}
```

---

## 📱 Mobile App Integration

### Navigation Structure
```
Purchase Manager Home Screen
├─ Dashboard (Tab 1)
├─ Material Requests (Tab 2) - Review pending
└─ Stock Inventory (Tab 3) - View levels

Drawer Menu
├─ Purchase Orders (Create/View)
├─ Vendors (Manage)
├─ Projects (View all)
├─ Cost Dashboard (Analytics)
├─ Profile
└─ Settings
```

### Key Screens
1. **Material Request List** - Shows pending/reviewed requests for procurement
2. **Purchase Order Create** - Multi-step PO creation with vendor selection
3. **Purchase Order List** - Track all POs with status filters
4. **Stock Inventory** - Real-time view of all materials by project
5. **Vendor Management** - Add/edit vendor details

---

## 🔒 Authorization & Policies

### PurchaseOrderPolicy
```php
✅ viewAny()    - Purchase Manager, Manager, Owner
✅ view()       - Purchase Manager (all) | Manager/Owner (project-specific)
✅ create()     - Purchase Manager only
✅ update()     - Purchase Manager only
✅ delete()     - Purchase Manager (only 'created' status)
✅ updateStatus() - Purchase Manager, Manager
✅ uploadInvoice() - Purchase Manager only
```

### Material Request Review
```php
Only Purchase Manager can call:
POST /material-requests/{id}/review
```

---

## 🧪 Testing Workflow

### Scenario 1: Complete Procurement Cycle
```
1. Login as Engineer (9876543213)
   → Create material request for 100 bags cement

2. Login as Purchase Manager (9876543215)
   → Review material request (mark as reviewed)

3. Login as Manager (9876543211)
   → Approve material request (final approval)

4. Login as Purchase Manager (9876543215)
   → Create PO from approved request
   → Select vendor
   → Confirm items match request
   → Submit PO (status: CREATED)

5. Manager or Purchase Manager
   → Update PO status to APPROVED

6. Purchase Manager
   → Upload vendor invoice (PDF/image)
   → System auto-triggers Stock IN
   → PO status → DELIVERED

7. View Stock Inventory
   → Verify 100 bags cement added to stock
   → Transaction recorded with PO reference
```

---

## 📊 GST Compliance Rules

### Rule 1: No Mixed GST Types in PO
```
❌ INVALID:
PO Items:
- Cement (GST 18%)
- Sand (Non-GST)

✅ VALID:
PO #1 Items:
- Cement (GST 18%)
- Steel (GST 18%)

PO #2 Items:
- Sand (Non-GST)
- Gravel (Non-GST)
```

### Rule 2: Invoice Validation
```
GST PO → Must upload GST Invoice with:
- GST percentage per item
- HSN codes
- GSTIN details

Non-GST PO → Must upload Non-GST Invoice with:
- No GST fields required
- Simple bill format
```

### Rule 3: Stock Segregation
```
Stock transactions maintain GST type:
- GST materials tracked separately
- Non-GST materials tracked separately
- Reports show breakdown by type
```

---

## 🎨 Mobile UI/UX

### Material Request Card (Purchase Manager View)
```
┌─────────────────────────────────────┐
│ 🔵 Cement - 100 bags                │
│ Project: Tower A Construction       │
│ Requested by: Vikram (Engineer)     │
│ Date: 2026-01-25                    │
│                                     │
│ Status: PENDING                     │
│                                     │
│ [Mark as Reviewed]  [View Details] │
└─────────────────────────────────────┘
```

### Purchase Order Status Badge
```
🟢 CREATED    - Just created
🟡 APPROVED   - Ready for delivery
🔵 DELIVERED  - Stock updated
⚫ CLOSED     - Complete
```

---

## 🚨 Common Issues & Solutions

### Issue 1: Cannot Create PO
**Symptom**: Button disabled or error on submit
**Solution**: 
- Ensure material request is in APPROVED status (not just reviewed)
- Check all items have same GST type
- Verify vendor is active

### Issue 2: Invoice Upload Fails
**Symptom**: Error "Invoice type mismatch"
**Solution**:
- GST PO needs GST invoice with percentages
- Non-GST PO needs simple invoice
- Check file size < 5MB

### Issue 3: Stock Not Updated
**Symptom**: PO delivered but stock unchanged
**Solution**:
- Verify PO status is APPROVED
- Check invoice is uploaded successfully
- Both conditions required for auto stock-in

---

## 📈 Best Practices

### 1. Review Before Creating PO
✅ Always review material requests before PO creation
✅ Verify quantities match actual requirements
✅ Check if stock already available
✅ Select most cost-effective vendor

### 2. GST Categorization
✅ Verify material GST type before adding to PO
✅ Group similar GST types together
✅ Maintain separate POs for GST and Non-GST

### 3. Vendor Management
✅ Keep vendor contact details updated
✅ Track vendor performance
✅ Maintain backup vendor list

### 4. Invoice Discipline
✅ Upload invoices immediately on delivery
✅ Verify invoice numbers are unique
✅ Match invoice items with PO items
✅ Store physical copies as backup

---

## 🔄 Integration Points

### With Engineers
- Engineers create material requests
- Purchase Manager reviews requests
- Engineers get notified of PO status

### With Managers
- Managers provide final approval on requests
- Managers can approve PO status changes
- Shared visibility on procurement

### With Inventory
- Auto stock-in on PO completion
- Real-time stock level updates
- Transaction history maintained

### With Accounting (Owner)
- All PO costs tracked
- GST amounts calculated
- Vendor payment tracking
- Budget variance reports

---

## 📚 Related Documentation

- [COMPLETE_SYSTEM_SUMMARY.md](backend/COMPLETE_SYSTEM_SUMMARY.md) - Full system architecture
- [PHASE_1_IMPLEMENTATION.md](backend/PHASE_1_IMPLEMENTATION.md) - Procurement model details
- [PHASE_2_IMPLEMENTATION.md](backend/PHASE_2_IMPLEMENTATION.md) - GST compliance
- [API_ENDPOINTS.md](backend/API_ENDPOINTS.md) - All API references
- [SYSTEM-CHANGE.md](SYSTEM-CHANGE.md) - Transformation overview

---

## ✅ Verification Checklist

Use this checklist to verify Purchase Manager role is working correctly:

- [ ] Can login with test credentials (9876543215)
- [ ] Can view pending material requests
- [ ] Can mark requests as reviewed
- [ ] Can create purchase order from approved request
- [ ] Cannot mix GST and Non-GST items in PO
- [ ] Can select vendor from dropdown
- [ ] Can upload vendor invoice (PDF/image)
- [ ] Stock updates automatically on PO approval + invoice
- [ ] Can view stock inventory across projects
- [ ] Cannot approve material requests (Manager only)
- [ ] Cannot create tasks or assign workers
- [ ] Cannot mark attendance
- [ ] Mobile app shows correct tabs (Dashboard, Requests, Stock)
- [ ] Drawer shows PO and Vendor management options

---

**Last Updated**: January 25, 2026
**Role Status**: ✅ Fully Implemented & Tested
**Platform Support**: Backend API ✅ | Mobile App ✅
