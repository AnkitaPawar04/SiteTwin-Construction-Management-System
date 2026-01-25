 You are a senior **Flutter mobile architect**.
 Build a **single, Android-first Flutter application** for a **Construction Field Management System** used by **field workers, engineers, managers, and owners** on real construction sites in India.

 The app must be **offline-first, low-bandwidth optimized, and role-based**, and it will consume a **Laravel REST API backend**.

 ---

 ### **Core Rules**

 * Flutter (latest stable)
 * Material UI (Material 3)
 * Single app, **role-based UI**
 * Android-first (optimize for low-end devices)
 * API-driven (no mock data)
 * Clean architecture

 ---

 ### **User Personas & Access**

 Implement **role-based navigation and permissions**:

 * **Worker**: Attendance, tasks, DPR submission
 * **Engineer**: DPR review, material requests
 * **Manager**: Task assignment, approvals, stock view
 * **Owner**: Dashboard, financials, reports (read-only)

 ---

 ### **Mandatory Functional Features**

 #### 1. Authentication

 * Login via phone / token
 * Secure token storage
 * Auto-login on app restart

 #### 2. Offline-First Architecture

 * Local database (SQLite / Hive)
 * Cache:

   * Attendance
   * DPRs
   * Tasks
   * Material requests
 * Background sync when internet is available
 * Conflict handling using timestamps

 #### 3. Location-Based Attendance

 * GPS capture on check-in / check-out
 * Prevent multiple check-ins per day
 * Store attendance offline if no network

 #### 4. Daily Progress Reports (DPR)

 * Text input for work done
 * Capture multiple photos via camera
 * Auto-compress images
 * GPS tagging
 * Offline DPR submission

 #### 5. Task Management

 * Task list per user
 * Status buttons: Pending / In Progress / Completed
 * Offline updates

 #### 6. Material Requests

 * Engineer creates material request
 * Quantity & unit selection
 * Offline creation & later sync

 #### 7. Dashboards

 * Owner / Manager dashboard
 * Project progress summary
 * Financial & material overview
 * Lazy loading for slow networks

 #### 8. Multilingual Support

 * Support Hindi, Tamil, Marathi
 * Language switch per user

 #### 9. Low Bandwidth Optimization

 * Minimal API payloads
 * Pagination
 * Deferred image uploads

 #### 10. Notifications

 * In-app notifications for:

   * Task assignment
   * Approvals

 ---

 ### **Technical Expectations**

 * Clean architecture (UI / Domain / Data)
 * Repository pattern
 * State management (Riverpod / Bloc)
 * API service layer
 * Reusable widgets
 * Form validation

 ---

 ### **Required Output**

 * Project folder structure
 * Key screens (login, attendance, tasks, DPR, dashboard)
 * API integration examples
 * Offline sync mechanism
 * Sample UI widgets

 Build the app so it can be **directly used by construction site staff with minimal training**, works **without internet**, and syncs safely with the Laravel backend.