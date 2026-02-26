import SwiftUI

struct ProjectsView: View {
    @Binding var projects: [Project]
    @State private var showAddProject = false
    @State private var projectToEdit: Project?
    @State private var searchText = ""
    
    private func projectSubtitle(_ project: Project) -> String {
        var parts: [String] = [project.displayTeamName]
        if !project.teamMembers.isEmpty {
            parts.append("\(project.teamMembers.count) \(project.assignmentType == .individual ? "member" : "members")")
        }
        return parts.joined(separator: " · ")
    }
    
    private var filteredProjects: [Project] {
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        guard !query.isEmpty else { return projects }
        return projects.filter {
            $0.name.lowercased().contains(query) ||
            $0.description.lowercased().contains(query) ||
            $0.displayTeamName.lowercased().contains(query)
        }
    }
    
    var body: some View {
        projectList
        .navigationTitle("Projects")
        .searchable(text: $searchText, prompt: "Search projects")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddProject = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddProject) {
            NavigationStack {
                AddProjectView(projects: $projects)
            }
        }
        .sheet(item: $projectToEdit) { project in
            NavigationStack {
                AddProjectView(projects: $projects, editingProject: project)
            }
        }
    }
    
    private var projectList: some View {
        List {
            if projects.isEmpty {
                Section {
                    ContentUnavailableView("No Projects", systemImage: "folder", description: Text("Tap + to add a project"))
                        .listRowBackground(Color.clear)
                }
            } else if filteredProjects.isEmpty {
                Section {
                    ContentUnavailableView("No Results", systemImage: "magnifyingglass", description: Text("No projects match \"\(searchText)\""))
                        .listRowBackground(Color.clear)
                }
            } else {
                Section {
                    projectRows
                }
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(.compact)
    }
    
    private var projectRows: some View {
        ForEach(filteredProjects) { project in
                NavigationLink {
                    ProjectDetailView(project: project, projects: $projects)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(project.name)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.primary)
                            Text(projectSubtitle(project))
                                .font(.subheadline)
                                .foregroundStyle(Color.primary)
                        }
                        Spacer()
                        Image(systemName: project.status.statusIcon)
                            .font(.body)
                            .foregroundStyle(project.status.statusColor)
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        projects.removeAll { $0.id == project.id }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    Button {
                        projectToEdit = project
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    .tint(.primary)
                }
        }
    }
}

struct ProjectDetailView: View {
    let project: Project
    @Binding var projects: [Project]
    @State private var showEdit = false
    private let students = StudentStorage.load()
    
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()
    
    private func studentName(for id: UUID) -> String {
        students.first { $0.id == id }?.name ?? "Unknown"
    }
    
    var body: some View {
        List {
            if !project.description.isEmpty {
                Section("Description") {
                    Text(project.description)
                        .foregroundStyle(.primary)
                }
            }
            
            if !project.teamMembers.isEmpty {
                Section(project.assignmentType == .individual ? "Assigned To" : "Team Members") {
                    ForEach(project.teamMembers, id: \.studentId) { member in
                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text(studentName(for: member.studentId))
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                                if project.assignmentType == .team && !member.domain.isEmpty {
                                    Text("·")
                                        .foregroundStyle(.tertiary)
                                    Text(member.domain)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            if !member.assignedTask.isEmpty {
                                Text(member.assignedTask)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            
            if !project.notes.isEmpty {
                Section("Notes") {
                    Text(project.notes)
                        .font(.body)
                        .foregroundStyle(.primary)
                }
            }
            
            Section("Details") {
                LabeledContent("Assignment", value: project.assignmentType.rawValue)
                LabeledContent("Domain", value: project.displayDomainValue)
                LabeledContent("Status", value: project.status.rawValue)
                LabeledContent("Start", value: dateFormatter.string(from: project.startDate))
                LabeledContent("Deadline", value: project.deadlineText)
                if let completionText = project.completionDateText {
                    LabeledContent("Completed", value: completionText)
                }
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(.compact)
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showEdit = true
                }
            }
        }
        .sheet(isPresented: $showEdit) {
            NavigationStack {
                AddProjectView(projects: $projects, editingProject: project)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProjectsView(projects: .constant(ProjectStorage.load()))
    }
}
