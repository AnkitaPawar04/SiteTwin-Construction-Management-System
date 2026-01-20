# Laravel Backend Setup Guide

## Complete Setup Instructions

### Step 1: Install Laravel Sanctum

```bash
composer require laravel/sanctum
```

### Step 2: Publish Sanctum Configuration

```bash
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
```

### Step 3: Run Migrations

```bash
php artisan migrate
```

### Step 4: Configure Database

Update your `.env` file with PostgreSQL credentials:

```env
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=construction_app
DB_USERNAME=postgres
DB_PASSWORD=your_password
```

### Step 5: Seed Initial Data (Optional)

Create a database seeder to add initial users and materials:

```bash
php artisan make:seeder InitialDataSeeder
```

Add the following to `database/seeders/InitialDataSeeder.php`:

```php
<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Material;
use Illuminate\Database\Seeder;

class InitialDataSeeder extends Seeder
{
    public function run()
    {
        // Create Owner
        User::create([
            'name' => 'Owner User',
            'phone' => '9999999999',
            'role' => 'owner',
            'language' => 'en',
            'is_active' => true,
        ]);

        // Create Manager
        User::create([
            'name' => 'Manager User',
            'phone' => '9999999998',
            'role' => 'manager',
            'language' => 'en',
            'is_active' => true,
        ]);

        // Create Engineer
        User::create([
            'name' => 'Engineer User',
            'phone' => '9999999997',
            'role' => 'engineer',
            'language' => 'en',
            'is_active' => true,
        ]);

        // Create Worker
        User::create([
            'name' => 'Worker User',
            'phone' => '9999999996',
            'role' => 'worker',
            'language' => 'hi',
            'is_active' => true,
        ]);

        // Create Materials
        $materials = [
            ['name' => 'Cement (OPC 53)', 'unit' => 'bag', 'gst_percentage' => 18],
            ['name' => 'Steel Bars (8mm)', 'unit' => 'kg', 'gst_percentage' => 18],
            ['name' => 'Steel Bars (12mm)', 'unit' => 'kg', 'gst_percentage' => 18],
            ['name' => 'Steel Bars (16mm)', 'unit' => 'kg', 'gst_percentage' => 18],
            ['name' => 'Sand', 'unit' => 'cubic meter', 'gst_percentage' => 5],
            ['name' => 'Aggregate (20mm)', 'unit' => 'cubic meter', 'gst_percentage' => 5],
            ['name' => 'Bricks', 'unit' => 'piece', 'gst_percentage' => 12],
            ['name' => 'Paint', 'unit' => 'liter', 'gst_percentage' => 18],
            ['name' => 'Tiles', 'unit' => 'sq ft', 'gst_percentage' => 18],
            ['name' => 'Electrical Wire', 'unit' => 'meter', 'gst_percentage' => 18],
        ];

        foreach ($materials as $material) {
            Material::create($material);
        }
    }
}
```

Run the seeder:

```bash
php artisan db:seed --class=InitialDataSeeder
```

### Step 6: Update DatabaseSeeder

Update `database/seeders/DatabaseSeeder.php`:

```php
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            InitialDataSeeder::class,
        ]);
    }
}
```

### Step 7: Configure CORS (Optional for Mobile App)

If you need to allow cross-origin requests from a mobile app, update `config/cors.php`:

```php
return [
    'paths' => ['api/*'],
    'allowed_methods' => ['*'],
    'allowed_origins' => ['*'], // Change to specific domains in production
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => false,
];
```

### Step 8: Start the Server

```bash
php artisan serve
```

Your API will be available at: `http://localhost:8000/api`

### Step 9: Test the API

#### Test Login

```bash
curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"9999999999"}'
```

You should receive a response with a token. Copy this token for subsequent requests.

#### Test Protected Endpoint

