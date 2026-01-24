# Construction Field Management API

> **Mobile-first, API-only Laravel backend** for Construction Field Management Application

[![Laravel](https://img.shields.io/badge/Laravel-11-red.svg)](https://laravel.com)
[![PHP](https://img.shields.io/badge/PHP-8.2+-blue.svg)](https://php.net)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14+-blue.svg)](https://postgresql.org)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## 🎯 Overview

A comprehensive backend API system designed for managing construction sites in India. Built for mobile-first offline usage with GPS tracking, real-time inventory management, and GST-compliant invoicing.

## ✨ Key Features

- 🔐 **Token-based Authentication** - Laravel Sanctum with phone-based login
- 👥 **Role-based Access Control** - Worker, Engineer, Manager, Purchase Manager, Owner
- 📍 **GPS-based Attendance** - Location-verified check-in/check-out
- 📝 **Daily Progress Reports** - Multi-photo uploads with approval workflow
- ✅ **Task Management** - Assignment and status tracking
- 📦 **Material Requests** - Multi-level approval system
- 📊 **Real-time Inventory** - Stock tracking with transaction history
- 💰 **GST-ready Invoicing** - Automated invoice generation
- 📈 **Owner Dashboard** - Comprehensive analytics
- 🔄 **Offline Sync** - Conflict-free data synchronization
- 🔔 **Push Notifications** - Real-time updates

## 🚀 Quick Start

### 1. Install Dependencies
```bash
composer install
composer require laravel/sanctum
```

### 2. Configure Environment
```bash
cp .env.example .env
# Update database credentials in .env
```

### 3. Setup Database
```bash
php artisan key:generate
php artisan migrate
php artisan db:seed
```

### 4. Start Server
```bash
php artisan serve
```

API available at: `http://localhost:8000/api`

**For detailed setup instructions, see [QUICK_START.md](QUICK_START.md)**

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [QUICK_START.md](QUICK_START.md) | Get started in 5 minutes |
| [API_DOCUMENTATION.md](API_DOCUMENTATION.md) | Complete API reference with examples |
| [API_ENDPOINTS.md](API_ENDPOINTS.md) | Quick endpoint reference |
| [SETUP_GUIDE.md](SETUP_GUIDE.md) | Detailed installation & troubleshooting |
| [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) | Technical architecture & features |

## 📱 Test Users

After seeding, login with these phone numbers:

| Role | Phone | Access Level |
|------|-------|--------------|
| Owner | 9876543210 | Full dashboard access |
| Manager | 9876543211 | Approve requests, manage projects |
| Engineer | 9876543213 | Create tasks, approve DPRs |
| Worker | 9876543220 | Attendance, view tasks |
| Purchase Manager | 9876543215 | Procurement, POs, stock management |

## 🔧 Tech Stack

- **Framework**: Laravel 11
- **Database**: PostgreSQL 14+
- **Authentication**: Laravel Sanctum
- **Architecture**: Service Layer Pattern
- **API**: RESTful JSON

## 📊 API Statistics

- **54+ Endpoints** across 11 controllers
- **16 Database Models** with full relationships
- **5 Policies** for authorization
- **10 Form Requests** for validation
- **11 API Resources** for consistent responses
- **8 Service Classes** for business logic

## 🎓 Architecture

```
app/
├── Http/
│   ├── Controllers/Api/  # 11 API controllers
│   ├── Requests/         # 10 validation classes
│   └── Resources/        # 11 resource formatters
├── Models/               # 16 eloquent models
├── Policies/             # 5 authorization policies
└── Services/             # 8 business logic services
```

## 🧪 Testing with Postman

Import the Postman collection:
```
Construction_API.postman_collection.json
```

1. Set `base_url` to `http://localhost:8000/api`
2. Login with test user phone number
3. Copy token to `token` variable
4. Test all 54 endpoints!

## 💡 Example API Calls

### Login
```bash
curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"9999999999"}'
```

### Check-in Attendance
```bash
curl -X POST http://localhost:8000/api/attendance/check-in \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "project_id": 1,
    "latitude": 19.0760,
    "longitude": 72.8777
  }'
```

### Submit DPR
```bash
curl -X POST http://localhost:8000/api/dprs \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "project_id": 1,
    "work_description": "Completed floor 2 concrete work",
    "latitude": 19.0760,
    "longitude": 72.8777,
    "photos": ["https://example.com/photo1.jpg"]
  }'
```

## 🔒 Security Features

- ✅ Token-based authentication
- ✅ Role-based authorization
- ✅ Policy-based access control
- ✅ Request validation
- ✅ SQL injection protection
- ✅ CORS configuration
- ✅ Rate limiting

## 📈 Performance

- ✅ Eager loading (No N+1 queries)
- ✅ Database indexing
- ✅ Pagination support
- ✅ Optimized for slow networks
- ✅ Lightweight JSON payloads

## 🌍 Production Ready

### Deployment Checklist
- [ ] Install Sanctum: `composer require laravel/sanctum`
- [ ] Run migrations: `php artisan migrate`
- [ ] Seed data: `php artisan db:seed`
- [ ] Set `APP_ENV=production`
- [ ] Set `APP_DEBUG=false`
- [ ] Configure HTTPS
- [ ] Cache config: `php artisan config:cache`
- [ ] Cache routes: `php artisan route:cache`
- [ ] Setup queue workers
- [ ] Configure logging

## 📦 Database Schema

17 tables with complete relationships:
- Users, Projects, Project Users
- Attendance, Tasks
- Daily Progress Reports, DPR Photos
- Materials, Material Requests, Material Request Items
- Stock, Stock Transactions
- Invoices, Invoice Items
- Approvals, Notifications
- Offline Sync Logs

## 🎯 Use Cases

### For Construction Sites
- Track worker attendance with GPS
- Manage daily work progress
- Request and approve materials
- Monitor inventory in real-time
- Generate GST invoices
- View project analytics

### For Mobile Apps
- Offline-first architecture
- Sync when online
- Photo upload support
- Location-based features
- Push notifications

## 🤝 Contributing

This is a proprietary project for construction management.

## 📄 License

All rights reserved.

## 🆘 Support

- **Setup Issues**: See [SETUP_GUIDE.md](SETUP_GUIDE.md)
- **API Questions**: See [API_DOCUMENTATION.md](API_DOCUMENTATION.md)
- **Architecture**: See [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md)

## 🎉 Status

✅ **100% Complete** - All features from requirements implemented

- Authentication ✅
- Project Management ✅
- Attendance Tracking ✅
- Task Management ✅
- DPR System ✅
- Material Requests ✅
- Stock Management ✅
- Invoicing ✅
- Dashboard ✅
- Notifications ✅
- Offline Sync ✅

---

Built with ❤️ for Construction Industry in India


In order to ensure that the Laravel community is welcoming to all, please review and abide by the [Code of Conduct](https://laravel.com/docs/contributions#code-of-conduct).

## Security Vulnerabilities

If you discover a security vulnerability within Laravel, please send an e-mail to Taylor Otwell via [taylor@laravel.com](mailto:taylor@laravel.com). All security vulnerabilities will be promptly addressed.

## License

The Laravel framework is open-sourced software licensed under the [MIT license](https://opensource.org/licenses/MIT).
