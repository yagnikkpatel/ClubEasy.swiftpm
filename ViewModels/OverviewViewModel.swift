import SwiftUI
import Combine

class OverviewViewModel: ObservableObject {
    @Published var students: [Student] = []
    @Published var projects: [Project] = []
    @Published var refreshID = UUID()
    
    init() {
        refreshData()
    }
    
    func refreshData() {
        self.students = StudentStorage.load()
        self.projects = ProjectStorage.load()
        self.refreshID = UUID()
    }
    
    var studentsWithAttendance: [(student: Student, percentage: Int)] {
        students.compactMap { student in
            let (present, total) = AttendanceStorage.attendanceStats(for: student.id)
            guard total > 0 else { return nil }
            let pct = Int(round(Double(present) / Double(total) * 100))
            return (student, pct)
        }.sorted { $0.percentage > $1.percentage }
    }
    
    var performers75AndAbove: [(student: Student, percentage: Int)] {
        studentsWithAttendance.filter { $0.percentage >= 75 }
    }
    
    var topPerformers: [(student: Student, percentage: Int)] {
        Array(performers75AndAbove.prefix(5))
    }
    
    var attendanceRiskAll: [(student: Student, percentage: Int)] {
        studentsWithAttendance
            .filter { $0.percentage < 75 }
            .sorted { $0.percentage < $1.percentage }
    }
    
    var attendanceRiskTop5: [(student: Student, percentage: Int)] {
        Array(attendanceRiskAll.prefix(5))
    }
    
    var projectsDueToday: [Project] {
        let cal = Calendar.current
        return projects.filter { cal.isDateInToday($0.deadline) }
    }
    
    var projectProgress: (completed: Int, inProgress: Int) {
        let completed = projects.filter { $0.status == .completed }.count
        let inProgress = projects.filter { $0.status == .inProgress }.count
        return (completed, inProgress)
    }
}
