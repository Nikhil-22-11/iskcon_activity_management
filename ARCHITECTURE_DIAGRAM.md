# ISKCON Activity Management – Architecture Diagram

## Flutter App Architecture

```mermaid
flowchart TD
    A([User]) --> B[LoginScreen]

    B -->|role = guard| C[GuardDashboard]
    B -->|role = teacher| D[TeacherDashboard]
    B -->|role = principal| E[PrincipalDashboard]

    %% Guard flow
    C --> C1[QR Scanner]
    C1 -->|decode JSON payload| C2[Mark Attendance]
    C2 --> C3[Scan History]

    %% Teacher flow
    D --> D1[Upcoming Activities]
    D1 -->|tap activity| D2[Enrolled Students]
    D --> D3[Admission Form]
    D3 -->|submit| D4[Admission Saved]

    %% Principal flow
    E --> E1[Overview / Analytics]
    E --> E2[Students]
    E --> E3[Attendance Trends]
    E --> E4[Finance]
    E --> E5[Reports / Export]

    %% Data layer
    C2 & D1 & D2 & D3 & E1 & E2 & E3 & E4 & E5 --> SVC

    subgraph SVC [Data Layer]
        AS[ApiService]
        MDS[MockDataService]
        AS --> MDS
    end
```

### Key layers

| Layer | Contents |
|---|---|
| **Presentation** | `screens/` – one folder per role; shared `widgets/` |
| **Navigation** | `navigation/` – role-based routing after login |
| **Domain** | `models/` – `User`, `Student`, `Activity`, `Admission`, `AttendanceRecord` |
| **Data** | `services/api_service.dart` → `services/mock_data_service.dart` (in-memory mock; no live DB yet) |