```bash
curl -X GET http://localhost:8000/api/me \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## Postman Collection

Import the `Construction_API.postman_collection.json` file into Postman for easy API testing.

1. Open Postman
2. Click "Import"
3. Select the JSON file
4. Update the `token` variable after logging in

## API Routes

All API routes are defined in `routes/api.php`. They are automatically prefixed with `/api`.

### Available Endpoints

- **Authentication**: `/api/login`, `/api/logout`, `/api/me`
- **Projects**: `/api/projects`
- **Attendance**: `/api/attendance/*`
- **Tasks**: `/api/tasks`
- **DPR**: `/api/dprs`
- **Materials**: `/api/materials`
- **Material Requests**: `/api/material-requests`
- **Stock**: `/api/stock/*`
- **Invoices**: `/api/invoices`
- **Dashboard**: `/api/dashboard/owner`
- **Notifications**: `/api/notifications`
- **Offline Sync**: `/api/sync/*`

See `API_DOCUMENTATION.md` for complete API documentation with examples.

## Architecture

### Service Layer Pattern

Business logic is separated into service classes:

- `AttendanceService`: Handles check-in/check-out logic
- `DprService`: Manages DPR creation and approval
- `MaterialRequestService`: Handles material request workflow
- `StockService`: Manages inventory transactions
- `InvoiceService`: Generates GST invoices
- `TaskService`: Task assignment and updates
- `DashboardService`: Analytics and reporting
- `OfflineSyncService`: Offline data synchronization

### Policies

Authorization is handled through Laravel Policies:

- `ProjectPolicy`: Project access control
- `TaskPolicy`: Task management permissions
- `DailyProgressReportPolicy`: DPR approvals
- `MaterialRequestPolicy`: Material request approvals
- `AttendancePolicy`: Attendance verification

### Form Requests

Validation is handled through Form Request classes in `app/Http/Requests/`.

### API Resources

Consistent JSON responses are formatted using API Resource classes in `app/Http/Resources/`.

## Common Issues & Solutions

### Issue: "No application encryption key has been set"
**Solution**: Run `php artisan key:generate`

### Issue: Database connection error
**Solution**: Check your `.env` file and ensure PostgreSQL is running

### Issue: "Class 'Laravel\Sanctum\Sanctum' not found"
**Solution**: Run `composer require laravel/sanctum` and `php artisan migrate`

### Issue: 404 on API routes
**Solution**: Run `php artisan route:clear` and check `bootstrap/app.php` has API routes configured

### Issue: Unauthorized on protected routes
**Solution**: Ensure you're passing the token in the Authorization header as `Bearer {token}`

## Production Deployment

### Optimization Commands

```bash
php artisan config:cache
php artisan route:cache
php artisan view:cache
composer install --optimize-autoloader --no-dev
```

### Environment Variables

Ensure these are set in production `.env`:

```env
APP_ENV=production
APP_DEBUG=false
APP_URL=https://your-domain.com

DB_CONNECTION=pgsql
DB_HOST=your-db-host
DB_PORT=5432
DB_DATABASE=your-db-name
DB_USERNAME=your-db-user
DB_PASSWORD=your-secure-password
```

### Queue Configuration (Optional)

For better performance with notifications and background tasks:

```env
QUEUE_CONNECTION=database
```

Run queue worker:

```bash
php artisan queue:work --tries=3
```

## Security Best Practices

1. Always use HTTPS in production
2. Set strong `APP_KEY`
3. Use environment-specific `.env` files
4. Enable rate limiting on sensitive endpoints
5. Regularly update dependencies
6. Use database transactions for critical operations
7. Validate all user inputs
8. Implement proper error logging

## Support & Maintenance

- Check Laravel logs: `storage/logs/laravel.log`
- Clear cache: `php artisan cache:clear`
- Clear config: `php artisan config:clear`
- Run migrations: `php artisan migrate`
- Rollback migration: `php artisan migrate:rollback`

## Testing

Run tests with:

```bash
php artisan test
```

For specific tests:

```bash
php artisan test --filter=ProjectTest
```

## Monitoring & Logging

Laravel logs are stored in `storage/logs/laravel.log`. 

For production, consider integrating:
- Sentry for error tracking
- Laravel Telescope for debugging
- New Relic for performance monitoring

## Next Steps

1. Install Laravel Sanctum: `composer require laravel/sanctum`
2. Run migrations: `php artisan migrate`
3. Seed initial data: `php artisan db:seed`
4. Test API endpoints using Postman collection
5. Integrate with your Flutter mobile app

## Questions?

Refer to:
- `API_DOCUMENTATION.md` for complete API reference
- Laravel Documentation: https://laravel.com/docs
- Laravel Sanctum: https://laravel.com/docs/sanctum
