# Phase 4 Implementation: Costing & Variance Analytics

## Overview

Phase 4 adds intelligence to the construction management system by deriving project costs from Purchase Orders (not tasks/DPRs), comparing theoretical vs actual material consumption, and calculating unit-wise costing for sales analysis.

**Key Principle**: All project costs are PO-based. No billing logic tied to worker tasks. Analytics focus on wastage detection, variance alerts, and profit/loss calculations.

---

## 1. Material Consumption Standards

### Purpose
Define theoretical/BOQ consumption for each material per project to detect wastage and overconsumption.

### Database Schema
**Migration**: `2026_01_24_000008_create_material_consumption_standards_table.php`

```php
Schema::create('material_consumption_standards', function (Blueprint $table) {
    $table->id();
    $table->foreignId('project_id')->constrained()->onDelete('cascade');
    $table->foreignId('material_id')->constrained()->onDelete('restrict');
    $table->decimal('standard_quantity', 10, 2); // BOQ quantity
    $table->string('unit', 50);
    $table->decimal('variance_tolerance_percentage', 5, 2)->default(10.00); // e.g., 10%
    $table->text('description')->nullable();
    $table->timestamps();
    $table->unique(['project_id', 'material_id']);
});
```

### Model Methods
```php
// Calculate max allowed consumption (standard + tolerance)
public function getMaxAllowedConsumption(): float
{
    return $this->standard_quantity * (1 + ($this->variance_tolerance_percentage / 100));
}
```

### Example
```json
{
  "project_id": 1,
  "material_id": 5,
  "standard_quantity": 1000,
  "unit": "Bags (50kg)",
  "variance_tolerance_percentage": 10.00,
  "description": "Cement for foundation and columns"
}
```
**Interpretation**: Project expects 1000 bags cement. Alert if consumption exceeds 1100 bags (10% tolerance).

---

## 2. Project Units (Real Estate)

### Purpose
Track individual units (flats/shops) for cost allocation and profit/loss analysis.

### Database Schema
**Migration**: `2026_01_24_000009_create_project_units_table.php`

```php
Schema::create('project_units', function (Blueprint $table) {
    $table->id();
    $table->foreignId('project_id')->constrained()->onDelete('cascade');
    $table->string('unit_number', 50); // e.g., "A-101", "Tower B-12-3"
    $table->string('unit_type', 50); // e.g., "1BHK", "2BHK", "Shop"
    $table->decimal('floor_area', 10, 2); // sqft or sqm
    $table->string('floor_area_unit', 20)->default('sqft');
    $table->boolean('is_sold')->default(false);
    $table->decimal('sold_price', 12, 2)->nullable();
    $table->date('sold_date')->nullable();
    $table->string('buyer_name', 255)->nullable();
    $table->decimal('allocated_cost', 12, 2)->nullable(); // Calculated
    $table->text('description')->nullable();
    $table->timestamps();
    $table->unique(['project_id', 'unit_number']);
});
```

### Model Methods
```php
// Calculate profit/loss for sold unit
public function getProfitLoss(): ?float
{
    return $this->sold_price - $this->allocated_cost;
}

// Calculate profit margin percentage
public function getProfitMargin(): ?float
{
    return (($this->sold_price - $this->allocated_cost) / $this->sold_price) * 100;
}
```

---

## 3. CostingService Methods

### 3.1 Calculate Project Cost
```php
public function calculateProjectCost(int $projectId): array
```

**Logic**:
- Sum all Purchase Orders in APPROVED/DELIVERED/CLOSED status
- Separate GST vs Non-GST procurement costs
- No task/DPR costs included

**Returns**:
```json
{
  "project_id": 1,
  "total_material_cost": 5000000.00,
  "total_gst_amount": 900000.00,
  "grand_total_cost": 5900000.00,
  "gst_procurement_cost": 4500000.00,
  "non_gst_procurement_cost": 1400000.00,
  "purchase_order_count": 15,
  "calculated_at": "2026-01-24 15:30:00"
}
```

---

### 3.2 Calculate Material Variance
```php
public function calculateMaterialVariance(int $projectId, int $materialId): ?array
```

**Logic**:
1. Get BOQ standard from `material_consumption_standards`
2. Calculate actual consumption from stock OUT transactions
3. Compute variance = actual - standard
4. Check if within tolerance

