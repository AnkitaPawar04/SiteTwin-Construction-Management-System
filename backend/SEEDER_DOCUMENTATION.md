# Database Seeder Documentation

## Overview

Comprehensive database seeders for the Construction Field Management Application with realistic data for testing and demonstration.

## Seeder Classes

### 1. **UserSeeder**
Creates 21 users across 4 roles:

- **1 Owner**: Rajesh Kumar (9876543210)
- **2 Managers**: Amit Sharma (9876543211), Priya Singh (9876543212)
- **3 Engineers**: Vikram Patel (9876543213), Sneha Reddy (9876543214), Arjun Menon (9876543215)
- **15 Workers**: Hindi-speaking workers (9876543220-9876543234)

### 2. **MaterialSeeder**
Creates 44 construction materials across categories:

- Cement & Concrete (4 items)
- Steel (6 items)
- Aggregates (4 items)
- Bricks & Blocks (4 items)
- Flooring & Tiles (4 items)
- Paint & Finishing (5 items)
- Plumbing (5 items)
- Electrical (6 items)
- Doors & Windows (3 items)
- Miscellaneous (3 items)

All materials include proper GST percentages (5%, 12%, or 18%).

### 3. **ProjectSeeder**
Creates 3 projects with realistic data:

#### Project 1: Commercial Plaza - Andheri
- Location: Andheri West, Mumbai
- Duration: Nov 2025 - Oct 2026
- Team: 1 Manager, 2 Engineers, 10 Workers
- Status: Active

#### Project 2: Skyline Residency - Pune
- Location: Kharadi, Pune
- Duration: Dec 2025 - Nov 2027
- Team: 1 Manager, 1 Engineer, 5 Workers
- Status: Active

#### Project 3: Green Valley Villas - Bangalore
- Location: Whitefield, Bangalore
- Duration: Mar 2026 - Feb 2027
- Team: 1 Manager, 1 Engineer
- Status: Upcoming

### 4. **AttendanceSeeder**
Generates attendance records:

- **Project 1**: Last 10 days, 10 workers, ~90% attendance rate
- **Project 2**: Last 5 days, 5 workers, ~90% attendance rate
- Skips Sundays
- Realistic check-in (8-9 AM) and check-out (5-6 PM) times
- GPS coordinates with small variations

**Total**: ~85 attendance records

### 5. **TaskSeeder**
Creates 12 realistic construction tasks:

**Project 1 (7 tasks)**:
- 2 Completed: Foundation excavation, Steel reinforcement
- 2 In Progress: Concrete pouring, Brickwork
- 3 Pending: Electrical, Plumbing, Plastering

**Project 2 (5 tasks)**:
- 2 Completed: Site preparation, Foundation marking
- 1 In Progress: Foundation excavation
- 2 Pending: PCC laying, Steel fixing

### 6. **DprSeeder**
Creates 8 Daily Progress Reports with photos:

**Approved DPRs (4)**:
- Foundation excavation (3 photos)
- Steel reinforcement (4 photos)
- Concrete pouring (5 photos)
- Site clearing (3 photos)

**Pending DPRs (4)**:
- Brickwork progress (4 photos)
- Electrical conduit (3 photos)
- Foundation excavation Phase 1 (4 photos)
- Plumbing rough-in (3 photos)

Each DPR includes:
- Detailed work description
- GPS coordinates
- Multiple photo URLs
- Approval records

### 7. **MaterialRequestSeeder**
Creates 6 material requests:

**Approved Requests (3)**:
- Request 1: Cement, Steel, Sand (Project 1)
- Request 2: Bricks, Cement, Sand (Project 1)
- Request 3: Cement, Steel, Aggregate (Project 2)

**Pending Requests (3)**:
- Request 4: Electrical materials (Project 1)
- Request 5: Plumbing materials (Project 1)
- Request 6: Steel & concrete (Project 2)

Each request includes:
- Multiple material items
- Quantities
- Approval workflow records

### 8. **StockSeeder**
Creates stock and transaction records:

**Project 1 Stock**:
- Cement: 150 bags available (300 received, 150 consumed)
- Steel 8mm: 2500 kg available (5000 received, 2500 consumed)
- Sand: 35 cu.m available (80 received, 45 consumed)
- Bricks: 6000 pieces available (10000 received, 4000 consumed)

**Project 2 Stock**:
- Cement: 120 bags available (150 received, 30 consumed)
- Steel 12mm: 2700 kg available (3000 received, 300 consumed)
- Aggregate: 38 cu.m available (40 received, 2 consumed)

Each stock item includes:
- Stock IN transactions (linked to material requests)
- Stock OUT transactions (consumption)

**Total**: 7 stock items, 14 transactions

### 9. **InvoiceSeeder**
Creates 4 GST-compliant invoices:

**Invoice 1** (Paid): ₹10,26,200
- Foundation Work for Project 1
- 4 line items (Excavation, Steel, Concrete, Labor)
- 18% GST on all items

**Invoice 2** (Paid): ₹5,51,550
- Brickwork & Masonry for Project 1
- 4 line items (External walls, Partitions, Plastering, Labor)
- 12-18% GST

