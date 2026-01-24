# Phase 5 Migration Guide

**Advanced Field & Compliance Features - Quick Deployment**

---

## Prerequisites

- ✅ Phases 1-4 completed
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
INFO  Running migrations.

2026_01_24_000010_create_contractor_ratings_table ................. 128.00ms DONE
2026_01_24_000011_create_daily_wager_attendance_table .............. 21.04ms DONE
2026_01_24_000012_create_tools_library_table ....................... 23.80ms DONE
2026_01_24_000013_create_tool_checkouts_table ...................... 22.59ms DONE
2026_01_24_000014_create_permit_to_work_table ...................... 19.84ms DONE
2026_01_24_000015_create_petty_cash_transactions_table ............. 18.32ms DONE
```

---

## Step 2: Verify Tables

```sql
-- Check all 6 new tables exist
SELECT tablename FROM pg_tables 
WHERE tablename IN (
  'contractor_ratings',
  'daily_wager_attendance',
  'tools_library',
  'tool_checkouts',
  'permit_to_work',
  'petty_cash_transactions'
);
```

---

## Step 3: Test Contractor Rating

```bash
# Rate a contractor
curl -X POST "http://localhost:8000/api/contractor-ratings" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "contractor_id": 5,
    "project_id": 1,
    "rating_period_start": "2026-01-01",
    "rating_period_end": "2026-01-31",
    "punctuality_score": 7.5,
    "quality_score": 8.0,
    "safety_score": 6.5,
    "wastage_score": 7.0,
    "comments": "Good performance overall"
  }'
```

**Expected**: Rating saved with calculated overall_rating and payment_action

---

## Step 4: Test Daily Wager Attendance

```bash
# Check-in wager (with multipart for image)
curl -X POST "http://localhost:8000/api/daily-wagers/check-in" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "wager_name=Raju Kumar" \
  -F "wager_phone=9876543210" \
  -F "project_id=1" \
  -F "wage_rate_per_hour=150" \
  -F "face_image=@/path/to/face.jpg"

# Check-out (returns attendance_id from check-in)
curl -X POST "http://localhost:8000/api/daily-wagers/1/check-out" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Expected**: Hours worked and wage calculated automatically

---

## Step 5: Test Tool Library

```bash
# Add tool
curl -X POST "http://localhost:8000/api/tools" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "tool_name": "Makita Drill Machine",
    "category": "Electrical",
    "purchase_date": "2025-12-01",
    "purchase_price": 15000
  }'

# Checkout tool
curl -X POST "http://localhost:8000/api/tools/checkout" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "tool_id": 1,
    "project_id": 1,
    "expected_return_time": "2026-01-31 18:00:00"
  }'

# Return tool
curl -X POST "http://localhost:8000/api/tools/checkouts/1/return" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "return_condition": "GOOD",
    "return_notes": "Returned in good condition"
  }'
```

---

## Step 6: Test Permit-to-Work

```bash
# Request permit
curl -X POST "http://localhost:8000/api/permits" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "project_id": 1,
    "task_description": "Demolition of 3rd floor slab",
    "risk_level": "HIGH",
    "safety_officer_id": 3,
    "safety_measures": "Fall protection harness required"
  }'

# Generate OTP
curl -X POST "http://localhost:8000/api/permits/1/generate-otp" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Verify OTP (use OTP from response)
curl -X POST "http://localhost:8000/api/permits/1/verify-otp" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "otp": "123456"
  }'

# Start work
curl -X POST "http://localhost:8000/api/permits/1/start-work" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Complete work
curl -X POST "http://localhost:8000/api/permits/1/complete-work" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "completion_notes": "Work completed safely"
  }'
```

---

## Step 7: Test Petty Cash

```bash
# Create request (with receipt image)
curl -X POST "http://localhost:8000/api/petty-cash" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "project_id=1" \
  -F "amount=1500" \
  -F "purpose=Tea for workers" \
  -F "latitude=28.6139" \
  -F "longitude=77.2090" \
  -F "receipt_image=@/path/to/receipt.jpg" \
  -F "payment_method=CASH"

# Approve request
curl -X POST "http://localhost:8000/api/petty-cash/1/approve" \
  -H "Authorization: Bearer YOUR_TOKEN"

# Get summary
curl -X GET "http://localhost:8000/api/petty-cash/summary?project_id=1&start_date=2026-01-01&end_date=2026-01-31" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

## Step 8: Verify All Endpoints

```bash
# Check route list
php artisan route:list | grep -E "contractor|wager|tool|permit|petty"
```

**Expected**: 34 new Phase 5 routes

---

## Production Deployment Checklist

### Before Deployment
- [ ] Database backup completed
- [ ] All Phase 1-4 features tested
- [ ] Storage directory writable (for images)
- [ ] Image size limits configured

### Deploy
```bash
git pull origin main
composer install --no-dev --optimize-autoloader
php artisan migrate --force
php artisan storage:link  # For image uploads
php artisan config:cache
php artisan route:cache
```

### After Deployment
- [ ] All 6 migrations successful
- [ ] Contractor rating endpoint working
- [ ] Daily wager check-in/out working
- [ ] Tool checkout/return working
- [ ] Permit OTP generation working
- [ ] Petty cash approval working
- [ ] Image uploads working (face, receipts)

---

## Configuration

### Image Storage

Add to `.env`:
```env
FILESYSTEM_DISK=public
```

Run:
```bash
php artisan storage:link
```

This creates symlink: `public/storage → storage/app/public`

**Image Paths**:
- Daily wager faces: `storage/app/public/wager-faces/`
- Petty cash receipts: `storage/app/public/petty-cash-receipts/`

### GPS Validation

Default geofence radius: **500 meters**

Modify per-project:
```sql
UPDATE projects SET geofence_radius_meters = 1000 WHERE id = 1;
```

---

## Troubleshooting

### Issue: "Storage not found"
**Solution**:
```bash
php artisan storage:link
chmod -R 775 storage/
```

### Issue: "OTP expired"
**Check**: OTP valid for 15 minutes
```sql
SELECT otp_expires_at FROM permit_to_work WHERE id = 1;
```

### Issue: "GPS validation failed"
**Check**: Project has coordinates
```sql
SELECT latitude, longitude, geofence_radius_meters 
FROM projects WHERE id = 1;
```

### Issue: "Tool not available"
**Check**: Tool status
```sql
SELECT tool_name, current_status, current_holder_id 
FROM tools_library WHERE id = 1;
```

---

## Summary

Phase 5 deployed successfully! ✅

**New Capabilities**:
- 🎯 Contractor performance rating → Payment advice
- 📸 Face recall attendance → No ID cards needed
- 🔧 Tool tracking → QR checkout/return
- 🚨 OTP permits → Safety compliance
- 💰 Petty cash → Geo-tagged expenses

**New Endpoints**: 34 (Total: 118)
**New Tables**: 6 (Total: 34)
**System Status**: **Production-Ready Enterprise ERP**