**Returns**:
```json
{
  "material_id": 1,
  "material_name": "Portland Cement 53 Grade",
  "unit": "Bags (50kg)",
  "standard_quantity": 1000.00,
  "actual_consumption": 1150.00,
  "variance": 150.00,
  "variance_percentage": 15.00,
  "tolerance_percentage": 10.00,
  "max_allowed": 1100.00,
  "is_within_tolerance": false,
  "alert_status": "EXCEEDED"
}
```

---

### 3.3 Calculate Flat Costing
```php
public function calculateFlatCosting(int $projectId): array
```

**Logic**:
- Total cost ÷ Total units = Cost per unit
- Equal cost allocated to each unit regardless of size
- Updates `allocated_cost` for all units

**Use Case**: Simple projects with uniform units (e.g., all 2BHK of same size)

**Returns**:
```json
{
  "project_id": 1,
  "project_name": "Sky Towers",
  "total_project_cost": 5900000.00,
  "total_units": 20,
  "cost_per_unit": 295000.00,
  "sold_units": 12,
  "unsold_units": 8,
  "sold_units_revenue": 7200000.00,
  "sold_units_cost": 3540000.00,
  "unsold_units_inventory_value": 2360000.00,
  "total_profit_loss": 3660000.00
}
```

---

### 3.4 Calculate Area-Based Costing
```php
public function calculateAreaBasedCosting(int $projectId): array
```

**Logic**:
- Total cost ÷ Total area = Cost per sqft/sqm
- Cost allocated proportional to floor area
- Updates `allocated_cost` for each unit

**Use Case**: Projects with varying unit sizes

**Returns**:
```json
{
  "project_id": 1,
  "total_project_cost": 5900000.00,
  "total_area": 15000.00,
  "area_unit": "sqft",
  "cost_per_unit_area": 393.33,
  "sold_area": 9000.00,
  "unsold_area": 6000.00,
  "sold_units_revenue": 7200000.00,
  "sold_units_cost": 3540000.00,
  "unsold_units_inventory_value": 2360000.00,
  "total_profit_loss": 3660000.00
}
```

---

### 3.5 Get Wastage Alerts
```php
public function getWastageAlerts(int $projectId): array
```

**Logic**:
- Run variance analysis for all materials
- Filter materials with `alert_status = EXCEEDED`

**Returns**:
```json
{
  "project_id": 1,
  "alert_count": 3,
  "alerts": [
    {
      "material_name": "Portland Cement",
      "variance_percentage": 15.00,
      "actual_consumption": 1150.00,
      "max_allowed": 1100.00
    },
    {...}
  ]
}
```

---

## 4. API Endpoints

### 4.1 Project Cost Dashboard

**GET** `/api/costing/project/{projectId}/cost`

**Authorization**: Manager, Owner, Purchase Manager

**Response**:
```json
{
  "success": true,
  "data": {
    "total_material_cost": 5000000.00,
    "total_gst_amount": 900000.00,
    "grand_total_cost": 5900000.00,
    "purchase_order_count": 15
  }
}
```

---

### 4.2 Variance Report

**GET** `/api/costing/project/{projectId}/variance`

**Response**:
```json
{
  "success": true,
  "data": {
    "total_materials_tracked": 25,
    "materials_exceeded_tolerance": 3,
    "variances": [...]
  }
}
```

---

### 4.3 Wastage Alerts

**GET** `/api/costing/project/{projectId}/wastage-alerts`

**Response**: List of materials exceeding tolerance

---

### 4.4 Flat Costing

**GET** `/api/costing/project/{projectId}/flat-costing`

**Response**: Equal cost per unit allocation

---

### 4.5 Area-Based Costing

**GET** `/api/costing/project/{projectId}/area-costing`

**Response**: Area-proportional cost allocation

---

### 4.6 Unit-Wise Costing

**GET** `/api/costing/project/{projectId}/unit-costing`

**Response**: Detailed breakdown for each unit with profit/loss

---

### 4.7 Create/Update Consumption Standard

**POST** `/api/costing/consumption-standards`

**Request**:
```json
{
  "project_id": 1,
  "material_id": 5,
  "standard_quantity": 1000,
  "unit": "Bags (50kg)",
  "variance_tolerance_percentage": 10,
  "description": "Cement for foundation"
}
```

---

### 4.8 Create/Update Project Unit

**POST** `/api/costing/project-units`

**Request**:
```json
{
  "project_id": 1,
  "unit_number": "A-101",
  "unit_type": "2BHK",
  "floor_area": 1200,
  "floor_area_unit": "sqft"
}
```

