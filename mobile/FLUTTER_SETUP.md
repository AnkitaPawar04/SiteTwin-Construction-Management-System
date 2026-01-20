# Flutter Mobile App - Setup Guide

## ✅ Completed Features

The Construction Manager Flutter app has been successfully created with the following features:

### 📱 Core Features Implemented

1. **Authentication System**
   - Phone-based login with token storage
   - Auto-login on app restart
   - Logout functionality
   - Role detection (Worker, Engineer, Manager, Owner)

2. **Offline-First Architecture**
   - Hive local database for offline storage
   - Attendance, Tasks, and DPRs cached locally
   - Auto-sync when internet connection is restored
   - Network connectivity monitoring

3. **GPS-Based Attendance**
   - Location permission handling
   - GPS-tagged check-in/check-out
   - Prevents duplicate check-ins
   - Calculates working hours
   - Offline attendance recording

4. **Daily Progress Reports (DPR)**
   - Create DPR with work description
   - Multi-photo capture using device camera
   - Automatic image compression (70% quality, max 1024x1024)
   - GPS tagging for each DPR
   - Offline DPR submission
   - View submission history with status

5. **Task Management**
   - View assigned tasks
   - Update task status (Pending → In Progress → Completed)
   - Offline status updates with sync
   - Task grouping by status
   - Project and assignee information

6. **Role-Based Navigation**
   - Worker: Attendance + Tasks + DPR
   - Engineer/Manager: Tasks + DPR + Approvals (drawer)
   - Owner: Dashboard access (drawer)
   - Dynamic bottom navigation based on role

### 🏗️ Technical Implementation

- **State Management**: Riverpod for reactive state
- **API Client**: Dio with interceptors for auth tokens
- **Local Storage**: Hive with TypeAdapters
- **Location**: Geolocator with permission handling
- **Camera**: Image Picker with compression
- **Connectivity**: Real-time network monitoring
- **Clean Architecture**: Data/Domain/Presentation layers

## 🚀 Next Steps

### 1. Install Dependencies

```bash
cd mobile
flutter pub get
```

### 2. Generate Hive Adapters

The `.g.dart` files are already created, but if you modify models, regenerate them:

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 3. Configure Backend URL

Edit `lib/core/constants/api_constants.dart`:

```dart
// For Android Emulator (default)
static const String baseUrl = 'http://10.0.2.2:8000/api';

// For Physical Device - Replace with your PC's IP address
static const String baseUrl = 'http://192.168.1.XXX:8000/api';
```

**To find your PC's IP:**
- Windows: `ipconfig` → Look for IPv4 Address
- Mac/Linux: `ifconfig` → Look for inet address

### 4. Start Laravel Backend

```bash
cd backend
php artisan serve
```

Backend will run on `http://localhost:8000`

### 5. Run Flutter App

```bash
# Check connected devices
flutter devices

# Run on connected device/emulator
flutter run

# Or specify device
flutter run -d <device-id>
```

## 📋 Testing the App

### Test User Logins (from seeded database)

```
Owner:    9876543210
Manager:  9876543211, 9876543212
Engineer: 9876543213, 9876543214, 9876543215
Worker:   9876543220 to 9876543234
```

### Test Flow for Worker

1. **Login** with 9876543220
2. **Check-in** - Allow location permission, tap CHECK IN button
3. **View Tasks** - Navigate to Tasks tab, see assigned tasks
4. **Update Task** - Tap "Start" on a pending task
5. **Create DPR** - Navigate to DPR tab, tap floating + button
   - Add work description (min 20 chars)
   - Allow camera permission
   - Take 2-3 photos
   - Submit DPR
6. **Check-out** - Return to Attendance tab, tap CHECK OUT
7. **Test Offline** - Turn off WiFi/mobile data
   - Submit DPR offline (saves locally)
   - Update task status offline
   - Turn on internet to auto-sync

### Test Flow for Manager

