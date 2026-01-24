# Phase 2 Migration Guide

## Quick Start

To apply Phase 2 changes (GST classification) to your database:

```bash
cd backend

# Run the new Phase 2 migrations
php artisan migrate

# Re-seed materials with GST classification
php artisan db:seed --class=MaterialSeeder
```

## Fresh Installation (Recommended)

If you want to start completely fresh with both Phase 1 and Phase 2:

```bash
cd backend

# Drop all tables and re-migrate everything
php artisan migrate:fresh

# Seed all data (users, materials, etc.)
php artisan db:seed
```

## Verify Phase 2 Installation

Check if the GST fields were added:

```sql
-- Check materials table has gst_type column
DESCRIBE materials;

-- View GST and Non-GST materials
SELECT name, unit, gst_type, gst_percentage FROM materials;

-- Count by type
SELECT gst_type, COUNT(*) as count FROM materials GROUP BY gst_type;

-- Check purchase_orders table has invoice_type column
DESCRIBE purchase_orders;
```

## Test GST Material Creation

```bash
# Create a GST material
curl -X POST http://localhost:8000/api/materials \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Cement",
    "unit": "bags",
    "gst_type": "gst",
    "gst_percentage": 28
  }'

# Create a Non-GST material
curl -X POST http://localhost:8000/api/materials \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Labour",
    "unit": "days",
    "gst_type": "non_gst"
  }'
```

## Test GST Separation in PO

```bash
# This should FAIL (mixing GST and Non-GST)
curl -X POST http://localhost:8000/api/purchase-orders \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "project_id": 1,
    "vendor_id": 1,
    "items": [
      {"material_id": 1, "quantity": 100, "unit": "bags", "rate": 350},
      {"material_id": 36, "quantity": 10, "unit": "days", "rate": 500}
    ]
  }'

# Expected Error:
# "Cannot mix GST and Non-GST materials in the same Purchase Order..."
```

## Rollback Phase 2 (if needed)

To rollback only Phase 2 migrations:

```bash
php artisan migrate:rollback --step=2
```

This will rollback:
1. invoice_type addition to purchase_orders
2. gst_type addition to materials

## Important Notes

1. **Existing Materials**: If you have existing materials in the database, they will default to `gst_type='gst'` after migration. You may need to update them manually:

```sql
-- Update labour materials to non_gst
UPDATE materials 
SET gst_type = 'non_gst', gst_percentage = 0 
WHERE name LIKE '%Labour%' OR name LIKE '%labour%';
```

2. **Existing Purchase Orders**: Old POs will continue to work, but new POs will enforce GST separation.

3. **Invoice Upload**: After Phase 2, invoice uploads require `invoice_type` parameter.

## Next Steps

After successful Phase 2 migration:
1. Verify materials are properly classified
2. Test PO creation with GST materials
3. Test PO creation with Non-GST materials  
4. Test invoice upload with type validation
5. Proceed to Phase 3 implementation
