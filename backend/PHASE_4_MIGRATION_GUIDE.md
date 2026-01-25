# Phase 4 Migration Guide

## Quick Start

Deploy Phase 4 (Costing & Variance Analytics) to enable project cost dashboards, wastage alerts, and unit-wise profit/loss analysis.

---

## Prerequisites

- ✅ Phase 1, 2, 3 completed
- ✅ Database backup taken
- ✅ Laravel application running

---

## Step 1: Run Migrations

```bash
cd backend
php artisan migrate
```

**Expected Output**:
```
Migrating: 2026_01_24_000008_create_material_consumption_standards_table
Migrated:  (39.68ms)
Migrating: 2026_01_24_000009_create_project_units_table
Migrated:  (20.29ms)
```

---

## Step 2: Verify New Tables

```sql
-- Check tables created
SELECT * FROM material_consumption_standards LIMIT 5;
SELECT * FROM project_units LIMIT 5;
```

---

## Step 3: Test Project Cost Calculation

```bash
# Calculate cost from existing POs
curl -X GET "http://localhost:8000/api/costing/project/1/cost" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Expected Response**:
```json
{
  "success": true,
  "data": {
    "total_material_cost": 5000000.00,
    "total_gst_amount": 900000.00,
    "grand_total_cost": 5900000.00,
    "gst_procurement_cost": 4500000.00,
    "non_gst_procurement_cost": 1400000.00,
    "purchase_order_count": 15
  }
}
```

---

## Step 4: Setup Consumption Standards (BOQ)

```bash
# Example: Cement standard
curl -X POST "http://localhost:8000/api/costing/consumption-standards" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "project_id": 1,
    "material_id": 1,
    "standard_quantity": 1000,
    "unit": "Bags (50kg)",
    "variance_tolerance_percentage": 10,
    "description": "Cement for foundation and columns"
  }'
```

---

## Step 5: Test Variance Report

```bash
# Check variance after some stock OUT transactions
curl -X GET "http://localhost:8000/api/costing/project/1/variance" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Expected Response**:
```json
{
  "success": true,
  "data": {
    "project_id": 1,
    "total_materials_tracked": 5,
    "materials_exceeded_tolerance": 1,
    "variances": [
      {
        "material_name": "Portland Cement",
        "standard_quantity": 1000.00,
        "actual_consumption": 1150.00,
        "variance": 150.00,
        "variance_percentage": 15.00,
        "alert_status": "EXCEEDED"
      }
    ]
  }
}
```

---

## Step 6: Setup Project Units

```bash
# Add residential units
curl -X POST "http://localhost:8000/api/costing/project-units" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "project_id": 1,
    "unit_number": "A-101",
    "unit_type": "2BHK",
    "floor_area": 1200,
    "floor_area_unit": "sqft"
  }'

# Repeat for other units (A-102, A-103, etc.)
```

---

## Step 7: Calculate Flat Costing

```bash
curl -X GET "http://localhost:8000/api/costing/project/1/flat-costing" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Expected Response**:
```json
{
  "success": true,
  "data": {
    "total_project_cost": 5900000.00,
    "total_units": 20,
    "cost_per_unit": 295000.00,
    "sold_units": 0,
    "unsold_units": 20,
    "unsold_units_inventory_value": 5900000.00
  }
}
```

---

## Step 8: Mark Units Sold

```bash
curl -X PATCH "http://localhost:8000/api/costing/units/1/mark-sold" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "sold_price": 6500000,
    "sold_date": "2026-01-24",
    "buyer_name": "John Doe"
  }'
```

---

## Step 9: Check Profit/Loss

```bash
# After marking several units sold
curl -X GET "http://localhost:8000/api/costing/project/1/unit-costing" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Expected**: Each unit shows `profit_loss` and `profit_margin_percentage`

---

## Step 10: Test Wastage Alerts

```bash
curl -X GET "http://localhost:8000/api/costing/project/1/wastage-alerts" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Expected**: List of materials with consumption exceeding tolerance

---

## Production Deployment Checklist

### Before Deployment
- [ ] Database backup completed
- [ ] Migrations tested on staging
- [ ] BOQ standards prepared for import
- [ ] Project units data prepared

### Deploy
```bash
git pull origin main
composer install --no-dev --optimize-autoloader
php artisan migrate --force
php artisan config:cache
php artisan route:cache
```

### After Deployment
- [ ] Verify new tables exist
- [ ] Test cost calculation endpoint
- [ ] Import consumption standards (if bulk data available)
- [ ] Import project units (if bulk data available)
- [ ] Test variance reports
- [ ] Train managers on wastage alerts

---

## Troubleshooting

### Issue: "No consumption standard defined"
**Solution**: Create standards via `/costing/consumption-standards` endpoint before checking variance

### Issue: "No units defined for this project"
**Solution**: Add units via `/costing/project-units` endpoint before running costing calculations

### Issue: Zero cost in cost dashboard
**Check**: Are POs in APPROVED/DELIVERED/CLOSED status? Only these statuses count toward cost

---

## Summary

Phase 4 successfully deployed! ✅

**New Capabilities**:
- 📊 Project cost dashboards from POs
- ⚠️ Wastage alerts for overconsumption
- 💰 Unit-wise profit/loss analysis
- 📈 Variance analytics (BOQ vs Actual)
- 🏠 Flat & area-based costing methods

**New Endpoints**: 12 (cost, variance, wastage, flat-costing, area-costing, unit-costing, CRUD for standards/units)
