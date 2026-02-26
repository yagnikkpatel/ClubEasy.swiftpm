import SwiftUI

struct CustomFieldsSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var sections: [CustomFieldSection]
    @State private var showAddSection = false
    @State private var sectionToEdit: CustomFieldSection?
    
    var body: some View {
        List {
            Section {
                ForEach(sections) { section in
                    Button {
                        sectionToEdit = section
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(section.name)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                                Text("\(section.fields.count) field\(section.fields.count == 1 ? "" : "s")")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        if !CustomFieldStorage.isDefaultSection(section.id) {
                            Button(role: .destructive) {
                                sections.removeAll { $0.id == section.id }
                                CustomFieldStorage.save(sections)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            } header: {
                Text("Field Sections")
            } footer: {
                Text("Add custom sections to collect additional student information. Each section can have multiple fields.")
            }
            
            Section {
                Button {
                    showAddSection = true
                } label: {
                    Label("Add Section", systemImage: "plus.circle.fill")
                        .foregroundStyle(.primary)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Custom Fields")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showAddSection) {
            AddCustomSectionView(sections: $sections)
        }
        .sheet(item: $sectionToEdit) { section in
            AddCustomSectionView(sections: $sections, editingSection: section)
        }
        .onChange(of: sections) { _, newSections in
            CustomFieldStorage.save(newSections)
        }
    }
}

struct AddCustomSectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var sections: [CustomFieldSection]
    var editingSection: CustomFieldSection?
    
    @State private var selectedSectionId: UUID?
    @State private var sectionName = ""
    @State private var fields: [CustomField] = []
    @State private var showAddField = false
    @State private var fieldToEdit: CustomField?
    
    private var isNewSection: Bool { selectedSectionId == nil }
    private var canSave: Bool {
        !sectionName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Section") {
                    Picker("Section", selection: $selectedSectionId) {
                        Text("New Section").tag(nil as UUID?)
                        ForEach(sections) { section in
                            Text(section.name).tag(section.id as UUID?)
                        }
                    }
                    .onChange(of: selectedSectionId) { _, newId in
                        if let id = newId, let section = sections.first(where: { $0.id == id }) {
                            sectionName = section.name
                            fields = section.fields
                        } else {
                            sectionName = ""
                            fields = []
                        }
                    }
                    
                    TextField("Section Name", text: $sectionName, prompt: Text("e.g. Emergency Contact"))
                        .disabled(selectedSectionId != nil && CustomFieldStorage.isDefaultSection(selectedSectionId!))
                        .foregroundStyle(selectedSectionId != nil && CustomFieldStorage.isDefaultSection(selectedSectionId!) ? .tertiary : .primary)
                }
                
                Section {
                    Button {
                        showAddField = true
                    } label: {
                        Label("Add New Field", systemImage: "plus.circle")
                            .foregroundStyle(.primary)
                    }
                } header: {
                    Text("Fields")
                } footer: {
                    Text("Add text, number, date, or multiline fields. Tap a field to edit.")
                }
                
                if !fields.isEmpty {
                    Section("Fields in this section") {
                        ForEach(fields) { field in
                            Button {
                                fieldToEdit = field
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(field.label)
                                            .font(.body)
                                            .foregroundStyle(.primary)
                                        Text(field.type.rawValue)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    fields.removeAll { $0.id == field.id }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(isNewSection ? "New Section" : "Add to Section")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveSection()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canSave)
                }
            }
            .sheet(isPresented: $showAddField) {
                AddFieldView(fields: $fields, simplified: !isNewSection)
            }
            .sheet(item: $fieldToEdit) { field in
                AddFieldView(fields: $fields, editingField: field)
            }
            .onAppear {
                if let section = editingSection {
                    selectedSectionId = section.id
                    sectionName = section.name
                    fields = section.fields
                } else {
                    selectedSectionId = nil
                }
            }
        }
    }
    
    private func saveSection() {
        let name = sectionName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        
        if isNewSection {
            sections.append(CustomFieldSection(name: name, fields: fields))
        } else if let id = selectedSectionId, let index = sections.firstIndex(where: { $0.id == id }) {
            let updated = CustomFieldSection(id: id, name: name, fields: fields)
            sections[index] = updated
        }
        CustomFieldStorage.save(sections)
        dismiss()
    }
}

struct AddFieldView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var fields: [CustomField]
    var editingField: CustomField?
    var simplified: Bool = false
    
    @State private var label = ""
    @State private var fieldType: CustomFieldType = .text
    @State private var placeholder = ""
    
    private var isEditing: Bool { editingField != nil }
    private var canSave: Bool {
        if simplified {
            return !placeholder.trimmingCharacters(in: .whitespaces).isEmpty
        } else {
            return !label.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                if simplified {
                    Section("Placeholder") {
                        TextField("e.g. Add emergency contact", text: $placeholder)
                    }
                    Section("Type") {
                        Picker("Type", selection: $fieldType) {
                            ForEach(CustomFieldType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                    }
                } else {
                    Section("Field Label") {
                        TextField("e.g. Parent Name", text: $label)
                    }
                    Section("Field Type") {
                        Picker("Type", selection: $fieldType) {
                            ForEach(CustomFieldType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                    }
                    Section("Placeholder (optional)") {
                        TextField("Hint text", text: $placeholder)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(isEditing ? "Edit Field" : "Add Field")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveField()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canSave)
                }
            }
            .onAppear {
                if let field = editingField {
                    label = field.label
                    fieldType = field.type
                    placeholder = field.placeholder
                }
            }
        }
    }
    
    private func saveField() {
        let fieldLabel = simplified
            ? placeholder.trimmingCharacters(in: .whitespaces)
            : label.trimmingCharacters(in: .whitespaces)
        guard !fieldLabel.isEmpty else { return }
        
        if let existing = editingField {
            let updated = CustomField(id: existing.id, label: fieldLabel, type: fieldType, placeholder: placeholder)
            if let index = fields.firstIndex(where: { $0.id == existing.id }) {
                fields[index] = updated
            }
        } else {
            fields.append(CustomField(
                label: fieldLabel,
                type: fieldType,
                placeholder: simplified ? fieldLabel : placeholder
            ))
        }
        dismiss()
    }
}

