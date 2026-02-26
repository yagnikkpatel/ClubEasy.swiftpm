import Foundation

enum AttendanceStorage {
    private static let key = "savedAttendance"
    
    private static var calendar: Calendar { .current }
    
    static func records(for date: Date) -> [UUID: Bool] {
        let startOfDay = calendar.startOfDay(for: date)
        let all = loadAll()
        return all
            .filter { calendar.isDate($0.date, inSameDayAs: startOfDay) }
            .reduce(into: [UUID: Bool]()) { $0[$1.studentId] = $1.isPresent }
    }
    
    static func save(records: [AttendanceRecord]) {
        var all = loadAll()
        let newDates = Set(records.map { calendar.startOfDay(for: $0.date) })
        all.removeAll { record in
            newDates.contains(calendar.startOfDay(for: record.date))
        }
        all.append(contentsOf: records)
        guard let data = try? encoder.encode(all) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
    
    static func save(date: Date, attendance: [UUID: Bool]) {
        let startOfDay = calendar.startOfDay(for: date)
        let records = attendance.map { AttendanceRecord(date: startOfDay, studentId: $0.key, isPresent: $0.value) }
        var all = loadAll()
        all.removeAll { calendar.isDate($0.date, inSameDayAs: startOfDay) }
        all.append(contentsOf: records)
        guard let data = try? encoder.encode(all) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
    
    static func delete(for date: Date) {
        let startOfDay = calendar.startOfDay(for: date)
        var all = loadAll()
        all.removeAll { calendar.isDate($0.date, inSameDayAs: startOfDay) }
        guard let data = try? encoder.encode(all) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
    
    static func hasAttendance(for date: Date) -> Bool {
        !records(for: date).isEmpty
    }
    
    static func datesWithAttendance() -> [Date] {
        let all = loadAll()
        let dates = Set(all.map { calendar.startOfDay(for: $0.date) })
        return dates.sorted()
    }
    
    /// Returns (presentCount, totalCount) for a student across all attendance records.
    static func attendanceStats(for studentId: UUID) -> (present: Int, total: Int) {
        let all = loadAll()
        let studentRecords = all.filter { $0.studentId == studentId }
        let total = studentRecords.count
        let present = studentRecords.filter { $0.isPresent }.count
        return (present, total)
    }
    
    /// Returns daily attendance percentage for each date in range. Empty days return 0.
    static func dailyAttendancePercentages(from start: Date, to end: Date) -> [(date: Date, percentage: Double)] {
        let cal = calendar
        var result: [(Date, Double)] = []
        var current = cal.startOfDay(for: start)
        let endDay = cal.startOfDay(for: end)
        while current <= endDay {
            let recs = records(for: current)
            let pct = recs.isEmpty ? 0 : Double(recs.values.filter { $0 }.count) / Double(recs.count) * 100
            result.append((current, pct))
            guard let next = cal.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        return result
    }
    
    /// Returns monthly attendance percentages for the last N months.
    static func monthlyAttendancePercentages(months: Int = 12) -> [(monthStart: Date, percentage: Double)] {
        let cal = calendar
        var result: [(Date, Double)] = []
        for i in (0..<months).reversed() {
            guard let refDate = cal.date(byAdding: .month, value: -i, to: Date()),
                  let monthStart = cal.date(from: cal.dateComponents([.year, .month], from: refDate)),
                  let nextMonth = cal.date(byAdding: .month, value: 1, to: monthStart),
                  let monthEnd = cal.date(byAdding: .day, value: -1, to: nextMonth)
            else { continue }
            let daily = dailyAttendancePercentages(from: monthStart, to: monthEnd)
            let withData = daily.filter { $0.percentage > 0 }
            let avg = withData.isEmpty ? 0 : withData.map(\.percentage).reduce(0, +) / Double(withData.count)
            result.append((monthStart, avg))
        }
        return result
    }
    
    private static func loadAll() -> [AttendanceRecord] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? decoder.decode([AttendanceRecord].self, from: data) else {
            return []
        }
        return decoded
    }
    
    private static var encoder: JSONEncoder {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }
    
    private static var decoder: JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }
}
