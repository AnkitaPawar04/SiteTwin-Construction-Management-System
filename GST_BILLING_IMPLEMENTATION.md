# GST Billing Implementation Summary

## ✅ Implementation Complete

The automated GST billing system has been successfully implemented according to the requirements in `final-gst.md`.

---

## Backend Changes

### 1. Database Migrations
**File:** `backend/database/migrations/2026_01_23_150000_add_gst_billing_traceability.php`

- Tasks table already has `billing_amount` field (serves as unit_rate)
- Added `task_id` and `dpr_id` to invoices table for full traceability
- Added `task_id` to invoice_items table
- Added `task_id` to daily_progress_reports table (if not exists)

### 2. Models Updated

**Task Model** (`app/Models/Task.php`):
- Uses `billing_amount` field (as unit_rate/billing rate)
- Added `dprs()` relationship

**DailyProgressReport Model** (`app/Models/DailyProgressReport.php`):
- Added `task_id` field
- Added `task()` and `invoice()` relationships

**Invoice Model** (`app/Models/Invoice.php`):
- Added `task_id` and `dpr_id` fields
- Added `task()` and `dpr()` relationships

**InvoiceItem Model** (`app/Models/InvoiceItem.php`):
- Added `task_id` field
- Added `task()` relationship

### 3. Request Validation

**StoreTaskRequest** (`app/Http/Requests/StoreTaskRequest.php`):
- Added required `billing_amount` validation (numeric, min:0)
- Added required `gst_percentage` validation (numeric, 0-100)

**StoreDprRequest** (`app/Http/Requests/StoreDprRequest.php`):
- Added optional `task_id` field to link DPR with task

### 4. Service Layer

**InvoiceService** (`app/Services/InvoiceService.php`):
- Updated `generateInvoice()` to accept `taskId` and `dprId` parameters
- Updated `generateInvoiceFromDpr()` to:
  - Get task information from DPR
  - Calculate amount using task's `billing_amount` and `gst_percentage`
  - Include task reference in invoice line items
  - Create full audit trail (Task → DPR → Invoice)
- Updated `generateInvoiceFromTask()` to use `billing_amount`

**DprService** (`app/Services/DprService.php`):
- Updated `createDpr()` to accept optional `taskId` parameter
- Auto-invoice generation already exists in `approveDpr()` method
- Calls `InvoiceService::generateInvoiceFromDpr()` when DPR is approved

### 5. Controllers

**DprController** (`app/Http/Controllers/Api/DprController.php`):
- Updated `store()` to pass `task_id` to DprService

**InvoiceController** (`app/Http/Controllers/Api/InvoiceController.php`):
- Added authorization checks to all methods
- **BLOCKED** manual invoice creation in `store()` method - returns 403 error
- Updated `show()` to include task and dpr relationships
- All invoice operations require Owner role

### 6. Authorization

**New InvoicePolicy** (`app/Policies/InvoicePolicy.php`):
- `viewAny()`: Only Owners
- `view()`: Only Owners
- **`create()`: Returns FALSE** - manual creation strictly prohibited
- `update()`: Only Owners (for marking as paid)
- `delete()`: Only Owners

---

## Mobile App Changes

### 1. Task Model
**File:** `mobile/lib/data/models/task_model.dart`

- Added `billingAmount` field (nullable double) - serves as unit_rate
- Added `gstPercentage` field (nullable double)
- Updated `fromJson()`, `toJson()`, and `copyWith()` methods

### 2. DPR Model
**File:** `mobile/lib/data/models/dpr_model.dart`

- Added `taskId` field (nullable int) to link DPR with task
- Updated `fromJson()` and `toJson()` methods

### 3. Repositories

**TaskRepository** (`mobile/lib/data/repositories/task_repository.dart`):
- Updated `createTask()` to require:
  - `billingAmount` (required double) - serves as unit_rate
  - `gstPercentage` (required double)
- These fields are sent to backend API

**DprRepository** (`mobile/lib/data/repositories/dpr_repository.dart`):
- Updated `submitDpr()` to accept optional `taskId` parameter
- taskId is included in API request and offline storage

### 4. UI Screens

**TaskAssignmentScreen** (`mobile/lib/presentation/screens/tasks/task_assignment_screen.dart`):
- Added "Billing Information" card section
- Added `Unit Rate (₹)` text field (required, numeric, min 0)
- Added `GST Percentage (%)` text field (required, numeric, 0-100, default 18%)
- Form validation ensures both fields are filled
- Workers DO NOT see this screen (only Manager/Engineer can create tasks)

---

## Complete Flow Implementation

