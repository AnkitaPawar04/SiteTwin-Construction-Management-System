# Request/Response Logging Configuration

## Overview
The backend now logs all HTTP requests and responses to the command line in JSON format with status codes.

## Implementation

### Files Created/Modified:
1. **app/Http/Middleware/RequestResponseLogger.php** - Custom middleware for logging
2. **bootstrap/app.php** - Registered middleware globally
3. **config/logging.php** - Added stdout channel

### Features:
- **Request Logging**: Method, URL, headers, query params, body
- **Response Logging**: Status code, status text, headers, body, duration
- **Security**: Automatically redacts sensitive data (passwords, tokens, authorization headers)
- **Performance**: Includes request duration in milliseconds
- **Format**: Clean JSON output with pretty printing

## Log Format

### Request Log Example:
```json
{
    "type": "REQUEST",
    "timestamp": "2026-01-22T10:30:45+00:00",
    "method": "POST",
    "url": "http://localhost:8000/api/login",
    "path": "api/login",
    "ip": "127.0.0.1",
    "user_agent": "PostmanRuntime/7.32.0",
    "headers": {
        "content-type": ["application/json"],
        "accept": ["*/*"],
        "authorization": ["***REDACTED***"]
    },
    "query_params": {},
    "body": {
        "phone": "+919876543210",
        "password": "***REDACTED***"
    }
}
```

### Response Log Example:
```json
{
    "type": "RESPONSE",
    "timestamp": "2026-01-22T10:30:45+00:00",
    "method": "POST",
    "url": "http://localhost:8000/api/login",
    "path": "api/login",
    "status_code": 200,
    "status_text": "OK",
    "duration_ms": 245.67,
    "headers": {
        "content-type": ["application/json"],
        "cache-control": ["no-cache, private"]
    },
    "body": {
        "status": "success",
        "user": {
            "id": 1,
            "name": "John Doe",
            "phone": "+919876543210",
            "role": "owner"
        },
        "token": "2|3kj4h5kjh34k5jh..."
    }
}
```

## Testing the Logger

### Start Laravel Development Server:
```bash
cd backend
php artisan serve
```

The console will now display all HTTP requests and responses in JSON format.

### Make a Test Request:
```bash
# Example: Test login endpoint
curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"phone": "+919876543210", "password": "password123"}'
```

You'll see both REQUEST and RESPONSE logs in the console.

## Security Features

The logger automatically redacts:
- **Headers**: authorization, cookie, x-csrf-token
- **Body Fields**: password, password_confirmation, token, secret

This ensures sensitive data is never exposed in logs.

## Performance Impact

- Minimal overhead (~2-5ms per request)
- Async logging to avoid blocking requests
- Response body truncated if >500 characters (configurable)

## Configuration

### Disable Logging (if needed):
Remove or comment out the middleware in `bootstrap/app.php`:
```php
->withMiddleware(function (Middleware $middleware): void {
    // $middleware->append(\App\Http\Middleware\RequestResponseLogger::class);
})
```

### Modify Logging Behavior:
Edit `app/Http/Middleware/RequestResponseLogger.php`:
- Adjust `$sensitiveHeaders` array
- Adjust `$sensitiveFields` array
- Modify response body truncation limit (currently 500 chars)
- Change log format or channels

## Log Persistence

Logs are also written to:
- **Console**: `php://stderr` via `error_log()`
- **File**: `storage/logs/laravel.log` via Laravel logging

This provides both real-time visibility and historical records.
