# Construction Field Management Application - Laravel Backend API

## Overview
A **mobile-first, API-only Laravel backend** for a Construction Field Management Application designed for construction sites in India. Built with Laravel 11, PostgreSQL, and Laravel Sanctum for authentication.

## Features
- ✅ JWT-like token authentication with Laravel Sanctum
- ✅ Role-based access control (Worker, Engineer, Manager, Owner)
- ✅ Project management with user assignment
- ✅ Location-based attendance tracking
- ✅ Daily Progress Reports (DPR) with photo uploads
- ✅ Task management and assignment
- ✅ Material request and approval workflow
- ✅ Real-time stock and inventory tracking
- ✅ GST-ready invoicing system
- ✅ Owner dashboard with analytics
- ✅ Offline sync support
- ✅ Push notification system

## Technology Stack
- **Framework**: Laravel 11
- **Database**: PostgreSQL
- **Authentication**: Laravel Sanctum
- **API**: RESTful JSON APIs
- **Architecture**: Service Layer Pattern

## Installation

### Prerequisites
- PHP 8.2+
- Composer
- PostgreSQL 14+
- Node.js (for asset compilation)

### Setup Steps

```bash
# Clone the repository
git clone <repository-url>
cd quasar-updated

# Install dependencies
composer install

# Copy environment file
cp .env.example .env

# Configure database in .env
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=construction_app
DB_USERNAME=your_username
DB_PASSWORD=your_password

# Generate application key
php artisan key:generate

# Run migrations
php artisan migrate

# Install Sanctum
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"

# Seed database (optional)
php artisan db:seed

# Start the server
php artisan serve
```

## API Documentation

### Base URL
```
http://localhost:8000/api
```

### Authentication

#### Login
```http
POST /api/login
Content-Type: application/json

{
  "phone": "9876543210"
}

Response:
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "phone": "9876543210",
      "role": "engineer",
      "language": "en"
    },
    "token": "1|abc123xyz..."
  }
}
```

#### Get Current User
```http
GET /api/me
Authorization: Bearer {token}

Response:
{
  "success": true,
  "data": {
    "id": 1,
    "name": "John Doe",
    "phone": "9876543210",
    "role": "engineer",
    "language": "en",
    "is_active": true
  }
}
```

#### Logout
```http
POST /api/logout
Authorization: Bearer {token}

Response:
{
  "success": true,
  "message": "Logged out successfully"
}
```

### Projects

#### List Projects
```http
GET /api/projects
Authorization: Bearer {token}

Response:
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Commercial Plaza Construction",
      "location": "Mumbai, Maharashtra",
      "latitude": 19.0760,
      "longitude": 72.8777,
      "start_date": "2026-01-01",
      "end_date": "2026-12-31",
      "owner_id": 5,
      "created_at": "2026-01-20T10:00:00"
    }
  ]
}
```

#### Create Project
```http
POST /api/projects
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "Residential Tower",
  "location": "Pune, Maharashtra",
  "latitude": 18.5204,
  "longitude": 73.8567,
  "start_date": "2026-02-01",
  "end_date": "2027-02-01",
  "owner_id": 5
}
```

#### Assign User to Project
```http
POST /api/projects/{id}/assign-user
Authorization: Bearer {token}
Content-Type: application/json

{
  "user_id": 3
}
```

### Attendance

#### Check-In
```http
POST /api/attendance/check-in
Authorization: Bearer {token}
Content-Type: application/json

{
  "project_id": 1,
  "latitude": 19.0760,
  "longitude": 72.8777
}

Response:
{
  "success": true,
  "message": "Check-in successful",
  "data": {
    "id": 1,
    "user_id": 1,
    "project_id": 1,
    "date": "2026-01-20",
    "check_in": "2026-01-20T09:00:00",
    "latitude": 19.0760,
    "longitude": 72.8777,
    "is_verified": true
  }
}
```

#### Check-Out
```http
POST /api/attendance/{id}/check-out
Authorization: Bearer {token}
Content-Type: application/json

{
  "latitude": 19.0760,
  "longitude": 72.8777
}
```

#### Get My Attendance
```http
GET /api/attendance/my?project_id=1
Authorization: Bearer {token}
```

#### Get Project Attendance
```http
GET /api/attendance/project/{projectId}?start_date=2026-01-01&end_date=2026-01-31
Authorization: Bearer {token}
```

### Tasks

#### List Tasks
```http
GET /api/tasks?project_id=1
Authorization: Bearer {token}
```

#### Create Task
```http
POST /api/tasks
Authorization: Bearer {token}
Content-Type: application/json

{
  "project_id": 1,
  "assigned_to": 2,
  "title": "Install electrical wiring - Floor 3",
  "description": "Complete electrical wiring installation for floor 3 as per blueprint",
  "status": "pending"
}

Response:
{
  "success": true,
  "message": "Task created successfully",
  "data": {
    "id": 1,
    "project_id": 1,
    "assigned_to": 2,
    "assigned_by": 1,
    "title": "Install electrical wiring - Floor 3",
    "description": "Complete electrical wiring installation...",
    "status": "pending",
    "created_at": "2026-01-20T10:00:00"
  }
}
```

