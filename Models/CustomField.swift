import Foundation

enum CustomFieldType: String, CaseIterable, Codable {
    case text = "Text"
    case number = "Number"
    case date = "Date"
    case multiline = "Multiline"
    case bool = "Bool"
}

struct CustomField: Identifiable, Codable, Equatable {
    let id: UUID
    var label: String
    var type: CustomFieldType
    var placeholder: String
    
    init(id: UUID = UUID(), label: String, type: CustomFieldType = .text, placeholder: String = "") {
        self.id = id
        self.label = label
        self.type = type
        self.placeholder = placeholder
    }
}

struct CustomFieldSection: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var fields: [CustomField]
    
    init(id: UUID = UUID(), name: String, fields: [CustomField] = []) {
        self.id = id
        self.name = name
        self.fields = fields
    }
}
