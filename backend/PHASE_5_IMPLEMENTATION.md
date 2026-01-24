# Phase 5 Implementation Guide

**Advanced Field & Compliance Features**

This phase adds enterprise-grade compliance and field management capabilities to the construction management system.

---

## Overview

Phase 5 implements:
1. **Contractor Rating System** - Performance-based payment decisions
2. **Face Recall for Daily Wagers** - Camera-based attendance without ID cards
3. **Tool Library** - QR-based tool checkout/return with accountability
4. **OTP Permit-to-Work** - Safety officer approval for dangerous tasks
5. **Petty Cash Wallet** - Geo-tagged expense tracking with manager approval

---

## 1. Contractor Rating System

### Purpose
Rate contractors (1-10) based on delays, defects, wastage, and safety violations. Generate payment recommendations (normal/hold/penalty).

### Database Schema

**Table**: `contractor_ratings`
```sql
- id
- contractor_id (FK: users)
- project_id (FK: projects)
- rating_period_start, rating_period_end
- punctuality_score (0-10)
- quality_score (0-10)
- safety_score (0-10)
- wastage_score (0-10)
- overall_rating (calculated average)
- payment_action (NORMAL/HOLD/PENALTY)
- penalty_amount
- rated_by (FK: users)
- comments
```

### API Endpoints

#### Create/Update Rating
```http
POST /api/contractor-ratings
Authorization: Bearer {token}
Content-Type: application/json

{
  "contractor_id": 5,
  "project_id": 1,
  "rating_period_start": "2026-01-01",
  "rating_period_end": "2026-01-31",
  "punctuality_score": 7.5,
  "quality_score": 8.0,
  "safety_score": 6.5,
  "wastage_score": 7.0,
  "comments": "Good work but some safety concerns",
  "penalty_base_amount": 50000
}
```

**Response**:
```json
{
  "success": true,
  "message": "Contractor rated successfully",
  "data": {
    "id": 1,
    "overall_rating": 7.3,
    "payment_action": "NORMAL",
    "penalty_amount": null
  }
}
```

#### Get Contractor History
```http
GET /api/contractors/5/ratings?project_id=1
```

#### Get Average Rating
```http
GET /api/contractors/5/average-rating
```

**Response**:
```json
{
  "success": true,
  "data": {
    "avg_punctuality": 7.5,
    "avg_quality": 8.2,
    "avg_safety": 6.8,
    "avg_wastage": 7.1,
    "avg_overall": 7.4,
    "total_ratings": 12
  }
}
```

#### Get Contractors Needing Attention
```http
GET /api/contractors/needing-attention?threshold=5.0
```

### Business Rules

**Payment Actions**:
- `overall_rating >= 5.0` → **NORMAL** payment
- `overall_rating < 5.0` → **HOLD** payment
- `overall_rating < 4.0` → **PENALTY** applied

**Penalty Calculation**:
```php
// Penalty = (4.0 - rating) * 10% of base amount
// Example: Rating 3.5, Base ₹50,000
// Penalty = (4.0 - 3.5) * 10% * 50,000 = ₹2,500
```

---

## 2. Face Recall for Daily Wagers

### Purpose
Camera-based attendance for daily wagers (no ID cards). Automatically calculate wages based on hours worked.

### Database Schema

**Table**: `daily_wager_attendance`
```sql
- id
- wager_name
- wager_phone
- project_id
- attendance_date
- check_in_time
- check_out_time
- face_image_path
- face_encoding (for ML matching)
- hours_worked
- wage_rate_per_hour
- total_wage (calculated)
- verified_by (FK: users)
- verified_at
- status (PENDING/VERIFIED/REJECTED)
```

### API Endpoints

#### Check-In Wager
```http
POST /api/daily-wagers/check-in
Authorization: Bearer {token}
Content-Type: multipart/form-data

{
  "wager_name": "Raju Kumar",
  "wager_phone": "9876543210",
  "project_id": 1,
  "attendance_date": "2026-01-24",
  "face_image": <file>,
  "wage_rate_per_hour": 150.00
}
```

#### Check-Out Wager
```http
POST /api/daily-wagers/1/check-out
```

**Response**:
```json
{
  "success": true,
  "message": "Check-out successful",
  "data": {
    "id": 1,
    "wager_name": "Raju Kumar",
    "check_in_time": "2026-01-24 08:00:00",
    "check_out_time": "2026-01-24 17:30:00",
    "hours_worked": 9.5,
    "wage_rate_per_hour": 150.00,
    "total_wage": 1425.00,
    "status": "PENDING"
  }
}
```

