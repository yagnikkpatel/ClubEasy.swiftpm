import Foundation

struct AttendanceRecord: Codable, Equatable {
    let date: Date
    let studentId: UUID
    let isPresent: Bool
}
