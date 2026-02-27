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
    
    /// Returns daily attendance stats for each date in range.
    static func dailyAttendanceStats(from start: Date, to end: Date) -> [(date: Date, present: Int, total: Int, percentage: Double)] {
        let cal = calendar
        var result: [(Date, Int, Int, Double)] = []
        var current = cal.startOfDay(for: start)
        let endDay = cal.startOfDay(for: end)
        
        while current <= endDay {
            let recs = records(for: current)
            let total = recs.count
            let present = recs.values.filter { $0 }.count
            let pct = total > 0 ? Double(present) / Double(total) * 100 : 0
            
            result.append((current, present, total, pct))
            
            guard let next = cal.date(byAdding: .day, value: 1, to: current) else { break }
            current = next
        }
        return result
    }
    
    /// Returns monthly attendance stats for the specified year.
    static func monthlyAttendanceStats(in year: Date = Date()) -> [(monthStart: Date, present: Int, total: Int, percentage: Double)] {
        let cal = calendar
        guard let yearStart = cal.date(from: cal.dateComponents([.year], from: year)) else { return [] }
        
        var result: [(Date, Int, Int, Double)] = []
        
        for i in 0..<12 {
            guard let monthStart = cal.date(byAdding: .month, value: i, to: yearStart),
                  let nextMonth = cal.date(byAdding: .month, value: 1, to: monthStart),
                  let monthEnd = cal.date(byAdding: .day, value: -1, to: nextMonth)
            else { continue }
            
            let daily = dailyAttendanceStats(from: monthStart, to: monthEnd)
            let totalPresent = daily.map(\.present).reduce(0, +)
            let totalStudents = daily.map(\.total).reduce(0, +)
            let avgPct = totalStudents > 0 ? Double(totalPresent) / Double(totalStudents) * 100 : 0
            
            result.append((monthStart, totalPresent, totalStudents, avgPct))
        }
        return result
    }
    /// Returns weekly attendance stats for the specified month.
    static func weeklyAttendanceStats(for month: Date = Date()) -> [(label: String, present: Int, total: Int, percentage: Double, isToday: Bool)] {
        let cal = calendar
        let now = Date()
        guard let monthStart = cal.date(from: cal.dateComponents([.year, .month], from: month)),
              let monthRange = cal.range(of: .day, in: .month, for: monthStart) else { return [] }
        
        var result: [(String, Int, Int, Double, Bool)] = []
        let daysInMonth = monthRange.count
        let currentDayInMonth = cal.isDate(month, equalTo: now, toGranularity: .month) ? cal.component(.day, from: now) : -1
        
        let weekRanges = [1...7, 8...14, 15...21, 22...daysInMonth]
        
        for (index, range) in weekRanges.enumerated() {
            guard let startDate = cal.date(byAdding: .day, value: range.lowerBound - 1, to: monthStart),
                  let endDate = cal.date(byAdding: .day, value: min(range.upperBound - 1, daysInMonth - 1), to: monthStart)
            else { continue }
            
            let daily = dailyAttendanceStats(from: startDate, to: endDate)
            let totalPresent = daily.map(\.present).reduce(0, +)
            let totalStudents = daily.map(\.total).reduce(0, +)
            let avgPct = totalStudents > 0 ? Double(totalPresent) / Double(totalStudents) * 100 : 0
            
            let isCurrentWeek = cal.isDate(month, equalTo: now, toGranularity: .month) && range.contains(currentDayInMonth)
            
            result.append(("W\(index + 1)", totalPresent, totalStudents, avgPct, isCurrentWeek))
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
