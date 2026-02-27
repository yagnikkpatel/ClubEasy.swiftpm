import SwiftUI

enum ProjectsFilter: String {
    case completed
    case inProgress
    case dueToday
    case tasksToComplete
    
    var title: String {
        switch self {
        case .completed: return "Completed"
        case .inProgress: return "In Progress"
        case .dueToday: return "Due Today"
        case .tasksToComplete: return "Tasks to Complete"
        }
    }
}

struct OverviewDashboard: View {
    @Binding var selectedTab: AppTab
    @Binding var projectFilterToShow: ProjectsFilter?
    @Binding var projects: [Project]
    @State private var students: [Student] = StudentStorage.load()
    @State private var refreshID = UUID()
    @State private var clubSubtitle: String = ClubSettingsStorage.subtitle
    @State private var selectedTimeRange: AttendanceTimeRange = .daily
    @State private var showCalendarView = false
    
    enum AttendanceTimeRange: String, CaseIterable, Identifiable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        var id: Self { self }
    }
    
    // MARK: - Computed Properties
    
    private var studentsWithAttendance: [(student: Student, percentage: Int)] {
        students.compactMap { student in
            let (present, total) = AttendanceStorage.attendanceStats(for: student.id)
            guard total > 0 else { return nil }
            let pct = Int(round(Double(present) / Double(total) * 100))
            return (student, pct)
        }.sorted { $0.percentage > $1.percentage }
    }
    
    private var performers75AndAbove: [(student: Student, percentage: Int)] {
        studentsWithAttendance.filter { $0.percentage >= 75 }
    }
    
    private var topPerformers: [(student: Student, percentage: Int)] {
        Array(performers75AndAbove.prefix(5))
    }
    
    private var attendanceRiskAll: [(student: Student, percentage: Int)] {
        studentsWithAttendance
            .filter { $0.percentage < 75 }
            .sorted { $0.percentage < $1.percentage }
    }
    
    private var attendanceRiskTop5: [(student: Student, percentage: Int)] {
        Array(attendanceRiskAll.prefix(5))
    }
    
    private var projectsDueToday: [Project] {
        let cal = Calendar.current
        return projects.filter { cal.isDateInToday($0.deadline) }
    }
    
    private var projectProgress: (completed: Int, inProgress: Int) {
        let completed = projects.filter { $0.status == .completed }.count
        let inProgress = projects.filter { $0.status == .inProgress }.count
        return (completed, inProgress)
    }

    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if !clubSubtitle.isEmpty {
                    Text(clubSubtitle)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.appTheme)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 4)
                        .padding(.top, -28)
                        .padding(.bottom, -8)
                }
                
                statCardsSection
                projectProgressSection
                attendanceTrendsSection
                projectsDueSection
                topPerformersSection
                attendanceRiskSection
            }
            .padding(.vertical, 20)
            .padding(.horizontal, 16)
            .id(refreshID)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Swift Coding Club")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            students = StudentStorage.load()
            projects = ProjectStorage.load()
            clubSubtitle = ClubSettingsStorage.subtitle
            refreshID = UUID()
        }
    }
}

// MARK: - Dashboard Sections

extension OverviewDashboard {
    
