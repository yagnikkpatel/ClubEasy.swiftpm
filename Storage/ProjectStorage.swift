import Foundation

enum ProjectStorage {
    private static let key = "savedProjects"
    
    static func load() -> [Project] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([Project].self, from: data) else {
            return []
        }
        return decoded
    }
    
    static func save(_ projects: [Project]) {
        guard let data = try? JSONEncoder().encode(projects) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
    
    /// Returns the number of completed projects the student is a member of.
    static func completedProjectsCount(for studentId: UUID) -> Int {
        let projects = load()
        return projects.filter { project in
            project.status == .completed &&
            project.teamMembers.contains { $0.studentId == studentId }
        }.count
    }
}
