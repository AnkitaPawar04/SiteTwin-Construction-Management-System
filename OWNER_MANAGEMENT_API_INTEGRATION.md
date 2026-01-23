# Owner Management Features - Backend Integration Guide

## Overview
Two new owner-exclusive management screens have been implemented in the Flutter mobile app:
1. **User Management** - CRUD operations for all users
2. **Team Attendance** - View and filter all employees' attendance records

## API Endpoints Required

### 1. User Management Endpoints

#### Create User
```
POST /api/users
Content-Type: application/json

{
  "name": "John Doe",
  "phone": "+1234567890",
  "email": "john@example.com",
  "password": "securepassword123",
  "role": "engineer"  // owner, manager, engineer, worker
}

Response (201 Created):
{
  "id": 1,
  "name": "John Doe",
  "phone": "+1234567890",
  "email": "john@example.com",
  "role": "engineer",
  "created_at": "2024-01-15T10:30:00Z"
}
```

#### List All Users
```
GET /api/users
Authorization: Bearer {token}

Response (200 OK):
[
  {
    "id": 1,
    "name": "John Doe",
    "phone": "+1234567890",
    "email": "john@example.com",
    "role": "engineer"
  },
  {
    "id": 2,
    "name": "Jane Smith",
    "phone": "+0987654321",
    "email": "jane@example.com",
    "role": "manager"
  }
]
```

#### Get Single User
```
GET /api/users/{id}
Authorization: Bearer {token}

Response (200 OK):
{
  "id": 1,
  "name": "John Doe",
  "phone": "+1234567890",
  "email": "john@example.com",
  "role": "engineer"
}
```

#### Update User
```
PUT /api/users/{id}
Content-Type: application/json
Authorization: Bearer {token}

{
  "name": "John Doe Updated",
  "phone": "+1234567890",
  "email": "john.updated@example.com",
  "role": "manager"
}

Response (200 OK):
{
  "id": 1,
  "name": "John Doe Updated",
  "phone": "+1234567890",
  "email": "john.updated@example.com",
  "role": "manager",
  "updated_at": "2024-01-15T11:45:00Z"
}
```

#### Delete User
```
DELETE /api/users/{id}
Authorization: Bearer {token}

Response (204 No Content)
or
Response (200 OK):
{
  "message": "User deleted successfully"
}
```

### 2. Team Attendance Endpoints

#### Get Filtered Attendance Records
```
GET /api/attendance
Authorization: Bearer {token}
Query Parameters:
  - project_id: (optional) UUID or ID of project
  - date: (optional) Date in YYYY-MM-DD format

Examples:
  GET /api/attendance?project_id=123&date=2024-01-15
  GET /api/attendance?date=2024-01-15
  GET /api/attendance?project_id=123

Response (200 OK):
[
  {
    "id": 1,
    "user_id": 1,
    "user_name": "John Doe",
    "project_id": 101,
    "project_name": "Mall Construction",
    "check_in_time": "09:30:00",
    "check_out_time": "17:45:00",
    "duration": "8h 15m",
    "status": "present",  // present, absent, leave
    "date": "2024-01-15"
  },
  {
    "id": 2,
    "user_id": 2,
    "user_name": "Jane Smith",
    "project_id": 101,
    "project_name": "Mall Construction",
    "check_in_time": null,
    "check_out_time": null,
    "duration": null,
    "status": "absent",
    "date": "2024-01-15"
  },
  {
    "id": 3,
    "user_id": 3,
    "user_name": "Mike Wilson",
    "project_id": 101,
    "project_name": "Mall Construction",
    "check_in_time": "08:00:00",
    "check_out_time": null,
    "duration": null,
    "status": "leave",
    "date": "2024-01-15"
  }
]
```

#### Get All Projects (for filter dropdown)
```
GET /api/projects
Authorization: Bearer {token}

Response (200 OK):
[
  {
    "id": 101,
    "name": "Mall Construction",
    "location": "Downtown",
    "status": "active"
  },
  {
    "id": 102,
    "name": "Office Building",
    "location": "Uptown",
    "status": "active"
  }
]
```

## Frontend Data Models

The app expects data in the following format:

### UserModel
```dart
class UserModel {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String role;  // 'owner', 'manager', 'engineer', 'worker'
  
  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
  });
}
```

