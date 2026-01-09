## FSTrack-Tractor: Flow & Feature Specification

### **1. WORKFLOW PROCESS**

```
┌─────────────┐
│   PLANNING  │
└─────────────┘
    │
    ├─► [Kasie PG] Membuat rencana kerja
    │       │
    │       ▼
    ├─► [Kasie FE] Menugaskan rencana kerja ke Operator
    │
    ▼
┌─────────────┐
│   ACTION    │
└─────────────┘
    │
    ├─► [Operator] Menerima notifikasi assignment
    │       │
    │       ▼
    ├─► [Operator] Memulai operasi subsoil (GPS tracking aktif)
    │       │
    │       ▼
    ├─► [Operator] Melaporkan hasil kerja
    │
    ▼
┌─────────────┐
│  APPROVAL   │
└─────────────┘
    │
    ├─► [Kasie PG] Cek data laporan hasil kerja
    │       │
    │       ▼
    ├─► [Kasie FE] Cek data laporan hasil kerja
    │       │
    │       ▼
    ├─► [Admin] Cek laporan hasil kerja
    │       │
    │       ▼
    ├─► [Kasie PG/FE] Approval hasil kerja
    │       │
    │       ▼
    └─► [PG/FE] Take action → END
```

---

### **2. ROLE-BASED ACCESS CONTROL (RBAC)**

#### **Role Definitions:**
```
1. Kasie PG     → Plantation Manager (creator)
2. Kasie FE     → Field Executive Manager (assigner)
3. Operator     → Tractor operator (executor)
4. Mandor       → Supervisor (viewer)
5. Estate PG    → Estate manager (dashboard viewer)
6. Admin        → System administrator (approver)
```

#### **Permission Matrix:**

| Feature | Kasie PG | Kasie FE | Operator | Mandor | Estate PG | Platform |
|---------|----------|----------|----------|--------|-----------|----------|
| **Work Plan** (Create) | ✅ | ❌ | ❌ | ❌ | ❌ | Mobile |
| **Work Plan** (Assign) | ❌ | ✅ | ❌ | ❌ | ❌ | Mobile |
| **Work Plan** (View) | ✅ | ✅ | ✅ | ✅ | ✅ | Both |
| **Live Tracking** | ✅ | ✅ | ✅ | ✅ | ✅ | Both |
| **Activity Result** (Submit) | ❌ | ❌ | ✅ | ❌ | ❌ | Mobile |
| **Activity Result** (View) | ✅ | ✅ | ✅ | ✅ | ✅ | Both |
| **Activity Report** | ✅ | ✅ | ✅ | ❌ | ❌ | Mobile |
| **Check Location** | ✅ | ❌ | ❌ | ❌ | ❌ | Mobile |
| **Operator and Unit** (Manage) | ✅ | ❌ | ❌ | ❌ | ❌ | Mobile |
| **Dashboard** (Analytics) | ❌ | ✅ | ❌ | ✅ | ✅ | Web |
| **Approval** (Final) | ❌ | ❌ | ❌ | ❌ | ❌ | Admin only |

---

### **3. FEATURE SPECIFICATIONS**

#### **A. Work Plan**
```
CRUD Operations:
├─ CREATE  → Kasie PG only
├─ ASSIGN  → Kasie FE only (add operator to plan)
├─ READ    → All roles
└─ UPDATE  → Creator only (before assignment)

Data Fields:
- plan_id
- estate_id
- date
- area_code
- task_type (subsoil operation)
- estimated_duration
- created_by (kasie_pg_id)
- status (draft/assigned/in_progress/completed)
```

#### **B. Live Tracking**
```
Features:
├─ Real-time GPS location
├─ Operator movement history
├─ Unit location tracking
└─ Map view (Google Maps)

Data Points:
- operator_id
- unit_id
- latitude
- longitude
- timestamp
- speed (optional)
- heading (optional)

Update Frequency: 30 seconds (configurable)
```

#### **C. Activity Result**
```
Submission Form (Operator):
├─ Work plan reference
├─ Start time
├─ End time
├─ Area covered
├─ Notes/remarks
├─ Photo evidence (optional)
└─ Submit button → triggers notification

Verification View (Kasie PG/FE):
├─ View submitted data
├─ Check GPS track
├─ Approve/Reject
└─ Add comments
```

#### **D. Check Location**
```
Features (Kasie PG only):
├─ Real-time operator position
├─ Unit location
├─ Distance calculation
└─ Filter by estate/area
```

