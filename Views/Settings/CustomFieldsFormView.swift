import SwiftUI

/// Built-in section names that are merged into existing form sections instead of shown separately
enum BuiltInSectionNames {
    static let personalInfo = "Personal Information"
    static let contactInfo = "Contact Information"
    static let academicInfo = "Academic Information"
}

struct CustomFieldsFormView: View {
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    private static let displayDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()
    @Binding var values: [String: String]
    let sections: [CustomFieldSection]
    var isEditable: Bool = true
    /// Sections to exclude (they are merged into built-in sections elsewhere)
    var excludeSectionNames: Set<String> = []
    
    private var filteredSections: [CustomFieldSection] {
        sections.filter { !excludeSectionNames.contains($0.name) }
    }
    
    var body: some View {
        ForEach(filteredSections) { section in
            if !section.fields.isEmpty {
                Section(section.name) {
                    ForEach(section.fields) { field in
                        if isEditable {
                            fieldInput(field: field)
                        } else {
                            if field.type == .bool {
                                BoolStatusRow(label: field.label, isOn: values[field.id.uuidString] == "true")
                            } else if let value = values[field.id.uuidString], !value.isEmpty {
                                let displayValue = field.type == .date && Self.dateFormatter.date(from: value) != nil
                                    ? (Self.displayDateFormatter.string(from: Self.dateFormatter.date(from: value)!))
                                    : value
                                LabeledRow(icon: "doc.text", title: field.label, value: displayValue)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func fieldInput(field: CustomField) -> some View {
        let binding = Binding(
            get: { values[field.id.uuidString] ?? "" },
            set: { newValue in
                var updated = values
                updated[field.id.uuidString] = newValue
                values = updated
            }
        )
        switch field.type {
        case .text:
            TextField(field.placeholder.isEmpty ? field.label : field.placeholder, text: binding)
        case .number:
            TextField(field.placeholder.isEmpty ? field.label : field.placeholder, text: binding)
                .keyboardType(.numberPad)
        case .date:
            DatePicker(field.label, selection: Binding(
                get: { Self.dateFormatter.date(from: binding.wrappedValue) ?? Date() },
                set: { binding.wrappedValue = Self.dateFormatter.string(from: $0) }
            ), displayedComponents: .date)
        case .multiline:
            TextField(field.placeholder.isEmpty ? field.label : field.placeholder, text: binding, axis: .vertical)
                .lineLimit(3...6)
        case .bool:
            Toggle(field.label, isOn: Binding(
                get: { binding.wrappedValue == "true" },
                set: { binding.wrappedValue = $0 ? "true" : "false" }
            ))
        }
    }
}

/// Read-only display of custom fields - for bool shows tick (✓) or cross (✗)
struct CustomFieldReadOnlyView: View {
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
    private static let displayDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()
    let fields: [CustomField]
    let values: [String: String]
    
    var body: some View {
        ForEach(fields) { field in
            if field.type == .bool {
                BoolStatusRow(label: field.label, isOn: values[field.id.uuidString] == "true")
            } else if let value = values[field.id.uuidString], !value.isEmpty {
                let displayValue = field.type == .date && Self.dateFormatter.date(from: value) != nil
                    ? Self.displayDateFormatter.string(from: Self.dateFormatter.date(from: value)!)
                    : value
                LabeledRow(icon: "doc.text", title: field.label, value: displayValue)
            }
        }
    }
}

/// Shows tick (✓) when on, cross (✗) when off - for Id Card status etc.
struct BoolStatusRow: View {
    let label: String
    let isOn: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "doc.text")
                .foregroundStyle(.secondary)
                .frame(width: 24, alignment: .center)
            Text(label)
                .font(.body)
            Spacer()
            Image(systemName: isOn ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.title2)
                .foregroundStyle(isOn ? .green : .red)
        }
    }
}

/// Renders custom field inputs for merging into built-in sections (e.g. Personal Information)
struct CustomFieldInputsView: View {
    let fields: [CustomField]
    @Binding var values: [String: String]
    
    var body: some View {
        ForEach(fields) { field in
            CustomFieldsFormView.fieldInput(for: field, values: $values)
        }
    }
}

extension CustomFieldsFormView {
    static func fieldInput(for field: CustomField, values: Binding<[String: String]>) -> some View {
        let binding = Binding(
            get: { values.wrappedValue[field.id.uuidString] ?? "" },
            set: { newValue in
                var updated = values.wrappedValue
                updated[field.id.uuidString] = newValue
                values.wrappedValue = updated
            }
        )
        return Group {
            switch field.type {
            case .text:
                TextField(field.placeholder.isEmpty ? field.label : field.placeholder, text: binding)
            case .number:
                TextField(field.placeholder.isEmpty ? field.label : field.placeholder, text: binding)
                    .keyboardType(.numberPad)
            case .date:
                DatePicker(field.label, selection: Binding(
                    get: { Self.dateFormatter.date(from: binding.wrappedValue) ?? Date() },
                    set: { binding.wrappedValue = Self.dateFormatter.string(from: $0) }
                ), displayedComponents: .date)
            case .multiline:
                TextField(field.placeholder.isEmpty ? field.label : field.placeholder, text: binding, axis: .vertical)
                    .lineLimit(3...6)
            case .bool:
                Toggle(field.label, isOn: Binding(
                    get: { binding.wrappedValue == "true" },
                    set: { binding.wrappedValue = $0 ? "true" : "false" }
                ))
            }
        }
    }
}
