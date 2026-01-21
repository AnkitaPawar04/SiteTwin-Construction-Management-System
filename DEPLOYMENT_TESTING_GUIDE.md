# Phase 1 Implementation - Deployment & Testing Guide
**Date**: January 21, 2026

---

## 📋 Pre-Deployment Checklist

### Backend Setup
- [ ] PHP 8.2+ installed
- [ ] Laravel 12.0 framework installed
- [ ] Database configured and migrated
- [ ] Composer dependencies installed
- [ ] `.env` file configured

### Mobile Setup
- [ ] Flutter SDK installed (3.10.4+)
- [ ] Android SDK configured
- [ ] iOS setup (if targeting iOS)
- [ ] Cocoapods installed (for iOS)

---

## 🔧 Backend Installation

### Step 1: Install Dependencies
```bash
cd backend
composer install
```

### Step 2: Update Dependencies
The PDF library has been added to `composer.json`. Run:
```bash
composer update
```

### Step 3: Publish Package Configuration
Some packages may need publishing:
```bash
php artisan vendor:publish --provider="Barryvdh\DomPDF\ServiceProvider"
```

### Step 4: Verify Installation
```bash
php artisan list
```

Should show available artisan commands.

---

## 📱 Mobile Installation

### Step 1: Update Dependencies
```bash
cd mobile
flutter pub get
```

### Step 2: Analyze for Issues
```bash
flutter analyze
```

Should show no errors.

### Step 3: Build Check
```bash
# For Android
flutter build apk --debug

# For iOS
flutter build ios --debug
```

---

## 🧪 Testing Phase 1 Features

### 1. PDF Export Testing

#### Backend PDF Generation:
```bash
# Test PDF generation via artisan tinker
php artisan tinker
>>> $invoice = App\Models\Invoice::find(1);
>>> return view('invoices.pdf', ['invoice' => $invoice])->render();
```

#### API PDF Endpoint:
```bash
# Test download endpoint
curl -X GET "http://localhost:8000/api/invoices/1/pdf" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -o test_invoice.pdf

# Verify PDF was created
file test_invoice.pdf
# Should show: PDF document, version 1.4
```

#### Mobile PDF Viewer:
1. Navigate to Invoices screen
2. Click on an invoice to expand
3. Click "View PDF" - should open PDF viewer
4. Click "Download PDF" - should download to device

---

### 2. Dashboard Testing

#### Owner Dashboard:
```bash
# GET /api/dashboard/owner
curl -X GET "http://localhost:8000/api/dashboard/owner" \
  -H "Authorization: Bearer OWNER_TOKEN" \
  -H "Content-Type: application/json" | jq
```

Expected response includes:
- `projects_count`
- `projects` array with progress
- `financial_overview`
- `attendance_summary`
- `material_consumption`
- `time_vs_cost_overall`

#### Manager Dashboard:
```bash
# GET /api/dashboard/manager
curl -X GET "http://localhost:8000/api/dashboard/manager" \
  -H "Authorization: Bearer MANAGER_TOKEN" \
  -H "Content-Type: application/json" | jq
```

Expected response includes:
- `projects_count`
- `today_attendance` with breakdown
- `pending_tasks`
- `pending_dprs`

#### Worker Dashboard:
```bash
# GET /api/dashboard/worker
curl -X GET "http://localhost:8000/api/dashboard/worker" \
  -H "Authorization: Bearer WORKER_TOKEN" \
  -H "Content-Type: application/json" | jq
```

Expected response includes:
- `today_status` with check-in status
- `assigned_tasks` with details
- `attendance_history`
- `weekly_attendance_rate`

#### Mobile Dashboard:
1. Login as different roles
2. Dashboard should automatically load correct endpoint
3. Verify stats display real data (not "0")
4. Refresh should update data

---

### 3. Team Attendance Testing

#### API Endpoint:
```bash
# Get team attendance for project 1 on specific date
curl -X GET "http://localhost:8000/api/attendance/project/1/team-summary?date=2025-01-21" \
  -H "Authorization: Bearer MANAGER_TOKEN" \
  -H "Content-Type: application/json" | jq
```

Expected response:
```json
{
  "success": true,
  "data": {
    "date": "2025-01-21",
    "total_workers": 50,
    "present": 45,
    "absent": 3,
    "leave": 2,
    "attendance_rate": 94.00,
    "workers": [...]
  }
}
```

#### Attendance Trends:
```bash
# Get 30-day trends
curl -X GET "http://localhost:8000/api/attendance/project/1/trends?days=30" \
  -H "Authorization: Bearer MANAGER_TOKEN" \
  -H "Content-Type: application/json" | jq
```

---

### 4. Time vs Cost Testing

#### API Endpoint:
```bash
# Get time vs cost dashboard
curl -X GET "http://localhost:8000/api/dashboard/time-vs-cost" \
  -H "Authorization: Bearer OWNER_TOKEN" \
  -H "Content-Type: application/json" | jq
```

Expected response includes:
- Project timelines
- Budget utilization
- Cost analysis
- Per-project breakdown

---

## 🐛 Debugging Guide

### PDF Generation Issues

**Issue**: "View not found" error
```
Solution: Ensure pdf.blade.php exists at resources/views/invoices/pdf.blade.php
```

**Issue**: "DomPDF not found" error
```bash
# Verify installation
composer show | grep dompdf
# Should show barryvdh/laravel-dompdf

# Re-publish configuration
php artisan vendor:publish --provider="Barryvdh\DomPDF\ServiceProvider"
```

