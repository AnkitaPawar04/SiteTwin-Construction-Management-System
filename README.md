# Construction Field Management System

A comprehensive enterprise resource planning (ERP) system for construction site management in India, featuring real-time procurement tracking, GPS-based attendance, safety compliance, and GST-compliant financial management.

---

## Table of Contents

- [Overview](#overview)
- [System Architecture](#system-architecture)
- [Key Features](#key-features)
- [Technology Stack](#technology-stack)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Database Setup](#database-setup)
- [Configuration](#configuration)
- [Running the Application](#running-the-application)
- [User Roles](#user-roles)
- [Core Modules](#core-modules)
- [API Documentation](#api-documentation)
- [Testing](#testing)
- [Project Structure](#project-structure)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

This system is designed to digitize and streamline construction field operations across India, addressing challenges in procurement, compliance, attendance tracking, and financial management. Built with a mobile-first approach, it supports offline operations with automatic synchronization when connectivity is restored.

### Problem Statement

Traditional construction management faces challenges including:
- Manual attendance tracking and time theft
- Lack of real-time inventory visibility
- Complex GST compliance requirements
- Safety permit management gaps
- Fragmented expense tracking
- Limited procurement accountability

### Solution

An integrated platform providing:
- GPS-verified attendance with geofencing
- Purchase order-driven procurement workflow
- Real-time stock and inventory management
- Automated GST-compliant invoicing
- Digital safety permit system with OTP verification
- Worker-based petty cash management
- Comprehensive analytics and reporting

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Mobile Application                        │
│                 (Flutter - Android/iOS)                      │
└─────────────────────────────────────────────────────────────┘
                            │
                    REST API / JSON
                            │
┌─────────────────────────────────────────────────────────────┐
│                   Backend API Server                         │
│              (Laravel 11 - PHP 8.2+)                        │
└─────────────────────────────────────────────────────────────┘
                            │
                    PostgreSQL 14+
                            │
┌─────────────────────────────────────────────────────────────┐
│                     Database Layer                           │
│         (Relational with JSONB support)                     │
└─────────────────────────────────────────────────────────────┘
```

### Design Principles

- **Mobile-First**: Optimized for field workers with limited connectivity
- **Offline-Capable**: Local data persistence with conflict-free sync
- **Role-Based Access**: Granular permissions aligned with organizational hierarchy
- **Audit Trail**: Complete transaction history for compliance
- **Scalable**: Microservice-ready architecture with API versioning

---

## Key Features

### Procurement & Inventory Management

- **Purchase Order Workflow**: Complete lifecycle from material request to delivery
- **Vendor Management**: Multi-vendor comparison and performance tracking
- **Real-Time Stock Tracking**: Live inventory with transaction history
- **GST Compliance**: Automated GST calculation and invoice generation
- **Mixed GST Support**: Separate handling of GST and non-GST items
- **Stock Reconciliation**: Periodic variance analysis and adjustment

### Attendance & Time Tracking

- **GPS-Based Check-In/Out**: Location verification with geofencing
- **Face Recognition**: Optional biometric attendance capture
- **Automated Timesheet**: Daily, weekly, and monthly attendance reports
- **Overtime Calculation**: Configurable rules for extra hours
- **Team Dashboard**: Real-time attendance monitoring for managers

### Safety & Compliance

- **OTP Permit-to-Work**: Supervisor-requested, safety officer-approved work permits
- **Fixed OTP System**: Secure 6-digit OTP (123456 for MVP) verification
- **Task Classification**: Height work, electrical, welding, confined space, hot work, excavation
- **Safety Checklist**: Mandatory safety measures documentation
- **Permit Lifecycle**: PENDING → APPROVED → IN_PROGRESS → COMPLETED workflow

### Financial Management

- **Petty Cash System**: Worker-submitted expenses with receipt verification
- **GPS Validation**: Location-based expense authentication
- **Duplicate Detection**: Image hash-based receipt verification
- **Manager Approval**: Multi-level expense authorization workflow
- **Wallet Management**: Project-based cash allocation and tracking

### Project Management

- **Task Assignment**: Multi-level task breakdown and assignment
- **Daily Progress Reports (DPR)**: Photo documentation with GPS tagging
- **Material Requests**: Field-initiated procurement requests
- **Progress Tracking**: Real-time project status and milestone monitoring
- **Cost Analytics**: Budget vs. actual comparison with variance analysis

### Analytics & Reporting

- **Cost Dashboard**: Material, labor, and overhead cost breakdowns
- **Consumption Variance**: Expected vs. actual material usage
- **Unit Costing**: Per-square-foot cost calculation
- **Flat Costing**: Individual unit cost allocation
- **Owner Dashboard**: Executive summary with KPIs

### Tool & Equipment Management

- **Tool Library**: Centralized tool inventory (32+ standard tools)
- **Issue/Return Workflow**: Tool allocation and tracking
- **Maintenance Scheduling**: Preventive maintenance alerts
- **Usage History**: Tool utilization reports
- **Damage Tracking**: Repair and replacement management

---

## Technology Stack

### Backend

| Component | Technology | Version |
|-----------|-----------|---------|
| Framework | Laravel | 11.x |
| Language | PHP | 8.2+ |
| Database | PostgreSQL | 14+ |
| Authentication | Laravel Sanctum | 4.2+ |
| PDF Generation | DomPDF | dev-master |
| Date/Time | Carbon | 3.0+ |
| Testing | Pest | 3.8+ |

### Mobile

| Component | Technology | Version |
|-----------|-----------|---------|
| Framework | Flutter | 3.10.4+ |
| Language | Dart | 3.10.4+ |
| State Management | Riverpod | 3.2.0+ |
| HTTP Client | Dio | 5.4.0+ |
| Local Storage | Hive | 2.2.3+ |
| Location Services | Geolocator | 14.0.2+ |
| Camera | Image Picker | 1.0.7+ |
| Charts | FL Chart | 0.69.2+ |
| PDF Viewer | PDF Render | 1.4.12+ |

### Development Tools

- **Version Control**: Git
- **API Testing**: Postman (collection included)
- **Code Quality**: Laravel Pint, Flutter Analyze
- **Database Migration**: Laravel Migrations
- **Seeding**: Laravel Seeders

---

## Prerequisites

### Backend Requirements

- PHP >= 8.2
- Composer >= 2.0
- PostgreSQL >= 14
- Apache/Nginx web server
- PHP Extensions:
  - pdo_pgsql
  - mbstring
  - openssl
  - json
  - tokenizer
  - xml
  - ctype
  - fileinfo
  - gd

### Mobile Requirements

- Flutter SDK >= 3.10.4
- Dart SDK >= 3.10.4
- Android Studio / Xcode (for emulators)
- Physical device or emulator with:
  - Android 6.0+ (API 23+)
  - iOS 12.0+
  - Camera access
  - Location services

---

## Installation

### Backend Setup

#### 1. Clone Repository

```bash
git clone <repository-url>
cd quasar-updated/backend
```

#### 2. Install Dependencies

```bash
composer install
```

#### 3. Environment Configuration

```bash
cp .env.example .env
```

Edit `.env` file with your database credentials:

```env
APP_NAME="Construction Management"
APP_ENV=local
APP_DEBUG=true
APP_URL=http://localhost:8000

DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=construction_db
DB_USERNAME=your_username
DB_PASSWORD=your_password

SANCTUM_STATEFUL_DOMAINS=localhost,127.0.0.1
```

#### 4. Generate Application Key

```bash
php artisan key:generate
```

#### 5. Run Migrations

```bash
php artisan migrate
```

#### 6. Seed Database

```bash
php artisan db:seed
```

This creates:
- 7 test users (one per role)
- 4 sample projects
- 50+ materials
- 20+ vendors
- 32 standard construction tools
- Sample purchase orders and invoices
- 8 permit-to-work records
- 5 petty cash transactions

#### 7. Start Development Server

```bash
php artisan serve
```

Backend API will be available at `http://localhost:8000`

### Mobile Setup

#### 1. Navigate to Mobile Directory

```bash
cd ../mobile
```

#### 2. Install Dependencies

```bash
flutter pub get
```

#### 3. Configure API Endpoint

Edit `lib/core/constants/api_constants.dart`:

```dart
static const String baseUrl = 'http://YOUR_IP_ADDRESS:8000';
```

Replace `YOUR_IP_ADDRESS` with:
- `localhost` for emulator
- Your machine's local IP (e.g., `192.168.1.100`) for physical device

#### 4. Run Application

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device_id>

# Or simply
flutter run
```

---

## Database Setup

### Create PostgreSQL Database

```sql
-- Connect to PostgreSQL
psql -U postgres

-- Create database
CREATE DATABASE construction_db;

-- Create user (optional)
CREATE USER construction_user WITH PASSWORD 'your_password';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE construction_db TO construction_user;

-- Exit
\q
```

### Migration Overview

The system includes 26+ migration files organized in phases:

**Phase 1: Core Tables**
- users
- projects
- tasks
- attendance
- materials
- vendors

**Phase 2: Procurement**
- material_requests
- purchase_orders
- purchase_order_items
- gst_bills
- non_gst_bills

**Phase 3: Compliance**
- contractor_ratings
- tools
- tool_transactions
- permit_to_work

**Phase 4: Financial**
- petty_cash_wallet
- petty_cash_transactions (mock data only)

### Reset Database

```bash
# Fresh migration with seeding
php artisan migrate:fresh --seed

# Rollback specific migration
php artisan migrate:rollback --step=1

# Check migration status
php artisan migrate:status
```

---

## Configuration

### Laravel Configuration Files

**Authentication** (`config/sanctum.php`):
```php
'expiration' => null, // Token never expires (modify for production)
'stateful' => explode(',', env('SANCTUM_STATEFUL_DOMAINS', 'localhost')),
```

**CORS** (`config/cors.php`):
```php
'paths' => ['api/*', 'sanctum/csrf-cookie'],
'allowed_methods' => ['*'],
'allowed_origins' => ['*'], // Restrict in production
```

**Database** (`config/database.php`):
```php
'default' => env('DB_CONNECTION', 'pgsql'),
```

### Flutter Configuration

**API Constants** (`lib/core/constants/api_constants.dart`):
```dart
class ApiConstants {
  static const String baseUrl = 'http://172.16.23.211:8000';
  static const String apiVersion = 'api';
  
  // Endpoints
  static const String login = '/login';
  static const String projects = '/projects';
  // ... etc
}
```

**App Constants** (`lib/core/constants/app_constants.dart`):
```dart
class AppConstants {
  static const int maxPhotoSize = 5 * 1024 * 1024; // 5 MB
  static const double geofenceRadius = 100.0; // meters
  static const int syncInterval = 300; // seconds
}
```

---

## Running the Application

### Development Workflow

#### Backend

```bash
# Terminal 1 - Run Laravel server
cd backend
php artisan serve --host=0.0.0.0 --port=8000

# Terminal 2 - Watch logs (optional)
php artisan pail

# Terminal 3 - Queue worker (if using queues)
php artisan queue:work
```

#### Mobile

```bash
# Terminal 1 - Run Flutter app
cd mobile
flutter run

# Terminal 2 - Watch for changes (hot reload enabled by default)
flutter analyze --watch

# Build for release
flutter build apk --release
flutter build ios --release
```

### Production Deployment

#### Backend

1. **Server Setup**
```bash
# Update packages
apt-get update && apt-get upgrade

# Install PHP, PostgreSQL, Composer
apt-get install php8.2 postgresql composer nginx

# Configure Nginx
cp deployment/nginx.conf /etc/nginx/sites-available/construction
ln -s /etc/nginx/sites-available/construction /etc/nginx/sites-enabled/
```

2. **Application Deployment**
```bash
# Clone repository
git clone <repo> /var/www/construction

# Install dependencies
composer install --optimize-autoloader --no-dev

# Configure environment
cp .env.production .env
php artisan key:generate
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Run migrations
php artisan migrate --force

# Set permissions
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache
```

#### Mobile

```bash
# Build Android APK
flutter build apk --release --split-per-abi

# Build iOS IPA
flutter build ios --release

# Distribute via Play Store / App Store
# Or use internal distribution
```

---

## User Roles

### Default Test Accounts

All accounts use password: `password`

| Role | Phone | Capabilities |
|------|-------|-------------|
| Owner | 9876543210 | Full system visibility, analytics, reports |
| Manager | 9876543211 | Project management, approvals, team oversight |
| Purchase Manager | 9876543212 | Procurement, PO management, vendor relations |
| Project Manager | 9876543213 | Project execution, task assignment, progress tracking |
| Site Engineer | 9876543214 | Field operations, DPR, material requests, tool management |
| Worker | 9876543215 | Attendance, tasks, expense submission |
| Safety Officer | 9876543216 | Permit approvals, safety compliance |
| Supervisor | 9876543217 | Work permits, team coordination |

### Permission Matrix

| Feature | Worker | Engineer | Supervisor | Safety Officer | Purchase Manager | Manager | Owner |
|---------|--------|----------|------------|----------------|------------------|---------|-------|
| Attendance (Self) | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | View |
| Tasks | View/Update | Assign/Update | View | - | - | Assign | View |
| DPR | Submit | Submit | - | - | - | Approve | View |
| Material Requests | - | Create | - | - | Review | Approve | View |
| Purchase Orders | - | - | - | - | Create/Manage | Approve | View |
| Stock Management | - | View | - | - | Manage | View | View |
| Petty Cash (Submit) | ✓ | - | - | - | - | - | - |
| Petty Cash (Review) | - | - | ✓ | - | - | ✓ | ✓ |
| Permit (Request) | - | - | ✓ | - | - | - | - |
| Permit (Approve) | - | - | - | ✓ | - | - | - |
| Tool Management | - | ✓ | - | - | - | ✓ | View |
| Analytics | - | - | - | - | Basic | Full | Full |

---

## Core Modules

### 1. Attendance Management

**Workflow**: Check-In → Work → Check-Out

**Features**:
- GPS-based location verification
- Geofencing (100m radius)
- Face recognition capture (optional)
- Automated timesheet generation
- Overtime calculation
- Monthly attendance reports

**API Endpoints**:
```
POST   /api/attendance/check-in
POST   /api/attendance/check-out
GET    /api/attendance/my-history
GET    /api/attendance/team (managers)
```

### 2. Purchase Order System

**Workflow**: Material Request → Review → PO Creation → Approval → Invoice Upload → Stock In

**Features**:
- Multi-item purchase orders
- GST/Non-GST segregation
- Vendor selection and comparison
- Invoice-PO linkage validation
- Auto stock update on approval
- PO status tracking

**API Endpoints**:
```
GET    /api/purchase-orders
POST   /api/purchase-orders
GET    /api/purchase-orders/{id}
PUT    /api/purchase-orders/{id}/approve
POST   /api/purchase-orders/{id}/upload-invoice
```

### 3. OTP Permit-to-Work

**Workflow**: Request → Safety Approval (OTP Generated) → Supervisor Verification → Work Start → Completion

**Features**:
- Task type classification (6 categories)
- Safety measures documentation
- Fixed OTP verification (123456)
- Status tracking across lifecycle
- Rejection with reasons
- Permit history and audit trail

**API Endpoints**:
```
GET    /api/permits
POST   /api/permits/request
POST   /api/permits/{id}/approve
POST   /api/permits/{id}/reject
POST   /api/permits/{id}/verify-otp
POST   /api/permits/{id}/complete
```

**Task Types**:
- HEIGHT: Work at heights (scaffolding, roofing)
- ELECTRICAL: Electrical installations and repairs
- WELDING: Hot work and welding operations
- CONFINED_SPACE: Work in confined spaces
- HOT_WORK: Cutting, grinding, flame work
- EXCAVATION: Digging and trenching

### 4. Petty Cash Management

**Workflow**: Worker Submits → Auto Validation → Manager Reviews → Approve/Reject

**Features**:
- Receipt photo capture with GPS
- Duplicate receipt detection (image hash)
- Location validation (on-site/off-site)
- Time-based submission verification
- Manager comments on approval/rejection
- Wallet balance tracking

**Mock Data Implementation** (No backend API):
```dart
// All operations use MockPettyCashRepository
repository.submitExpense(...)
repository.getTransactions(...)
repository.approveExpense(...)
repository.rejectExpense(...)
```

**Validation Checks**:
- GPS Status: ON_SITE / OUTSIDE_SITE
- Duplicate Flag: Image hash comparison
- Time Validation: Submission within reasonable timeframe
- Amount Validation: Minimum/maximum limits

### 5. Stock & Inventory

**Features**:
- Real-time stock levels
- Transaction history
- Low stock alerts
- Stock-in from PO
- Stock-out to projects
- Variance analysis

**API Endpoints**:
```
GET    /api/stock
POST   /api/stock/in
POST   /api/stock/out
GET    /api/stock/transactions
```

### 6. Tool Library

**Pre-seeded Tools** (32 items):
- Concrete Mixer, Drilling Machine, Welding Machine
- Angle Grinder, Circular Saw, Concrete Vibrator
- Water Pump, Plate Compactor, Tile Cutter
- And 23 more standard construction tools

**Features**:
- Tool inventory management
- Issue/Return workflow
- Maintenance scheduling
- Usage tracking
- Damage reporting

**API Endpoints**:
```
GET    /api/tools
POST   /api/tools
POST   /api/tools/{id}/issue
POST   /api/tools/{id}/return
GET    /api/tools/{id}/history
```

---

## API Documentation

### Authentication

All API requests (except login) require Bearer token:

```http
Authorization: Bearer {token}
```

### Login

**Endpoint**: `POST /api/login`

**Request**:
```json
{
  "phone": "9876543210"
}
```

**Response**:
```json
{
  "token": "1|abc123...",
  "user": {
    "id": 1,
    "name": "Rajesh Kumar",
    "phone": "9876543210",
    "role": "owner"
  }
}
```

### Complete API Reference

Full API documentation available at:
- Backend: `/backend/API_DOCUMENTATION.md`
- Postman Collection: `/backend/Construction_API.postman_collection.json`

**Import Postman Collection**:
1. Open Postman
2. Import → `Construction_API.postman_collection.json`
3. Set environment variable `base_url` to `http://localhost:8000`
4. Test all endpoints with pre-configured requests

---

## Testing

### Backend Testing

#### Unit Tests

```bash
cd backend

# Run all tests
php artisan test

# Run specific test file
php artisan test tests/Feature/AuthTest.php

# Run with coverage
php artisan test --coverage
```

#### Manual API Testing

```bash
# Test login
curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"9876543210"}'

# Test authenticated endpoint
curl -X GET http://localhost:8000/api/projects \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Mobile Testing

#### Unit Tests

```bash
cd mobile

# Run all tests
flutter test

# Run specific test file
flutter test test/models/user_model_test.dart

# Run with coverage
flutter test --coverage
lcov --list coverage/lcov.info
```

#### Widget Tests

```bash
# Run widget tests
flutter test test/widgets/

# Run integration tests
flutter test integration_test/
```

#### Device Testing

```bash
# Run on connected device
flutter run

# Debug mode
flutter run --debug

# Profile mode (performance testing)
flutter run --profile

# Release mode
flutter run --release
```

### Testing Checklist

**Authentication**:
- [ ] Login with all 8 user roles
- [ ] Token persistence
- [ ] Logout functionality

**Attendance**:
- [ ] GPS check-in validation
- [ ] Check-out calculation
- [ ] Face capture (if enabled)

**Petty Cash**:
- [ ] Worker submits expense with photo
- [ ] GPS validation (ON_SITE/OUTSIDE_SITE)
- [ ] Duplicate detection
- [ ] Manager approval workflow
- [ ] Rejection with reason
- [ ] Wallet balance update

**OTP Permit**:
- [ ] Supervisor request creation
- [ ] Safety officer approval (OTP generation)
- [ ] Correct OTP verification (123456)
- [ ] Invalid OTP rejection
- [ ] Status progression (PENDING → IN_PROGRESS → COMPLETED)
- [ ] Rejection workflow

**Purchase Orders**:
- [ ] PO creation from material request
- [ ] GST/Non-GST separation validation
- [ ] Approval workflow
- [ ] Stock-in on invoice upload

---

## Project Structure

### Backend Structure

```
backend/
├── app/
│   ├── Http/
│   │   ├── Controllers/
│   │   │   ├── Api/
│   │   │   │   ├── AttendanceController.php
│   │   │   │   ├── PermitToWorkController.php
│   │   │   │   ├── PurchaseOrderController.php
│   │   │   │   ├── StockController.php
│   │   │   │   └── ... (20+ controllers)
│   │   └── Middleware/
│   ├── Models/
│   │   ├── User.php
│   │   ├── Project.php
│   │   ├── PurchaseOrder.php
│   │   ├── PermitToWork.php
│   │   └── ... (30+ models)
│   ├── Services/
│   │   ├── StockService.php
│   │   └── InvoiceService.php
│   └── Policies/
│       └── PurchaseOrderPolicy.php
├── database/
│   ├── migrations/
│   │   ├── 2024_01_01_000001_create_users_table.php
│   │   ├── 2026_01_24_000014_create_permit_to_work_table.php
│   │   └── ... (26+ migrations)
│   ├── seeders/
│   │   ├── UserSeeder.php
│   │   ├── ProjectSeeder.php
│   │   ├── ToolSeeder.php
│   │   ├── PermitToWorkSeeder.php
│   │   └── DatabaseSeeder.php
│   └── factories/
├── routes/
│   ├── api.php (100+ endpoints)
│   └── web.php
├── config/
│   ├── sanctum.php
│   ├── cors.php
│   └── database.php
├── tests/
│   ├── Feature/
│   └── Unit/
└── storage/
    └── app/
        ├── public/
        │   ├── dpr_photos/
        │   ├── invoices/
        │   └── receipts/
        └── logs/
```

### Mobile Structure

```
mobile/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   ├── api_constants.dart
│   │   │   └── app_constants.dart
│   │   ├── localization/
│   │   │   └── app_localizations.dart
│   │   └── utils/
│   │       ├── app_logger.dart
│   │       └── date_formatter.dart
│   ├── data/
│   │   ├── models/
│   │   │   ├── user_model.dart
│   │   │   ├── project_model.dart
│   │   │   ├── petty_cash_transaction.dart
│   │   │   ├── petty_cash_wallet.dart
│   │   │   └── ... (25+ models)
│   │   └── repositories/
│   │       ├── auth_repository.dart
│   │       ├── project_repository.dart
│   │       ├── permit_repository.dart
│   │       ├── mock_petty_cash_repository.dart
│   │       └── ... (15+ repositories)
│   ├── presentation/
│   │   ├── screens/
│   │   │   ├── auth/
│   │   │   │   └── login_screen.dart
│   │   │   ├── home/
│   │   │   │   └── home_screen.dart
│   │   │   ├── petty_cash/
│   │   │   │   ├── submit_expense_screen.dart
│   │   │   │   ├── my_expenses_screen.dart
│   │   │   │   └── review_expenses_screen.dart
│   │   │   ├── compliance/
│   │   │   │   ├── otp_permit_screen.dart
│   │   │   │   ├── request_permit_screen.dart
│   │   │   │   └── tool_library_screen.dart
│   │   │   ├── analytics/
│   │   │   │   ├── cost_dashboard_screen.dart
│   │   │   │   ├── consumption_variance_screen.dart
│   │   │   │   ├── unit_costing_screen.dart
│   │   │   │   └── flat_costing_screen.dart
│   │   │   └── ... (40+ screens)
│   │   └── widgets/
│   │       ├── connection_indicator.dart
│   │       └── global_sync_indicator.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   └── providers.dart
│   └── main.dart
├── test/
│   ├── models/
│   └── widgets/
├── android/
├── ios/
└── pubspec.yaml
```

---

## Contributing

### Development Guidelines

1. **Code Style**
   - Backend: Follow PSR-12 coding standards
   - Mobile: Follow Dart effective guidelines
   - Use Laravel Pint for PHP formatting
   - Use `flutter analyze` for Dart linting

2. **Git Workflow**
   ```bash
   # Create feature branch
   git checkout -b feature/your-feature-name
   
   # Make changes
   git add .
   git commit -m "feat: add feature description"
   
   # Push changes
   git push origin feature/your-feature-name
   
   # Create pull request
   ```

3. **Commit Message Format**
   ```
   type(scope): subject
   
   Types: feat, fix, docs, style, refactor, test, chore
   Example: feat(permits): add OTP verification workflow
   ```

4. **Testing Requirements**
   - All new features must include tests
   - Maintain minimum 70% code coverage
   - Run full test suite before PR

5. **Documentation**
   - Update README for new features
   - Add API documentation for new endpoints
   - Include code comments for complex logic

### Pull Request Process

1. Update documentation
2. Add/update tests
3. Run linters and fix issues
4. Request code review
5. Address review comments
6. Squash commits before merge

---

## License

This project is licensed under the MIT License.

```
MIT License

Copyright (c) 2026 Construction Management System

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## Support

For issues, questions, or contributions:

- **Documentation**: See `/backend/API_DOCUMENTATION.md`
- **API Reference**: See `/backend/API_ENDPOINTS.md`
- **System Guide**: See `/backend/COMPLETE_SYSTEM_SUMMARY.md`
- **Feature List**: See `/ALL-FEATURES.md`

---

## Acknowledgments

- Laravel Framework - Robust PHP backend framework
- Flutter Framework - Cross-platform mobile development
- PostgreSQL - Reliable relational database
- Riverpod - State management solution
- Indian GST Compliance - Regulatory framework

---

**Version**: 1.0.0  
**Last Updated**: January 25, 2026  
**Status**: Production Ready
