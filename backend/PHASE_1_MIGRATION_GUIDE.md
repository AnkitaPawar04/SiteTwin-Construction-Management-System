# Phase 1 Migration Guide

## Quick Start

To apply Phase 1 changes to your database, run these commands in the backend directory:

```bash
# Navigate to backend directory
cd backend

# Run the new migrations
php artisan migrate

# Seed the database with updated users (including Purchase Manager)
php artisan db:seed --class=UserSeeder
```

## Fresh Installation

If you want to start fresh with all Phase 1 changes:

```bash
cd backend

# Drop all tables and re-migrate
php artisan migrate:fresh

# Seed all data
php artisan db:seed
```

## Verify Installation

Check if the new tables were created:

```sql
-- Check vendors table
SELECT * FROM vendors;

-- Check purchase_orders table
SELECT * FROM purchase_orders;

-- Check purchase_order_items table
SELECT * FROM purchase_order_items;

-- Verify Purchase Manager user
SELECT * FROM users WHERE role = 'purchase_manager';
```

## Test Purchase Manager Login

```bash
# Using curl
curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"phone": "9876543215"}'

# Save the token from response and use it for subsequent requests
```

## Rollback (if needed)

To rollback the Phase 1 migrations:

```bash
php artisan migrate:rollback --step=3
```

This will rollback:
1. purchase_order_items table
2. purchase_orders table
3. vendors table

## Next Steps

After successful migration:
1. Test the Purchase Manager login
2. Create test vendors
3. Create test purchase orders
4. Proceed to Phase 2 implementation
