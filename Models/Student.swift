import Foundation

struct Student: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let level: String
    let initials: String
    let enrollmentNumber: String
    let skills: [String]
    let contactNumber: String
    let department: String
    let collegeEmail: String
    let year: String
    let profileImageFileName: String?
    let customFieldValues: [String: String]
    
    init(id: UUID = UUID(), name: String, level: String, initials: String, enrollmentNumber: String, skills: [String], contactNumber: String, department: String, collegeEmail: String, year: String = "", profileImageFileName: String? = nil, customFieldValues: [String: String] = [:]) {
        self.id = id
        self.name = name
        self.level = level
        self.initials = initials
        self.enrollmentNumber = enrollmentNumber
        self.skills = skills
        self.contactNumber = contactNumber
        self.department = department
        self.collegeEmail = collegeEmail
        self.year = year
        self.profileImageFileName = profileImageFileName
        self.customFieldValues = customFieldValues
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        level = try container.decode(String.self, forKey: .level)
        initials = try container.decode(String.self, forKey: .initials)
        enrollmentNumber = try container.decode(String.self, forKey: .enrollmentNumber)
        skills = try container.decode([String].self, forKey: .skills)
        contactNumber = try container.decode(String.self, forKey: .contactNumber)
        department = try container.decode(String.self, forKey: .department)
        collegeEmail = try container.decode(String.self, forKey: .collegeEmail)
        year = try container.decodeIfPresent(String.self, forKey: .year) ?? ""
        profileImageFileName = try container.decodeIfPresent(String.self, forKey: .profileImageFileName)
        customFieldValues = try container.decodeIfPresent([String: String].self, forKey: .customFieldValues) ?? [:]
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(level, forKey: .level)
        try container.encode(initials, forKey: .initials)
        try container.encode(enrollmentNumber, forKey: .enrollmentNumber)
        try container.encode(skills, forKey: .skills)
        try container.encode(contactNumber, forKey: .contactNumber)
        try container.encode(department, forKey: .department)
        try container.encode(collegeEmail, forKey: .collegeEmail)
        try container.encode(year, forKey: .year)
        try container.encodeIfPresent(profileImageFileName, forKey: .profileImageFileName)
        try container.encode(customFieldValues, forKey: .customFieldValues)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, level, initials, enrollmentNumber, skills, contactNumber, department, collegeEmail, year, profileImageFileName, customFieldValues
    }
    
    func with(customFieldValues: [String: String]) -> Student {
        Student(id: id, name: name, level: level, initials: initials, enrollmentNumber: enrollmentNumber, skills: skills, contactNumber: contactNumber, department: department, collegeEmail: collegeEmail, year: year, profileImageFileName: profileImageFileName, customFieldValues: customFieldValues)
    }
}
