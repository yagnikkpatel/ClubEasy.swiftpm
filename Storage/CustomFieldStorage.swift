import Foundation

enum CustomFieldStorage {
    private static let key = "customFieldSections"
    
    /// Fixed UUIDs for category-wise default sections
    static let defaultSectionIds: [String: UUID] = [
        "Contact Information": UUID(uuidString: "A1B2C3D4-E5F6-7890-ABCD-EF1234567890")!,
        "Academic Information": UUID(uuidString: "B2C3D4E5-F6A7-8901-BCDE-F12345678901")!,
        "Personal Information": UUID(uuidString: "D4E5F6A7-B8C9-0123-DEF0-234567890123")!
    ]
    
    static func isDefaultSection(_ id: UUID) -> Bool {
        defaultSectionIds.values.contains(id)
    }
    
    static var defaultSections: [CustomFieldSection] {
        return [
            CustomFieldSection(id: defaultSectionIds["Contact Information"]!, name: "Contact Information", fields: []),
            CustomFieldSection(id: defaultSectionIds["Academic Information"]!, name: "Academic Information", fields: []),
            CustomFieldSection(id: defaultSectionIds["Personal Information"]!, name: "Personal Information", fields: [])
        ]
    }
    
    /// Deprecated section IDs (Emergency Contact - removed)
    private static let deprecatedSectionIds: Set<UUID> = [
        UUID(uuidString: "C3D4E5F6-A7B8-9012-CDEF-123456789012")!
    ]
    
    static func load() -> [CustomFieldSection] {
        var stored: [CustomFieldSection] = []
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([CustomFieldSection].self, from: data) {
            stored = decoded
        }
        
        var result: [CustomFieldSection] = []
        for defaultSection in defaultSections {
            if let existing = stored.first(where: { $0.id == defaultSection.id }) {
                var merged = existing
                for defaultField in defaultSection.fields {
                    if let idx = merged.fields.firstIndex(where: { $0.id == defaultField.id }) {
                        // Field already exists, no need to update
                    } else {
                        merged.fields.append(defaultField)
                    }
                }
                result.append(merged)
            } else {
                result.append(defaultSection)
            }
        }
        let defaultIds = Set(defaultSectionIds.values)
        for section in stored where !defaultIds.contains(section.id) && !deprecatedSectionIds.contains(section.id) {
            result.append(section)
        }
        
        if result != stored {
            save(result)
        }
        return result
    }
    
    static func save(_ sections: [CustomFieldSection]) {
        guard let data = try? JSONEncoder().encode(sections) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
