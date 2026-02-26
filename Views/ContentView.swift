import SwiftUI

enum AppTab: Int, CaseIterable {
    case overview = 0
    case students = 1
    case attendance = 2
    case projects = 3
    case settings = 4
}

struct ContentView: View {
    @State private var selectedTab: AppTab = .overview
    @State private var projectFilterToShow: ProjectsFilter? = nil
    @State private var projects: [Project] = ProjectStorage.load()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Overview", systemImage: "square.grid.2x2.fill", value: AppTab.overview) {
                OverviewTab(selectedTab: $selectedTab, projectFilterToShow: $projectFilterToShow, projects: $projects)
            }
            Tab("Students", systemImage: "person.2.fill", value: AppTab.students) {
                NavigationStack {
                    StudentListView()
                }
            }
            Tab("Attendance", systemImage: "checkmark.circle.fill", value: AppTab.attendance) {
                NavigationStack {
                    AttendanceView()
                }
            }
            Tab("Projects", systemImage: "folder.fill", value: AppTab.projects) {
                NavigationStack {
                    ProjectsTabContent(projectFilterToShow: $projectFilterToShow, projects: $projects)
                }
            }
            Tab("Settings", systemImage: "gearshape.fill", value: AppTab.settings) {
                NavigationStack {
                    SettingsView()
                }
            }
        }
        .onChange(of: projects) { _, newProjects in
            ProjectStorage.save(newProjects)
        }
        .onChange(of: selectedTab) { _, newTab in
            if newTab != .projects {
                projectFilterToShow = nil
            }
        }
    }
}

struct OverviewTab: View {
    @Binding var selectedTab: AppTab
    @Binding var projectFilterToShow: ProjectsFilter?
    @Binding var projects: [Project]
    
    var body: some View {
        NavigationStack {
            OverviewDashboard(selectedTab: $selectedTab, projectFilterToShow: $projectFilterToShow, projects: $projects)
        }
    }
}

struct ProjectsTabContent: View {
    @Binding var projectFilterToShow: ProjectsFilter?
    @Binding var projects: [Project]
    
    var body: some View {
        Group {
            if let filter = projectFilterToShow {
                ProjectsFilteredListView(projects: $projects, filter: filter)
            } else {
                ProjectsView(projects: $projects)
            }
        }
    }
}

#Preview {
    ContentView()
}
