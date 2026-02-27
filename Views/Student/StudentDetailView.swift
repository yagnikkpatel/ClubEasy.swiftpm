import SwiftUI

@MainActor
struct StudentDetailView: View {
    let student: Student
    @Binding var students: [Student]
    @Environment(\.openURL) private var openURL
    @State private var currentStudent: Student
    @State private var showEditProfile = false
    
    init(student: Student, students: Binding<[Student]>) {
        self.student = student
        self._students = students
        self._currentStudent = State(initialValue: student)
    }
    
    var body: some View {
        List {
            profileHeader
            actionButtons
            contactSection
            academicSection
            skillsSection
            performanceSection
            customFieldsSection
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(.compact)
        .navigationTitle(currentStudent.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showEditProfile = true
                } label: {
                    Text("Edit")
                }
            }
        }
        .sheet(isPresented: $showEditProfile) {
            AddStudentView(students: $students, editingStudent: currentStudent)
        }
        .onChange(of: showEditProfile) { _, isShowing in
            if !isShowing {
                currentStudent = students.first(where: { $0.id == currentStudent.id }) ?? currentStudent
            }
        }
    }
    
    private var profileHeader: some View {
        Section {
            VStack(spacing: 16) {
                Group {
                    if let filename = currentStudent.profileImageFileName,
                       let image = ProfileImageStorage.load(filename: filename) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [Color.primary.opacity(0.9), Color.primary.opacity(0.6)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                                    .scaleEffect(1.12)
                            )
                    } else {
                        ZStack {
                            Circle()
                                .fill(Color(.tertiarySystemFill))
                                .frame(width: 120, height: 120)
                            Text(firstLetter(of: currentStudent.name))
                                .font(.system(size: 48, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [Color.primary.opacity(0.8), Color.primary.opacity(0.5)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                                .scaleEffect(1.12)
                        )
                    }
                }
                .padding(.top, 8)
                
                VStack(spacing: 4) {
                    Text(currentStudent.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                    Text(currentStudent.level)
                        .font(.body)
                        .foregroundStyle(.secondary)
                    attendanceBadge
                }
            }
            .frame(maxWidth: .infinity)
            .listRowInsets(EdgeInsets(top: 24, leading: 16, bottom: 24, trailing: 16))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
    }
    
    private var actionButtons: some View {
        Section {
            HStack(spacing: 24) {
                ActionButton(icon: "phone.fill", label: "Call") {
                    let digits = currentStudent.contactNumber.filter { $0.isNumber || $0 == "+" }
                    if let url = URL(string: "tel:\(digits)"), !digits.isEmpty {
                        openURL(url)
                    }
                }
                ActionButton(icon: "message.fill", label: "Message") {
                    let digits = currentStudent.contactNumber.filter { $0.isNumber || $0 == "+" }
                    if let url = URL(string: "sms:\(digits)"), !digits.isEmpty {
                        openURL(url)
                    }
                }
                ActionButton(icon: "envelope.fill", label: "Email") {
                    if !currentStudent.collegeEmail.isEmpty, let url = URL(string: "mailto:\(currentStudent.collegeEmail)") {
                        openURL(url)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .listRowInsets(EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24))
            .listRowBackground(Color.clear)
        }
    }
    
    private var contactSection: some View {
        let sections = CustomFieldStorage.load()
        let contactFields = sections.first(where: { $0.name == BuiltInSectionNames.contactInfo })?.fields ?? []
        return Section("Contact Information") {
            if !currentStudent.contactNumber.isEmpty {
                LabeledRow(icon: "phone.fill", title: "Phone", value: currentStudent.contactNumber)
            }
            if !currentStudent.collegeEmail.isEmpty {
                LabeledRow(icon: "envelope.fill", title: "Email", value: currentStudent.collegeEmail)
            }
            CustomFieldReadOnlyView(fields: contactFields, values: currentStudent.customFieldValues)
        }
    }
    
    private var academicSection: some View {
        let sections = CustomFieldStorage.load()
        let academicFields = sections.first(where: { $0.name == BuiltInSectionNames.academicInfo })?.fields ?? []
        let personalFields = sections.first(where: { $0.name == BuiltInSectionNames.personalInfo })?.fields ?? []
        return Section("Academic Information") {
            if !currentStudent.enrollmentNumber.isEmpty {
                LabeledRow(icon: "number", title: "Enrollment", value: currentStudent.enrollmentNumber)
            }
            if !currentStudent.year.isEmpty {
                LabeledRow(icon: "calendar", title: "Year", value: currentStudent.year)
            }
            if !currentStudent.semester.isEmpty {
                LabeledRow(icon: "graduationcap", title: "Semester", value: currentStudent.semester)
            }
            if !currentStudent.department.isEmpty {
                LabeledRow(icon: "building.2.fill", title: "Department", value: currentStudent.department)
            }
            LabeledRow(icon: "star.circle.fill", title: "Programming Level", value: currentStudent.level)
            CustomFieldReadOnlyView(fields: academicFields + personalFields, values: currentStudent.customFieldValues)
        }
    }
    
    private var skillsSection: some View {
        Section("Skills") {
            if currentStudent.skills.isEmpty {
                Text("No skills added")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(currentStudent.skills, id: \.self) { skill in
                    Label(skill, systemImage: "checkmark.circle.fill")
                }
            }
        }
    }
    
    private var attendanceBadge: some View {
        let (present, total) = AttendanceStorage.attendanceStats(for: currentStudent.id)
        let pct = total > 0 ? Double(present) / Double(total) * 100 : nil
        let text = total > 0 ? "\(Int(round(pct ?? 0)))% Attendance (\(present)/\(total))" : "No attendance recorded"
        let color: Color = {
            guard let p = pct else { return .secondary }
            return p >= 75 ? .green : .red
        }()
        return Text(text)
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(total > 0 ? color : .secondary)
    }
    
    private var projectsCompletedRow: some View {
        let count = ProjectStorage.completedProjectsCount(for: currentStudent.id)
        let value = count > 0 ? "\(count)" : "None"
        return HStack(spacing: 12) {
            Image(systemName: "star.fill")
                .foregroundStyle(.secondary)
                .frame(width: 24, alignment: .center)
            VStack(alignment: .leading, spacing: 2) {
                Text("Projects Completed")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.body)
                    .foregroundStyle(.primary)
            }
            Spacer()
        }
    }
    
    private func firstLetter(of name: String) -> String {
        guard let first = name.first else { return "" }
        return String(first).uppercased()
    }
    
    private var performanceSection: some View {
        let (present, total) = AttendanceStorage.attendanceStats(for: currentStudent.id)
        let percentage = total > 0 ? "\(Int(round(Double(present) / Double(total) * 100)))%" : "—"
        let ratio = total > 0 ? "(\(present)/\(total))" : "—"
        return Section("Performance") {
            HStack(spacing: 12) {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(.secondary)
                    .frame(width: 24, alignment: .center)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Attendance")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(percentage)
                        .font(.body)
                        .foregroundStyle(.primary)
                }
                Spacer()
                Text(ratio)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            projectsCompletedRow
        }
    }
    
    private var customFieldsSection: some View {
        let sections = CustomFieldStorage.load()
        return Group {
            if !sections.isEmpty {
                CustomFieldsFormView(
                    values: .constant(currentStudent.customFieldValues),
                    sections: sections,
                    isEditable: false,
                    excludeSectionNames: Set([
                        BuiltInSectionNames.personalInfo,
                        BuiltInSectionNames.contactInfo,
                        BuiltInSectionNames.academicInfo
                    ])
                )
            }
        }
    }
}

struct ActionButton: View {
    let icon: String
    let label: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(Color(.tertiarySystemFill))
                        .frame(width: 56, height: 56)
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(.primary)
                }
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

struct LabeledRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 24, alignment: .center)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.body)
                    .foregroundStyle(.primary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        StudentDetailView(
            student: Student(
                name: "Alex Chen",
                level: "Intermediate",
                initials: "AC",
                enrollmentNumber: "ENR001",
                skills: ["SwiftUI", "Swift"],
                contactNumber: "+1 555-0101",
                department: "Computer Science",
                collegeEmail: "alex.chen@college.edu",
                year: "2024"
            ),
            students: .constant([])
        )
    }
}