    private var statCardsSection: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            OverviewStatCardRow(value: "\(students.count)", label: "Total Students", icon: "person.2.fill", iconColor: .appTheme)
            OverviewStatCardRow(value: "\(projectProgress.completed)", label: "Completed", icon: "checkmark.circle.fill", iconColor: .green)
            OverviewStatCardRow(value: "\(projectProgress.inProgress)", label: "In Progress", icon: "arrow.clockwise", iconColor: .appTheme)
            OverviewStatCardRow(value: "\(projectsDueToday.count)", label: "Due Today", icon: "calendar.badge.clock", iconColor: .purple)
        }
    }
    
    private var attendanceTrendsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Attendance Trends")
                        .font(.headline)
                        .foregroundStyle(Color.primary)
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        Button {
                            selectedTimeRange = .daily
                            refreshID = UUID()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                                .font(.title3)
                                .foregroundStyle(.appTheme)
                        }
                        
                        Button {
                            showCalendarView = true
                        } label: {
                            Image(systemName: "calendar")
                                .font(.title3)
                                .foregroundStyle(.appTheme)
                        }
                    }
                }
                
                Picker("Range", selection: $selectedTimeRange) {
                    ForEach(AttendanceTimeRange.allCases) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            AttendanceTrendsChart(
                range: selectedTimeRange
            )
        }
        .sheet(isPresented: $showCalendarView) {
            AttendanceCalendarView()
        }
    }
    
    private var attendanceRiskSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.subheadline)
                        .foregroundStyle(Color.red)
                    Text("Attendance Risk")
                        .font(.headline)
                        .foregroundStyle(Color.primary)
                }
                Spacer()
                NavigationLink {
                    AttendanceRiskAllView(performers: attendanceRiskAll)
                } label: {
                    HStack(spacing: 4) {
                        Text("View All")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(Color.primary)
                }
                .buttonStyle(.plain)
            }
            if attendanceRiskAll.isEmpty {
                Text("No students below 75% attendance")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(attendanceRiskTop5.enumerated()), id: \.element.student.id) { index, item in
                        AttendanceRiskRow(student: item.student, percentage: item.percentage)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                        if index < attendanceRiskTop5.count - 1 {
                            Divider()
                                .padding(.leading, 20)
                        }
                    }
                }
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
    
    private var topPerformersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "trophy.fill")
                        .font(.subheadline)
                        .foregroundStyle(Color.green)
                    Text("Top Performers")
                        .font(.headline)
                        .foregroundStyle(Color.primary)
                }
                Spacer()
                NavigationLink {
                    TopPerformersAllView(performers: performers75AndAbove)
                } label: {
                    HStack(spacing: 4) {
                        Text("View All")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(Color.primary)
                }
                .buttonStyle(.plain)
            }
            if topPerformers.isEmpty {
                Text("No attendance data yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(topPerformers.enumerated()), id: \.element.student.id) { index, item in
                        TopPerformerRow(student: item.student, percentage: item.percentage)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                        if index < topPerformers.count - 1 {
                            Divider()
                                .padding(.leading, 20)
                        }
                    }
                }
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
    
    private var projectsDueSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.subheadline)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(Color.purple)
                    Text("Projects Due Today")
                        .font(.headline)
                        .foregroundStyle(Color.primary)
                }
                Spacer()
                NavigationLink {
                    ProjectsFilteredListView(projects: $projects, filter: .dueToday)
                } label: {
                    HStack(spacing: 4) {
                        Text("View All")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(Color.primary)
                }
                .buttonStyle(.plain)
            }
            if projectsDueToday.isEmpty {
                Text("No projects due today")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                VStack(spacing: 0) {
                    ForEach(projectsDueToday) { project in
                        NavigationLink {
                            ProjectDetailView(project: project, projects: $projects)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(project.name)
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundStyle(Color.primary)
                                    Text(project.displayTeamName)
                                        .font(.subheadline)
                                        .foregroundStyle(Color.primary)
                                }
                                Spacer()
                                Image(systemName: project.status.statusIcon)
                                    .font(.body)
                                    .foregroundStyle(project.status.statusColor)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                    }
                }
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
    
    private var projectProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Project Progress Overview")
                    .font(.headline)
                    .foregroundStyle(Color.primary)
                Spacer()
                NavigationLink {
                    ProjectsFilteredListView(projects: $projects, filter: .tasksToComplete)
                } label: {
                    HStack(spacing: 4) {
                        Text("View All")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(Color.primary)
                }
                .buttonStyle(.plain)
            }
            ProjectProgressChart(completed: projectProgress.completed, inProgress: projectProgress.inProgress)
        }
    }
}

// MARK: - Subviews & Components

