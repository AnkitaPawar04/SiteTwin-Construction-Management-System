# DPR Photo Storage - Quick Test Guide

## 🎯 What's Been Implemented

The system now stores DPR photos as files and serves them through a secure API endpoint:

```
Photo Upload Flow:
Worker App → Backend API → File Stored (public disk) → DB Record → API Endpoint URL

Photo Display Flow:
Owner App → Fetches DPR List → Gets API Endpoint URLs → Image.network() loads from API
```

## ⚡ Quick Test (5 minutes)

### 1. Start Backend
```powershell
cd d:\Hackathon\quasar-updated\backend
php artisan serve
# Server runs on http://localhost:8000
```

### 2. Verify Configuration
- ✅ Symlink exists: `D:\Hackathon\quasar-updated\backend\public\storage` → `storage/app/public`
- ✅ Storage disk: public (configured in DprService)
- ✅ Full_url model: DprPhoto returns API endpoint URLs
- ✅ Photo endpoint: GET `/api/dprs/{dprId}/photos/{photoId}` 

### 3. Test Submission (Worker)
1. Open mobile app
2. Go to "Submit DPR"
3. Fill form and attach 2 photos
4. Submit
5. ✅ Photos should be stored in `storage/app/public/dprs/project_X/dpr_Y/`

### 4. Test API Response (Postman)
```
GET http://localhost:8000/api/dprs/pending/all
Header: Authorization: Bearer {owner_token}

Response should show:
{
  "photos": [
    {
      "id": 1,
      "photo_url": "dprs/project_1/dpr_5/dpr_5_123456789_abc.jpg",
      "full_url": "http://localhost:8000/api/dprs/5/photos/1"
    }
  ]
}
```

### 5. Test Photo Download (Postman)
```
GET http://localhost:8000/api/dprs/5/photos/1
Header: Authorization: Bearer {owner_token}

Expected: 200 OK + image file
```

### 6. Test Mobile Display (Owner)
1. Open mobile app as owner
2. Go to DPR List
3. Tap submitted DPR
4. Photos should load and display ✅

## 🔧 Troubleshooting

| Issue | Solution |
|-------|----------|
| 403 Forbidden on photo endpoint | Check authorization: Is user authenticated? Do they have access to this DPR? |
| 404 Not Found | Check: File exists in storage? DB record exists? DPR ID and photo ID correct? |
| Photos not displaying in app | Check: API returns `full_url`? Mobile app uses it? Network connection OK? |
| Symlink error | Run: `php artisan storage:link` |
| File not saved | Check: `storage/app/public/` directory exists and is writable? |

## 📁 Storage Structure

```
backend/storage/app/public/
└── dprs/
    ├── project_1/
    │   └── dpr_5/
    │       ├── dpr_5_1672992000_abc123.jpg
    │       └── dpr_5_1672992001_def456.jpg
    └── project_2/
        └── dpr_10/
            └── dpr_10_1673078400_ghi789.jpg
```

## 🎯 Expected API Response Format

```json
{
  "data": {
    "id": 5,
    "status": "submitted",
    "project_id": 1,
    "user_id": 2,
    "photos": [
      {
        "id": 1,
        "dpr_id": 5,
        "photo_url": "dprs/project_1/dpr_5/dpr_5_1672992000_abc123.jpg",
        "full_url": "http://localhost:8000/api/dprs/5/photos/1"
      }
    ]
  }
}
```

## 🔑 Key Files Changed

| File | Change | Purpose |
|------|--------|---------|
| `DprService.php` | Store to 'public' disk | Files HTTP accessible |
| `DprPhoto.php` | Add `full_url` attribute | API returns endpoint URLs |
| `DprController.php` | Add `getPhoto()` method | Serve photos with auth |
| `routes/api.php` | Add photo route | Enable URL generation |
| `dpr_model.dart` | Use `full_url` from API | Mobile loads from endpoint |

## ✅ System is Ready

All components are configured. Ready for:
1. ✅ Submit DPR with photos
2. ✅ Store files in public disk
3. ✅ Return API endpoint URLs
4. ✅ Serve photos via authenticated endpoint
5. ✅ Display photos in mobile app

**Proceed with testing!**
