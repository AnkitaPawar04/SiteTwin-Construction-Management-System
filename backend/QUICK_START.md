# 🚀 Quick Start Guide

Get the Construction Field Management API running in 5 minutes!

## Prerequisites Check

Ensure you have:
- ✅ PHP 8.2 or higher
- ✅ Composer
- ✅ PostgreSQL 14+
- ✅ Git (optional)

## Installation Steps

### 1. Install Laravel Sanctum

```bash
composer require laravel/sanctum
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
```

### 2. Configure Database

Edit `.env` file:

```env
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=construction_app
DB_USERNAME=postgres
DB_PASSWORD=your_password
```

### 3. Create Database

```bash
# In PostgreSQL
createdb construction_app
```

Or using psql:
```sql
CREATE DATABASE construction_app;
```

### 4. Run Migrations

```bash
php artisan migrate
```

Expected output: ✅ 17 tables created

### 5. Seed Sample Data

```bash
php artisan db:seed
```

This creates:
- 4 test users (Owner, Manager, Engineer, Worker)
- 12 common construction materials

### 6. Start Server

```bash
php artisan serve
```

API available at: `http://localhost:8000/api`

## 🧪 Test the API

### Option 1: Using cURL

```bash
# Login
curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"9999999999"}'

# Copy the token from response, then:
curl -X GET http://localhost:8000/api/me \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Option 2: Using Postman

1. Import `Construction_API.postman_collection.json`
2. Set `base_url` variable to `http://localhost:8000/api`
3. Login using phone: `9999999999`
4. Copy token to `token` variable
5. Test other endpoints!

## 📱 Test Users

After seeding, use these phone numbers to login:

| Role | Phone | Use Case |
|------|-------|----------|
| Owner | 9999999999 | Dashboard, full access |
| Manager | 9999999998 | Approve requests |
| Engineer | 9999999997 | Create tasks, DPR |
| Worker | 9999999996 | Attendance, tasks |

## ✅ Verify Installation

Test these key endpoints:

1. **Login**: `POST /api/login`
   ```json
   {"phone":"9999999999"}
   ```

2. **Get Profile**: `GET /api/me`
   - Header: `Authorization: Bearer {token}`

3. **List Materials**: `GET /api/materials`
   - Should return 12 materials

4. **Create Project**: `POST /api/projects`
   ```json
   {
     "name": "Test Project",
     "location": "Mumbai",
     "latitude": 19.0760,
     "longitude": 72.8777,
     "start_date": "2026-01-01",
     "end_date": "2026-12-31",
     "owner_id": 1
   }
   ```

## 📖 Next Steps

1. **Read Documentation**:
   - `API_DOCUMENTATION.md` - Complete API reference
   - `IMPLEMENTATION_SUMMARY.md` - Architecture overview
   - `SETUP_GUIDE.md` - Detailed setup

2. **Explore Endpoints**:
   - Use Postman collection
   - Try different user roles
   - Test approval workflows

3. **Integrate with Mobile App**:
   - All APIs return JSON
   - Use Bearer token authentication
   - Handle offline sync

## 🔧 Common Issues

### "No application encryption key"
```bash
php artisan key:generate
```

### "Could not find driver"
```bash
# Install PostgreSQL PHP extension
# Ubuntu/Debian:
sudo apt-get install php-pgsql

# Mac:
brew install php@8.2
```

### "Access denied for user"
Check your `.env` database credentials

### "Base table or view not found"
```bash
php artisan migrate:fresh --seed
```

## 🎯 What You Get

- ✅ 50+ API endpoints
- ✅ 16 database models
- ✅ Role-based access control
- ✅ GPS-based attendance
- ✅ Material request workflows
- ✅ GST-ready invoicing
- ✅ Owner dashboard
- ✅ Offline sync support

## 📞 Support

For detailed documentation, see:
- `API_DOCUMENTATION.md`
- `SETUP_GUIDE.md`
- `IMPLEMENTATION_SUMMARY.md`

## 🎉 You're Ready!

Your Construction Field Management API is now running and ready to be consumed by your mobile application!

**API Base URL**: `http://localhost:8000/api`

Happy Coding! 🚀
