# 📋 DPR Approval Features - Owner/Manager UI Implementation

## ✅ Features Added

### 1. Status Filters for DPR List
- **Filter chips** at the top of the DPR list when viewing as owner/manager
- Filter options:
  - All
  - Submitted
  - Approved
  - Rejected
- Filters are interactive and update the list in real-time

### 2. Inline Approve/Reject Buttons
- **Green "Approve" button** on each submitted DPR
- **Red "Reject" button** on each submitted DPR
- Buttons only appear for submitted DPRs (not for already approved/rejected)
- Buttons only visible to owners and managers

### 3. Quick Approval/Rejection
- **One-click approval**: Tap "Approve" → Confirm → Done
- **Rejection with remarks**: Tap "Reject" → Enter optional reason → Confirm → Done
- Both actions trigger a confirmation dialog to prevent accidents

### 4. Full DPR Review Screen
- Tap on DPR card to open full approval screen
- View all details: photos, work description, date, etc.
- Add detailed remarks when approving/rejecting
- See approval history

---

## 🔧 Code Changes

### File: `mobile/lib/presentation/screens/dpr/dpr_list_screen.dart`

**New Providers:**
```dart
final dprFilterProvider = StateProvider<String>((ref) => 'all');
final dprProjectFilterProvider = StateProvider<int?>((ref) => null);
```

**Updated DprCard:**
- Added `isApprover`, `onApprove`, `onReject` parameters
- Displays action buttons for submitted DPRs
- Buttons only visible when `isApprover == true`

**New Methods:**
- `_buildFilterChip()` - Creates filter chip UI
- `_approveDpr()` - Handles approval flow with confirmation
- `_rejectDpr()` - Handles rejection flow with remarks dialog

### File: `mobile/lib/data/repositories/dpr_repository.dart`

**New Method:**
```dart
Future<void> rejectDpr(int dprId, String remarks) async {
  // Sends rejection request with optional remarks
}
```

---

## 📱 UI/UX Flow

### For Owners/Managers:

```
DPR List Screen
├── Filter Bar (All | Submitted | Approved | Rejected)
├── DPR Card 1 (Submitted)
│   ├── Title, Date, Status
│   ├── Project Name
│   ├── Work Description
│   ├── Photo Count
│   └── Action Buttons
│       ├── ✅ Approve (Green)
│       └── ❌ Reject (Red)
├── DPR Card 2 (Approved)
│   └── (No action buttons - status is final)
└── DPR Card 3 (Submitted)
    └── (Approve/Reject buttons)
```

### Approval Flow:
```
User taps "Approve"
    ↓
Confirmation Dialog
    ↓
User confirms
    ↓
API call: POST /api/dprs/{id}/approve
    ↓
Success SnackBar
    ↓
List refreshes automatically
```

### Rejection Flow:
```
User taps "Reject"
    ↓
Rejection Dialog (with remarks field)
    ↓
User enters remarks (optional)
    ↓
User confirms
    ↓
API call: POST /api/dprs/{id}/approve {status: 'rejected', remarks: '...'}
    ↓
Success SnackBar
    ↓
List refreshes automatically
```

---

## 🎯 Behavior

### For Workers/Engineers:
- See only their own submitted DPRs
- No filters
- No action buttons
- Can tap to view details (read-only)
- Can create new DPRs with FAB button

### For Owners/Managers:
- See all pending DPRs across all projects
- Can filter by status (All, Submitted, Approved, Rejected)
- Can approve submitted DPRs with one click
- Can reject submitted DPRs with optional remarks
- Can view full details by tapping card
- No FAB button for creating DPRs

---

## ✨ Key Features

| Feature | Details |
|---------|---------|
| **Status Filters** | Quick toggle to show specific status DPRs |
| **Inline Actions** | Approve/Reject without opening detail screen |
| **Confirmation Dialogs** | Prevent accidental approval/rejection |
| **Rejection Remarks** | Optional comments for rejected DPRs |
| **Auto-Refresh** | List updates immediately after action |
| **Role-Based UI** | Buttons only for owners/managers |
| **Visual Feedback** | Snackbars confirm success/failure |
| **Status-Based Buttons** | Only show for submitted DPRs |

---

## 🔌 API Endpoints Used

### Approve:
```
POST /api/dprs/{id}/approve
Body: {"status": "approved"}
```

### Reject:
```
POST /api/dprs/{id}/approve
Body: {"status": "rejected", "remarks": "..."}
```

### Get Pending:
```
GET /api/dprs/pending/all
Headers: Authorization: Bearer {token}
```

---

## 📊 Status Flow

```
Draft (Worker)
    ↓ (Submit)
Submitted (Review pending)
    ├─→ Approve → Approved (Final)
    └─→ Reject → Rejected (Final)
```

---

## 🧪 Testing Checklist

- [ ] Login as owner/manager
- [ ] See filter chips (All, Submitted, Approved, Rejected)
- [ ] Click filter chips - list updates correctly
- [ ] See approve/reject buttons on submitted DPRs
- [ ] Click "Approve" - confirmation dialog appears
- [ ] Confirm approval - DPR status changes to "approved"
- [ ] See reject button on submitted DPR
- [ ] Click "Reject" - rejection dialog with remarks field appears
- [ ] Add remarks and reject - DPR status changes to "rejected"
- [ ] Approved/Rejected DPRs don't have action buttons
- [ ] Snackbars show success messages
- [ ] List auto-refreshes after action
- [ ] Tap DPR card to see full approval screen
- [ ] Worker sees no filters or action buttons

---

*Implementation Complete: January 23, 2026*
*All features ready for testing*
