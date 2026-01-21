# New API Endpoints - Phase 1 Implementation
**Date**: January 21, 2026  
**Total New Endpoints**: 9

---

## Invoice PDF Endpoints

### 1. Generate PDF (Download)
```
GET /api/invoices/{id}/pdf
```
**Description**: Generates and downloads invoice as PDF file

**Request**:
- Parameter: `id` (invoice ID)
- Authentication: Required (Bearer token)

**Response**:
- Content-Type: `application/pdf`
- Binary PDF file

**Example**:
```bash
curl -X GET "https://api.example.com/api/invoices/123/pdf" \
  -H "Authorization: Bearer TOKEN" \
  -o invoice_123.pdf
```

**Error Responses**:
- `404`: Invoice not found
- `422`: PDF generation failed

---

### 2. View PDF (Stream)
```
GET /api/invoices/{id}/view-pdf
```
**Description**: Streams invoice PDF for in-browser viewing

**Request**:
- Parameter: `id` (invoice ID)
- Authentication: Required (Bearer token)

**Response**:
- Content-Type: `application/pdf`
- Inline PDF stream

**Error Responses**:
- `404`: Invoice not found
- `422`: PDF generation failed

---

## Dashboard Endpoints

### 3. Manager Dashboard
```
GET /api/dashboard/manager
```
**Description**: Gets dashboard data for managers/site incharges

**Request**:
- Authentication: Required (Manager role)
- Headers: `Authorization: Bearer TOKEN`

**Response**:
```json
{
  "success": true,
  "data": {
    "projects_count": 5,
    "projects_assigned": [
      {
        "id": 1,
        "name": "Commercial Plaza",
        "location": "Mumbai",
        "start_date": "2025-01-15",
        "end_date": "2025-06-30",
        "progress": 35.50
      }
    ],
    "today_attendance": {
      "present_count": 45,
      "absent_count": 5,
      "total_workers": 50
    },
    "pending_tasks": {
      "total": 12,
      "by_project": {
        "1": 8,
        "2": 4
      }
    },
    "pending_dprs": 3,
    "material_stock_summary": [...]
  }
}
```

**Error Responses**:
- `403`: Unauthorized (not a manager)

---

### 4. Worker Dashboard
```
GET /api/dashboard/worker
```
**Description**: Gets dashboard data for workers/engineers

**Request**:
- Authentication: Required (Worker role)
- Headers: `Authorization: Bearer TOKEN`

**Response**:
```json
{
  "success": true,
  "data": {
    "projects_count": 3,
    "assigned_projects": [
      {
        "id": 1,
        "name": "Commercial Plaza",
        "location": "Mumbai"
      }
    ],
    "today_status": {
      "checked_in": true,
      "checked_out": false,
      "status": "present"
    },
    "assigned_tasks": {
      "total": 8,
      "completed": 2,
      "pending": 3,
      "in_progress": 3,
      "recent_tasks": [...]
    },
    "attendance_history": [
      {
        "date": "2025-01-20",
        "status": "present",
        "check_in_time": "08:00:00",
        "check_out_time": "17:30:00"
      }
    ],
    "weekly_attendance_rate": {
      "present": 5,
      "absent": 1,
      "leave": 0
    }
  }
}
```

**Error Responses**:
- `403`: Unauthorized (not a worker)

---

### 5. Time vs Cost Dashboard
```
GET /api/dashboard/time-vs-cost
```
**Description**: Gets time vs cost analysis for all projects

**Request**:
- Authentication: Required (Owner role)
- Headers: `Authorization: Bearer TOKEN`

**Response**:
```json
{
  "success": true,
  "data": {
    "total_projects": 5,
    "total_planned_days": 150,
    "total_elapsed_days": 45,
    "overall_progress": 30.00,
    "total_budget": 5000000,
    "total_spent": 1500000,
    "total_remaining": 3500000,
    "cost_utilization_rate": 30.00,
    "projects_analysis": [
      {
        "project_id": 1,
        "planned_days": 150,
        "elapsed_days": 45,
        "remaining_days": 105,
        "progress_percentage": 30.00,
        "total_budget": 1000000,
        "spent_amount": 300000,
        "remaining_budget": 700000,
        "estimated_daily_cost": 6666.67,
        "labor_man_days": 225
      }
    ]
  }
}
```

**Error Responses**:
- `403`: Unauthorized (not an owner)

---

## Attendance Endpoints

### 6. Team Attendance Summary
```
GET /api/attendance/project/{projectId}/team-summary?date=2025-01-21
```
**Description**: Gets team attendance summary for a specific date

