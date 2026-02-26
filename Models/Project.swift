import SwiftUI

enum ProjectStatus: String, CaseIterable, Codable {
    case inProgress = "In Progress"
    case completed = "Completed"
    
    var statusIcon: String {
        switch self {
        case .inProgress: return "arrow.clockwise"
        case .completed: return "checkmark.circle.fill"
        }
    }
    
    var statusColor: Color {
        switch self {
        case .inProgress: return .primary
        case .completed: return .green
        }
    }
}

enum ProjectAssignmentType: String, CaseIterable, Codable {
    case team = "Team"
    case individual = "Individual"
}

struct ProjectMember: Codable, Equatable, Identifiable {
    var id: UUID { studentId }
    let studentId: UUID
    var assignedTask: String
    var domain: String
    
    init(studentId: UUID, assignedTask: String, domain: String = "") {
        self.studentId = studentId
        self.assignedTask = assignedTask
        self.domain = domain
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        studentId = try c.decode(UUID.self, forKey: .studentId)
        assignedTask = try c.decode(String.self, forKey: .assignedTask)
        domain = try c.decodeIfPresent(String.self, forKey: .domain) ?? ""
    }
    
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(studentId, forKey: .studentId)
        try c.encode(assignedTask, forKey: .assignedTask)
        try c.encode(domain, forKey: .domain)
    }
    
    enum CodingKeys: String, CodingKey {
        case studentId, assignedTask, domain
    }
}

struct Project: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let teamName: String
    let progress: Double
    let startDate: Date
    let deadline: Date
    let status: ProjectStatus
    let assignmentType: ProjectAssignmentType
    let teamMembers: [ProjectMember]
    let notes: String
    let completionDate: Date?
    
    var deadlineText: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: deadline)
    }
    
    var completionDateText: String? {
        guard let date = completionDate else { return nil }
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: date)
    }
    
    var displayTeamName: String {
        teamName.replacingOccurrences(of: " Team", with: "")
    }
    
    var displayDomainValue: String {
        if assignmentType == .team && !teamMembers.isEmpty {
            let domains = Set(teamMembers.compactMap { m in
                m.domain.isEmpty ? nil : m.domain
            })
            return domains.sorted().joined(separator: ", ")
        }
        return displayTeamName
    }
    
    init(id: UUID = UUID(), name: String, description: String = "", teamName: String, progress: Double = 0, startDate: Date = Date(), deadline: Date, status: ProjectStatus = .inProgress, assignmentType: ProjectAssignmentType = .team, teamMembers: [ProjectMember] = [], notes: String = "", completionDate: Date? = nil) {
        self.id = id
        self.name = name
        self.description = description
        self.teamName = teamName
        self.progress = progress
        self.startDate = startDate
        self.deadline = deadline
        self.status = status
        self.assignmentType = assignmentType
        self.teamMembers = teamMembers
        self.notes = notes
        self.completionDate = completionDate
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        description = try c.decodeIfPresent(String.self, forKey: .description) ?? ""
        teamName = try c.decode(String.self, forKey: .teamName)
        progress = try c.decode(Double.self, forKey: .progress)
        startDate = try c.decode(Date.self, forKey: .startDate)
        deadline = try c.decode(Date.self, forKey: .deadline)
        status = try c.decode(ProjectStatus.self, forKey: .status)
        assignmentType = try c.decodeIfPresent(ProjectAssignmentType.self, forKey: .assignmentType) ?? .team
        teamMembers = try c.decodeIfPresent([ProjectMember].self, forKey: .teamMembers) ?? []
        notes = try c.decodeIfPresent(String.self, forKey: .notes) ?? ""
        completionDate = try c.decodeIfPresent(Date.self, forKey: .completionDate)
    }
    
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(description, forKey: .description)
        try c.encode(teamName, forKey: .teamName)
        try c.encode(progress, forKey: .progress)
        try c.encode(startDate, forKey: .startDate)
        try c.encode(deadline, forKey: .deadline)
        try c.encode(status, forKey: .status)
        try c.encode(assignmentType, forKey: .assignmentType)
        try c.encode(teamMembers, forKey: .teamMembers)
        try c.encode(notes, forKey: .notes)
        try c.encodeIfPresent(completionDate, forKey: .completionDate)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, teamName, progress, startDate, deadline, status, assignmentType, teamMembers, notes, completionDate
    }
}