#### Verify Attendance
```http
POST /api/daily-wagers/1/verify
```

#### Get Daily Report
```http
GET /api/daily-wagers/daily-report?project_id=1&date=2026-01-24
```

**Response**:
```json
{
  "success": true,
  "data": {
    "date": "2026-01-24",
    "total_wagers": 15,
    "verified_count": 10,
    "pending_count": 5,
    "total_hours": 142.5,
    "total_wages": 21375.00,
    "attendances": [...]
  }
}
```

#### Get Wage Summary (Period)
```http
GET /api/daily-wagers/wage-summary?project_id=1&start_date=2026-01-01&end_date=2026-01-31
```

### Future ML Integration

**Face Encoding Matching**:
```python
# Pseudo-code for future implementation
face_encoding = extract_face_encoding(uploaded_image)
matches = find_similar_encodings(face_encoding, project_id)
if match_confidence > 0.85:
    return matched_wager
```

---

## 3. Tool Library (QR-Based)

### Purpose
Track construction tools with QR codes. Checkout/return accountability. Prevent loss.

### Database Schema

**Table**: `tools_library`
```sql
- id
- tool_name
- tool_code (unique)
- qr_code (unique, auto-generated)
- category (Electrical, Carpentry, Safety, etc.)
- current_status (AVAILABLE/CHECKED_OUT/MAINTENANCE/DAMAGED/LOST)
- current_holder_id (FK: users)
- current_project_id (FK: projects)
- purchase_date
- purchase_price
- condition (EXCELLENT/GOOD/FAIR/POOR)
```

**Table**: `tool_checkouts`
```sql
- id
- tool_id
- checked_out_by
- project_id
- checkout_time
- expected_return_time
- actual_return_time
- return_condition
- verified_by
- checkout_notes
- return_notes
- status (ACTIVE/RETURNED/OVERDUE/LOST)
```

### API Endpoints

#### Add Tool
```http
POST /api/tools
{
  "tool_name": "Makita Drill Machine",
  "category": "Electrical",
  "purchase_date": "2025-12-01",
  "purchase_price": 15000.00,
  "description": "18V Cordless Drill"
}
```

**Response**:
```json
{
  "success": true,
  "data": {
    "id": 1,
    "tool_code": "MAK-0001",
    "qr_code": "550e8400-e29b-41d4-a716-446655440000",
    "current_status": "AVAILABLE"
  }
}
```

#### Checkout Tool
```http
POST /api/tools/checkout
{
  "tool_id": 1,
  "project_id": 1,
  "expected_return_time": "2026-01-31 18:00:00",
  "checkout_notes": "Needed for column drilling"
}
```

#### Return Tool
```http
POST /api/tools/checkouts/1/return
{
  "return_condition": "GOOD",
  "return_notes": "Returned in good condition"
}
```

#### Get Overdue Tools
```http
GET /api/tools/overdue?project_id=1
```

**Response**:
```json
{
  "success": true,
  "data": [
    {
      "checkout_id": 5,
      "tool_name": "Concrete Mixer",
      "tool_code": "CON-0003",
      "checked_out_by": "Ramesh Singh",
      "project_name": "Sunrise Heights",
      "expected_return_time": "2026-01-20 18:00:00",
      "days_overdue": 4
    }
  ]
}
```

#### Get Availability Report
```http
GET /api/tools/availability-report
```

**Response**:
```json
{
  "success": true,
  "data": {
    "total_tools": 50,
    "available": 30,
    "checked_out": 15,
    "maintenance": 3,
    "damaged": 1,
    "lost": 1,
    "by_category": {
      "Electrical": 12,
      "Carpentry": 8,
      "Safety": 15,
      "Heavy": 10,
      "Measuring": 5
    }
  }
}
```

#### Mark Tool as Lost
```http
POST /api/tools/checkouts/5/mark-lost
```

---

## 4. OTP Permit-to-Work

### Purpose
Safety officer must approve dangerous tasks via OTP before work can start. Ensures accountability for high-risk work.

### Database Schema

**Table**: `permit_to_work`
```sql
- id
- project_id
- task_description
- risk_level (LOW/MEDIUM/HIGH/CRITICAL)
- requested_by
- requested_at
- safety_officer_id
- otp_code (6-digit)
- otp_generated_at
- otp_expires_at (15 minutes)
- approved_at
- work_started_at
- work_completed_at
- completed_by
- status (PENDING/OTP_SENT/APPROVED/IN_PROGRESS/COMPLETED/REJECTED/EXPIRED)
- safety_measures
- rejection_reason
- completion_notes
```

