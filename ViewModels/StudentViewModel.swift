import SwiftUI
import Combine

class StudentViewModel: ObservableObject {
    @Published var students: [Student] = []
    @Published var searchText: String = ""
    
    init() {
        loadStudents()
    }
    
    func loadStudents() {
        self.students = StudentStorage.load()
    }
    
    func saveStudents() {
        StudentStorage.save(students)
    }
    
    var filteredStudents: [Student] {
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        guard !query.isEmpty else { return students }
        return students.filter {
            $0.name.lowercased().contains(query) ||
            $0.enrollmentNumber.lowercased().contains(query) ||
            $0.department.lowercased().contains(query) ||
            $0.collegeEmail.lowercased().contains(query)
        }
    }
    
    var groupedStudents: [(key: String, students: [Student])] {
        let grouped = Dictionary(grouping: filteredStudents.sorted { $0.name < $1.name }) { student in
            String(student.name.prefix(1)).uppercased()
        }
        return grouped.sorted { $0.key < $1.key }.map { (key: $0.key, students: $0.value) }
    }
    
    func deleteStudents(at indexSet: IndexSet, from groupStudents: [Student]) {
        for index in indexSet {
            let studentToDelete = groupStudents[index]
            if let filename = studentToDelete.profileImageFileName {
                ProfileImageStorage.delete(filename: filename)
            }
            students.removeAll { $0.id == studentToDelete.id }
        }
        saveStudents()
    }
}
