# Geofencing Feature - Quick Start Guide

## For Project Owners/Managers

### Setting Up Geofence for a Project

#### When Creating a New Project:
1. Go to **Add Project** screen
2. Fill in project details (name, location, dates)
3. **Select Location on Map** - Pin the exact project location
4. **Enter Geofence Radius** - Choose how many meters workers must be within:
   - 50-100m: Tight control (office/small site)
   - 150-300m: Typical construction site
   - 500-1000m: Large industrial complex
5. Click **Create Project**

#### When Editing a Project:
1. Go to **Edit Project**
2. Modify **Geofence Radius** if needed
3. Update and save

### Understanding Geofence Settings
- **Minimum Radius**: 10 meters
- **Maximum Radius**: 5000 meters
- **Default**: 100 meters
- **Unit**: Meters from project location

### Benefits
✅ Ensure workers are on-site for attendance  
✅ Prevent fraudulent attendance from remote locations  
✅ Comply with site safety protocols  
✅ Maintain accurate time tracking  

---

## For Workers/Engineers

### Marking Attendance with Geofence

#### Before Check-In:
1. **Enable GPS** - Turn on location services on your phone
2. **Go to Project Site** - Move within the geofence radius
3. Open the **Attendance** screen
4. Select the project

#### Checking In:
1. Click **Check In** button
2. App requests your **current location**
3. System validates:
   - ✅ If within geofence → Check-in succeeds
   - ❌ If outside geofence → Shows error with distance

#### If Outside Geofence:
The app shows:
- "You are outside the geofence area"
- Distance you are from the project
- Allowed radius limit
- Example: "Distance: 250m from project (Allowed radius: 100m)"

**Solution**: Move closer to the project and try again

#### Successful Check-In Message:
"Check-in successful!  
Distance from project: 45m"

### Troubleshooting

#### "Location permission is required"
- Go to **Phone Settings** → **Permissions** → **Location**
- Allow the app to access your location
- Try check-in again

#### "Failed to get location"
- Ensure GPS/Location Services are enabled
- Move to an open area (avoid buildings)
- Wait a few seconds for GPS to lock on
- Try again

#### Still outside geofence?
- Move closer to the project location
- Check you're at the right project site
- GPS accuracy is ±5-10 meters, move a bit closer
- Contact manager if geofence seems incorrect

---

## Geofence Radius Guide

### Recommended Settings by Site Type

| Site Type | Radius | Use Case |
|-----------|--------|----------|
| **Office/Small Site** | 50-100m | Confined workspace |
| **Building Floor** | 75-150m | Multi-story building |
| **Typical Construction** | 150-300m | Small to medium project |
| **Large Construction** | 300-500m | Multi-building complex |
| **Industrial Complex** | 500-1000m | Factory or large facility |
| **Outdoor Site** | 200-400m | Open field/road project |

### GPS Accuracy
- **Typical Accuracy**: ±5-10 meters outdoors
- **Building Interior**: ±20-50 meters (less accurate)
- **Open Area**: ±2-5 meters (most accurate)
- **Cloud/Rain**: Slightly reduced accuracy

### Best Practices
- Set radius **slightly larger** than actual site to account for GPS variation
- For tight control, use 100-150m
- For open sites, use 200-300m
- Test with a worker before final deployment

---

## Sample Geofence Scenarios

### Scenario 1: Small Construction Site (150m × 150m)
- **Geofence Radius**: 150 meters
- **Coverage**: Entire construction site
- **Worker Experience**: Can mark attendance from anywhere on site

### Scenario 2: Multi-Story Building
- **Geofence Radius**: 100 meters
- **Coverage**: Building perimeter
- **Worker Experience**: Must be in/around building to check in

### Scenario 3: Large Factory Complex
- **Geofence Radius**: 500 meters
- **Coverage**: Main facility area
- **Worker Experience**: Can check in from parking, offices, or production area

### Scenario 4: Road Construction Project
- **Geofence Radius**: 200 meters
- **Coverage**: Construction zone and staging areas
- **Worker Experience**: Can check in from work zone or equipment staging

---

## Technical Information

### How It Works
1. **GPS Location**: Phone's GPS provides latitude/longitude
2. **Distance Calculation**: App calculates distance from geofence center
3. **Validation**: Distance compared against allowed radius
4. **Decision**: Check-in approved only if within radius
5. **Recording**: Distance stored in attendance record

### Data Stored
- ✓ Exact GPS coordinates where checked in
- ✓ Distance from geofence center
- ✓ Compliance flag (within/outside)
- ✓ Timestamp of check-in

### Offline Support
- Attendance can be marked offline
- Geofence validation happens when online
- Location data syncs when connection restored

---

## FAQ

**Q: Can I check in indoors?**  
A: GPS may be less accurate indoors (±20-50m). Move to a window or outside for better accuracy.

**Q: What if I'm just outside the geofence?**  
A: Move a few meters closer to the project. GPS accuracy is typically ±5-10m.

**Q: Can the geofence be changed?**  
A: Yes, managers can edit the radius anytime in project settings.

**Q: What if my phone doesn't have GPS?**  
A: GPS is required for attendance. Use a phone with location services.

**Q: Is my location data saved?**  
A: Yes, for attendance records. Data is stored securely on the server.

**Q: Can I spoof my location?**  
A: Don't attempt this - GPS spoofing may be detected and violates policies.

**Q: What happens if I check in then leave?**  
A: The location is recorded at check-in time. Leaving doesn't affect it.

**Q: Multiple projects - which geofence applies?**  
A: Each project has its own geofence. Only the selected project's radius applies.

---

## Support
If you have questions about geofencing:
- Contact your project manager
- Check app settings for permissions
- Verify GPS is enabled
- Move to open area for best GPS signal
