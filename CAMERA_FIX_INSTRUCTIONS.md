# Camera Initialization Fix

## Changes Made

### 1. Android Build Configuration
**File:** `mobile/android/app/build.gradle.kts`
- Set explicit `minSdk = 21` (required for camera plugin)
- This ensures camera APIs are available

### 2. Camera Initialization Improvements
**File:** `mobile/lib/presentation/screens/attendance/face_attendance_camera_screen.dart`
- Added explicit camera permission request using `permission_handler`
- Added better error handling with descriptive messages
- Timer now starts only AFTER camera initializes successfully
- Added check for camera availability before initialization
- Improved error messages for troubleshooting

### 3. Error Handling
- Shows clear error message if camera permission denied
- Shows error if no cameras available on device
- Auto-closes screen after showing error (2 seconds delay)
- Prevents timer from starting if camera fails to initialize

## To Test the Fix

### Step 1: Rebuild the App
Run these commands in the mobile directory:

```bash
cd mobile
flutter clean
flutter pub get
flutter build apk --debug
# OR for direct installation:
flutter run
```

### Step 2: Grant Permissions
When the app opens the camera screen for the first time:
1. Android will prompt for camera permission
2. Tap "Allow" or "While using the app"
3. Camera should initialize and show preview

### Step 3: Test Attendance Flow
1. Login as a worker
2. Select a project
3. Tap "Check In"
4. Camera should open with timer
5. Take selfie within 60 seconds
6. Face detection should validate
7. Attendance marked successfully

## Troubleshooting

### If Camera Still Doesn't Work:

#### Option 1: Check Android Settings
1. Go to device Settings
2. Apps → SiteTwin → Permissions
3. Enable Camera permission manually
4. Restart the app

#### Option 2: Uninstall & Reinstall
```bash
flutter clean
flutter run
```
This ensures fresh build with all configurations

#### Option 3: Check Device Camera
- Test if device camera works in other apps
- Some emulators don't have camera support
- Try on a physical device

#### Option 4: Enable Developer Mode (if needed)
```bash
start ms-settings:developers
```
Enable "Developer Mode" in Windows Settings

### Common Errors & Solutions

| Error | Solution |
|-------|----------|
| `channel-error` | Rebuild app after `flutter clean` |
| `Permission denied` | Grant camera permission in app settings |
| `No cameras available` | Test on physical device or emulator with camera |
| `minSdk version` | Already fixed (set to 21) |

## Technical Details

### Minimum SDK Version
- **Before:** `flutter.minSdkVersion` (variable, could be < 21)
- **After:** `21` (explicit, required for camera plugin)

### Permission Flow
1. App requests camera permission via `permission_handler`
2. If denied → Show error & close screen
3. If granted → Initialize camera with proper error handling
4. Start timer only after successful initialization

### Camera Plugin Requirements
- Android: minSdk 21+, camera permission
- iOS: NSCameraUsageDescription in Info.plist (already added)
- Physical camera or emulator with camera support

## Files Modified

1. `mobile/android/app/build.gradle.kts` - Set minSdk to 21
2. `mobile/lib/presentation/screens/attendance/face_attendance_camera_screen.dart` - Improved initialization
3. `mobile/ios/Runner/Info.plist` - Already had camera permission description

## Next Steps

After rebuilding the app:
1. ✅ Camera should initialize properly
2. ✅ Permission prompt should appear on first use
3. ✅ Timer starts only after camera is ready
4. ✅ Clear error messages if something goes wrong
5. ✅ Face detection works after successful capture

## Notes

- The error was caused by camera plugin unable to communicate with Android native code
- Setting explicit minSdk ensures compatibility
- Permission handler provides better control over permission flow
- Timer starting before camera initialization could cause race conditions (now fixed)
