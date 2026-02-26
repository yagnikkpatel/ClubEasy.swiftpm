import SwiftUI

struct AddProjectView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var projects: [Project]
    var editingProject: Project?
    
    @State private var name = ""
    @State private var description = ""
    @State private var selectedTeam = "Backend"
    @State private var startDate = Date()
    @State private var deadline = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
    @State private var status: ProjectStatus = .inProgress
    @State private var assignmentType: ProjectAssignmentType = .team
    @State private var teamMembers: [ProjectMember] = []
    @State private var notes = ""
    @State private var showMemberPicker = false
    
    private let students = StudentStorage.load()
    
    private static let domains = ["Backend", "Design", "Full Stack"]
    
    private var isEditing: Bool { editingProject != nil }
    private var canSave: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }
    
    private var progress: Double {
        switch status {
        case .inProgress: return 0.5
        case .completed: return 1.0
        }
    }
    
    private func studentName(for id: UUID) -> String {
        students.first { $0.id == id }?.name ?? "Unknown"
    }
    
    private func displayTeamName(_ name: String) -> String {
        name.replacingOccurrences(of: " Team", with: "")
    }
    
    private var nameSection: some View {
        Section {
            TextField("Name", text: $name)
            TextField("Description", text: $description, axis: .vertical)
                .lineLimit(3...6)
        }
    }
    
    private var teamMembersSection: some View {
        Section {
            ForEach(Array(teamMembers.enumerated()), id: \.element.studentId) { index, member in
                memberRow(index: index, member: member)
            }
            .onDelete { indexSet in
                teamMembers.remove(atOffsets: indexSet)
            }
            Button {
                showMemberPicker = true
            } label: {
                Label(assignmentType == .individual ? "Add Member" : "Add Team Member", systemImage: "person.badge.plus")
                    .foregroundStyle(.blue)
            }
        } header: {
            Text(assignmentType == .individual ? "Assigned To" : "Team Members")
        }
    }
    
    @ViewBuilder
    private func memberRow(index: Int, member: ProjectMember) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(studentName(for: member.studentId))
                .font(.headline)
                .foregroundStyle(.primary)
            if assignmentType == .team {
                HStack {
                    Text("Domain")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Picker("", selection: $teamMembers[index].domain) {
                        ForEach(Self.domains, id: \.self) { domain in
                            Text(domain).tag(domain)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                }
            }
            TextField("Assigned task", text: $teamMembers[index].assignedTask)
                .font(.subheadline)
        }
        .padding(.vertical, 4)
    }
    
    private var notesSection: some View {
        Section("Notes") {
            TextField("Add notes about this team…", text: $notes, axis: .vertical)
                .lineLimit(3...8)
        }
    }
    
    private var assignmentSection: some View {
        Section {
            Picker("Assignment", selection: $assignmentType) {
                ForEach(ProjectAssignmentType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            if assignmentType == .individual {
                Picker("Domain", selection: $selectedTeam) {
                    ForEach(Self.domains, id: \.self) { domain in
                        Text(domain).tag(domain)
                    }
                }
            }
            Picker("Status", selection: $status) {
                ForEach(ProjectStatus.allCases, id: \.self) { s in
                    Text(s.rawValue).tag(s)
                }
            }
        }
    }
    
    private var datesSection: some View {
        Section {
            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
            DatePicker("Deadline", selection: $deadline, displayedComponents: .date)
        }
    }
    
    var body: some View {
        Form {
            nameSection
            teamMembersSection
            notesSection
            assignmentSection
            datesSection
        }
        .formStyle(.grouped)
        .tint(Color(.secondaryLabel))
        .navigationTitle(isEditing ? "Edit Project" : "New Project")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveProject()
                }
                .fontWeight(.semibold)
                .disabled(!canSave)
            }
        }
        .sheet(isPresented: $showMemberPicker) {
            TeamMemberPickerView(
                students: students,
                selectedIds: assignmentType == .individual ? [] : Set(teamMembers.map(\.studentId)),
                isIndividual: assignmentType == .individual
            ) { studentId in
                if assignmentType == .individual {
                    teamMembers = [ProjectMember(studentId: studentId, assignedTask: "", domain: "")]
                } else {
                    teamMembers.append(ProjectMember(studentId: studentId, assignedTask: "", domain: Self.domains.first ?? ""))
                }
                showMemberPicker = false
            }
        }
        .onChange(of: assignmentType) { _, newType in
            if newType == .individual && teamMembers.count > 1 {
                teamMembers = Array(teamMembers.prefix(1))
            }
            if newType == .team {
                let defaultDomain = Self.domains.first ?? ""
                teamMembers = teamMembers.map { m in
                    var copy = m
                    if copy.domain.isEmpty { copy.domain = defaultDomain }
                    return copy
                }
            }
        }
        .onAppear {
            if let project = editingProject {
                name = project.name
                description = project.description
                let loadedTeam = displayTeamName(project.teamName)
                selectedTeam = Self.domains.contains(loadedTeam) ? loadedTeam : (Self.domains.first ?? "Backend")
                startDate = project.startDate
                deadline = project.deadline
                status = project.status
                assignmentType = project.assignmentType
                var members = project.teamMembers
                if project.assignmentType == .team {
                    let defaultDomain = Self.domains.first ?? ""
                    members = members.map { m in
                        var copy = m
                        if copy.domain.isEmpty { copy.domain = defaultDomain }
                        return copy
                    }
                }
                teamMembers = members
                notes = project.notes
            }
        }
    }
    
    private func saveProject() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        let desc = description.trimmingCharacters(in: .whitespaces)
        let members = teamMembers.map { m in
            ProjectMember(studentId: m.studentId, assignedTask: m.assignedTask.trimmingCharacters(in: CharacterSet.whitespaces), domain: m.domain)
        }
        let notesText = notes.trimmingCharacters(in: .whitespaces)
        let projectDomain = assignmentType == .individual ? selectedTeam : (members.first?.domain ?? Self.domains.first ?? "Backend")
        let completedDate: Date? = status == .completed ? (editingProject?.completionDate ?? Date()) : nil
        
        if let existing = editingProject {
            let updated = Project(
                id: existing.id,
                name: trimmedName,
                description: desc,
                teamName: projectDomain,
                progress: progress,
                startDate: startDate,
                deadline: deadline,
                status: status,
                assignmentType: assignmentType,
                teamMembers: members,
                notes: notesText,
                completionDate: completedDate
            )
            if let index = projects.firstIndex(where: { $0.id == existing.id }) {
                projects[index] = updated
            }
        } else {
            let newProject = Project(
                name: trimmedName,
                description: desc,
                teamName: projectDomain,
                progress: progress,
                startDate: startDate,
                deadline: deadline,
                status: status,
                assignmentType: assignmentType,
                teamMembers: members,
                notes: notesText,
                completionDate: completedDate
            )
            projects.append(newProject)
        }
        dismiss()
    }
}

struct TeamMemberPickerView: View {
    let students: [Student]
    let selectedIds: Set<UUID>
    var isIndividual: Bool = false
    let onSelect: (UUID) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    private var availableStudents: [Student] {
        if isIndividual { return students }
        return students.filter { !selectedIds.contains($0.id) }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(availableStudents) { student in
                    Button {
                        onSelect(student.id)
                    } label: {
                        HStack(spacing: 12) {
                            Group {
                                if let filename = student.profileImageFileName,
                                   let image = ProfileImageStorage.load(filename: filename) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 36, height: 36)
                                        .clipShape(Circle())
                                } else {
                                    Text(student.initials)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.white)
                                        .frame(width: 36, height: 36)
                                        .background(Color(.systemGray3))
                                        .clipShape(Circle())
                                }
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(student.name)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                                Text([student.level, student.department].filter { !$0.isEmpty }.joined(separator: " · "))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
                if availableStudents.isEmpty && !isIndividual {
                    ContentUnavailableView("No Students", systemImage: "person.2", description: Text("All students are already on the team. Add more students in the Students tab."))
                }
            }
            .navigationTitle(isIndividual ? "Assign Member" : "Add Team Member")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddProjectView(projects: .constant([]))
}
