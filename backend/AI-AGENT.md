 You are a senior Laravel backend architect.
 Build a **mobile-first, API-only Laravel backend** for a **Construction Field Management Application** used on real construction sites in India.

 I will provide you with a **DBML schema** — you must strictly follow it to generate **Laravel migrations, models, relationships, policies, controllers, services, and APIs**.

 ### **Core Rules**

 * Laravel latest stable version
 * PostgreSQL database
 * API-only (no Blade, no web routes)
 * JSON responses only
 * Mobile-first & offline-sync friendly
 * Secure, scalable, and clean architecture

 ---

 ### **Mandatory Functional Requirements**

 Implement **all** the following features:

 #### 1. Authentication & Roles

 * JWT or Sanctum-based authentication
 * Role-based access control: **Worker, Engineer, Manager, Owner**
 * Laravel Policies & Gates for authorization
 * Project-based access (users only see assigned projects)

 #### 2. Project Management

 * CRUD APIs for projects
 * Assign users to projects
 * Owner assigned to project

 #### 3. Location-Based Attendance

 * Check-in / check-out APIs
 * Capture GPS coordinates
 * Validate attendance against project geo-location
 * Prevent duplicate attendance per day

 #### 4. Daily Progress Reports (DPR)

 * Submit DPR with:

   * Work description
   * GPS coordinates
   * Multiple photos
 * DPR approval workflow (Engineer/Manager)
 * DPR status tracking

 #### 5. Task Management

 * Manager assigns tasks to workers
 * Task status updates: pending → in_progress → completed
 * Worker-side update APIs

 #### 6. Material Requests & Approval

 * Engineers create material requests
 * Managers approve/reject requests
 * Request status history

 #### 7. Stock & Inventory Tracking

 * Maintain real-time stock per project
 * Stock IN/OUT transactions
 * Link transactions to material requests
 * Prevent negative stock

 #### 8. GST-Ready Invoicing

 * Auto-generate invoice from approved work
 * GST calculation per item
 * Store total, GST amount, and invoice status
 * Invoice line items support

 #### 9. Owner Dashboard APIs

 * Project progress summary
 * Financial overview
 * Attendance utilization
 * Material consumption report

 #### 10. Offline Sync Support

 * APIs designed for offline-first mobile apps
 * Sync endpoints for:

   * Attendance
   * DPRs
   * Tasks
   * Material requests
 * Conflict resolution using timestamps
 * Offline sync logs tracking

 #### 11. Notifications

 * Create notifications for:

   * Task assignment
   * DPR approval/rejection
   * Material request approval/rejection

 ---

 ### **Technical Expectations**

 * Generate:

   * Migrations from DBML
   * Eloquent models with relationships
   * API Controllers (RESTful)
   * Service layer for business logic
   * Form Request validation
   * Policies for role-based access
 * Use transactions for stock & invoices
 * Follow clean folder structure
 * Add meaningful API response messages

 ---

 ### **Performance & Optimization**

 * Lightweight JSON payloads
 * Pagination where required
 * Index important foreign keys
 * Optimized for slow networks

 ---

 ### **Output Required**

 * Laravel project structure
 * Migration files
 * Model definitions
 * Controller logic
 * Sample API routes
 * Example request/response JSON

 You must ensure **all business requirements are satisfied**, and the backend is **ready to be consumed by a Flutter offline-first mobile app**.