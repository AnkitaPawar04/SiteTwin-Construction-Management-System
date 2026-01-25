# Phase 3 Implementation: Stock & Inventory Integration

## Overview

Phase 3 connects the procurement system (Phases 1 & 2) to inventory management, creating a fully auditable stock tracking system. Stock movements are controlled exclusively through Purchase Orders (IN) and task/site consumption (OUT), with strict validation to prevent negative stock and unauthorized inventory changes.

**Key Principle**: Stock increases only when a PO is approved AND a vendor invoice is uploaded. All stock movements must reference their source (PO ID, Task ID, or manual adjustment).

---

## 1. Stock Transaction Model

### Database Schema

**Migration**: `2026_01_24_000006_create_stock_transactions_table.php`

```php
Schema::create('stock_transactions', function (Blueprint $table) {
    $table->id();
    $table->foreignId('material_id')->constrained()->onDelete('restrict');
    $table->foreignId('project_id')->constrained()->onDelete('restrict');
    
    // Transaction type: 'in' or 'out'
    $table->string('transaction_type');
    
    // Quantity (always positive, type determines direction)
    $table->decimal('quantity', 10, 2);
    
    // Reference to source of transaction
    $table->string('reference_type'); // 'purchase_order', 'task', 'adjustment'
    $table->unsignedBigInteger('reference_id'); // ID of PO or Task
    
    // For stock IN: required invoice reference
    $table->string('invoice_id')->nullable(); // Vendor invoice ID/number
    
    // User who performed the transaction
    $table->foreignId('performed_by')->constrained('users')->onDelete('restrict');
    
    // Transaction timestamp
    $table->timestamp('transaction_date');
    
    // Optional notes/remarks
    $table->text('notes')->nullable();
    
    // Stock balance after this transaction (for quick lookup)
    $table->decimal('balance_after_transaction', 10, 2)->default(0);
    
    $table->timestamps();
    
    // Indexes for performance
    $table->index(['material_id', 'project_id']);
    $table->index(['reference_type', 'reference_id']);
    $table->index('transaction_date');
});
```

### Model Constants

```php
// Transaction types
const TYPE_IN = 'in';
const TYPE_OUT = 'out';

// Reference types
const REFERENCE_PURCHASE_ORDER = 'purchase_order';
const REFERENCE_TASK = 'task';
const REFERENCE_ADJUSTMENT = 'adjustment';
```

### Key Features

1. **Balance Tracking**: Each transaction stores the `balance_after_transaction` for quick current stock lookups
2. **Audit Trail**: Every transaction references its source (PO, Task, or Adjustment)
3. **Invoice Linkage**: Stock IN transactions must reference vendor invoice number
4. **User Accountability**: Tracks which user performed each transaction
5. **Temporal Data**: Transaction date allows historical stock analysis

---

## 2. Stock IN Workflow (Purchase Order Integration)

### Trigger Conditions

Stock IN transactions are automatically created when **BOTH** conditions are met:

1. **Purchase Order is APPROVED** (status = 'approved')
2. **Vendor Invoice is UPLOADED** (invoice_file + invoice_number exist)

### Implementation Path 1: Upload Invoice First

```
1. Purchase Manager uploads invoice → PO status still 'created'
2. Manager approves PO → Stock IN transactions created automatically
```

**Code**: `PurchaseOrderController::updateStatus()`

```php
if ($validated['status'] === PurchaseOrder::STATUS_APPROVED) {
    $purchaseOrder->approved_at = now();

    // Create stock IN if invoice already uploaded
    if ($purchaseOrder->invoice_file && $purchaseOrder->invoice_number) {
        $stockService = new StockService();
        $stockTransactions = $stockService->createStockInFromPurchaseOrder(
            $purchaseOrder,
            $purchaseOrder->invoice_number,
            auth()->id()
        );
        // Returns count of transactions created
    }
}
```

### Implementation Path 2: Approve PO First