#### **E. Operator and Unit Management**
```
Manage (Kasie PG only):
├─ Add/remove operators
├─ Assign unit to operator
├─ View operator status
└─ View unit status
```

#### **F. Dashboard (Web Only)**
```
Analytics:
├─ Work plan statistics
├─ Completion rate
├─ Operator utilization
├─ Area coverage map
├─ Daily/weekly reports
└─ Export functionality
```

#### **G. Notification System**
```
Trigger Events:
├─ Work plan assigned → notify Operator
├─ Activity submitted → notify Kasie PG/FE
├─ Approval needed → notify Admin
├─ Approval done → notify all stakeholders
└─ System alerts (offline, battery low)
```

---

### **4. STATE MACHINE (Work Plan Lifecycle)**

```
[DRAFT]
   │
   ├─ Kasie PG creates work plan
   │
   ▼
[ASSIGNED]
   │
   ├─ Kasie FE assigns to Operator
   ├─ Operator receives notification
   │
   ▼
[IN_PROGRESS]
   │
   ├─ Operator starts operation
   ├─ GPS tracking active
   │
   ▼
[SUBMITTED]
   │
   ├─ Operator submits result
   ├─ Kasie PG/FE verifies
   │
   ▼
[PENDING_APPROVAL]
   │
   ├─ Admin reviews
   │
   ▼
[APPROVED] ───► [COMPLETED]
   │
   └─ [REJECTED] ───► [IN_PROGRESS] (re-work)
```

---

### **5. API ENDPOINT MAPPING**

```
AUTH:
POST   /auth/login
POST   /auth/logout
GET    /auth/me

WORK PLAN:
POST   /work-plans              (Kasie PG)
GET    /work-plans              (All roles, filtered by permission)
GET    /work-plans/:id          
PATCH  /work-plans/:id/assign   (Kasie FE)
PATCH  /work-plans/:id/status   

OPERATOR:
GET    /operators               (Kasie PG, Kasie FE)
GET    /operators/:id/location  (Real-time)
POST   /operators               (Kasie PG)

UNIT:
GET    /units
GET    /units/:id/location

ACTIVITY:
POST   /activities              (Operator submit result)
GET    /activities              (View results)
PATCH  /activities/:id/approve  (Kasie PG/FE)

TRACKING:
WS     /tracking/live           (WebSocket for real-time GPS)
POST   /tracking/location       (Operator sends GPS data)
GET    /tracking/history/:id

DASHBOARD:
GET    /dashboard/stats
GET    /dashboard/reports

NOTIFICATION:
GET    /notifications
PATCH  /notifications/:id/read
```

---

### **6. DATABASE RELATIONSHIPS**

```
users
  └─── has_one → role (kasie_pg, kasie_fe, operator, mandor, admin)
  └─── belongs_to → estate

work_plans
  └─── belongs_to → user (creator: kasie_pg)
  └─── belongs_to → estate
  └─── has_many → assignments

assignments
  └─── belongs_to → work_plan
  └─── belongs_to → operator
  └─── belongs_to → unit
  └─── has_many → activity_results

operators
  └─── belongs_to → user
  └─── has_one → unit
  └─── has_many → locations

units
  └─── belongs_to → estate
  └─── has_one → operator

locations (GPS tracking)
  └─── belongs_to → operator
  └─── belongs_to → unit
  └─── indexed_by → timestamp

activity_results
  └─── belongs_to → assignment
  └─── belongs_to → operator
  └─── has_many → approvals

approvals
  └─── belongs_to → activity_result
  └─── belongs_to → approver (user)

notifications
  └─── belongs_to → user
```

---

### **7. CRITICAL TECHNICAL DECISIONS**

```
1. GPS Tracking Strategy:
   ├─ Foreground service (when operator "starts operation")
   ├─ Background service (optional, battery concern)
   ├─ Update interval: 30s
   └─ Offline queue + sync when reconnected

2. Real-time Communication:
   ├─ WebSocket (Socket.io) for live tracking
   ├─ HTTP POST for bulk location updates
   └─ FCM for notifications

3. State Management (Flutter):
   ├─ Riverpod (recommended) atau Bloc
   ├─ Centralized state for GPS tracking
   └─ Cached data for offline mode

4. Map Integration:
   ├─ Google Maps Flutter
   ├─ Custom markers for operators/units
   └─ Polyline for movement history

5. Authentication:
   ├─ JWT tokens (access + refresh)
   ├─ Role stored in JWT payload
   └─ Permission check: middleware + route guards
```