#### Update Task Status
```http
PATCH /api/tasks/{id}/status
Authorization: Bearer {token}
Content-Type: application/json

{
  "status": "in_progress"
}
```

### Daily Progress Reports (DPR)

#### Submit DPR
```http
POST /api/dprs
Authorization: Bearer {token}
Content-Type: application/json

{
  "project_id": 1,
  "work_description": "Completed concrete pouring for floor 2. Total area covered: 500 sq ft.",
  "latitude": 19.0760,
  "longitude": 72.8777,
  "photos": [
    "https://example.com/photo1.jpg",
    "https://example.com/photo2.jpg"
  ]
}

Response:
{
  "success": true,
  "message": "DPR submitted successfully",
  "data": {
    "id": 1,
    "project_id": 1,
    "user_id": 1,
    "work_description": "Completed concrete pouring...",
    "report_date": "2026-01-20",
    "status": "submitted",
    "photos": [
      {
        "id": 1,
        "photo_url": "https://example.com/photo1.jpg"
      }
    ]
  }
}
```

#### Approve/Reject DPR
```http
POST /api/dprs/{id}/approve
Authorization: Bearer {token}
Content-Type: application/json

{
  "status": "approved"
}
```

#### Get Pending DPRs
```http
GET /api/dprs/pending/all?project_id=1
Authorization: Bearer {token}
```

### Material Management

#### List Materials
```http
GET /api/materials
Authorization: Bearer {token}

Response:
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Cement (OPC 53)",
      "unit": "bag",
      "gst_percentage": 18.0
    },
    {
      "id": 2,
      "name": "Steel Bars (12mm)",
      "unit": "kg",
      "gst_percentage": 18.0
    }
  ]
}
```

#### Create Material Request
```http
POST /api/material-requests
Authorization: Bearer {token}
Content-Type: application/json

{
  "project_id": 1,
  "items": [
    {
      "material_id": 1,
      "quantity": 100
    },
    {
      "material_id": 2,
      "quantity": 500
    }
  ]
}

Response:
{
  "success": true,
  "message": "Material request created successfully",
  "data": {
    "id": 1,
    "project_id": 1,
    "requested_by": 1,
    "status": "pending",
    "items": [
      {
        "id": 1,
        "material": {
          "id": 1,
          "name": "Cement (OPC 53)",
          "unit": "bag"
        },
        "quantity": 100
      }
    ]
  }
}
```

#### Approve Material Request
```http
POST /api/material-requests/{id}/approve
Authorization: Bearer {token}
Content-Type: application/json

{
  "status": "approved"
}
```

### Stock Management

#### Get Project Stock
```http
GET /api/stock/project/{projectId}
Authorization: Bearer {token}

Response:
{
  "success": true,
  "data": [
    {
      "id": 1,
      "material": {
        "id": 1,
        "name": "Cement (OPC 53)",
        "unit": "bag"
      },
      "available_quantity": 250.0,
      "updated_at": "2026-01-20T10:00:00"
    }
  ]
}
```

#### Add Stock
```http
POST /api/stock/add
Authorization: Bearer {token}
Content-Type: application/json

{
  "project_id": 1,
  "material_id": 1,
  "quantity": 100,
  "type": "in",
  "reference_id": 5
}
```

#### Remove Stock
```http
POST /api/stock/remove
Authorization: Bearer {token}
Content-Type: application/json

{
  "project_id": 1,
  "material_id": 1,
  "quantity": 50,
  "type": "out"
}
```

#### Get Stock Transactions
```http
GET /api/stock/project/{projectId}/transactions?material_id=1
Authorization: Bearer {token}
```

### Invoices

#### Generate Invoice
```http
POST /api/invoices
Authorization: Bearer {token}
Content-Type: application/json

{
  "project_id": 1,
  "items": [
    {
      "description": "Labor charges - Floor 2",
      "amount": 50000,
      "gst_percentage": 18
    },
    {
      "description": "Material supply - Cement",
      "amount": 25000,
      "gst_percentage": 18
    }
  ]
}

Response:
{
  "success": true,
  "message": "Invoice generated successfully",
  "data": {
    "id": 1,
    "invoice_number": "INV-20260120-0001",
    "total_amount": 88500.00,
    "gst_amount": 13500.00,
    "status": "generated",
    "items": [
      {
        "description": "Labor charges - Floor 2",
        "amount": 50000.00,
        "gst_percentage": 18.00,
        "gst_amount": 9000.00,
        "total": 59000.00
      }
    ]
  }
}
```

