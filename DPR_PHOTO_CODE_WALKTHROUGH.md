# DPR Photo Implementation - Code Walkthrough

## 📝 How Photo Storage Works (Step-by-Step)

### 1️⃣ Mobile App Submits DPR with Photos

**File**: `mobile/lib/data/repositories/dpr_repository.dart`

```dart
// Worker submits DPR with 2 photos
submitDpr(
  projectId: 1,
  workDescription: "Completed foundation work",
  photos: [File('path/to/photo1.jpg'), File('path/to/photo2.jpg')]
)
```

**What happens**:
- Photos converted to `MultipartFile` objects
- FormData created with DPR fields + photo files
- POST request sent to `/api/dprs` with `Content-Type: multipart/form-data`

---

### 2️⃣ Backend Receives DPR Submission

**File**: `backend/app/Http/Controllers/Api/DprController.php`

```php
public function store(StoreDprRequest $request)
{
    // DprService handles file storage and DPR creation
    $dpr = $this->dprService->createDpr(
        $request->project_id,
        $request->work_description,
        $request->report_date,
        $request->photos,  // Array of uploaded files
        $request->latitude,
        $request->longitude
    );
    
    return $this->success($dpr);
}
```

---

### 3️⃣ DprService Stores Photos

**File**: `backend/app/Services/DprService.php`

```php
public function createDpr($projectId, $description, $reportDate, $photos, $latitude, $longitude)
{
    // Create DPR record
    $dpr = DailyProgressReport::create([
        'project_id' => $projectId,
        'user_id' => auth()->id(),
        'work_description' => $description,
        'report_date' => $reportDate,
        'latitude' => $latitude,
        'longitude' => $longitude,
        'status' => 'submitted',
    ]);

    // Process photos
    if (!empty($photos)) {
        foreach ($photos as $photo) {
            // 🔑 KEY: Store in PUBLIC disk (not private)
            // This makes files HTTP accessible
            $path = $photo->store(
                "dprs/project_{$projectId}/dpr_{$dpr->id}",
                'public'  // ← PUBLIC DISK
            );

            // Save to database with relative path
            DprPhoto::create([
                'dpr_id' => $dpr->id,
                'photo_url' => $path,  // e.g., "dprs/project_1/dpr_5/dpr_5_123456.jpg"
            ]);
        }
    }

    return $dpr;
}
```

**Result**:
- Photo file: `storage/app/public/dprs/project_1/dpr_5/dpr_5_1672992000_abc123.jpg`
- Database: `photo_url` = `"dprs/project_1/dpr_5/dpr_5_1672992000_abc123.jpg"`
- Symlink: `public/storage` → `storage/app/public` (created by `php artisan storage:link`)

---

### 4️⃣ DprPhoto Model Adds Full URL

**File**: `backend/app/Models/DprPhoto.php`

```php
class DprPhoto extends Model
{
    protected $appends = ['full_url'];

    public function getFullUrlAttribute()
    {
        // 🔑 KEY: Generate API endpoint URL
        // This allows secure, authenticated photo serving
        return route('api.dprs.photo', [
            'dprId' => $this->dpr_id,
            'photoId' => $this->id
        ]);
    }
}
```

**When API is called**:
```php
$photo = DprPhoto::find(1);
echo $photo->full_url;
// Output: http://localhost:8000/api/dprs/5/photos/1
```

**Why**: This computed attribute is added to API responses automatically because of `$appends`.

---

### 5️⃣ API Endpoint Serves Photos

**File**: `backend/app/Http/Controllers/Api/DprController.php`

```php
public function getPhoto($dprId, $photoId)
{
    // 🔑 KEY: Authorize access
    $dpr = DailyProgressReport::findOrFail($dprId);
    $this->authorize('view', $dpr);  // Only authorized users can see photos

    // Get photo record
    $photo = $dpr->photos()->where('id', $photoId)->firstOrFail();

    // Construct full file path
    $filePath = storage_path('app/public/' . $photo->photo_url);
    
    // Verify file exists
    if (!file_exists($filePath)) {
        return response()->json([
            'success' => false,
            'message' => 'Photo not found'
        ], 404);
    }

    // Serve file
    return response()->file($filePath);
}
```

**Security Layers**:
1. Authentication: User must be logged in
2. Authorization: User must be able to view this DPR
3. File validation: File must exist on disk

---

### 6️⃣ API Route Configuration

**File**: `backend/routes/api.php`

```php
Route::get('/dprs/{dprId}/photos/{photoId}', 
    [DprController::class, 'getPhoto']
)->name('dprs.photo');  // Named route enables route() helper
```

**The Named Route**:
- `route('dprs.photo', ['dprId' => 5, 'photoId' => 1])`
- Generates: `http://localhost:8000/api/dprs/5/photos/1`

---

### 7️⃣ API Response with Full URL

**When getting DPRs**:
```bash
GET /api/dprs/pending/all
Authorization: Bearer {token}
```

