Below is a **clear, role-wise feature matrix** based **exactly on your Flutter prompt and the PS**, showing **what each of the 4 user personas SHOULD have and SHOULD NOT have**.
This helps avoid scope creep and permission mistakes.

---

## 👷 **Worker**

**HAS**

* Login
* View assigned projects
* GPS-based **check-in / check-out**
* View own attendance history
* View assigned tasks
* Update task status (Pending → In Progress → Completed)
* Submit **Daily Progress Report (DPR)**

  * Text work log
  * Photos
  * GPS capture
* Offline save & auto-sync

**DOES NOT HAVE**

* Task assignment
* DPR approval
* Material requests
* Stock visibility
* Approvals
* Financial data
* Owner dashboard

---

## 🧑‍🔧 **Engineer**

**HAS**

* All **Worker** features
* Create **material requests**
* View material request status
* Submit DPRs
* View project-level tasks & DPRs

**DOES NOT HAVE**

* Final approval of material requests
* Stock modification
* Invoice generation
* Financial dashboards
* Owner-level reports

---

## 👨‍💼 **Manager**

**HAS**

* All **Engineer** features
* Assign tasks to workers
* Approve / reject:

  * DPRs
  * Material requests
* View **stock & inventory**
* View attendance summary
* Project progress overview
* In-app notifications for approvals

**DOES NOT HAVE**

* Owner-level financial controls
* Multi-project financial summary
* System configuration access

---

## 🧑‍💼 **Owner**

**HAS**

* Login (read-only)
* View **all projects**
* Single-screen dashboard:

  * Project progress
  * Time vs cost
  * Attendance utilization
  * Material consumption
* View invoices & GST amounts
* Reports & analytics

**DOES NOT HAVE**

* Attendance marking
* Task updates
* DPR submission
* Material requests
* Approvals
* Stock edits

---

## 🧠 Key Design Rule (Very Important)

> **Higher roles can VIEW lower-role data, but cannot DO their actions**

This keeps:

* UX simple
* Data safe
* Permissions clean
* Judges happy 😉

---

## ✅ Summary Table

| Feature          | Worker | Engineer | Manager      | Owner |
| ---------------- | ------ | -------- | ------------ | ----- |
| Attendance       | ✅      | ✅        | ❌            | ❌     |
| Tasks (update)   | ✅      | ✅        | ❌            | ❌     |
| Task assignment  | ❌      | ❌        | ✅            | ❌     |
| DPR submit       | ✅      | ✅        | ❌            | ❌     |
| DPR approve      | ❌      | ❌        | ✅            | ❌     |
| Material request | ❌      | ✅        | ❌            | ❌     |
| Material approve | ❌      | ❌        | ✅            | ❌     |
| Stock view       | ❌      | ❌        | ✅            | ❌     |
| Dashboard        | ❌      | ❌        | ⚠️ (project) | ✅     |
| Financials       | ❌      | ❌        | ❌            | ✅     |