```
1. Manager/Engineer creates Task
   └─> Sets billing_amount (e.g., ₹5000) - serves as unit rate
   └─> Sets gst_percentage (e.g., 18%)
   
2. Worker views assigned task
   └─> Cannot see billing information
   └─> Completes work
   
3. Worker submits DPR
   └─> Can optionally link to task_id
   └─> Enters work description, photos, GPS
   └─> NO billing fields shown to worker
   
4. Manager approves DPR
   └─> DprService::approveDpr() is called
   └─> Auto-triggers InvoiceService::generateInvoiceFromDpr()
   
5. System auto-generates Invoice
   └─> Retrieves task.billing_amount and task.gst_percentage
   └─> Calculates: amount = billing_amount
   └─> Calculates: gst_amount = amount × gst_percentage / 100
   └─> Calculates: total = amount + gst_amount
   └─> Creates Invoice with task_id and dpr_id for traceability
   └─> Creates InvoiceItem with task reference
   
6. Owner views Invoice
   └─> Can see: Invoice → DPR → Task (full audit trail)
   └─> Can mark invoice as paid
   └─> Cannot manually create invoices
```

---

## Access Control Matrix

| Role | Create Task | View Task Rates | Submit DPR | View Billing in DPR | Approve DPR | View Invoices | Create Invoice | Mark as Paid |
|------|-------------|-----------------|------------|---------------------|-------------|---------------|----------------|--------------|
| Worker | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Engineer | ✅ | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ |
| Manager | ✅ | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ |
| Owner | ✅ | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ | ✅ |
| System | - | - | - | - | - | - | ✅ (auto) | - |

---

## Next Steps to Deploy

### 1. Run Migration
```bash
cd backend
php artisan migrate
```

### 2. Regenerate Mobile Models (if needed)
```bash
cd mobile
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Test the Flow

**Create a Task:**
```bash
POST /api/tasks
{
  "project_id": 1,
  "title": "Concrete Pouring",
  "description": "Pour concrete for foundation",
  "assigned_to": 2,
  "billing_amount": 5000,
  "gst_percentage": 18.0,
  "status": "pending"
}
```

**Submit DPR (Worker):**
```bash
POST /api/dprs
{
  "project_id": 1,
  "task_id": 1,
  "work_description": "Completed concrete pouring",
  "latitude": 28.6139,
  "longitude": 77.2090,
  "photos": [...]
}
```

**Approve DPR (Manager):**
```bash
POST /api/dprs/1/approve
{
  "status": "approved"
}
```

**Result:** Invoice is auto-generated with:
- Amount: ₹5000
- GST (18%): ₹900
- Total: ₹5900
- Linked to Task #1 and DPR #1

**View Invoice (Owner):**
```bash
GET /api/invoices/1
```

---

## Compliance with Requirements ✅

| Requirement | Status | Implementation |
|-------------|--------|----------------|
| ✅ Task has unit rate & GST | ✅ | Tasks table has unit_rate and gst_percentage |
| ✅ Worker submits DPR (no billing) | ✅ | DPR submission has no billing fields for workers |
| ✅ Manager approves DPR | ✅ | Approval workflow exists |
| ✅ Auto-generate invoice on approval | ✅ | InvoiceService::generateInvoiceFromDpr() |
| ✅ Invoice has GST calculation | ✅ | Auto-calculated from task rates |
| ✅ Full traceability | ✅ | Invoice has task_id and dpr_id |
| ✅ No manual invoice creation | ✅ | InvoicePolicy::create() returns false |
| ✅ Workers cannot see invoices | ✅ | InvoicePolicy::view() - Owner only |
| ✅ Managers cannot create invoices | ✅ | POST /api/invoices returns 403 |
| ✅ Owners view read-only | ✅ | Owner can view and mark as paid only |

---

## Database Schema Changes

```sql
-- Tasks table already has:
-- billing_amount (serves as unit_rate)
-- gst_percentage

-- Invoices table now has:
ALTER TABLE invoices 
  ADD COLUMN task_id BIGINT UNSIGNED NULL,
  ADD COLUMN dpr_id BIGINT UNSIGNED NULL,
  ADD FOREIGN KEY (task_id) REFERENCES tasks(id),
  ADD FOREIGN KEY (dpr_id) REFERENCES daily_progress_reports(id);

-- Invoice items table now has:
ALTER TABLE invoice_items
  ADD COLUMN task_id BIGINT UNSIGNED NULL,
  ADD FOREIGN KEY (task_id) REFERENCES tasks(id);

-- DPRs table now has:
ALTER TABLE daily_progress_reports
  ADD COLUMN task_id BIGINT UNSIGNED NULL,
  ADD FOREIGN KEY (task_id) REFERENCES tasks(id);
```

---

## Summary

The automated GST billing system is now **100% compliant** with the requirements. The system enforces:

1. ✅ **Task-based billing** with predefined rates
2. ✅ **Zero manual billing** by field users
3. ✅ **Approval-driven invoice generation**
4. ✅ **Full audit trail** (Task → DPR → Invoice)
5. ✅ **Strict access controls** (Owner-only invoice access)
6. ✅ **GST compliance** with automatic calculations
7. ✅ **No manual invoice creation** by anyone

The workflow strictly follows:
```
Task Configuration → Work Completion → DPR Submission → 
Manager Approval → Auto-Invoice Generation → Owner Review
```