**Response**:
```json
{
  "data": [
    {
      "id": 5,
      "status": "submitted",
      "photos": [
        {
          "id": 1,
          "dpr_id": 5,
          "photo_url": "dprs/project_1/dpr_5/dpr_5_1672992000_abc123.jpg",
          "full_url": "http://localhost:8000/api/dprs/5/photos/1"
        },
        {
          "id": 2,
          "dpr_id": 5,
          "photo_url": "dprs/project_1/dpr_5/dpr_5_1672992001_def456.jpg",
          "full_url": "http://localhost:8000/api/dprs/5/photos/2"
        }
      ]
    }
  ]
}
```

---

### 8️⃣ Mobile App Receives and Uses Full URL

**File**: `mobile/lib/data/models/dpr_model.dart`

```dart
factory DprModel.fromJson(Map<String, dynamic> json) {
    final photos = json['photos'] as List<dynamic>?;
    final photoUrls = photos?.map((p) {
        // 🔑 KEY: Use full_url from API
        final fullUrl = p['full_url'] as String?;
        if (fullUrl != null && fullUrl.isNotEmpty) {
            return fullUrl;  // Complete API endpoint URL
        }
        
        // Fallback if needed
        final photoUrl = p['photo_url'] as String?;
        if (photoUrl != null && photoUrl.isNotEmpty) {
            // Construct URL (shouldn't be needed now)
            return '$baseUrl/storage/$photoUrl';
        }
        
        return '';
    }).toList() ?? [];

    return DprModel(
        id: json['id'],
        projectId: json['project_id'],
        photoUrls: photoUrls,  // Complete endpoint URLs
    );
}
```

---

### 9️⃣ Mobile App Displays Photo

**File**: `mobile/lib/presentation/widgets/dpr_card.dart` (or similar)

```dart
Image.network(
    photoUrl,  // e.g., "http://localhost:8000/api/dprs/5/photos/1"
    headers: {
        'Authorization': 'Bearer $token'  // Sent automatically by dio
    }
)
```

**What happens**:
1. Mobile app makes GET request to endpoint with auth token
2. Backend verifies authentication
3. Backend checks authorization (can user view this DPR?)
4. Backend returns image file
5. Image displays in app

---

## 🔄 Complete Data Flow

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. MOBILE APP (Worker)                                          │
│    Selects photos → Creates FormData → POST /api/dprs           │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ 2. BACKEND CONTROLLER (DprController::store)                    │
│    Receives multipart request → Calls DprService::createDpr     │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ 3. DPR SERVICE (DprService::createDpr)                          │
│    ✅ Creates DPR record                                        │
│    ✅ For each photo:                                           │
│       - Stores file in public disk                              │
│       - Creates DprPhoto record with relative path              │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ 4. DATABASE STORAGE                                             │
│    daily_progress_reports table:                                │
│      - id, project_id, user_id, status, ...                    │
│    dpr_photos table:                                            │
│      - id, dpr_id, photo_url (relative path)                   │
│                                                                  │
│    File System:                                                 │
│      storage/app/public/dprs/project_1/dpr_5/dpr_5_*.jpg        │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ 5. API RESPONSE                                                  │
│    GET /api/dprs/pending/all (Owner fetches)                   │
│    DprPhoto model appends 'full_url' attribute                  │
│    Response includes:                                           │
│      - photos[].photo_url: "dprs/project_1/dpr_5/..."           │
│      - photos[].full_url: "http://.../api/dprs/5/photos/1"      │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ 6. MOBILE APP (Owner)                                            │
│    Receives DprModel with photoUrls (full_url values)           │
│    Image.network(photoUrl) makes request to endpoint             │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ 7. BACKEND PHOTO ENDPOINT                                       │
│    GET /api/dprs/{dprId}/photos/{photoId}                      │
│    ✅ Verify authentication (token valid?)                      │
│    ✅ Verify authorization (user can view DPR?)                 │
│    ✅ Check file exists                                         │
│    ✅ Return file: response()->file($filePath)                  │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│ 8. IMAGE DISPLAYED                                              │
│    Mobile app displays image in DPR detail view                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🎯 Key Design Decisions

| Design | Why | Benefit |
|--------|-----|---------|
| Files in **public** disk | Must be served via HTTP | Easier than custom serving |
| **Symlink** public/storage | Exposes storage to web | Natural laravel pattern |
| **API endpoint** for serving | Control access | Auth + authorization checks |
| **Full_url** attribute | Always return complete URL | No URL construction in mobile |
| **Named route** for generation | Consistent URL format | Single source of truth |
| **Policy authorization** | DPR visibility control | Only authorized users see photos |

---

## ✅ Verification Checklist

- [ ] Symlink exists: `public/storage` → `storage/app/public`
- [ ] Storage disk: photos stored in `storage/app/public/dprs/`
- [ ] Database: `dpr_photos` has relative paths
- [ ] DprPhoto model: `$appends = ['full_url']`
- [ ] DprPhoto method: `getFullUrlAttribute()` returns route URL
- [ ] DprController: `getPhoto()` method exists and checks auth
- [ ] API route: `/api/dprs/{dprId}/photos/{photoId}` exists
- [ ] Mobile model: `fromJson()` uses `full_url`
- [ ] API response: includes `full_url` for each photo
- [ ] Image display: loads from full_url endpoint

All checks should be ✅ - system is ready for testing!
