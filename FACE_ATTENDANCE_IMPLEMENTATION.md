# Face-Based Attendance System Implementation

## Overview
Implemented a complete face-based attendance verification system for workers with timer, face detection, and geo-location validation.

## Features Implemented

### 1. Face Camera Screen
**File:** `mobile/lib/presentation/screens/attendance/face_attendance_camera_screen.dart`

- **60-Second Timer**: Countdown displayed prominently, changes to red when < 10 seconds
- **Front Camera**: Automatically selects front-facing camera for selfie
- **Face Detection**: Uses Google ML Kit to detect faces in captured images
- **Face Oval Guide**: Visual guide overlay to help users align their face
- **Auto-timeout**: Screen closes automatically with error message when timer expires
- **Error Handling**: Shows dialog if no face detected in photo
- **Geo-location**: Captures current location before marking attendance
- **UI Elements**:
  - Camera preview
  - Timer display with color warning
  - Capture button (enabled after camera initialized)
  - Cancel button
  - Face oval guide overlay

### 2. Mobile Repository Methods
**File:** `mobile/lib/data/repositories/attendance_repository.dart`

Added two new methods:
- `checkInWithFace()`: Upload face image with check-in data
- `checkOutWithFace()`: Upload face image with check-out data

Both methods:
- Use FormData multipart upload
- Send face_image, latitude, longitude, timestamp
- Call respective backend API endpoints

### 3. Attendance Screen Integration
**File:** `mobile/lib/presentation/screens/attendance/attendance_screen.dart`

Modified:
- `_handleCheckIn()`: Now navigates to FaceAttendanceCameraScreen instead of direct API call
- `_handleCheckOut()`: Now navigates to FaceAttendanceCameraScreen for checkout verification
- Kept legacy methods for reference (renamed to `_handleCheckInLegacy`, `_handleCheckOutLegacy`)

### 4. Backend API Endpoints
**File:** `backend/app/Http/Controllers/Api/AttendanceController.php`

Added two new methods:
- `checkInWithFace()`: 
  - Validates face_image upload (JPEG/PNG/JPG, max 5MB)
  - Stores image in `storage/attendance/faces/`
  - Creates attendance record with face_image_path
  - Returns success with attendance data

- `checkOutWithFace()`:
  - Validates face_image upload
  - Finds today's attendance record
  - Stores checkout face image
  - Updates attendance with checkout time and location
  - Returns success with updated attendance data

### 5. Backend Routes
**File:** `backend/routes/api.php`

Added routes:
```php
Route::post('/attendance/check-in-face', [AttendanceController::class, 'checkInWithFace']);
Route::post('/attendance/check-out-face', [AttendanceController::class, 'checkOutWithFace']);
```

### 6. Backend Service Updates
**File:** `backend/app/Services/AttendanceService.php`

Modified `checkIn()` method:
- Added optional `$faceImagePath` parameter
- Stores face_image_path in attendance record when provided
- Maintains backward compatibility with non-face attendance

### 7. Database Schema
**File:** `backend/app/Models/Attendance.php`

Added to fillable fields:
- `face_image_path`: Stores path to the face image

**Migration:** `backend/database/migrations/2026_01_25_000001_add_face_fields_to_attendance_table.php`
- Adds `face_image_path` column (nullable string)

### 8. Mobile Dependencies
**File:** `mobile/pubspec.yaml`

Added packages:
- `camera: ^0.10.5+5`: Camera access and image capture
- `google_mlkit_face_detection: ^0.10.0`: ML-based face detection

### 9. Platform Permissions

**Android:** `mobile/android/app/src/main/AndroidManifest.xml`
- Already had camera permission

**iOS:** `mobile/ios/Runner/Info.plist`
- Added `NSCameraUsageDescription`: "This app requires camera access to capture your photo for attendance verification."
- Added `NSLocationWhenInUseUsageDescription`: "This app requires location access to verify your attendance at the project site."

## Workflow

### Check-In Flow:
1. Worker selects project on attendance screen
2. Taps "Check In" button
3. Face camera screen opens with 60-second timer
4. Worker positions face within guide oval
5. Taps capture button
6. System detects face using ML Kit
7. If face found: Gets geo-location, uploads face image + coordinates
8. Backend validates and creates attendance record
9. Success message shown, returns to attendance screen

### Check-Out Flow:
1. Worker taps "Check Out" button
2. Face camera screen opens (same as check-in)
3. Worker captures selfie with face detection
4. System validates face and location
5. Backend finds today's attendance record and updates checkout time
6. Success message shown

### Error Scenarios:
- **No Face Detected**: Dialog shows "Face not found. Please capture a clear selfie."
- **Timeout**: Screen closes with error message "Time's up! Attendance not recorded."
- **No Check-in**: Checkout fails with "No check-in found for today"
- **Outside Geofence**: Validates location against project geofence (existing feature)

## Technical Details

### Face Detection Configuration:
```dart
FaceDetectorOptions(
  performanceMode: FaceDetectorMode.accurate,
  minFaceSize: 0.15,
)
```

### Camera Configuration:
- Front camera selected by default
- ResolutionPreset.medium for optimal balance
- Audio disabled

### File Storage:
- Backend stores images in: `storage/app/public/attendance/faces/`
- Filename format: `face_{userId}_{timestamp}.{ext}`
- Max file size: 5MB

### Security:
- All endpoints protected by Sanctum authentication
- Validates user permissions (workers and engineers only)
- Validates project assignment
- Geofence validation before marking attendance

## Testing Checklist

- [ ] Camera opens with front camera
- [ ] Timer counts down from 60 seconds
- [ ] Timer turns red at 10 seconds
- [ ] Capture button works after camera initializes
- [ ] Face detection identifies faces correctly
- [ ] Error shown when no face detected
- [ ] Timeout closes screen after 60 seconds
- [ ] Location captured correctly
- [ ] Face image uploaded to backend
- [ ] Check-in creates attendance record
- [ ] Check-out updates existing record
- [ ] Error handling for no check-in found
- [ ] Permissions requested on first use

## Future Enhancements

1. **Face Recognition**: Store face encodings and verify the same person checks in/out
2. **Multiple Attempts**: Allow 2-3 attempts if face not detected
3. **Image Quality Check**: Validate image brightness, blur, etc.
4. **Offline Support**: Queue face images for upload when connection restored
5. **Admin Dashboard**: View face images in attendance reports
6. **Face Comparison**: Compare check-in and check-out faces for verification

## Files Modified/Created

### Mobile (Flutter):
- `mobile/pubspec.yaml` - Added dependencies
- `mobile/lib/presentation/screens/attendance/face_attendance_camera_screen.dart` - NEW (420 lines)
- `mobile/lib/data/repositories/attendance_repository.dart` - Added face methods
- `mobile/lib/presentation/screens/attendance/attendance_screen.dart` - Updated flow
- `mobile/ios/Runner/Info.plist` - Added camera permission

### Backend (Laravel):
- `backend/app/Http/Controllers/Api/AttendanceController.php` - Added face endpoints
- `backend/routes/api.php` - Added face routes
- `backend/app/Services/AttendanceService.php` - Added face support
- `backend/app/Models/Attendance.php` - Added face_image_path field
- `backend/database/migrations/2026_01_25_000001_add_face_fields_to_attendance_table.php` - NEW

## Notes

- Migration already run successfully
- Flutter dependencies installed
- Android permission already existed
- iOS permission added
- System ready for testing
- Legacy methods preserved for reference
