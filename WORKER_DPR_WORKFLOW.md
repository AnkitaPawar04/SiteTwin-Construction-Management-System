# Worker DPR Submission Workflow - Fixed

## Issues Fixed

### 1. ✅ Task Click Now Works
- **Before**: Clicking on task card did nothing for workers
- **After**: Clicking on an "In Progress" task navigates directly to DPR creation with that task pre-selected

### 2. ✅ Task Selection in DPR Creation
- **Before**: No option to select task when creating DPR
- **After**: Task dropdown is now the primary field, showing only in-progress tasks

### 3. ✅ Removed Manual Billing Fields
- **Before**: Workers could see/enter billing amount and GST percentage
- **After**: Billing is automatically inherited from the task configuration (set by manager)

---

## Testing Workflow for Workers

### Step 1: Login as Worker
```
Email: worker@example.com
Password: password
```

### Step 2: View Your Tasks
1. Go to **Tasks** tab
2. You'll see tasks grouped by status:
   - **In Progress** (tasks you've started)
   - **Pending** (tasks assigned but not started)
   - **Completed**

### Step 3: Start a Task (if pending)
1. Find a **Pending** task
2. Click the **"Start"** button
3. Task status changes to **"In Progress"**

### Step 4: Submit DPR - Method 1 (Direct from Task)
1. Click anywhere on an **"In Progress"** task card
2. Automatically navigates to DPR creation
3. Task is pre-selected
4. Fill in:
   - ✅ **Task**: Pre-selected (the one you clicked)
   - ✅ **Project**: Auto-filled from task
   - ✅ **Work Description**: Describe what you did (min 20 characters)
   - ✅ **Photos**: Take at least one photo
5. Click **"SUBMIT DPR"**

### Step 5: Submit DPR - Method 2 (From DPR Tab)
1. Go to **DPR** tab
2. Click **"New DPR"** button
3. Select from dropdown:
   - **Task**: Choose which in-progress task this report is for
   - **Project**: Automatically set when you select a task
4. Fill in work description and photos
5. Submit

---

## What You Should See

### In Task Selection Dropdown
Only tasks with status = **"In Progress"** will appear, showing:
- Task title
- Project name (below title)

### If Task Has Billing Enabled
You'll see a blue info box:
```
🧾 Auto-billing enabled
₹15,000.00 + 18% GST
```

This means when a manager approves your DPR, an invoice will be automatically generated with:
- Taxable Amount: ₹15,000
- GST (18%): ₹2,700
- **Total: ₹17,700**

### If No In-Progress Tasks
You'll see an orange warning:
```
⚠️ No in-progress tasks available
Start a task first to submit a DPR
```

---

## Click Behavior Summary

| Task Status | Click Action |
|-------------|-------------|
| **Pending** | Shows message: "Start the task first to submit a DPR" |
| **In Progress** | Navigates to DPR creation with task pre-selected |
| **Completed** | No action (task is done) |

---

## Backend Auto-Processing

When manager approves your DPR:
1. DPR status → `approved`
2. If task has billing configured:
   - **Invoice automatically created**
   - Line item: Task title
   - Amount: Task billing_amount
   - GST: Task gst_percentage
   - Links: `task_id` and `dpr_id` for audit trail

---

## Key Changes Made

### DprCreateScreen
- Added `preSelectedTaskId` parameter
- Added task selection dropdown (primary field)
- Removed manual billing input fields
- Auto-fills project from selected task
- Shows billing info badge when task has billing

### TaskScreen (TaskCard)
- Added `InkWell` wrapper for tap detection
- Workers can tap in-progress tasks
- Navigates to DPR with task pre-selected
- Shows helpful message for pending tasks

### Data Flow
```
Manager Creates Task → Sets billing_amount & gst_percentage
       ↓
Worker Starts Task → Status: in-progress
       ↓
Worker Clicks Task → Navigate to DPR
       ↓
Worker Submits DPR → Links to task_id
       ↓
Manager Approves → Auto-invoice generated
```

---

## Testing Checklist

- [ ] Login as worker
- [ ] View tasks in Tasks tab
- [ ] Start a pending task
- [ ] Click on in-progress task card
- [ ] Verify DPR screen opens with task pre-selected
- [ ] Verify project auto-filled
- [ ] Verify no manual billing fields
- [ ] If task has billing, verify blue info badge shows
- [ ] Fill work description (20+ chars)
- [ ] Add at least one photo
- [ ] Submit DPR
- [ ] Verify success message
- [ ] Try creating new DPR from DPR tab
- [ ] Verify task dropdown shows only in-progress tasks
- [ ] Try clicking pending task → verify warning message

---

## Notes

- **Workers can ONLY submit DPRs for in-progress tasks**
- **Billing is NEVER manually entered by workers**
- **All billing comes from task configuration**
- **Project is automatically determined by task**
- **Multiple DPRs can be submitted for the same task** (daily progress)