struct OverviewStatCardRow: View {
    let value: String
    let label: String
    let icon: String
    var iconColor: Color = .secondary
    
    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(iconColor)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            Spacer(minLength: 0)
        }
        .frame(minHeight: 72)
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct AttendanceTrendsChart: View {
    let range: OverviewDashboard.AttendanceTimeRange
    
    @State private var animateProgress: Double = 0
    
    private var chartConfig: (barWidth: CGFloat, spacing: CGFloat, fontSize: CGFloat, showScroll: Bool) {
        return (24, 6, 8, true)
    }
    
    private var data: [(label: String, percentage: Double, present: Int, total: Int, isToday: Bool)] {
        let cal = Calendar.current
        let now = Date()
        
        switch range {
        case .daily:
            // Full current month detail
            guard let monthStart = cal.date(from: cal.dateComponents([.year, .month], from: now)),
                  let monthRange = cal.range(of: .day, in: .month, for: monthStart) else { return [] }
            
            let monthEnd = cal.date(byAdding: .day, value: monthRange.count - 1, to: monthStart)!
            let stats = AttendanceStorage.dailyAttendanceStats(from: monthStart, to: monthEnd)
            
            let df = DateFormatter()
            df.dateFormat = "d"
            
            return stats.map { stat in
                let isToday = cal.isDateInToday(stat.date)
                let label = df.string(from: stat.date)
                return (label: label, percentage: stat.percentage, present: stat.present, total: stat.total, isToday: isToday)
            }
            
        case .weekly:
            // Weeks of the current month
            let stats = AttendanceStorage.weeklyAttendanceStats()
            return stats.map { (label: $0.label, percentage: $0.percentage, present: $0.present, total: $0.total, isToday: $0.isToday) }
            
        case .monthly:
            // Months of the year
            let stats = AttendanceStorage.monthlyAttendanceStats()
            let df = DateFormatter()
            df.dateFormat = "MMM"
            return stats.map { 
                let isCurrentMonth = cal.isDate($0.monthStart, equalTo: now, toGranularity: .month)
                return (label: df.string(from: $0.monthStart), percentage: $0.percentage, present: $0.present, total: $0.total, isToday: isCurrentMonth)
            }
            
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if data.isEmpty {
                emptyState
            } else {
                chartContent
                summaryInfo
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animateProgress = 1
            }
        }
    }
    
    private var emptyState: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "chart.bar.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.quaternary)
                Text("No attendance records found")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 40)
            Spacer()
        }
    }
    
    private var chartContent: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                ZStack(alignment: .bottomLeading) {
                    // Background grid lines
                    VStack {
                        ForEach(0...4, id: \.self) { i in
                            Divider().opacity(0.3)
                            if i < 4 { Spacer() }
                        }
                    }
                    .frame(height: 120)
                    .padding(.bottom, 32)
                    
                    HStack(alignment: .bottom, spacing: chartConfig.spacing) {
                        ForEach(Array(data.enumerated()), id: \.offset) { index, item in
                            VStack(spacing: 8) {
                                ZStack(alignment: .bottom) {
                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                        .fill(Color(.quaternaryLabel).opacity(0.3))
                                        .frame(width: chartConfig.barWidth, height: 120)
                                    
                                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                                        .fill(colorFor(item.percentage))
                                        .frame(width: chartConfig.barWidth, height: max(6, CGFloat(item.percentage / 100 * 120) * animateProgress))
                                }
                                .id(item.isToday ? "today" : "\(index)")
                                
                                Text(item.label)
                                    .font(.system(size: chartConfig.fontSize, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundStyle(item.isToday ? .appTheme : .secondary)
                                    .frame(width: chartConfig.barWidth + chartConfig.spacing)
                                    .lineLimit(1)
                                    .fixedSize()
                            }
                        }
                    }
                    .frame(minWidth: UIScreen.main.bounds.width - 72, alignment: .leading)
                    .padding(.horizontal, 4)
                }
            }
            .disabled(!chartConfig.showScroll)
            .onAppear {
                if range == .daily {
                    scrollToToday(proxy: proxy)
                }
            }
        }
    }
    
    private func scrollToToday(proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                proxy.scrollTo("today", anchor: .leading)
            }
        }
    }
    
    
    private var summaryInfo: some View {
        Group {
            let displayItem = data.first(where: { $0.isToday }) ?? data.last
            if let item = displayItem {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.isToday ? "Today's Status" : "Latest Update")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundStyle(.appTheme)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.appTheme.opacity(0.1))
                            .clipShape(Capsule())
                        
                        if item.total > 0 {
                            Text("\(item.present) / \(item.total) students present")
                                .font(.subheadline)
                                .fontWeight(.bold)
                        } else {
                            Text("No attendance recorded")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 0) {
                        Text("\(Int(round(item.percentage)))%")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(item.total > 0 ? colorFor(item.percentage) : .secondary)
                        Text(range == .monthly ? "Yearly Avg" : "Accuracy")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 8)
            }
        }
    }
    
    private func colorFor(_ pct: Double) -> Color {
        if pct >= 75 { return .green }
        if pct >= 50 { return .orange }
        return .red
    }
}

struct ProjectsFilteredListView: View {
    @Binding var projects: [Project]
    let filter: ProjectsFilter
    