```
1. Manager approves PO → Status becomes 'approved'
2. Purchase Manager uploads invoice → Stock IN transactions created automatically
```

**Code**: `PurchaseOrderController::uploadInvoice()`

```php
// After validating and storing invoice file
if ($purchaseOrder->status === PurchaseOrder::STATUS_APPROVED) {
    $stockService = new StockService();
    $stockTransactions = $stockService->createStockInFromPurchaseOrder(
        $purchaseOrder,
        $validated['invoice_number'],
        auth()->id()
    );
    return "Invoice uploaded and stock IN transactions created";
}
return "Invoice uploaded successfully. Stock will be added when PO is approved.";
```

### Stock IN Transaction Details

For each item in the PO, a stock transaction is created:

```php
StockTransaction::create([
    'material_id' => $item->material_id,
    'project_id' => $purchaseOrder->project_id,
    'transaction_type' => 'in',
    'quantity' => $item->quantity,
    'reference_type' => 'purchase_order',
    'reference_id' => $purchaseOrder->id,
    'invoice_id' => $invoiceNumber,
    'performed_by' => auth()->id(),
    'transaction_date' => now(),
    'notes' => "Stock IN from PO #{$purchaseOrder->po_number}",
    'balance_after_transaction' => $currentBalance + $item->quantity,
]);
```

---

## 3. Stock OUT Workflow (Task/Site Consumption)

### Manual Stock OUT (API Endpoint)

Since tasks in the current system don't have direct material associations, stock OUT is triggered manually via API:

**Endpoint**: `POST /api/stock/out`

**Request**:
```json
{
  "material_id": 5,
  "project_id": 2,
  "task_id": 12,  // Optional: links to specific task
  "quantity": 50,
  "notes": "Material consumed for foundation work"
}
```

**Response (Success)**:
```json
{
  "success": true,
  "message": "Stock OUT transaction created successfully",
  "data": {
    "id": 45,
    "material_id": 5,
    "project_id": 2,
    "transaction_type": "out",
    "quantity": "50.00",
    "balance_after_transaction": "150.00",
    "reference_type": "task",
    "reference_id": 12,
    "performed_by": 3,
    "transaction_date": "2026-01-24T14:30:00.000000Z"
  }
}
```

**Response (Insufficient Stock)**:
```json
{
  "success": false,
  "message": "Failed to create stock OUT: Insufficient stock for material 'Portland Cement 53 Grade'. Available: 30, Required: 50"
}
```

### Negative Stock Prevention

**StockService::createStockTransaction()** validates before creating OUT transactions:

```php
if ($transactionType === StockTransaction::TYPE_OUT) {
    $newBalance = $currentBalance - $quantity;
    
    if ($newBalance < 0) {
        throw new Exception(
            "Cannot create stock OUT transaction. " .
            "Insufficient stock for material '{$material->name}'. " .
            "Current balance: {$currentBalance}, Requested: {$quantity}"
        );
    }
}
```

### Future Task Integration

In Phase 4 or later, the system can be enhanced to:
1. Add `task_materials` table linking tasks to required materials
2. Automatically deduct stock when task status changes to 'completed'
3. Validate material availability before allowing task start

---

## 4. Stock Service Methods

### 4.1 Create Stock IN from Purchase Order

```php
public function createStockInFromPurchaseOrder(
    PurchaseOrder $purchaseOrder,
    string $invoiceId,
    int $performedBy
): array
```

**Validations**:
- PO must be in 'approved' status
- Creates one transaction per PO item
- Wraps all transactions in database transaction (all-or-nothing)

**Returns**: Array of created `StockTransaction` objects

---

### 4.2 Create Stock OUT from Task

```php
public function createStockOutFromTask(
    int $materialId,
    int $projectId,
    int $taskId,
    float $quantity,
    int $performedBy
): StockTransaction
```

**Validations**:
- Checks sufficient stock availability
- Prevents negative stock
- Links transaction to task ID

---

### 4.3 Get Stock Report (GST/Non-GST Segregation)

