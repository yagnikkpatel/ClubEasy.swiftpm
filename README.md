## ClubEasy – Swift Coding Club Manager

ClubEasy is a modern iOS app for managing a university Swift / coding club. It helps faculty advisors and student leaders track members, monitor project progress, manage attendance, and generate professional reports for the university.

---

### Features at a Glance

- **Beautiful onboarding**: Clearly explains what the app does and how it helps your club.
- **Member management**: Keep a structured list of students with levels, contact details, and academic info.
- **Attendance tracking**: Create attendance sessions by date and monitor each student’s attendance rate.
- **Project tracking**: Organize student projects, see status at a glance, and track overall club progress.
- **Dashboard overview**: Visual project and attendance summaries for quick status checks.
- **Configurable settings**: Customize club metadata, email sender details, recipient lists, and default report messages.
- **Professional reports**: Generate export-ready attendance reports (PDF / Excel) for institutional use.
- **Email exports**: Send polished attendance reports directly via email.

---

## App Walkthrough

### 1. Onboarding Flow

The app opens with a three-step onboarding that introduces the main value of ClubEasy.

<p align="center">
<img src="images/Simulator Screenshot - iPhone 17 Pro - 2026-03-13 at 22.47.52.png" alt="Swift Coding Club intro" width="320" />
</p>

- **Swift Coding Club**: Presents the app as *“The professional management dashboard for your university's developer community.”*

<p align="center">
<img src="images/Simulator Screenshot - iPhone 17 Pro - 2026-03-13 at 22.47.55.png" alt="Professional Reports onboarding" width="320" />
</p>

- **Professional Reports**: Highlights that you can generate industry‑standard PDF and Excel attendance reports for university records.

<p align="center">
<img src="images/Simulator Screenshot - iPhone 17 Pro - 2026-03-13 at 22.47.57.png" alt="Student Success onboarding" width="320" />
</p>

- **Student Success**: Emphasizes tracking student projects, attendance risk, and top performers in one place.  
  The final screen uses a **Get Started** call to action to enter the main app.

---

### 2. Overview Dashboard

Once onboarding is complete, users land on the main dashboard.

<p align="center">
<img src="images/Simulator Screenshot - iPhone 17 Pro - 2026-03-13 at 22.56.05.png" alt="Overview dashboard" width="320" />
</p>

- **Club header**: Shows the club name (e.g. *Swift Coding Club*) and location (*Parul University, Apple Lab, CV Raman*).
- **Key stats cards**:
  - Total Students
  - Completed projects
  - In‑progress projects
  - Items due today
- **Project Progress Overview**: A circular progress chart summarizing how many projects are completed vs in progress.
- **Attendance Trends**: A segmented control (Daily / Weekly / Monthly) with a graph to quickly see attendance over time.
- **Tab bar**: Navigation to `Overview`, `Students`, `Attendance`, `Projects`, and `Settings`.

This screen is the high‑level control center for club health.

---

### 3. Managing Students

#### Students List

<p align="center">
<img src="images/Simulator Screenshot - iPhone 17 Pro - 2026-03-13 at 22.52.11.png" alt="Students list" width="320" />
</p>

- **Alphabetical sections**: Students are grouped by initial (B, P, S, Y).
- **Student cards**:
  - Profile photo
  - Name
  - Skill level (Beginner / Intermediate / Advanced)
- **Add button (`+`)**: Quickly add a new student from the top‑right.
- Bottom navigation remains visible for instant switching to other modules.

#### Student Detail

<p align="center">
<img src="images/Simulator Screenshot - iPhone 17 Pro - 2026-03-13 at 22.52.39.png" alt="Student detail" width="320" />
</p>

- **Profile section**:
  - Large avatar and name
  - Level (e.g. *Advanced*)
  - Attendance summary (e.g. *100% Attendance (1/1)*)
- **Quick actions**:
  - Call
  - Message
  - Email
- **Contact Information**: Phone number and email in a clean card layout.
- **Academic Information**: Dedicated section (partially visible) to store academic/club‑specific fields.

This screen serves as the single source of truth for student information and communication.

---

### 4. Attendance Tracking

Creating and tracking attendance is a core workflow in ClubEasy.

<p align="center">
<img src="images/Simulator Screenshot - iPhone 17 Pro - 2026-03-13 at 22.52.23.png" alt="New Attendance calendar" width="320" />
</p>

- **New Attendance** modal:
  - Calendar picker to choose the session date (e.g. March 13, 2026).
  - Clear **Create Attendance** button to generate a new attendance record for that day.
- Once attendance sessions are created, their impact is reflected in:
  - Each student’s individual attendance rate on the profile screen.
  - The aggregated **Attendance Trends** chart on the Overview screen.

---

### 5. Project Management

Projects help you track what your students are actually building.

<p align="center">
<img src="images/Simulator Screenshot - iPhone 17 Pro - 2026-03-13 at 22.55.06.png" alt="Projects list" width="320" />
</p>

- **Project list**:
  - Each project shows title (e.g. *To Do App*, *Grocery App*, *Quiz App*).
  - Tech focus / category (e.g. *Full Stack*, *Backend*).
  - Number of members per project.
- **Refresh / status icons**: Indicate ongoing work or the ability to update status.
- **Add button (`+`)**: Top‑right control to create new projects.

Project completion and in‑progress counts feed into the Overview’s **Project Progress** chart.

---

### 6. Settings & Report Configuration

The Settings screen controls how the club info and reports are configured.

<p align="center">
<img src="images/Simulator Screenshot - iPhone 17 Pro - 2026-03-13 at 22.56.53.png" alt="Settings screen" width="320" />
</p>

- **Club Info**:
  - Club Subtitle (e.g. *Parul University, Apple Lab, CV Raman*).
  - University Domain (e.g. `@paruluniversity.ac.in`).
- **Email & Attendance Sharing**:
  - Default Sender Email (who the reports are sent from).
  - Recipient List (who receives the reports).
  - Default Message (template body for attendance/report emails).
- **Students**:
  - Custom Fields for Students to adapt the data model to your club’s needs.
- **Report Exports** (section visible at bottom):
  - Tied to the onboarding promise of **Professional Reports** (PDF / Excel) for attendance exports.

This configuration layer ensures that ClubEasy can integrate cleanly with your university’s communication and reporting workflow.

---

### 7. Email Attendance Report (What the Email Looks Like)

<img src="images/Screenshot 2026-03-13 at 11.04.24 PM.png" alt="Email attendance report"  />

- **Email body**: Shows a branded attendance report titled *Swift Coding Club* with club location.
- **Export metadata**: Includes the export date and summary (e.g. *1/1 present*).
- **Student row**: For each student, shows enrollment number, email, year, semester, and status (e.g. *Present*).
- This is the final, polished view that faculty or admins receive when attendance is exported from the app.

---

## Tech Stack

- **Platform**: iOS
- **Language**: Swift
- **Architecture / Libraries**: Built as a Swift Package (`.swiftpm`) and designed to integrate with Xcode and modern SwiftUI‑style UI patterns.

---

## Getting Started (High-Level)

> Note: Adjust these steps to match your actual project setup.

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd ClubEasy.swiftpm