**Invoice 3** (Pending): ₹4,48,800
- Site Preparation for Project 2
- 4 line items (Clearing, Testing, Excavation, Equipment)
- 18% GST

**Invoice 4** (Pending): ₹4,43,700
- Electrical & Plumbing for Project 1
- 4 line items (Electrical, Plumbing, Materials)
- 18% GST

**Total Invoice Amount**: ₹24,70,250

### 10. **NotificationSeeder**
Creates 30 notifications:

- **Worker notifications**: Task assignments, DPR approvals (15)
- **Engineer notifications**: Material request approvals (6)
- **Manager notifications**: Pending approvals (3)
- **Owner notifications**: Project updates, invoices, stock alerts (3)
- **Project 2 notifications**: Worker updates (3)

Mix of read and unread notifications.

## Running Seeders

### Seed Everything
```bash
php artisan db:seed
```

### Seed Specific Seeder
```bash
php artisan db:seed --class=UserSeeder
php artisan db:seed --class=MaterialSeeder
php artisan db:seed --class=ProjectSeeder
# ... etc
```

### Fresh Migration + Seed
```bash
php artisan migrate:fresh --seed
```

## Data Summary

| Entity | Count | Description |
|--------|-------|-------------|
| Users | 21 | 1 Owner, 2 Managers, 3 Engineers, 15 Workers |
| Materials | 44 | Complete construction materials catalog |
| Projects | 3 | 2 Active, 1 Upcoming |
| Project Assignments | 23 | Users assigned to projects |
| Attendance Records | ~85 | Last 10 days of realistic attendance |
| Tasks | 12 | Various statuses across projects |
| DPRs | 8 | With 30 photos total |
| Material Requests | 6 | 3 Approved, 3 Pending |
| Stock Items | 7 | Real-time inventory |
| Stock Transactions | 14 | IN/OUT movements |
| Invoices | 4 | 2 Paid, 2 Pending |
| Invoice Items | 16 | Line items with GST |
| Approvals | 14 | DPR and Material Request approvals |
| Notifications | 30 | Various types across users |

## Test Scenarios Covered

### Authentication
- ✅ Login with different roles
- ✅ Phone-based authentication

### Project Management
- ✅ Active and upcoming projects
- ✅ Team assignments
- ✅ Multi-project scenarios

### Attendance
- ✅ Daily check-in/check-out
- ✅ Historical data
- ✅ GPS variations

### Task Management
- ✅ Task assignment across roles
- ✅ Status progression
- ✅ Multiple tasks per project

### DPR System
- ✅ Submission with photos
- ✅ Approval workflow
- ✅ Pending approvals

### Material Management
- ✅ Material catalog
- ✅ Request creation
- ✅ Approval process
- ✅ Stock updates

### Inventory
- ✅ Stock tracking
- ✅ Consumption recording
- ✅ Transaction history

### Invoicing
- ✅ Multi-item invoices
- ✅ GST calculations
- ✅ Payment status

### Notifications
- ✅ Task assignments
- ✅ Approval updates
- ✅ System alerts

## Login Credentials

### Owner Access
```
Phone: 9876543210
Name: Rajesh Kumar (Owner)
```

### Manager Access
```
Phone: 9876543211 (Project 1)
Name: Amit Sharma (Manager)

Phone: 9876543212 (Project 2)
Name: Priya Singh (Manager)
```

### Engineer Access
```
Phone: 9876543213 (Project 1)
Name: Vikram Patel (Engineer)

Phone: 9876543214 (Project 1)
Name: Sneha Reddy (Engineer)

Phone: 9876543215 (Project 2)
Name: Arjun Menon (Engineer)
```

### Worker Access
```
Phone: 9876543220-9876543234
Names: Various Hindi-speaking workers
```

## API Testing Flow

### 1. Login as Owner
```bash
POST /api/login
{"phone": "9876543210"}
```

### 2. View Dashboard
```bash
GET /api/dashboard/owner
```

### 3. Login as Worker
```bash
POST /api/login
{"phone": "9876543220"}
```

### 4. Check Today's Attendance
```bash
GET /api/attendance/my
```

### 5. View Assigned Tasks
```bash
GET /api/tasks
```

### 6. Login as Manager
```bash
POST /api/login
{"phone": "9876543211"}
```

### 7. View Pending Approvals
```bash
GET /api/dprs/pending/all
GET /api/material-requests/pending/all
```

### 8. Approve DPR
```bash
POST /api/dprs/1/approve
{"status": "approved"}
```

## Notes

- All timestamps are relative to current date
- GPS coordinates are realistic for Indian cities
- GST rates are as per Indian taxation
- Worker names are in Hindi (Devanagari script)
- Phone numbers follow Indian format
- All monetary amounts are in INR (₹)
- Attendance respects working days (excludes Sundays)

## Customization

To modify seed data:
1. Edit respective seeder class
2. Run `php artisan migrate:fresh --seed`
3. Data will be regenerated with changes

## Production Usage

⚠️ **Warning**: These seeders contain test data. For production:
1. Create separate production seeders
2. Seed only master data (materials, etc.)
3. Never seed user data in production
4. Use environment checks in seeders
