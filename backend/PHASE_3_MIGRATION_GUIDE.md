# Phase 3 Migration Guide

## Quick Start

This guide walks you through deploying Phase 3 (Stock & Inventory Integration) to your Construction Management System.

---

## Prerequisites

- ✅ Phase 1 completed (Purchase Manager role, PO system)
- ✅ Phase 2 completed (GST classification, material segregation)
- ✅ Database backup taken
- ✅ Laravel application running
- ✅ PostgreSQL 14+ database

---

## Step 1: Run Database Migrations

### Command

```bash
cd backend
php artisan migrate
```

### Expected Output

```
Migrating: 2026_01_24_000006_create_stock_transactions_table
Migrated:  2026_01_24_000006_create_stock_transactions_table (45.23ms)

Migrating: 2026_01_24_000007_add_invoice_number_to_purchase_orders_table
Migrated:  2026_01_24_000007_add_invoice_number_to_purchase_orders_table (12.45ms)
```

### Verify Migration

```bash
php artisan migrate:status
```

Look for these migrations with "Ran" status:
- `2026_01_24_000006_create_stock_transactions_table`
- `2026_01_24_000007_add_invoice_number_to_purchase_orders_table`

---

## Step 2: Verify New Models and Services

Check that these files exist:

```
backend/app/Models/StockTransaction.php (updated)
backend/app/Services/StockService.php (updated)
backend/app/Http/Controllers/Api/StockController.php (updated)
backend/app/Http/Controllers/Api/PurchaseOrderController.php (updated)
backend/app/Models/Material.php (updated - stock methods)
backend/app/Models/PurchaseOrder.php (updated - invoice_number field)
```

---

## Step 3: Test API Endpoints

### 3.1 Test Stock Reporting

**Get project stock report with GST segregation:**

```bash
curl -X GET "http://localhost:8000/api/stock/project/1/report" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "project_id": 1,
    "gst_materials": [],
    "non_gst_materials": [],
    "total_gst_items": 0,
    "total_non_gst_items": 0
  }
}
```

---

### 3.2 Test Stock Summary

**Get stock across all projects:**

```bash
curl -X GET "http://localhost:8000/api/stock/summary" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

### 3.3 Test Stock Movements

**Get transaction history for a material:**

```bash
curl -X GET "http://localhost:8000/api/stock/movements?material_id=1&project_id=1&limit=50" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## Step 4: Test Stock IN Workflow

### Scenario: Create Stock via Purchase Order

#### 4.1 Create Purchase Order

```bash
curl -X POST "http://localhost:8000/api/purchase-orders" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "project_id": 1,
    "vendor_id": 1,
    "items": [
      {
        "material_id": 1,
        "quantity": 100,
        "unit": "Bags (50kg)",
        "rate": 450
      }
    ]
  }'
```

**Note the PO ID from response (e.g., `"id": 5`)**

---

#### 4.2 Approve Purchase Order

```bash
curl -X PATCH "http://localhost:8000/api/purchase-orders/5/status" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "approved"
  }'
```

---

#### 4.3 Upload Vendor Invoice

**Create a test PDF/image file first, then:**

```bash
curl -X POST "http://localhost:8000/api/purchase-orders/5/upload-invoice" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "invoice=@/path/to/test-invoice.pdf" \
  -F "invoice_type=gst" \
  -F "invoice_number=TEST-INV-001"
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Invoice uploaded and stock IN transactions created successfully",
  "data": {...},
  "stock_transactions": 1
}
```

**✅ This confirms stock IN was created!**

---

#### 4.4 Verify Stock Created

```bash
curl -X GET "http://localhost:8000/api/stock/project/1/report" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Expected**: Material with ID 1 should now show `"current_stock": 100.00`

---

#### 4.5 Check Transaction History

```bash
curl -X GET "http://localhost:8000/api/stock/movements?material_id=1&project_id=1" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Expected**: One transaction with:
- `"transaction_type": "in"`
- `"quantity": "100.00"`
- `"reference_type": "purchase_order"`
- `"invoice_id": "TEST-INV-001"`

---

## Step 5: Test Stock OUT Workflow

### 5.1 Create Stock OUT Transaction

```bash
curl -X POST "http://localhost:8000/api/stock/out" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "material_id": 1,
    "project_id": 1,
    "quantity": 30,
    "notes": "Consumed for foundation work"
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Stock OUT transaction created successfully",
  "data": {
    "transaction_type": "out",
    "quantity": "30.00",
    "balance_after_transaction": "70.00",
    ...
  }
}
```

---

### 5.2 Verify Balance Reduced

```bash
curl -X GET "http://localhost:8000/api/stock/project/1/report" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Expected**: Material with ID 1 should now show `"current_stock": 70.00`

---

### 5.3 Test Negative Stock Prevention

**Attempt to withdraw more than available:**

```bash
curl -X POST "http://localhost:8000/api/stock/out" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "material_id": 1,
    "project_id": 1,
    "quantity": 999999
  }'
```

**Expected Response (422 Error):**
```json
{
  "success": false,
  "message": "Failed to create stock OUT: Cannot create stock OUT transaction. Insufficient stock for material 'Portland Cement 53 Grade'. Current balance: 70, Requested: 999999"
}
```

**✅ This confirms negative stock prevention works!**

---

## Step 6: Alternative Workflow (Approve Before Invoice)

### 6.1 Create Another PO

```bash
curl -X POST "http://localhost:8000/api/purchase-orders" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "project_id": 1,
    "vendor_id": 1,
    "items": [
      {
        "material_id": 2,
        "quantity": 50,
        "unit": "MT",
        "rate": 55000
      }
    ]
  }'
