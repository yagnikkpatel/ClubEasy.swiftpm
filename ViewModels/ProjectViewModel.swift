import SwiftUI
import Combine

class ProjectViewModel: ObservableObject {
    @Published var projects: [Project] = []
    @Published var searchText: String = ""
    
    init() {
        loadProjects()
    }
    
    func loadProjects() {
        self.projects = ProjectStorage.load()
    }
    
    func saveProjects() {
        ProjectStorage.save(projects)
    }
    
    var filteredProjects: [Project] {
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        guard !query.isEmpty else { return projects }
        return projects.filter {
            $0.name.lowercased().contains(query) ||
            $0.description.lowercased().contains(query) ||
            $0.displayTeamName.lowercased().contains(query)
        }
    }
    
    func deleteProject(_ project: Project) {
        projects.removeAll { $0.id == project.id }
        saveProjects()
    }
    
    func projectSubtitle(_ project: Project) -> String {
        var parts: [String] = [project.displayTeamName]
        if !project.teamMembers.isEmpty {
            parts.append("\(project.teamMembers.count) \(project.assignmentType == .individual ? "member" : "members")")
        }
        return parts.joined(separator: " · ")
    }
}
