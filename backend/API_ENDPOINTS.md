# API Endpoints Reference

## Base URL
```
http://localhost:8000/api
```

## Authentication Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/login` | Login with phone number | ❌ |
| POST | `/logout` | Logout current session | ✅ |
| GET | `/me` | Get current user profile | ✅ |

---

## Project Endpoints

| Method | Endpoint | Description | Auth Required | Roles |
|--------|----------|-------------|---------------|-------|
| GET | `/projects` | List all projects | ✅ | All |
| POST | `/projects` | Create new project | ✅ | Owner, Manager |
| GET | `/projects/{id}` | Get project details | ✅ | All |
| PUT/PATCH | `/projects/{id}` | Update project | ✅ | Owner, Manager |
| DELETE | `/projects/{id}` | Delete project | ✅ | Owner |
| POST | `/projects/{id}/assign-user` | Assign user to project | ✅ | Owner, Manager |
| DELETE | `/projects/{id}/users/{userId}` | Remove user from project | ✅ | Owner, Manager |

---

## Attendance Endpoints

| Method | Endpoint | Description | Auth Required | Roles |
|--------|----------|-------------|---------------|-------|
| POST | `/attendance/check-in` | Check-in to project | ✅ | All |
| POST | `/attendance/{id}/check-out` | Check-out from project | ✅ | All |
| GET | `/attendance/my` | Get my attendance records | ✅ | All |
| GET | `/attendance/project/{projectId}` | Get project attendance | ✅ | Manager, Engineer, Owner |

---

## Task Endpoints

| Method | Endpoint | Description | Auth Required | Roles |
|--------|----------|-------------|---------------|-------|
| GET | `/tasks` | List tasks | ✅ | All |
| POST | `/tasks` | Create task | ✅ | Manager, Engineer |
| GET | `/tasks/{id}` | Get task details | ✅ | All |
| PUT/PATCH | `/tasks/{id}` | Update task | ✅ | Manager, Engineer, Worker* |
| DELETE | `/tasks/{id}` | Delete task | ✅ | Manager, Engineer |
| PATCH | `/tasks/{id}/status` | Update task status | ✅ | All |

*Workers can only update their own assigned tasks

---

## Daily Progress Report (DPR) Endpoints

| Method | Endpoint | Description | Auth Required | Roles |
|--------|----------|-------------|---------------|-------|
| GET | `/dprs` | List DPRs | ✅ | All |
| POST | `/dprs` | Submit new DPR | ✅ | All |
| GET | `/dprs/{id}` | Get DPR details | ✅ | All |
| POST | `/dprs/{id}/approve` | Approve/Reject DPR | ✅ | Manager, Engineer |
| GET | `/dprs/pending/all` | Get pending DPRs | ✅ | Manager, Engineer |

---

## Material Endpoints

> **🆕 PHASE 2**: Materials now require `gst_type` classification (gst/non_gst)

| Method | Endpoint | Description | Auth Required | Roles |
|--------|----------|-------------|---------------|-------|
| GET | `/materials` | List all materials | ✅ | All |
| POST | `/materials` | Create material (requires gst_type) | ✅ | Manager, Owner |
| GET | `/materials/{id}` | Get material details | ✅ | All |
| PUT/PATCH | `/materials/{id}` | Update material | ✅ | Manager, Owner |

**Material Fields:**
- `name`: Material name
- `unit`: Unit of measurement
- `gst_type`: 'gst' or 'non_gst' (required)
- `gst_percentage`: GST percentage (required if gst_type='gst', auto-set to 0 if non_gst)

---

## Material Request Endpoints

> **⚠️ UPDATED FLOW**: Material requests now follow PENDING → REVIEWED → APPROVED/REJECTED workflow

| Method | Endpoint | Description | Auth Required | Roles |
|--------|----------|-------------|---------------|-------|
| GET | `/material-requests` | List material requests | ✅ | All |
| POST | `/material-requests` | Create material request | ✅ | Engineer, Manager |
| GET | `/material-requests/{id}` | Get request details | ✅ | All |
| POST | `/material-requests/{id}/review` | Mark as reviewed | ✅ | Purchase Manager |
| POST | `/material-requests/{id}/approve` | Approve/Reject request | ✅ | Manager |
| GET | `/material-requests/pending/all` | Get pending requests | ✅ | Manager, Purchase Manager |

---

## Vendor Endpoints

| Method | Endpoint | Description | Auth Required | Roles |
|--------|----------|-------------|---------------|-------|
| GET | `/vendors` | List all vendors | ✅ | Purchase Manager, Manager, Owner |
| POST | `/vendors` | Create vendor | ✅ | Purchase Manager, Manager |
| GET | `/vendors/{id}` | Get vendor details | ✅ | Purchase Manager, Manager, Owner |
| PUT/PATCH | `/vendors/{id}` | Update vendor | ✅ | Purchase Manager, Manager |
| DELETE | `/vendors/{id}` | Delete vendor | ✅ | Purchase Manager |

---

## Purchase Order Endpoints

> **🆕 PHASE 2 RULES**:  
> - **GST/Non-GST Separation**: Cannot mix GST and Non-GST materials in same PO
> - **Auto-Detection**: PO type automatically determined from materials
> - **Invoice Validation**: GST invoices required for GST POs, Non-GST for Non-GST POs

