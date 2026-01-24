# Server URL Configuration Feature

## Overview
Added a dynamic server URL configuration feature to the login screen, allowing users to change the backend server URL without modifying code.

## Implementation

### 1. **Storage Key Added**
- Added `serverUrlKey` to `AppConstants` for storing the custom server URL

### 2. **Preferences Service Updated**
- `setServerUrl(String url)` - Save custom server URL
- `getServerUrl()` - Retrieve saved server URL (returns null if not set)

### 3. **API Client Dynamic URL**
- Updated `ApiClient` to check for custom server URL on every request
- Falls back to `ApiConstants.baseUrl` if no custom URL is set
- Updates base URL dynamically in the request interceptor

### 4. **Login Screen UI**
- Added 3-dot menu (⋮) in the AppBar
- Menu item: "Server Settings"
- Opens a dialog with:
  - Text field to enter custom server URL
  - Display of current URL
  - Display of default URL
  - "Reset to Default" button
  - "Save" button to apply changes

## Usage

### For Users:
1. Open the login screen
2. Tap the 3-dot menu (⋮) in the top-right corner
3. Select "Server Settings"
4. Enter the new server URL (e.g., `http://192.168.1.100:8000/api`)
5. Tap "Save"
6. The app will now use the new URL for all API requests

### To Reset to Default:
1. Open Server Settings dialog
2. Tap "Reset to Default"
3. The default URL from `ApiConstants.baseUrl` will be restored

## Technical Details

**Server URL Priority:**
1. Custom URL from SharedPreferences (if set)
2. Default URL from `ApiConstants.baseUrl`

**Dynamic Updates:**
- URL is checked on every API request
- No app restart required
- Changes take effect immediately

**Default URL:**
- Default: `http://172.16.23.211:8000/api` (from ApiConstants)
- Can be changed via the UI without code modification

## Files Modified

1. `lib/core/constants/app_constants.dart` - Added `serverUrlKey`
2. `lib/core/storage/preferences_service.dart` - Added server URL methods
3. `lib/core/network/api_client.dart` - Dynamic URL loading in interceptor
4. `lib/presentation/screens/auth/login_screen.dart` - Added 3-dot menu and settings dialog

## Benefits

✅ No code changes needed to switch servers  
✅ Easy testing across different environments  
✅ Quick switching between local/staging/production  
✅ User-friendly interface  
✅ Persistent across app restarts  
✅ Shows current and default URLs for reference  

## Example URLs

```
Local Development:    http://localhost:8000/api
Local Network:        http://192.168.1.100:8000/api
Android Emulator:     http://10.0.2.2:8000/api
Production:           https://api.yourdomain.com/api
Staging:              https://staging-api.yourdomain.com/api
```
