import SwiftUI
import UIKit

enum StudentLevel: String, CaseIterable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
}

enum PredefinedSkills {
    static let all: [String] = [
        "Swift",
        "SwiftUI",
        "UIKit",
        "Combine",
        "Swift Concurrency",
        "Core Data",
        "Core Animation",
        "Core ML",
        "Xcode",
        "Git",
        "REST APIs",
        "MVVM",
        "TestFlight",
        "App Store Connect",
        "WidgetKit",
        "SwiftData",
    ]
}

@MainActor
struct AddStudentView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var students: [Student]
    var editingStudent: Student? = nil
    
    @State private var selectedPhotoImage: UIImage?
    @State private var showCamera = false
    @State private var showPhotoLibrary = false
    @State private var name = ""
    @State private var enrollmentNumber = ""
    @State private var contactNumber = ""
    @State private var collegeEmail = ""
    @State private var year = ""
    @State private var programmingLevel: StudentLevel = .beginner
    @State private var department = ""
    @State private var selectedSkills: Set<String> = []
    @State private var customSkillText = ""
    @State private var showSkillPicker = false
    @State private var customFieldValues: [String: String] = [:]
    
    private var isEditing: Bool { editingStudent != nil }
    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                photoSection
                nameSection
                contactSection
                academicSection
                programmingLevelSection
                skillsSection
                customFieldsSection
            }
            .formStyle(.grouped)
            .navigationTitle(isEditing ? "Edit Profile" : "New Student")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveStudent()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canSave)
                }
            }
            .sheet(isPresented: $showSkillPicker) {
                SkillPickerView(
                    selectedSkills: $selectedSkills,
                    onDismiss: { showSkillPicker = false }
                )
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraPickerView(image: $selectedPhotoImage)
            }
            .fullScreenCover(isPresented: $showPhotoLibrary) {
                PhotoLibraryPickerView(image: $selectedPhotoImage)
            }
            .onAppear {
                if let student = editingStudent {
                    name = student.name
                    enrollmentNumber = student.enrollmentNumber
                    contactNumber = student.contactNumber
                    collegeEmail = student.collegeEmail
                    year = student.year
                    department = student.department
                    programmingLevel = StudentLevel(rawValue: student.level) ?? .beginner
                    selectedSkills = Set(student.skills)
                    customFieldValues = student.customFieldValues
                    if let filename = student.profileImageFileName,
                       let image = ProfileImageStorage.load(filename: filename) {
                        selectedPhotoImage = image
                    }
                }
            }
        }
    }
    
    private var customFieldsSection: some View {
        let sections = CustomFieldStorage.load()
        return Group {
            if !sections.isEmpty {
                CustomFieldsFormView(
                    values: $customFieldValues,
                    sections: sections,
                    isEditable: true,
                    excludeSectionNames: Set([
                        BuiltInSectionNames.personalInfo,
                        BuiltInSectionNames.contactInfo,
                        BuiltInSectionNames.academicInfo
                    ])
                )
            }
        }
    }
    
    private var photoSection: some View {
        Section {
            Button {
                showPhotoLibrary = true
            } label: {
                ZStack(alignment: .bottomTrailing) {
                    Group {
                        if let image = selectedPhotoImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [Color.primary.opacity(0.9), Color.primary.opacity(0.6)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2
                                        )
                                        .scaleEffect(1.12)
                                )
                        } else {
                            ZStack {
                                Circle()
                                    .fill(Color(.tertiarySystemFill))
                                    .frame(width: 120, height: 120)
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 52))
                                    .foregroundStyle(.secondary)
                            }
                            .overlay(
                                Circle()
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [Color.primary.opacity(0.8), Color.primary.opacity(0.5)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                                    .scaleEffect(1.12)
                            )
                        }
                    }
                    .overlay(alignment: .bottomTrailing) {
                        ZStack {
                            Circle()
                                .fill(Color.appTheme)
                                .frame(width: 24, height: 24)
                            Image(systemName: "pencil")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.white)
                        }
                        .offset(x: -2, y: -2)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
            .buttonStyle(.plain)
            .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
            .listRowBackground(Color.clear)
        }
    }
    
    private var nameSection: some View {
        Section("Name") {
            TextField("Full Name", text: $name)
                .textContentType(.name)
                .autocapitalization(.words)
        }
    }
    
    private var contactSection: some View {
        let sections = CustomFieldStorage.load()
        let contactFields = sections.first(where: { $0.name == BuiltInSectionNames.contactInfo })?.fields ?? []
        return Section("Contact Information") {
            TextField("Contact Number", text: $contactNumber)
                .keyboardType(.phonePad)
            TextField("College Email", text: $collegeEmail)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
            CustomFieldInputsView(fields: contactFields, values: $customFieldValues)
        }
    }
    
    private var academicSection: some View {
        let sections = CustomFieldStorage.load()
        let academicFields = sections.first(where: { $0.name == BuiltInSectionNames.academicInfo })?.fields ?? []
        let personalFields = sections.first(where: { $0.name == BuiltInSectionNames.personalInfo })?.fields ?? []
        return Section("Academic Information") {
            TextField("Enrollment Number", text: $enrollmentNumber)
                .keyboardType(.numberPad)
            TextField("Year", text: $year)
                .keyboardType(.numberPad)
            TextField("Department", text: $department)
                .autocapitalization(.words)
            CustomFieldInputsView(fields: academicFields + personalFields, values: $customFieldValues)
        }
    }
    
    private var programmingLevelSection: some View {
        Section {
            Picker("", selection: $programmingLevel) {
                ForEach(StudentLevel.allCases, id: \.self) { level in
                    Text(level.rawValue).tag(level)
                }
            }
            .pickerStyle(.segmented)
        } header: {
            Text("Programming Level")
        } footer: {
            Text("Swift programming skill level for judging.")
        }
    }
    
    private var skillsSection: some View {
        Section {
            Button {
                showSkillPicker = true
            } label: {
                Label("Add Skill", systemImage: "plus.circle.fill")
            }
            HStack(spacing: 12) {
                TextField("Custom skill", text: $customSkillText)
                    .textInputAutocapitalization(.words)
                Button("Add") {
                    let trimmed = customSkillText.trimmingCharacters(in: .whitespaces)
                    if !trimmed.isEmpty {
                        selectedSkills.insert(trimmed)
                        customSkillText = ""
                    }
                }
                .fontWeight(.medium)
                .foregroundStyle(Color.appTheme)
                .disabled(customSkillText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            ForEach(selectedSkills.sorted(), id: \.self) { skill in
                HStack {
                    Text(skill)
                    Spacer()
                    Button(role: .destructive) {
                        selectedSkills.remove(skill)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.plain)
                }
            }
        } header: {
            Text("Skills")
        } footer: {
            Text("Add from predefined Swift/iOS skills or enter a custom skill.")
        }
    }
    
    private func saveStudent() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        let initials = trimmedName
            .split(separator: " ")
            .compactMap { $0.first }
            .prefix(2)
            .map { String($0).uppercased() }
            .joined()
        
        let studentId = editingStudent?.id ?? UUID()
        var profileImageFileName: String? = editingStudent?.profileImageFileName
        if let image = selectedPhotoImage {
            if let oldFilename = editingStudent?.profileImageFileName {
                ProfileImageStorage.delete(filename: oldFilename)
            }
            profileImageFileName = ProfileImageStorage.save(image, for: studentId)
        }
        
        let updatedStudent = Student(
            id: studentId,
            name: trimmedName,
            level: programmingLevel.rawValue,
            initials: initials.isEmpty ? "?" : initials,
            enrollmentNumber: enrollmentNumber.trimmingCharacters(in: .whitespaces),
            skills: Array(selectedSkills).sorted(),
            contactNumber: contactNumber.trimmingCharacters(in: .whitespaces),
            department: department.trimmingCharacters(in: .whitespaces),
            collegeEmail: collegeEmail.trimmingCharacters(in: .whitespaces),
            year: year.trimmingCharacters(in: .whitespaces),
            profileImageFileName: profileImageFileName,
            customFieldValues: customFieldValues
        )
        
        if let index = students.firstIndex(where: { $0.id == studentId }) {
            students[index] = updatedStudent
        } else {
            students.append(updatedStudent)
        }
        dismiss()
    }
}


struct SkillRowView: View {
    let skill: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(skill)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.appTheme)
                }
            }
        }
    }
}

struct SkillPickerView: View {
    @Binding var selectedSkills: Set<String>
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(0..<PredefinedSkills.all.count, id: \.self) { index in
                    SkillRowView(
                        skill: PredefinedSkills.all[index],
                        isSelected: selectedSkills.contains(PredefinedSkills.all[index]),
                        onTap: {
                            let skill = PredefinedSkills.all[index]
                            if selectedSkills.contains(skill) {
                                selectedSkills.remove(skill)
                            } else {
                                selectedSkills.insert(skill)
                            }
                        }
                    )
                }
            }
            .navigationTitle("Add Skills")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onDismiss()
                    }
                }
            }
        }
    }
}

struct PhotoLibraryPickerView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: PhotoLibraryPickerView
        
        init(_ parent: PhotoLibraryPickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

struct CameraPickerView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPickerView
        
        init(_ parent: CameraPickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    AddStudentView(students: .constant([]))
}