```php
public function getStockReport(int $projectId): array
```

**Returns**:
```json
{
  "project_id": 2,
  "gst_materials": [
    {
      "material_id": 1,
      "material_name": "Portland Cement 53 Grade",
      "unit": "Bags (50kg)",
      "current_stock": 200.00,
      "gst_percentage": 28.00
    }
  ],
  "non_gst_materials": [
    {
      "material_id": 15,
      "material_name": "General Labor",
      "unit": "Person-Days",
      "current_stock": 0,
      "gst_percentage": 0
    }
  ],
  "total_gst_items": 35,
  "total_non_gst_items": 8
}
```

**Use Case**: Inventory valuation, GST compliance reporting

---

### 4.4 Get Stock Movements (Transaction History)

```php
public function getStockMovements(
    int $materialId,
    int $projectId,
    ?int $limit = null
)
```

**Returns**: Collection of transactions ordered by date (newest first)

**Use Case**: Audit trail, material consumption analysis, wastage detection

---

## 5. Material Model Enhancements

### New Methods

```php
// Get current stock balance for a specific project
public function getCurrentStock($projectId)
{
    return $this->stockTransactions()
        ->where('project_id', $projectId)
        ->orderBy('transaction_date', 'desc')
        ->orderBy('id', 'desc')
        ->value('balance_after_transaction') ?? 0;
}

// Get total stock across all projects
public function getTotalStock()
{
    $projects = Project::all();
    $totalStock = 0;
    foreach ($projects as $project) {
        $totalStock += $this->getCurrentStock($project->id);
    }
    return $totalStock;
}

// Check if sufficient stock for a given project
public function hasSufficientStock($projectId, $requiredQuantity)
{
    $currentStock = $this->getCurrentStock($projectId);
    return $currentStock >= $requiredQuantity;
}
```

**Design Note**: Current stock is computed from `balance_after_transaction` of the latest transaction, not summing all transactions. This is more efficient and prevents rounding errors.

---

## 6. API Endpoints

### 6.1 Get Project Stock Report

**Endpoint**: `GET /api/stock/project/{projectId}/report`

**Authorization**: Authenticated users (Manager, Engineer, Purchase Manager)

**Response**:
```json
{
  "success": true,
  "data": {
    "project_id": 2,
    "gst_materials": [...],
    "non_gst_materials": [...],
    "total_gst_items": 35,
    "total_non_gst_items": 8
  }
}
```

---

### 6.2 Get Stock Movements

**Endpoint**: `GET /api/stock/movements?material_id={id}&project_id={id}&limit={n}`

**Query Parameters**:
- `material_id` (required): Material ID
- `project_id` (required): Project ID
- `limit` (optional): Max transactions to return (default: all, max: 1000)

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "id": 45,
      "material": {...},
      "project": {...},
      "performer": {...},
      "transaction_type": "out",
      "quantity": "50.00",
      "balance_after_transaction": "150.00",
      "reference_type": "task",
      "reference_id": 12,
      "invoice_id": null,
      "transaction_date": "2026-01-24T14:30:00Z",
      "notes": "Material consumed for foundation work"
    }
  ]
}
```

---

### 6.3 Get Stock Summary (All Projects)

**Endpoint**: `GET /api/stock/summary`

**Authorization**: Manager, Purchase Manager, Owner

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "material_id": 1,
      "material_name": "Portland Cement 53 Grade",
      "unit": "Bags (50kg)",
      "gst_type": "gst",
      "total_stock": 450.00,
      "project_wise_stock": [
        {"project_id": 1, "project_name": "Sky Towers", "stock": 200.00},
        {"project_id": 2, "project_name": "Green Valley", "stock": 250.00}
      ]
    }
  ]
}
```

---

### 6.4 Create Stock OUT (Manual)

**Endpoint**: `POST /api/stock/out`

**Authorization**: Manager, Engineer (must have permissions on the project)