| Method | Endpoint | Description | Auth Required | Roles |
|--------|----------|-------------|---------------|-------|
| GET | `/purchase-orders` | List purchase orders | ✅ | Purchase Manager, Manager, Owner |
| POST | `/purchase-orders` | Create purchase order | ✅ | Purchase Manager |
| GET | `/purchase-orders/{id}` | Get PO details | ✅ | Purchase Manager, Manager, Owner |
| PATCH | `/purchase-orders/{id}/status` | Update PO status | ✅ | Purchase Manager, Manager |
| POST | `/purchase-orders/{id}/invoice` | Upload vendor invoice | ✅ | Purchase Manager |
| DELETE | `/purchase-orders/{id}` | Delete PO (created only) | ✅ | Purchase Manager |

**PO Creation Rules:**
- `type` field removed - auto-detected from materials
- All materials in PO must have same `gst_type`
- GST percentage auto-applied from material master
- Invoice upload requires matching `invoice_type` (gst/non_gst)

---

## Stock/Inventory Endpoints

| Method | Endpoint | Description | Auth Required | Roles |
|--------|----------|-------------|---------------|-------|
| GET | `/stock/project/{projectId}` | Get project stock | ✅ | All |
| GET | `/stock/project/{projectId}/transactions` | Get stock transactions | ✅ | Manager, Engineer, Owner |
| POST | `/stock/add` | Add stock | ✅ | Manager, Owner |
| POST | `/stock/remove` | Remove stock | ✅ | Manager, Owner |

---

## Invoice Endpoints

> **⚠️ DEPRECATED**: Task/DPR-based invoice generation has been disabled. The system now uses Purchase Order-driven procurement with vendor invoices.

| Method | Endpoint | Description | Auth Required | Roles |
|--------|----------|-------------|---------------|-------|
| GET | `/invoices/project/{projectId}` | Get project invoices (legacy) | ✅ | Manager, Owner |
| GET | `/invoices/{id}` | Get invoice details (legacy) | ✅ | Manager, Owner |
| POST | `/invoices/{id}/mark-paid` | Mark invoice as paid (legacy) | ✅ | Manager, Owner |

---

## Dashboard Endpoints

| Method | Endpoint | Description | Auth Required | Roles |
|--------|----------|-------------|---------------|-------|
| GET | `/dashboard/owner` | Get owner dashboard | ✅ | Owner |

---

## Notification Endpoints

| Method | Endpoint | Description | Auth Required | Roles |
|--------|----------|-------------|---------------|-------|
| GET | `/notifications` | Get all notifications | ✅ | All |
| GET | `/notifications/unread` | Get unread notifications | ✅ | All |
| POST | `/notifications/{id}/read` | Mark notification as read | ✅ | All |
| POST | `/notifications/read-all` | Mark all as read | ✅ | All |

---

## Offline Sync Endpoints

| Method | Endpoint | Description | Auth Required | Roles |
|--------|----------|-------------|---------------|-------|
| GET | `/sync/pending` | Get pending sync logs | ✅ | All |
| POST | `/sync/batch` | Sync batch of records | ✅ | All |
| POST | `/sync/{id}/mark-synced` | Mark log as synced | ✅ | All |

---

## Query Parameters

### Common Query Parameters

| Parameter | Endpoints | Description | Example |
|-----------|-----------|-------------|---------|
| `project_id` | tasks, dprs, attendance | Filter by project | `?project_id=1` |
| `start_date` | attendance, dprs | Filter from date | `?start_date=2026-01-01` |
| `end_date` | attendance, dprs | Filter to date | `?end_date=2026-01-31` |
| `material_id` | stock/transactions | Filter by material | `?material_id=1` |

---

## Request Headers

All authenticated endpoints require:

```
Authorization: Bearer {token}
Content-Type: application/json
```

---

## Response Format

### Success Response
```json
{
  "success": true,
  "message": "Operation successful",
  "data": { ... }
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error message",
  "errors": { ... }
}
```

---

## HTTP Status Codes

| Code | Meaning | When Used |
|------|---------|-----------|
| 200 | OK | Successful GET, PUT, PATCH, DELETE |
| 201 | Created | Successful POST |
| 400 | Bad Request | Invalid request format |
| 401 | Unauthorized | Missing or invalid token |
| 403 | Forbidden | No permission for resource |
| 404 | Not Found | Resource doesn't exist |
| 422 | Unprocessable Entity | Validation failed |
| 500 | Server Error | Internal server error |

---

## Pagination

List endpoints support pagination:

```
GET /api/notifications?page=2
```

Response includes:
```json
{
  "data": [...],
  "current_page": 2,
  "last_page": 5,
  "per_page": 20,
  "total": 100
}
```

---

## Rate Limiting

Default Laravel rate limiting applies:
- 60 requests per minute for API endpoints
- Configurable in middleware

---

## CORS

Configure in `config/cors.php` for mobile app integration:
- Allowed origins: Configure your mobile app domains
- Allowed methods: All methods supported
- Credentials: Configured based on needs

---

## Total Endpoints: 68

- Authentication: 3
- Projects: 7
- Attendance: 4
- Tasks: 6
- DPR: 5
- Materials: 4
- Material Requests: 6 (updated with review)
- Vendors: 5 (new)
- Purchase Orders: 6 (new)
- Stock: 4
- Invoices: 3 (deprecated, legacy support)
- Dashboard: 1
- Notifications: 4
- Offline Sync: 3
- Health Check: 1 (Laravel default)

---

For detailed request/response examples, see `API_DOCUMENTATION.md`