```

**Note the PO ID (e.g., `"id": 6`)**

---

### 6.2 Upload Invoice (Before Approval)

```bash
curl -X POST "http://localhost:8000/api/purchase-orders/6/upload-invoice" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "invoice=@/path/to/test-invoice2.pdf" \
  -F "invoice_type=gst" \
  -F "invoice_number=TEST-INV-002"
```

**Expected Message:**
```
"Invoice uploaded successfully. Stock will be added when PO is approved."
```

**No stock created yet!**

---

### 6.3 Now Approve PO

```bash
curl -X PATCH "http://localhost:8000/api/purchase-orders/6/status" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "approved"
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Purchase Order approved and stock IN transactions created successfully",
  "stock_transactions": 1
}
```

**✅ Stock created when PO approved!**

---

## Step 7: Verify Stock Movement Audit Trail

```bash
curl -X GET "http://localhost:8000/api/stock/movements?material_id=1&project_id=1" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Expected Output:**

Should show transactions in chronological order:
1. Stock IN from PO #... (+100 bags)
2. Stock OUT for site consumption (-30 bags)
3. Current balance: 70 bags

Each transaction should include:
- User who performed it (`performed_by`)
- Timestamp (`transaction_date`)
- Reference to source (`reference_type`, `reference_id`)
- Running balance (`balance_after_transaction`)

---

## Step 8: Production Deployment Checklist

### Before Deployment

- [ ] Database backup completed
- [ ] Migrations tested on staging environment
- [ ] API endpoints tested with authentication
- [ ] Mobile app updated (if applicable)
- [ ] Purchase Managers trained on new invoice_number requirement

### Deploy to Production

```bash
# 1. Pull latest code
git pull origin main

# 2. Install dependencies (if needed)
composer install --no-dev --optimize-autoloader

# 3. Run migrations
php artisan migrate --force

# 4. Clear caches
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 5. Restart queue workers (if using)
php artisan queue:restart
```

### After Deployment

- [ ] Verify migrations ran successfully
- [ ] Test stock IN workflow with real PO
- [ ] Test stock OUT workflow
- [ ] Verify stock reports show correct data
- [ ] Check error logs for issues

---

## Step 9: Rollback Plan (If Needed)

### If Issues Occur

```bash
# Rollback last 2 migrations
php artisan migrate:rollback --step=2

# Or rollback to specific batch
php artisan migrate:rollback --batch=X
```

**Note**: Stock transactions will be deleted. Ensure PO data is intact before retrying.

---

## Troubleshooting

### Issue: "Column 'invoice_number' not found"

**Solution**: Run migrations:
```bash
php artisan migrate
```

---

### Issue: "Class 'StockService' not found"

**Solution**: Clear caches:
```bash
php artisan config:clear
php artisan cache:clear
composer dump-autoload
```

---

### Issue: Stock IN not created when uploading invoice

**Check**:
1. Is PO status = 'approved'?
2. Is invoice_number provided in request?
3. Check error logs: `storage/logs/laravel.log`

**Debug**:
```bash
# Check PO status
curl -X GET "http://localhost:8000/api/purchase-orders/{id}" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

### Issue: Negative stock error when sufficient stock exists

**Possible Causes**:
1. Stock is on different project
2. Multiple concurrent requests depleted stock
3. Database transaction rollback

**Check Current Stock**:
```bash
curl -X GET "http://localhost:8000/api/stock/movements?material_id=X&project_id=Y" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## API Endpoint Summary

### New Endpoints (Phase 3)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/stock/project/{id}/report` | Stock report with GST segregation |
| GET | `/api/stock/movements` | Transaction history (query params: material_id, project_id, limit) |
| GET | `/api/stock/summary` | Stock across all projects |
| POST | `/api/stock/out` | Create stock OUT transaction |

### Modified Endpoints

| Method | Endpoint | Change |
|--------|----------|--------|
| POST | `/api/purchase-orders/{id}/upload-invoice` | Now requires `invoice_number` field |
| PATCH | `/api/purchase-orders/{id}/status` | Auto-creates stock IN when approving |

---

## Database Schema Changes

### New Table: `stock_transactions`

```sql
-- Check table created
SELECT * FROM stock_transactions LIMIT 5;

-- Check indexes
\d stock_transactions
```

### Modified Table: `purchase_orders`

```sql
-- Verify new column
SELECT invoice_number FROM purchase_orders LIMIT 5;
```

---

## Performance Considerations

### Indexes

Phase 3 adds these indexes for optimal performance:
- `stock_transactions (material_id, project_id)` - Fast stock lookups
- `stock_transactions (reference_type, reference_id)` - Fast PO/task linking
- `stock_transactions (transaction_date)` - Fast date range queries

### Query Optimization

Current stock is retrieved from latest transaction's `balance_after_transaction` field, avoiding SUM operations on large datasets.

---

## Next Steps

After successful Phase 3 deployment:

1. **Train Users**: Educate Purchase Managers on invoice_number requirement
2. **Monitor Stock**: Watch for negative stock errors in first week
3. **Generate Reports**: Use stock reports for inventory valuation
4. **Plan Phase 4**: Costing & Variance Analytics (next phase)

---

## Support

If issues persist:
1. Check `storage/logs/laravel.log` for errors
2. Verify database constraints: `SELECT * FROM stock_transactions WHERE balance_after_transaction < 0;`
3. Review API responses for detailed error messages

---

**Phase 3 Migration Complete! ✅**

Your system now has:
- ✅ Fully auditable stock tracking
- ✅ PO-driven stock IN automation
- ✅ Negative stock prevention
- ✅ GST-segregated inventory reports
- ✅ Complete transaction audit trail