---

### 4.9 Mark Unit as Sold

**PATCH** `/api/costing/units/{unitId}/mark-sold`

**Request**:
```json
{
  "sold_price": 6500000,
  "sold_date": "2026-01-24",
  "buyer_name": "John Doe"
}
```

---

## 5. Testing Scenarios

### Scenario 1: Setup BOQ Standards

```bash
# Define cement standard
POST /api/costing/consumption-standards
{
  "project_id": 1,
  "material_id": 1,
  "standard_quantity": 1000,
  "unit": "Bags",
  "variance_tolerance_percentage": 10
}

# Define steel standard
POST /api/costing/consumption-standards
{
  "project_id": 1,
  "material_id": 2,
  "standard_quantity": 50,
  "unit": "MT",
  "variance_tolerance_percentage": 5
}
```

---

### Scenario 2: Check Variance

```bash
# After some stock OUT transactions
GET /api/costing/project/1/variance

# Expected: Shows which materials exceeded tolerance
```

---

### Scenario 3: Calculate Project Cost

```bash
# After creating approved POs
GET /api/costing/project/1/cost

# Expected: Total cost from all POs
{
  "grand_total_cost": 5900000,
  "purchase_order_count": 15
}
```

---

### Scenario 4: Setup Project Units

```bash
# Add 20 units
POST /api/costing/project-units
{
  "project_id": 1,
  "unit_number": "A-101",
  "unit_type": "2BHK",
  "floor_area": 1200,
  "floor_area_unit": "sqft"
}

# Repeat for units A-102 to A-120
```

---

### Scenario 5: Calculate Flat Costing

```bash
GET /api/costing/project/1/flat-costing

# Expected: Cost allocated equally
{
  "cost_per_unit": 295000,
  "total_units": 20
}
```

---

### Scenario 6: Mark Units Sold

```bash
# Sell unit A-101
PATCH /api/costing/units/1/mark-sold
{
  "sold_price": 6500000,
  "sold_date": "2026-01-24",
  "buyer_name": "John Doe"
}

# Repeat for 11 more units
```

---

### Scenario 7: Check Profit/Loss

```bash
GET /api/costing/project/1/flat-costing

# Expected:
{
  "sold_units": 12,
  "sold_units_revenue": 78000000,
  "sold_units_cost": 3540000,
  "total_profit_loss": 74460000
}
```

---

## 6. Key Business Rules

### ✅ Cost Calculation Rules
1. **PO-Based Only**: Costs derived from Purchase Orders, not tasks/DPRs
2. **Status Filter**: Only APPROVED, DELIVERED, CLOSED POs counted
3. **GST Segregation**: Separate tracking of GST vs Non-GST costs

### ✅ Variance Rules
1. **Standard Required**: Material must have consumption standard defined
2. **Tolerance Configurable**: Each material can have different tolerance (default 10%)
3. **Alert Trigger**: System alerts when actual > (standard + tolerance)

### ✅ Unit Costing Rules
1. **Flat Method**: Equal cost per unit (simple, fair for uniform units)
2. **Area Method**: Cost proportional to floor area (accurate for varying sizes)
3. **Auto-Update**: Allocated cost updated when costing method runs

---

## 7. Migration Guide

```bash
cd backend
php artisan migrate
```

**Expected Output**:
```
Migrating: 2026_01_24_000008_create_material_consumption_standards_table
Migrated:  2026_01_24_000008_create_material_consumption_standards_table (39.68ms)
Migrating: 2026_01_24_000009_create_project_units_table
Migrated:  2026_01_24_000009_create_project_units_table (20.29ms)
```

---

## 8. Summary

Phase 4 successfully adds intelligence to the construction system:

✅ **Cost Dashboards**: PO-based project cost calculation  
✅ **Variance Analytics**: Compare theoretical vs actual consumption  
✅ **Wastage Alerts**: Auto-detect materials exceeding tolerance  
✅ **Flat Costing**: Equal cost allocation per unit  
✅ **Area Costing**: Proportional cost by floor area  
✅ **Profit/Loss**: Real-time calculation for sold units  
✅ **Inventory Valuation**: Track unsold unit costs  

**12 New Endpoints**: Cost dashboard, variance reports, unit costing, wastage alerts, consumption standards CRUD, project units CRUD

**Next Phase**: Phase 5 will add advanced features like contractor rating, face recall, tool library, OTP permits, and petty cash wallets.
