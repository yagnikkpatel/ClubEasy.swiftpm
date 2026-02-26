import SwiftUI
import Combine

class AttendanceViewModel: ObservableObject {
    @Published var hasAttendance: Bool = false
    @Published var refreshTrigger: Int = 0
    
    init() {
        checkAttendance()
    }
    
    func checkAttendance() {
        self.hasAttendance = !AttendanceStorage.datesWithAttendance().isEmpty
    }
    
    func refresh() {
        refreshTrigger += 1
        checkAttendance()
    }
}
