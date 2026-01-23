# Quick Reference - Automated GST Billing

## API Endpoints

### Create Task (Manager/Engineer)
```http
POST /api/tasks
Authorization: Bearer {token}
Content-Type: application/json

{
  "project_id": 1,
  "assigned_to": 4,
  "title": "Foundation Work",
  "description": "Complete foundation pouring",
  "billing_amount": 15000,
  "gst_percentage": 18
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "title": "Foundation Work",
    "billing_amount": "15000.00",
    "gst_percentage": "18.00"
  }
}
```

---

### Submit DPR (Worker)
```http
POST /api/dprs
Authorization: Bearer {token}
Content-Type: multipart/form-data

project_id: 1
task_id: 1
work_description: "Completed concrete foundation work"
latitude: 28.6139
longitude: 77.2090
photos[]: [files...]
```

**Response:**
```json
{
  "success": true,
  "message": "DPR submitted successfully",
  "data": {
    "id": 1,
    "status": "submitted",
    "task_id": 1
  }
}
```

**Note:** Worker does NOT send billing_amount or gst_percentage

---

### Approve DPR (Manager)
```http
POST /api/dprs/{id}/approve
Authorization: Bearer {token}
Content-Type: application/json

{
  "status": "approved"
}
```

**Response:**
```json
{
  "success": true,
  "message": "DPR approved successfully",
  "data": {
    "id": 1,
    "status": "approved"
  }
}
```

**Result:** Invoice auto-generated!

---

### View Invoices (Owner Only)
```http
GET /api/invoices/{id}
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "invoice_number": "INV-20260123-4102",
    "total_amount": "17700.00",
    "gst_amount": "2700.00",
    "status": "generated",
    "task_id": 1,
    "dpr_id": 1,
    "task": {
      "id": 1,
      "title": "Foundation Work"
    },
    "dpr": {
      "id": 1,
      "work_description": "Completed work"
    },
    "items": [
      {
        "description": "Task: Foundation Work - Work completed as per DPR",
        "amount": "15000.00",
        "gst_percentage": "18.00"
      }
    ]
  }
}
```

---

### Attempt Manual Invoice Creation (Blocked!)
```http
POST /api/invoices
Authorization: Bearer {token}
Content-Type: application/json

{
  "project_id": 1,
  "items": [...]
}
```

**Response:**
```json
{
  "success": false,
  "message": "Manual invoice creation is not allowed. Invoices are auto-generated when DPRs are approved."
}
```
**Status Code:** 403 Forbidden

---

## Database Queries

### Check Auto-Generated Invoice
```sql
SELECT 
    i.id,
    i.invoice_number,
    i.total_amount,
    i.gst_amount,
    i.status,
    t.title as task_title,
    t.billing_amount as task_rate,
    d.work_description,
    d.status as dpr_status
FROM invoices i
LEFT JOIN tasks t ON i.task_id = t.id
LEFT JOIN daily_progress_reports d ON i.dpr_id = d.id
WHERE i.id = 1;
```

### Verify Audit Trail
```sql
-- Full traceability: Task -> DPR -> Invoice
SELECT 
    t.id as task_id,
    t.title,
    t.billing_amount,
    t.gst_percentage,
    d.id as dpr_id,
    d.status as dpr_status,
    i.id as invoice_id,
    i.invoice_number,
    i.total_amount
FROM tasks t
LEFT JOIN daily_progress_reports d ON d.task_id = t.id
LEFT JOIN invoices i ON i.dpr_id = d.id
WHERE t.id = 1;
```

---

## Test Credentials

After running `php artisan db:seed`:

| Role | Phone | Usage |
|------|-------|-------|
| Owner | 9876543210 | View invoices, analytics |
| Manager | 9876543211 | Create tasks, approve DPRs |
| Engineer | 9876543213 | Create tasks, submit DPRs |
| Worker | 9876543220 | Submit DPRs only |

**Login:**
```http
POST /api/login
Content-Type: application/json

{
  "phone": "9876543211"
}
```

---

## Mobile App Usage

### Manager - Create Task with Billing
```dart
await taskRepository.createTask(
  projectId: 1,
  title: 'Concrete Work',
  description: 'Foundation pouring',
  billingAmount: 15000.0,  // Required
  gstPercentage: 18.0,     // Required
  assignedTo: 4,
);
```

### Worker - Submit DPR (No Billing)
```dart
await dprRepository.submitDpr(
  projectId: 1,
  taskId: 1,  // Optional link to task
  workDescription: 'Completed foundation work',
  latitude: 28.6139,
  longitude: 77.2090,
  photoPaths: [...],
  // NO billingAmount parameter!
  // NO gstPercentage parameter!
);
```

### Owner - View Invoice
```dart
// Only Owner role can access
final invoice = await invoiceRepository.getInvoice(invoiceId);
print('Total: ₹${invoice.totalAmount}');
print('GST: ₹${invoice.gstAmount}');
print('Linked Task: ${invoice.task?.title}');
```

---

## Billing Calculation

Given:
- Task billing_amount: ₹15,000
- Task gst_percentage: 18%

Auto-calculation:
```
Taxable Amount = ₹15,000
GST Amount = ₹15,000 × 18 / 100 = ₹2,700
Grand Total = ₹15,000 + ₹2,700 = ₹17,700
```

This is stored in invoice:
- `total_amount` = ₹17,700 (includes GST)
- `gst_amount` = ₹2,700

---

## Error Scenarios

### Worker tries to view invoice
```json
{
  "message": "This action is unauthorized."
}
```

### Manager tries to create invoice manually
```json
{
  "success": false,
  "message": "Manual invoice creation is not allowed."
}
```

### DPR approved without linked task
- Invoice NOT generated (billing_amount would be null)
- Or falls back to DPR's billing_amount if present

### Task without billing_amount
- Validation error: "The billing_amount field is required."

---

## Testing Checklist

- [ ] Manager can create task with billing info
- [ ] Worker can submit DPR without billing fields
- [ ] Manager can approve DPR
- [ ] Invoice auto-generates on approval
- [ ] Invoice has correct GST calculation
- [ ] Invoice is linked to task and DPR
- [ ] Worker CANNOT view invoice (403)
- [ ] Manager CANNOT create invoice manually (403)
- [ ] Owner CAN view invoice
- [ ] Audit trail is complete (task → dpr → invoice)

Run: `php test_gst_billing.php --cleanup`

---

## Common Issues

### Issue: Invoice not generated after approval
**Check:**
- Is DPR linked to a task? (`task_id` not null)
- Does task have `billing_amount > 0`?
- Is approval status exactly "approved"?

**Debug:**
```php
$dpr = DailyProgressReport::with('task')->find(1);
dd($dpr->task->billing_amount);
```

### Issue: Manual invoice creation succeeds
**Fix:** Ensure `InvoicePolicy` is registered in `AuthServiceProvider`

### Issue: Worker sees billing fields in UI
**Fix:** Add role check in mobile app task creation screen

---

## Support

For issues or questions, refer to:
- `GST_BILLING_IMPLEMENTATION.md` - Detailed implementation docs
- `IMPLEMENTATION_COMPLETE.md` - Summary and deployment guide
- `backend/test_gst_billing.php` - Working test example
