import SwiftUI

struct AttendanceCalendarView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMonth = Date()
    
    private let calendar = Calendar.current
    private let daysInWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    // MARK: - Computed Properties
    
    private var monthDates: [Date?] {
        guard let monthRange = calendar.range(of: .day, in: .month, for: selectedMonth),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth))
        else { return [] }
        
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let leadingEmptyDays = firstWeekday - 1
        
        var dates: [Date?] = Array(repeating: nil, count: leadingEmptyDays)
        
        for day in monthRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                dates.append(date)
            }
        }
        
        return dates
    }
    
    private func attendanceFor(date: Date) -> (present: Int, total: Int, percentage: Double)? {
        let stats = AttendanceStorage.records(for: date)
        guard !stats.isEmpty else { return nil }
        let total = stats.count
        let present = stats.values.filter { $0 }.count
        let percentage = Double(present) / Double(total) * 100
        return (present, total, percentage)
    }

    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Month Selector Card
                    VStack(spacing: 20) {
                        HStack {
                            Button {
                                withAnimation { changeMonth(by: -1) }
                            } label: {
                                Image(systemName: "chevron.left.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.appTheme)
                            }
                            
                            Spacer()
                            
                            Text(selectedMonth.formatted(.dateTime.month(.wide).year()))
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            Button {
                                withAnimation { changeMonth(by: 1) }
                            } label: {
                                Image(systemName: "chevron.right.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.appTheme)
                            }
                        }
                        
                        Divider()
                        
                        // Calendar Grid
                        VStack(spacing: 0) {
                            // Weekday labels
                            HStack(spacing: 0) {
                                ForEach(daysInWeek, id: \.self) { day in
                                    Text(day)
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.secondary)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.bottom, 12)
                            
                            // Days grid
                            let dates = monthDates
                            let rows = Int(ceil(Double(dates.count) / 7.0))
                            
                            VStack(spacing: 0) {
                                ForEach(0..<rows, id: \.self) { row in
                                    HStack(spacing: 0) {
                                        ForEach(0..<7, id: \.self) { column in
                                            let index = row * 7 + column
                                            if index < dates.count {
                                                DayCell(date: dates[index], stats: dates[index].flatMap { attendanceFor(date: $0) })
                                            } else {
                                                Color.clear
                                                    .frame(maxWidth: .infinity)
                                                    .aspectRatio(1, contentMode: .fill)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                        
                    // Legend Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Performance Key")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        
                        HStack(spacing: 20) {
                            LegendItem(color: .green, label: "75%+")
                            LegendItem(color: .orange, label: "50-74%")
                            LegendItem(color: .red, label: "<50%")
                            LegendItem(color: Color(.quaternaryLabel), label: "Empty")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Calendar View")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
    
    private func changeMonth(by amount: Int) {
        if let newDate = calendar.date(byAdding: .month, value: amount, to: selectedMonth) {
            selectedMonth = newDate
        }
    }
}

private struct DayCell: View {
    let date: Date?
    let stats: (present: Int, total: Int, percentage: Double)?
    
    var body: some View {
        VStack(spacing: 4) {
            if let date = date {
                let isToday = Calendar.current.isDateInToday(date)
                
                ZStack {
                    if isToday {
                        Circle()
                            .fill(Color.appTheme.opacity(0.15))
                            .frame(width: 28, height: 28)
                    }
                    
                    Text(Calendar.current.component(.day, from: date).description)
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(isToday ? .bold : .medium)
                        .foregroundStyle(isToday ? .appTheme : .primary)
                }
                
                if let stats = stats {
                    Circle()
                        .fill(colorFor(stats.percentage))
                        .frame(width: 6, height: 6)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 6, height: 6)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fill)
    }
    
    private func colorFor(_ pct: Double) -> Color {
        if pct >= 75 { return .green }
        if pct >= 50 { return .orange }
        return .red
    }
}

private struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            Text(label)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    AttendanceCalendarView()
}