**Request Body**:
```json
{
  "material_id": 5,
  "project_id": 2,
  "task_id": 12,  // Optional
  "quantity": 50,
  "notes": "Consumed for column casting"
}
```

**Validations**:
- Material and project must exist
- Sufficient stock must be available
- User must have permissions for the project

---

## 7. Changes to Purchase Order Model

### New Field

**Migration**: `2026_01_24_000007_add_invoice_number_to_purchase_orders_table.php`

```php
$table->string('invoice_number', 100)->nullable()->after('invoice_type');
```

**Updated Fillable**:
```php
protected $fillable = [
    // ... existing fields
    'invoice_number',
];
```

**Purpose**: Track vendor invoice number for stock IN traceability

---

## 8. Testing Scenarios

### Scenario 1: Stock IN from PO (Path 1: Invoice First)

```
1. Purchase Manager creates PO for 100 bags cement
2. Purchase Manager uploads vendor invoice #INV-2024-001
3. Manager approves PO
4. ✅ Stock IN transaction created: +100 bags
5. Verify balance_after_transaction = 100
```

**API Calls**:
```bash
# Create PO
POST /api/purchase-orders
{
  "project_id": 2,
  "vendor_id": 3,
  "items": [{"material_id": 1, "quantity": 100, "unit": "Bags", "rate": 450}]
}

# Upload invoice
POST /api/purchase-orders/{id}/upload-invoice
{
  "invoice": <file>,
  "invoice_type": "gst",
  "invoice_number": "INV-2024-001"
}

# Approve PO
PATCH /api/purchase-orders/{id}/status
{"status": "approved"}

# Verify stock
GET /api/stock/project/2/report
# Should show cement: 100 bags
```

---

### Scenario 2: Stock IN from PO (Path 2: Approve First)

```
1. Purchase Manager creates PO for 50 tons steel
2. Manager approves PO (status = 'approved')
3. Purchase Manager uploads invoice #INV-2024-002
4. ✅ Stock IN transaction created: +50 tons
```

---

### Scenario 3: Stock OUT (Task Consumption)

```
1. Verify current stock: 100 bags cement
2. Engineer creates stock OUT for 30 bags
3. ✅ Transaction created, balance = 70 bags
4. Engineer attempts stock OUT for 80 bags
5. ❌ Error: Insufficient stock (Available: 70, Required: 80)
```

**API Calls**:
```bash
# Check current stock
GET /api/stock/project/2/report

# Create stock OUT
POST /api/stock/out
{
  "material_id": 1,
  "project_id": 2,
  "task_id": 15,
  "quantity": 30,
  "notes": "Foundation work"
}

# Verify transaction
GET /api/stock/movements?material_id=1&project_id=2
```

---

### Scenario 4: GST Stock Segregation

```
1. Project has 200 bags GST cement (28%)
2. Project has 50 person-days Non-GST labor
3. GET /api/stock/project/2/report
4. ✅ Response segregates GST vs Non-GST materials
```

---

### Scenario 5: Stock Movement Audit Trail

```
1. Material: Cement (ID: 1), Project: 2
2. Transactions:
   - Jan 20: Stock IN from PO-001 (+100 bags)
   - Jan 22: Stock OUT for Task 10 (-30 bags)
   - Jan 24: Stock IN from PO-003 (+50 bags)
3. GET /api/stock/movements?material_id=1&project_id=2
4. ✅ All 3 transactions returned with references
```

---

## 9. Migration Guide

### Step 1: Run Migrations

```bash
cd backend
php artisan migrate
```

**Expected Output**:
```
Migrating: 2026_01_24_000006_create_stock_transactions_table
Migrated:  2026_01_24_000006_create_stock_transactions_table (45.23ms)
Migrating: 2026_01_24_000007_add_invoice_number_to_purchase_orders_table
Migrated:  2026_01_24_000007_add_invoice_number_to_purchase_orders_table (12.45ms)
```

---

### Step 2: Test Stock IN Workflow