#### Mark Invoice as Paid
```http
POST /api/invoices/{id}/mark-paid
Authorization: Bearer {token}
```

### Dashboard

#### Owner Dashboard
```http
GET /api/dashboard/owner
Authorization: Bearer {token}

Response:
{
  "success": true,
  "data": {
    "projects_count": 3,
    "projects": [...],
    "financial_overview": {
      "total_invoices": 15,
      "total_amount": 2500000.00,
      "total_gst": 450000.00,
      "paid_amount": 1800000.00,
      "pending_amount": 700000.00
    },
    "attendance_summary": {
      "today_attendance": 45,
      "total_workers": 60
    },
    "material_consumption": [...]
  }
}
```

### Notifications

#### Get Notifications
```http
GET /api/notifications
Authorization: Bearer {token}
```

#### Get Unread Notifications
```http
GET /api/notifications/unread
Authorization: Bearer {token}
```

#### Mark as Read
```http
POST /api/notifications/{id}/read
Authorization: Bearer {token}
```

#### Mark All as Read
```http
POST /api/notifications/read-all
Authorization: Bearer {token}
```

### Offline Sync

#### Get Pending Sync Logs
```http
GET /api/sync/pending
Authorization: Bearer {token}
```

#### Sync Batch
```http
POST /api/sync/batch
Authorization: Bearer {token}
Content-Type: application/json

{
  "records": [
    {
      "entity": "attendance",
      "entity_id": 1,
      "action": "create"
    }
  ]
}
```

## Project Structure

```
app/
├── Http/
│   ├── Controllers/
│   │   └── Api/
│   │       ├── AuthController.php
│   │       ├── ProjectController.php
│   │       ├── AttendanceController.php
│   │       ├── TaskController.php
│   │       ├── DprController.php
│   │       ├── MaterialController.php
│   │       ├── MaterialRequestController.php
│   │       ├── StockController.php
│   │       ├── InvoiceController.php
│   │       ├── DashboardController.php
│   │       ├── NotificationController.php
│   │       └── OfflineSyncController.php
│   ├── Requests/
│   │   ├── StoreProjectRequest.php
│   │   ├── StoreAttendanceRequest.php
│   │   ├── StoreTaskRequest.php
│   │   └── ...
│   └── Resources/
│       ├── UserResource.php
│       ├── ProjectResource.php
│       └── ...
├── Models/
│   ├── User.php
│   ├── Project.php
│   ├── Attendance.php
│   ├── Task.php
│   ├── DailyProgressReport.php
│   ├── Material.php
│   ├── Stock.php
│   └── ...
├── Policies/
│   ├── ProjectPolicy.php
│   ├── TaskPolicy.php
│   └── ...
└── Services/
    ├── AttendanceService.php
    ├── DprService.php
    ├── MaterialRequestService.php
    ├── StockService.php
    ├── InvoiceService.php
    └── DashboardService.php
```

## Role-Based Access Control

### Roles
- **Worker**: Can mark attendance, view assigned tasks, submit DPRs
- **Engineer**: Can create tasks, material requests, approve DPRs
- **Manager**: Can approve material requests, manage projects, view reports
- **Owner**: Full access to all projects, dashboard analytics

### Authorization
All endpoints are protected using Laravel Policies. Each request is authorized based on the user's role and relationship to the resource.

## Error Handling

All API responses follow a consistent format:

**Success Response:**
```json
{
  "success": true,
  "message": "Operation successful",
  "data": {...}
}
```

**Error Response:**
```json
{
  "success": false,
  "message": "Error message",
  "errors": {...}
}
```

**HTTP Status Codes:**
- 200: Success
- 201: Created
- 422: Validation Error
- 403: Forbidden
- 404: Not Found
- 500: Server Error

## Database Schema

The database schema follows the DBML specification provided, with all relationships properly defined using foreign keys and cascading deletes where appropriate.

## Performance Optimization

- Eager loading relationships to avoid N+1 queries
- Database indexes on foreign keys
- Pagination for large datasets
- Lightweight JSON responses
- Optimized for slow network conditions

## Security Features

- Token-based authentication with Sanctum
- Role-based access control
- Policy-based authorization
- SQL injection protection via Eloquent ORM
- CORS configuration
- Rate limiting on API endpoints

## Testing

```bash
# Run tests
php artisan test

# Run specific test
php artisan test --filter ProjectTest
```

## Deployment

### Production Checklist
- [ ] Set `APP_ENV=production` in `.env`
- [ ] Set `APP_DEBUG=false`
- [ ] Configure production database
- [ ] Run `php artisan config:cache`
- [ ] Run `php artisan route:cache`
- [ ] Run `php artisan view:cache`
- [ ] Set up SSL certificate
- [ ] Configure CORS for mobile app domains
- [ ] Set up queue worker for background jobs
- [ ] Configure logging and monitoring

## Support

For issues and questions, please contact the development team.

## License

Proprietary - All rights reserved