### API Endpoints

#### Request Permit
```http
POST /api/permits
{
  "project_id": 1,
  "task_description": "Demolition of 3rd floor slab",
  "risk_level": "HIGH",
  "safety_officer_id": 3,
  "safety_measures": "Fall protection harness, safety nets, barricades"
}
```

#### Generate OTP
```http
POST /api/permits/1/generate-otp
```

**Response**:
```json
{
  "success": true,
  "message": "OTP sent to safety officer",
  "data": {
    "permit_id": 1,
    "otp_code": "123456",  // Remove in production
    "otp_expires_at": "2026-01-24 10:15:00"
  }
}
```

#### Verify OTP and Approve
```http
POST /api/permits/1/verify-otp
{
  "otp": "123456"
}
```

**Response**:
```json
{
  "success": true,
  "message": "Permit approved successfully",
  "data": {
    "id": 1,
    "status": "APPROVED",
    "approved_at": "2026-01-24 10:05:00"
  }
}
```

#### Start Work
```http
POST /api/permits/1/start-work
```

#### Complete Work
```http
POST /api/permits/1/complete-work
{
  "completion_notes": "Demolition completed safely. No incidents."
}
```

#### Get Active Permits
```http
GET /api/permits/active?project_id=1
```

**Response**:
```json
{
  "success": true,
  "data": {
    "total_active": 3,
    "pending": 1,
    "approved": 1,
    "in_progress": 1,
    "permits": [...]
  }
}
```

#### Get Critical Risk Permits
```http
GET /api/permits/critical-risk?project_id=1
```

#### Get Permit Statistics
```http
GET /api/permits/statistics?project_id=1&start_date=2026-01-01&end_date=2026-01-31
```

**Response**:
```json
{
  "success": true,
  "data": {
    "total_permits": 45,
    "approved": 40,
    "rejected": 3,
    "completed": 38,
    "by_risk_level": {
      "low": 15,
      "medium": 20,
      "high": 8,
      "critical": 2
    },
    "avg_approval_time_minutes": 12.5
  }
}
```

### Workflow

1. **Request** → Engineer requests permit for dangerous task
2. **Generate OTP** → System sends 6-digit OTP to safety officer
3. **Verify** → Safety officer enters OTP (valid 15 minutes)
4. **Approve** → Permit status changes to APPROVED
5. **Start** → Worker starts task
6. **Complete** → Worker marks task complete

---

## 5. Petty Cash Wallet (Geo-Tagged)

### Purpose
Track small expenses with geo-location validation. Manager approval required. Receipt upload mandatory.

### Database Schema

**Table**: `petty_cash_transactions`
```sql
- id
- project_id
- amount
- purpose
- description
- receipt_image_path
- latitude, longitude
- gps_validated (boolean)
- requested_by
- requested_at
- approved_by
- approved_at
- transaction_date
- vendor_name
- payment_method (CASH/UPI/CARD/CHEQUE)
- status (PENDING/APPROVED/REJECTED/REIMBURSED)
- rejection_reason
```

### API Endpoints

#### Create Request
```http
POST /api/petty-cash
Content-Type: multipart/form-data

{
  "project_id": 1,
  "amount": 1500.00,
  "purpose": "Tea for workers",
  "description": "Weekly tea expense",
  "receipt_image": <file>,
  "latitude": 28.6139,
  "longitude": 77.2090,
  "transaction_date": "2026-01-24",
  "vendor_name": "Sharma Tea Stall",
  "payment_method": "CASH"
}
```

#### Approve Request
```http
POST /api/petty-cash/1/approve
```

**Response**:
```json
{
  "success": true,
  "message": "Request approved",
  "data": {
    "id": 1,
    "amount": 1500.00,
    "gps_validated": true,
    "status": "APPROVED",
    "approved_at": "2026-01-24 11:00:00"
  }
}
```

#### Reject Request
```http
POST /api/petty-cash/1/reject
{
  "reason": "No receipt provided"
}
```

#### Mark as Reimbursed
```http
POST /api/petty-cash/1/mark-reimbursed
```

#### Get Pending Requests
```http
GET /api/petty-cash/pending?project_id=1
```

**Response**:
```json
{
  "success": true,
  "data": {
    "total_pending": 5,
    "total_amount_pending": 7500.00,
    "requests": [...]
  }
}
```

#### Get Summary
```http
GET /api/petty-cash/summary?project_id=1&start_date=2026-01-01&end_date=2026-01-31
```