```bash
# 1. Create test PO with approved status
POST /api/purchase-orders
{
  "project_id": 1,
  "vendor_id": 1,
  "items": [
    {"material_id": 1, "quantity": 100, "unit": "Bags", "rate": 450}
  ]
}

# 2. Approve PO
PATCH /api/purchase-orders/{id}/status
{"status": "approved"}

# 3. Upload invoice (should trigger stock IN)
POST /api/purchase-orders/{id}/upload-invoice
{
  "invoice": <file>,
  "invoice_type": "gst",
  "invoice_number": "TEST-INV-001"
}

# 4. Verify stock created
GET /api/stock/project/1/report
```

---

### Step 3: Test Stock OUT

```bash
# Create stock OUT
POST /api/stock/out
{
  "material_id": 1,
  "project_id": 1,
  "quantity": 20,
  "notes": "Test consumption"
}

# Verify balance reduced
GET /api/stock/movements?material_id=1&project_id=1
```

---

### Step 4: Test Negative Stock Prevention

```bash
# Attempt to withdraw more than available
POST /api/stock/out
{
  "material_id": 1,
  "project_id": 1,
  "quantity": 999999
}

# Expected: 422 error with message about insufficient stock
```

---

## 10. Database Relationships

```
StockTransaction
├─ belongs to Material
├─ belongs to Project
├─ belongs to User (performer)
├─ belongs to PurchaseOrder (when reference_type = 'purchase_order')
└─ belongs to Task (when reference_type = 'task')

Material
├─ has many StockTransactions
└─ methods: getCurrentStock($projectId), hasSufficientStock($projectId, $qty)

PurchaseOrder
├─ has many StockTransactions (via reference)
└─ new field: invoice_number
```

---

## 11. Key Business Rules

### ✅ Stock IN Rules

1. **Dual Approval Required**: PO must be approved AND invoice uploaded
2. **Invoice Traceability**: Every stock IN references vendor invoice number
3. **Batch Creation**: All PO items become stock transactions in single database transaction
4. **User Tracking**: Recorded who performed the stock IN (usually Purchase Manager)

### ✅ Stock OUT Rules

1. **Negative Stock Prevention**: System rejects transactions that would result in negative balance
2. **Reference Requirement**: Must link to task, PO, or manual adjustment
3. **Project Scope**: Stock is project-specific (cannot transfer between projects without explicit transfer transaction)

### ✅ Reporting Rules

1. **GST Segregation**: Stock reports separate GST vs Non-GST materials
2. **Balance Efficiency**: Current stock retrieved from latest transaction, not summed
3. **Audit Trail**: Complete history maintained with timestamps and user accountability

---

## 12. Future Enhancements (Phase 4+)

### Planned for Phase 4

1. **Inter-Project Transfers**: Allow stock movement between projects
2. **Stock Adjustments**: Physical verification and adjustment transactions
3. **Consumption Variance**: Compare theoretical BOQ consumption vs actual
4. **Wastage Alerts**: Flag materials with abnormal consumption patterns
5. **Reorder Levels**: Trigger material requests when stock falls below threshold

### Planned for Phase 5

1. **Batch/Lot Tracking**: Track materials by batch for quality issues
2. **Expiry Management**: Alert for perishable materials (cement aging)
3. **Tool Library Integration**: Track tool stock similar to materials
4. **Mobile Offline Stock**: Sync stock transactions from offline mobile app

---

## 13. Summary

Phase 3 successfully integrates the procurement system with inventory management:

✅ **Stock IN**: Triggered only when PO approved + invoice uploaded  
✅ **Stock OUT**: Manual API or task-based with negative stock prevention  
✅ **Audit Trail**: Complete transaction history with references  
✅ **GST Compliance**: Segregated reporting for GST/Non-GST materials  
✅ **Performance**: Efficient stock lookups via balance_after_transaction  
✅ **Security**: User accountability on every transaction  

**Next Phase**: Phase 4 will add costing analytics, variance reporting, and project cost dashboards based on this stock foundation.