1. **Login** with 9876543211
2. **View Tasks** - See tasks in your projects
3. **View DPRs** - See submitted DPRs
4. **Approvals** (Future): Access from drawer menu

## 🔧 Troubleshooting

### Cannot connect to backend

**Problem**: App shows network error when logging in

**Solutions**:
1. Check Laravel backend is running: `php artisan serve`
2. Verify IP address in `api_constants.dart`
3. For Android emulator: Use `10.0.2.2` not `localhost`
4. For physical device: Use PC's network IP (both on same WiFi)
5. Check Windows Firewall allows port 8000

### Location permission denied

**Problem**: "Location permission is required" message

**Solutions**:
1. Go to device Settings → Apps → Construction Manager
2. Enable Location permission (Allow all the time or While using app)
3. Restart the app

### Camera not working

**Problem**: Cannot capture photos for DPR

**Solutions**:
1. Check camera permissions in app settings
2. Ensure device has a working camera
3. Try granting camera permission manually in settings
4. Restart the app

### Images not uploading

**Problem**: DPR submitted but photos don't sync

**Solutions**:
1. Check internet connection
2. Images auto-compress to 70% quality
3. Check backend `php.ini` settings:
   - `upload_max_filesize = 10M`
   - `post_max_size = 10M`
4. Check Laravel storage permissions

### Build errors

**Problem**: Flutter build fails

**Solutions**:
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

## 📦 Building Release APK

### Android Debug APK (for testing)

```bash
flutter build apk --debug
```

Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Android Release APK (for distribution)

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Install APK on Device

```bash
# Install via ADB
adb install build/app/outputs/flutter-apk/app-release.apk

# Or copy APK to device and install manually
```

## 📊 Project Structure

```
mobile/
├── lib/
│   ├── core/
│   │   ├── constants/          # API & App constants
│   │   ├── network/            # API client, network monitoring
│   │   ├── theme/              # App theme
│   │   └── utils/              # Logger
│   ├── data/
│   │   ├── models/             # Hive models (User, Attendance, Task, DPR)
│   │   └── repositories/       # Data layer with API + local storage
│   ├── providers/              # Riverpod providers
│   ├── presentation/
│   │   └── screens/            # UI screens
│   │       ├── auth/           # Login
│   │       ├── home/           # Home with navigation
│   │       ├── attendance/     # Check-in/out
│   │       ├── tasks/          # Task management
│   │       └── dpr/            # DPR list & create
│   └── main.dart               # App entry point
├── android/                    # Android-specific files
└── pubspec.yaml               # Dependencies
```

## 🎯 Remaining Features (Future)

These features have repository/provider setup but need UI screens:

1. **Material Requests** - Create material request with items
2. **Dashboard Screens** - Owner/Manager analytics dashboards
3. **Multilingual Support** - Hindi, Tamil, Marathi translations
4. **Push Notifications** - Firebase Cloud Messaging
5. **Approval Screens** - DPR and Material Request approvals
6. **Settings Screen** - Language selection, profile edit

## 📝 Notes

- All screens are responsive for different Android screen sizes
- App works seamlessly offline with automatic sync
- Images are auto-compressed for low bandwidth
- GPS coordinates are captured with each attendance and DPR
- Role-based UI ensures users only see relevant features
- Clean architecture makes it easy to add new features

## 🆘 Support

If you encounter any issues:

1. Check this guide first
2. Review error logs: `flutter logs`
3. Check Laravel logs: `backend/storage/logs/laravel.log`
4. Ensure both backend and mobile app have compatible API contracts

## ✨ Success Indicators

Your app is working correctly when:

- ✅ Login with test credentials succeeds
- ✅ Attendance check-in captures GPS location
- ✅ Tasks are fetched and displayed
- ✅ DPR with photos can be submitted
- ✅ Offline mode saves data locally
- ✅ Data syncs automatically when back online
- ✅ Role-based navigation shows appropriate tabs

Happy coding! 🎉