**Issue**: PDF generation timeout
```
Solution: Increase execution time in php.ini
max_execution_time = 300
```

### Dashboard Data Issues

**Issue**: Dashboard returns null/empty data
```bash
# Verify user has projects assigned
php artisan tinker
>>> $user = App\Models\User::find(1);
>>> $user->projects()->count();
>>> $user->projects()->get();
```

**Issue**: Attendance data missing
```bash
# Check attendance records exist
php artisan tinker
>>> App\Models\Attendance::where('project_id', 1)->count();
>>> App\Models\Attendance::where('project_id', 1)->first();
```

### Mobile App Issues

**Issue**: PDF viewer not loading
```dart
// Check URL format in PdfViewerScreen
// Verify base URL is correct in ApiClient
// Check network connectivity
```

**Issue**: Dashboard not refreshing
```dart
// Check FutureProvider is properly invalidated
ref.invalidate(dashboardRepositoryProvider);

// Verify repository method implementation
```

**Issue**: Language not persisting
```dart
// Verify SharedPreferences save/load
final prefs = await SharedPreferences.getInstance();
print(prefs.getString('language'));
```

---

## 📊 Performance Testing

### Backend Load Testing:
```bash
# Install Apache Bench
apt-get install apache2-utils

# Test PDF endpoint (100 requests, 10 concurrent)
ab -n 100 -c 10 \
  -H "Authorization: Bearer TOKEN" \
  http://localhost:8000/api/invoices/1/pdf
```

### Mobile Performance:
1. Open Developer Tools (Android Studio / Xcode)
2. Monitor memory usage while loading dashboard
3. Check network requests in DevTools
4. Verify smooth scrolling with large lists

---

## ✅ Test Cases Checklist

### PDF Export
- [ ] PDF downloads successfully
- [ ] PDF contains correct invoice data
- [ ] PDF displays properly in viewer
- [ ] Multiple invoices can be downloaded
- [ ] PDF generation doesn't crash app
- [ ] File size is reasonable

### Dashboard
- [ ] Owner dashboard shows correct projects
- [ ] Manager dashboard shows assigned projects
- [ ] Worker dashboard shows correct stats
- [ ] All stats display real data
- [ ] Refresh updates data
- [ ] Navigation between dashboards works

### Team Attendance
- [ ] Team summary shows correct totals
- [ ] Individual worker status visible
- [ ] Attendance rate calculation correct
- [ ] Trends show correct data over time
- [ ] Date filter works properly

### Settings & Profile
- [ ] Profile loads user data
- [ ] Edit profile fields enabled
- [ ] Language selection persists
- [ ] Notifications toggle works
- [ ] Logout confirmation appears

---

## 🚀 Production Deployment

### Pre-Production:
```bash
# Clean up
composer install --no-dev
flutter clean
flutter pub get

# Build release APK
flutter build apk --release

# Build release iOS
flutter build ios --release

# Optimize Laravel
php artisan optimize:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

### Environment Variables:
```bash
# .env configuration
APP_ENV=production
APP_DEBUG=false
APP_URL=https://your-domain.com

# PDF generation
DOMPDF_ENABLE_AUTOLOAD=true

# Database
DB_HOST=your-db-host
DB_DATABASE=construction_db
DB_USERNAME=db_user
DB_PASSWORD=secure_password

# Mail (for notifications)
MAIL_DRIVER=smtp
MAIL_HOST=smtp.mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=your_username
MAIL_PASSWORD=your_password
```

### Security:
```bash
# Generate app key
php artisan key:generate

# Set file permissions
chmod -R 755 storage
chmod -R 755 bootstrap/cache

# Enable HTTPS
# Configure SSL certificate
# Update APP_URL to use https://
```

---

## 📝 Documentation References

- [Laravel DomPDF Documentation](https://github.com/barryvdh/laravel-dompdf)
- [Flutter Firebase Messaging](https://pub.dev/packages/firebase_messaging)
- [Syncfusion PDF Viewer](https://pub.dev/packages/syncfusion_flutter_pdfviewer)
- [FL Chart Documentation](https://pub.dev/packages/fl_chart)

---

## 🆘 Support & Issues

### Report Issues:
1. Check logs: `storage/logs/laravel.log`
2. Enable debug mode: `APP_DEBUG=true`
3. Check mobile logs: `flutter logs`
4. Use Postman to test API endpoints
5. Verify database connections

### Common Solutions:
- Clear cache: `php artisan cache:clear`
- Rebuild Flutter: `flutter clean && flutter pub get`
- Restart services: `php artisan serve`
- Check database connection

---

## 📅 Timeline

**Installation**: 30 minutes
**Testing**: 2-3 hours
**Bug Fixes**: 1-2 hours
**Deployment**: 1 hour

**Total**: 4-7 hours for full Phase 1 deployment

---

## ✨ Success Criteria

Phase 1 is successfully deployed when:
- [ ] All PDF endpoints return valid PDFs
- [ ] All dashboards show real data
- [ ] Team attendance endpoints work
- [ ] Mobile app loads data correctly
- [ ] Settings/Profile screens functional
- [ ] No critical errors in logs
- [ ] Performance is acceptable
- [ ] All tests pass

---

**Last Updated**: January 21, 2026  
**Status**: Ready for Deployment  
**Next Phase**: Phase 2 - Advanced Features