    private var filteredProjects: [Project] {
        let cal = Calendar.current
        switch filter {
        case .completed:
            return projects.filter { $0.status == .completed }
        case .inProgress:
            return projects.filter { $0.status == .inProgress }
        case .dueToday:
            return projects.filter { cal.isDateInToday($0.deadline) }
        case .tasksToComplete:
            return projects.filter { $0.status == .inProgress }
        }
    }
    
    var body: some View {
        List {
            if filteredProjects.isEmpty {
                ContentUnavailableView("No Projects", systemImage: "folder", description: Text("No projects match this filter"))
                    .listRowBackground(Color.clear)
            } else {
                ForEach(filteredProjects) { project in
                    NavigationLink {
                        ProjectDetailView(project: project, projects: $projects)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(project.name)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color.primary)
                                Text(project.displayTeamName)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.primary)
                            }
                            Spacer()
                            Image(systemName: project.status.statusIcon)
                                .font(.body)
                                .foregroundStyle(project.status.statusColor)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(filter.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TopPerformerRow: View {
    let student: Student
    let percentage: Int
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.green)
                .frame(width: 8, height: 8)
            Text(student.name)
                .font(.body)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .lineLimit(1)
            Spacer()
            Text("\(percentage)%")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
    }
}

struct TopPerformersAllView: View {
    let performers: [(student: Student, percentage: Int)]
    
    var body: some View {
        Group {
            if performers.isEmpty {
                ContentUnavailableView("No Data", systemImage: "person.2.slash", description: Text("No attendance data available yet"))
            } else {
                List {
                    ForEach(Array(performers.enumerated()), id: \.element.student.id) { index, item in
                        HStack {
                            Text("\(index + 1)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                                .frame(width: 24, alignment: .leading)
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 8, height: 8)
                                Text(item.student.name)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                            }
                            Spacer()
                            Text("\(item.percentage)%")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("All Performers")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AttendanceRiskAllView: View {
    let performers: [(student: Student, percentage: Int)]
    
    var body: some View {
        Group {
            if performers.isEmpty {
                ContentUnavailableView("No Risk", systemImage: "checkmark.circle", description: Text("No students currently below 75% attendance"))
            } else {
                List {
                    ForEach(Array(performers.enumerated()), id: \.element.student.id) { index, item in
                        HStack {
                            Text("\(index + 1)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                                .frame(width: 24, alignment: .leading)
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 8, height: 8)
                                Text(item.student.name)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                            }
                            Spacer()
                            Text("\(item.percentage)%")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Attendance Risk")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AttendanceRiskRow: View {
    let student: Student
    let percentage: Int
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.red)
                .frame(width: 8, height: 8)
            Text(student.name)
                .font(.body)
                .foregroundStyle(.primary)
            Spacer()
            Text("\(percentage)%")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

struct ProjectProgressChart: View {
    let completed: Int
    let inProgress: Int
    @State private var appeared = false
    
    private var total: Int { completed + inProgress }
    private var completedPct: Double { total > 0 ? Double(completed) / Double(total) : 0 }
    private var inProgressPct: Double { total > 0 ? Double(inProgress) / Double(total) : 0 }
    private var centerPercentage: Int { Int(round(completedPct * 100)) }
    
    var body: some View {
        HStack(spacing: 32) {
            ZStack {
                Circle()
                    .stroke(Color(.quaternaryLabel), style: StrokeStyle(lineWidth: 14))
                    .frame(width: 100, height: 100)
                
                Circle()
                    .trim(from: 0, to: appeared ? completedPct : 0)
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                
                Circle()
                    .trim(from: completedPct, to: appeared ? completedPct + inProgressPct : completedPct)
                    .stroke(Color.appTheme, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: -2) {
                    Text("\(centerPercentage)%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    Text("Done")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 100)
            
            VStack(alignment: .leading, spacing: 12) {
                ChartLegendRow(label: "Completed", count: completed, color: .green, percentage: Int(round(completedPct * 100)))
                ChartLegendRow(label: "In Progress", count: inProgress, color: .appTheme, percentage: Int(round(inProgressPct * 100)))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                appeared = true
            }
        }
    }
}

struct ChartLegendRow: View {
    let label: String
    let count: Int
    let color: Color
    let percentage: Int
    
    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 4) {
                    Text("\(count)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    Text("(\(percentage)%)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        OverviewDashboard(
            selectedTab: .constant(.overview),
            projectFilterToShow: .constant(nil),
            projects: .constant(ProjectStorage.load())
        )
    }
}