### AttendanceModel
```dart
class AttendanceModel {
  final int id;
  final int userId;
  final String userName;
  final int projectId;
  final String projectName;
  final String? checkInTime;  // HH:mm:ss format
  final String? checkOutTime; // HH:mm:ss format
  final String? duration;     // e.g., "8h 15m"
  final String status;        // 'present', 'absent', 'leave'
  final String date;          // YYYY-MM-DD format
  
  AttendanceModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.projectId,
    required this.projectName,
    this.checkInTime,
    this.checkOutTime,
    this.duration,
    required this.status,
    required this.date,
  });
}
```

### ProjectModel
```dart
class ProjectModel {
  final int id;
  final String name;
  final String? location;
  final String status;  // 'active', 'completed', 'paused'
  
  ProjectModel({
    required this.id,
    required this.name,
    this.location,
    required this.status,
  });
}
```

## Integration Checklist

### Backend Tasks:
- [ ] Implement POST /api/users endpoint with validation
- [ ] Implement GET /api/users endpoint
- [ ] Implement GET /api/users/{id} endpoint
- [ ] Implement PUT /api/users/{id} endpoint
- [ ] Implement DELETE /api/users/{id} endpoint
- [ ] Add authorization checks (only owner can manage users)
- [ ] Implement GET /api/attendance with query filters
- [ ] Add pagination to attendance endpoint (recommended for large datasets)
- [ ] Ensure proper error responses (400, 401, 403, 404, 500)
- [ ] Test all endpoints with owner authorization

### Frontend Tasks:
- [ ] Create UserRepository methods for API calls
- [ ] Implement API calls in user management screen
- [ ] Test user creation form
- [ ] Test user editing
- [ ] Test user deletion with confirmation
- [ ] Test attendance filtering by project
- [ ] Test attendance filtering by date
- [ ] Verify role-based access control
- [ ] Run flutter analyze (should show 0 errors)

## Authorization Requirements

All endpoints must verify:
1. User is authenticated (valid bearer token)
2. User role is 'owner' for:
   - POST /api/users (create user)
   - PUT /api/users/{id} (update user)
   - DELETE /api/users/{id} (delete user)
   - GET /api/users (list all users)
   - GET /api/attendance with filters (view team attendance)

## Error Handling

The app expects standard HTTP status codes:

```
200 - Success
201 - Created (POST endpoints)
204 - No Content (DELETE endpoints)
400 - Bad Request (invalid input)
401 - Unauthorized (missing/invalid token)
403 - Forbidden (user lacks permission)
404 - Not Found (resource doesn't exist)
500 - Internal Server Error
```

Error response format:
```json
{
  "message": "Error description",
  "errors": {
    "field_name": ["Error message for this field"]
  }
}
```

## Field Validation

### User Creation:
- name: Required, string, max 255 chars
- phone: Required, string (phone format)
- email: Optional, must be valid email format
- password: Required, min 6 chars
- role: Required, one of: owner, manager, engineer, worker

### Attendance Filtering:
- project_id: Optional, integer, must be valid project
- date: Optional, date format YYYY-MM-DD, must be valid date

## Testing Tips

1. **User Creation**: Try creating users with each role and verify they appear in the list
2. **User Updates**: Edit a user's details and verify changes persist
3. **User Deletion**: Delete a user and confirm they no longer appear
4. **Attendance Filtering**: 
   - Test with no filters (should show all attendance)
   - Test with project filter (should show only that project's attendance)
   - Test with date filter (should show only that date's attendance)
   - Test with both filters (intersection of both)
5. **Edge Cases**:
   - Empty result sets
   - Invalid date formats
   - Non-existent project IDs
   - Users with no attendance records

## Performance Considerations

For large datasets:
1. Implement pagination in attendance endpoint
2. Add indexing on: user_id, project_id, date in attendance table
3. Consider caching project list (doesn't change frequently)
4. Implement lazy loading for user lists if > 100 users

## Security Notes

1. Password should NEVER be returned in API responses
2. Only owners can perform user management operations
3. Users should only see their own attendance (non-owner role)
4. Hash passwords with proper algorithm (bcrypt, Argon2)
5. Implement rate limiting on user creation/update endpoints
6. Audit log all user management actions