**Request**:
- Parameter: `projectId` (project ID)
- Query: `date` (optional, defaults to today)
- Authentication: Required (Manager role)

**Response**:
```json
{
  "success": true,
  "data": {
    "date": "2025-01-21",
    "total_workers": 50,
    "present": 45,
    "absent": 3,
    "leave": 2,
    "not_marked": 0,
    "attendance_rate": 94.00,
    "workers": [
      {
        "id": 1,
        "name": "Raj Kumar",
        "email": "raj@example.com",
        "role": "worker",
        "status": "present",
        "check_in_time": "08:00:00",
        "check_out_time": "17:30:00"
      },
      {
        "id": 2,
        "name": "Priya Singh",
        "email": "priya@example.com",
        "role": "worker",
        "status": "absent",
        "check_in_time": null,
        "check_out_time": null
      }
    ]
  }
}
```

**Error Responses**:
- `403`: Unauthorized
- `404`: Project not found
- `422`: Invalid date format

---

### 7. Attendance Trends
```
GET /api/attendance/project/{projectId}/trends?days=30
```
**Description**: Gets attendance trends for a period

**Request**:
- Parameter: `projectId` (project ID)
- Query: `days` (optional, defaults to 30)
- Authentication: Required (Manager role)

**Response**:
```json
{
  "success": true,
  "data": {
    "period_days": 30,
    "total_project_workers": 50,
    "daily_trends": [
      {
        "date": "2025-01-21",
        "total_present": 45,
        "attendance_rate": 90.00
      },
      {
        "date": "2025-01-20",
        "total_present": 48,
        "attendance_rate": 96.00
      }
    ]
  }
}
```

**Error Responses**:
- `403`: Unauthorized
- `404`: Project not found
- `422`: Invalid parameter

---

## Summary Table

| Endpoint | Method | Role Required | Purpose |
|----------|--------|---------------|---------|
| `/api/invoices/{id}/pdf` | GET | Owner | Download invoice PDF |
| `/api/invoices/{id}/view-pdf` | GET | Owner | View invoice PDF |
| `/api/dashboard/manager` | GET | Manager | Manager dashboard |
| `/api/dashboard/worker` | GET | Worker | Worker dashboard |
| `/api/dashboard/time-vs-cost` | GET | Owner | Time vs cost analysis |
| `/api/attendance/project/{id}/team-summary` | GET | Manager | Team attendance summary |
| `/api/attendance/project/{id}/trends` | GET | Manager | Attendance trends |

---

## Common Response Format

All endpoints follow this response structure:

### Success Response:
```json
{
  "success": true,
  "data": { /* endpoint-specific data */ }
}
```

### Error Response:
```json
{
  "success": false,
  "message": "Error description"
}
```

**HTTP Status Codes**:
- `200`: Success
- `201`: Created
- `400`: Bad Request
- `403`: Forbidden (Unauthorized)
- `404`: Not Found
- `422`: Unprocessable Entity
- `500`: Server Error

---

## Authentication

All endpoints (except Login) require Bearer token authentication:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

Token is obtained via:
```
POST /api/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password"
}
```

---

## Rate Limiting (Recommended for Phase 2)

Consider implementing rate limiting:
- 100 requests per minute for general users
- 1000 requests per minute for admin users

---

## Testing

### Using cURL:
```bash
# Get manager dashboard
curl -X GET "https://api.example.com/api/dashboard/manager" \
  -H "Authorization: Bearer TOKEN"

# Download invoice PDF
curl -X GET "https://api.example.com/api/invoices/1/pdf" \
  -H "Authorization: Bearer TOKEN" \
  -o invoice.pdf

# Get team attendance summary
curl -X GET "https://api.example.com/api/attendance/project/1/team-summary?date=2025-01-21" \
  -H "Authorization: Bearer TOKEN"
```

### Using Postman:
1. Create collection "Construction API"
2. Set base URL: `https://api.example.com/api`
3. Create requests for each endpoint
4. Set Bearer token in Authorization tab
5. Export for team use

---

## Frontend Integration

### Mobile (Flutter):
```dart
// Get manager dashboard
final response = await apiClient.get('/dashboard/manager');
final dashboard = response.data['data'];

// Download invoice PDF
final response = await apiClient.get('/invoices/123/pdf');
// Handle binary response
```

### Expected in `ApiClient`:
```dart
final apiClientProvider = Provider((ref) {
  return ApiClient(
    dio: Dio(),
    baseUrl: 'https://api.example.com/api',
  );
});
```

---

**Last Updated**: January 21, 2026  
**Version**: 1.0
