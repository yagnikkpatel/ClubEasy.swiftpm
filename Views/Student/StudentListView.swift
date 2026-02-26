import SwiftUI

struct StudentListView: View {
    @State private var showAddStudent = false
    @State private var searchText = ""
    @State private var students: [Student] = StudentStorage.load()
    
    private var filteredStudents: [Student] {
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        guard !query.isEmpty else { return students }
        return students.filter {
            $0.name.lowercased().contains(query) ||
            $0.enrollmentNumber.lowercased().contains(query) ||
            $0.department.lowercased().contains(query) ||
            $0.collegeEmail.lowercased().contains(query)
        }
    }
    
    private var groupedStudents: [(key: String, students: [Student])] {
        let grouped = Dictionary(grouping: filteredStudents.sorted { $0.name < $1.name }) { student in
            String(student.name.prefix(1)).uppercased()
        }
        return grouped.sorted { $0.key < $1.key }.map { (key: $0.key, students: $0.value) }
    }
    
    var body: some View {
        studentList
            .listStyle(.insetGrouped)
            .listSectionSpacing(.compact)
            .navigationTitle("Students")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search students")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddStudent = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddStudent) {
                AddStudentView(students: $students)
            }
            .onChange(of: students) { _, newStudents in
                StudentStorage.save(newStudents)
            }
    }
    
    private var studentList: some View {
        List {
            ForEach(groupedStudents, id: \.key) { group in
                studentSection(group: group)
            }
        }
    }
    
    private func studentSection(group: (key: String, students: [Student])) -> some View {
        Section(group.key) {
            ForEach(group.students) { student in
                NavigationLink {
                    StudentDetailView(student: student, students: $students)
                } label: {
                    StudentRow(student: student)
                }
            }
            .onDelete { indexSet in
                deleteStudents(at: indexSet, from: group.students)
            }
        }
    }
    
    private func deleteStudents(at indexSet: IndexSet, from groupStudents: [Student]) {
        for index in indexSet {
            let studentToDelete = groupStudents[index]
            if let filename = studentToDelete.profileImageFileName {
                ProfileImageStorage.delete(filename: filename)
            }
            students.removeAll { $0.id == studentToDelete.id }
        }
    }
}

struct StudentRow: View {
    let student: Student
    
    private func firstLetter(of name: String) -> String {
        guard let first = name.first else { return "" }
        return String(first).uppercased()
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Group {
                if let filename = student.profileImageFileName,
                   let image = ProfileImageStorage.load(filename: filename) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                        .clipShape(Circle())
                } else {
                    ZStack {
                        Circle()
                            .fill(Color(.tertiarySystemFill))
                            .frame(width: 44, height: 44)
                        Text(firstLetter(of: student.name))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(student.name)
                    .font(.headline)
                Text(student.level)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        StudentListView()
    }
}
