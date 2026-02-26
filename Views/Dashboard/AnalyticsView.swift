import SwiftUI
import Charts

struct AnalyticsView: View {
    @State private var projects: [Project] = ProjectStorage.load()
    @State private var students: [Student] = StudentStorage.load()
    
    private var totalProjects: Int { projects.count }
    private var teamProjects: Int { projects.filter { $0.assignmentType == .team }.count }
    private var individualProjects: Int { projects.filter { $0.assignmentType == .individual }.count }
    private var completedProjects: Int { projects.filter { $0.status == .completed }.count }
    private var inProgressProjects: Int { projects.filter { $0.status == .inProgress }.count }
    
    private var performanceScore: Int {
        guard totalProjects > 0 else { return 0 }
        let completedWeight = completedProjects * 100
        let inProgressWeight = inProgressProjects * 50
        let totalWeight = totalProjects * 100
        return min(100, (completedWeight + inProgressWeight) / totalProjects)
    }
    
    private var completionRate: Double {
        guard totalProjects > 0 else { return 0 }
        return Double(completedProjects) / Double(totalProjects)
    }
    
    private var attendanceRate: Double {
        guard !students.isEmpty else { return 0 }
        let stats = students.map { AttendanceStorage.attendanceStats(for: $0.id) }
        let totalPresent = stats.map(\.present).reduce(0, +)
        let totalPossible = stats.map(\.total).reduce(0, +)
        return totalPossible > 0 ? Double(totalPresent) / Double(totalPossible) : 0
    }
    
    private var weeklyChartData: [WeeklyBarItem] {
        let cal = Calendar.current
        let today = Date()
        return (0..<7).reversed().compactMap { daysAgo -> WeeklyBarItem? in
            guard let date = cal.date(byAdding: .day, value: -daysAgo, to: today) else { return nil }
            let dayName = cal.shortWeekdaySymbols[cal.component(.weekday, from: date) - 1]
            let activeCount = projects.filter { project in
                cal.compare(project.startDate, to: date, toGranularity: .day) != .orderedDescending &&
                cal.compare(project.deadline, to: date, toGranularity: .day) != .orderedAscending
            }.count
            return WeeklyBarItem(day: dayName, count: activeCount, date: date)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                performanceHighlightCard
                statsGrid
                weeklyProgressChart
                circularProgressCard
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            projects = ProjectStorage.load()
            students = StudentStorage.load()
        }
    }
    
    private var performanceHighlightCard: some View {
        VStack(spacing: 8) {
            Text("\(performanceScore)%")
                .font(.system(size: 56, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            Text("Overall Performance")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    private var statsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            AnalyticsStatCard(value: "\(totalProjects)", label: "Total", icon: "folder.fill")
            AnalyticsStatCard(value: "\(teamProjects)", label: "Teams", icon: "person.3.fill")
            AnalyticsStatCard(value: "\(individualProjects)", label: "Individual", icon: "person.fill")
            AnalyticsStatCard(value: "\(completedProjects)", label: "Completed", icon: "checkmark.circle.fill")
            AnalyticsStatCard(value: "\(inProgressProjects)", label: "In Progress", icon: "arrow.clockwise")

        }
    }
    
    private var weeklyProgressChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Weekly Progress")
                .font(.headline)
                .foregroundStyle(.primary)
            
            Chart(weeklyChartData) { item in
                BarMark(
                    x: .value("Day", item.day),
                    y: .value("Active", item.count)
                )
                .foregroundStyle(Color(.tertiaryLabel))
                .cornerRadius(6)
            }
            .frame(height: 160)
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    private var circularProgressCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Progress Overview")
                .font(.headline)
                .foregroundStyle(.primary)
            
            HStack(spacing: 24) {
                CircularProgressView(value: attendanceRate, label: "Attendance", icon: "person.2.fill")
                CircularProgressView(value: completionRate, label: "Completion", icon: "checkmark.circle.fill")
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct WeeklyBarItem: Identifiable {
    let id = UUID()
    let day: String
    let count: Int
    let date: Date
}

struct AnalyticsStatCard: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.tertiarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct CircularProgressView: View {
    let value: Double
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color(.tertiarySystemFill), lineWidth: 8)
                    .frame(width: 80, height: 80)
                Circle()
                    .trim(from: 0, to: value)
                    .stroke(Color(.secondaryLabel), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        AnalyticsView()
    }
}