**Response**:
```json
{
  "success": true,
  "data": {
    "period": {
      "start_date": "2026-01-01",
      "end_date": "2026-01-31"
    },
    "total_transactions": 50,
    "total_requested": 75000.00,
    "total_approved": 68000.00,
    "total_reimbursed": 55000.00,
    "pending_reimbursement": 13000.00,
    "by_payment_method": {
      "cash": 45000.00,
      "upi": 15000.00,
      "card": 5000.00,
      "cheque": 3000.00
    },
    "gps_validated_count": 45,
    "gps_failed_count": 5
  }
}
```

#### Get Transactions Without Receipts
```http
GET /api/petty-cash/without-receipts?project_id=1
```

#### Get GPS Validation Failures
```http
GET /api/petty-cash/gps-failures?project_id=1
```

### GPS Validation Logic

```php
// Validates if transaction location is within project geofence
function validateGPS($txnLat, $txnLng, $projectLat, $projectLng, $radiusMeters) {
    $distance = haversine_distance($txnLat, $txnLng, $projectLat, $projectLng);
    return $distance <= $radiusMeters;
}

// Default radius: 500 meters
```

---

## Summary Table

| Feature | Tables | API Endpoints | Key Capability |
|---------|--------|---------------|----------------|
| Contractor Rating | 1 | 4 | Performance-based payment advice |
| Daily Wagers | 1 | 6 | Face recognition attendance |
| Tool Library | 2 | 7 | QR checkout/return tracking |
| Permit-to-Work | 1 | 9 | OTP-based safety approval |
| Petty Cash | 1 | 8 | Geo-tagged expense control |
| **Total** | **6** | **34** | **Enterprise compliance** |

---

## Combined System Metrics

**Phase 1-5 Complete**:
- **Total Tables**: 34 (19 main + 15 Phase 1-5)
- **Total API Endpoints**: 118 (84 existing + 34 Phase 5)
- **Total Migrations**: 21
- **System Capabilities**: Full procurement, stock, costing, compliance

---

## Testing Scenarios

### Scenario 1: Poor Contractor Rating
1. Rate contractor with overall_rating < 4.0
2. Verify payment_action = 'PENALTY'
3. Check penalty_amount calculated
4. Confirm contractor appears in "needing attention" list

### Scenario 2: Daily Wager Full Cycle
1. Check-in wager with face image
2. Work 8 hours
3. Check-out (auto-calculate wage)
4. Supervisor verifies attendance
5. Generate wage summary for month

### Scenario 3: Tool Overdue
1. Checkout tool with expected_return_time = yesterday
2. Tool status = 'CHECKED_OUT'
3. Call /tools/overdue
4. Verify tool appears with days_overdue > 0

### Scenario 4: Critical Permit Workflow
1. Request permit with risk_level = 'CRITICAL'
2. Generate OTP
3. Verify OTP within 15 minutes
4. Start work
5. Complete work with notes

### Scenario 5: GPS Validation Failure
1. Create petty cash request
2. Provide GPS coordinates > 500m from project
3. Manager approves
4. Verify gps_validated = false
5. Transaction appears in GPS failures list

---

## Production Deployment

```bash
# 1. Backup database
pg_dump construction_db > backup_pre_phase5.sql

# 2. Pull latest code
git pull origin main

# 3. Install dependencies
composer install --no-dev

# 4. Run migrations
php artisan migrate --force

# 5. Clear caches
php artisan config:cache
php artisan route:cache

# 6. Verify tables
psql -d construction_db -c "\dt"
# Should show: contractor_ratings, daily_wager_attendance, 
# tools_library, tool_checkouts, permit_to_work, petty_cash_transactions

# 7. Test critical endpoints
curl -X POST /api/contractor-ratings
curl -X POST /api/daily-wagers/check-in
curl -X POST /api/tools/checkout
curl -X POST /api/permits
curl -X POST /api/petty-cash
```

---

## Next Steps

**Phase 5 Complete!** ✅

System now includes:
- ✅ Core procurement (POs, GST compliance)
- ✅ Stock management (IN/OUT tracking)
- ✅ Cost analytics (BOQ variance, unit costing)
- ✅ Compliance features (contractor rating, permits, petty cash)
- ✅ Field management (daily wagers, tool library)

**Total System**:
- **118 API Endpoints**
- **34 Database Tables**
- **21 Migrations**
- **Full Indian construction ERP system**

**Recommended Next Actions**:
1. Mobile app integration for Phase 5 features
2. Face recognition ML model integration
3. SMS/Email notifications for OTP permits
4. QR code scanning in mobile app
5. GPS tracking improvement
6. Reporting dashboards for all phases
