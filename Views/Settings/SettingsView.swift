import SwiftUI

struct SettingsView: View {
    @State private var showCustomFields = false
    @State private var sections: [CustomFieldSection] = CustomFieldStorage.load()
    
    var body: some View {
        List {
            Section {
                SettingsRow(
                    icon: "list.bullet.rectangle",
                    iconColor: .blue,
                    title: "Custom Fields for Students"
                ) {
                    sections = CustomFieldStorage.load()
                    showCustomFields = true
                }
            } header: {
                Text("STUDENTS")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
            
            Section {
                NavigationLink {
                    AboutView()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "info.circle")
                            .font(.body)
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        Text("About")
                            .font(.body)
                            .foregroundStyle(.primary)
                    }
                }
            } header: {
                Text("ABOUT")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(.compact)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showCustomFields) {
            NavigationStack {
                CustomFieldsSettingsView(sections: $sections)
            }
        }
    }
}

struct AboutView: View {
    var body: some View {
        List {
            Section {
                VStack(spacing: 16) {
                    Image(systemName: "person.2.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.blue)
                    
                    VStack(spacing: 8) {
                        Text("ClubEasy")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("Version 1.0.0")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .listRowBackground(Color.clear)
            }
            
            Section("Description") {
                Text("ClubEasy is a professional management tool designed for coding clubs. It helps leaders track student progress, monitor attendance, and manage projects all in one place.")
                    .font(.body)
                    .foregroundStyle(.primary)
            }
            
            Section("Key Features") {
                Label("Student Directory", systemImage: "person.2")
                Label("Attendance Tracking", systemImage: "calendar.badge.checkmark")
                Label("Project Milestones", systemImage: "folder")
                Label("Performance Analytics", systemImage: "chart.bar.xaxis")
            }
            
            Section("Developer") {
                Text("Built with Swift and SwiftUI")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String?
    let action: () -> Void
    
    init(
        icon: String,
        iconColor: Color = .blue,
        title: String,
        subtitle: String? = nil,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(iconColor)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                
                if let subtitle {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(title)
                            .font(.body)
                            .foregroundStyle(.primary)
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text(title)
                        .font(.body)
                        .foregroundStyle(.primary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
