import SwiftUI

struct SettingsView: View {
    @State private var showCustomFields = false
    @State private var sections: [CustomFieldSection] = CustomFieldStorage.load()
    @State private var showClubSubtitleEditor = false
    @State private var clubSubtitle: String = ClubSettingsStorage.subtitle
    @State private var showDomainEditor = false
    @State private var emailDomain: String = ClubSettingsStorage.emailDomain
    
    var body: some View {
        List {
            Section {
                SettingsRow(
                    icon: "building.2",
                    iconColor: .appTheme,
                    title: "Club Subtitle",
                    subtitle: clubSubtitle.isEmpty ? nil : clubSubtitle
                ) {
                    showClubSubtitleEditor = true
                }
                
                SettingsRow(
                    icon: "at",
                    iconColor: .appTheme,
                    title: "University Domain",
                    subtitle: emailDomain.isEmpty ? "None" : emailDomain
                ) {
                    showDomainEditor = true
                }
            } header: {
                Text("CLUB INFO")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            } 
            
            Section {
                SettingsRow(
                    icon: "list.bullet.rectangle",
                    iconColor: .appTheme,
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
                            .background(Color.appTheme)
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
        .sheet(isPresented: $showClubSubtitleEditor) {
            ClubSubtitleEditorView(subtitle: $clubSubtitle)
        }
        .sheet(isPresented: $showDomainEditor) {
            UniversityDomainEditorView(domain: $emailDomain)
        }
    }
}

struct ClubSubtitleEditorView: View {
    @Binding var subtitle: String
    @Environment(\.dismiss) private var dismiss
    @State private var draft: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("e.g. Parul University, Apple Lab, CV Raman", text: $draft, axis: .vertical)
                        .font(.body)
                        .autocorrectionDisabled()
                        .lineLimit(2...4)
                } header: {
                    Text("CLUB SUBTITLE")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                } footer: {
                    Text("Shown below \"Swift Coding Club\" on the Overview screen and in exported attendance reports.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Club Subtitle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        subtitle = draft
                        ClubSettingsStorage.subtitle = draft
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                draft = subtitle
            }
        }
    }
}

struct UniversityDomainEditorView: View {
    @Binding var domain: String
    @Environment(\.dismiss) private var dismiss
    @State private var draft: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("e.g. @paruluniversity.ac.in", text: $draft)
                        .font(.body)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                } header: {
                    Text("UNIVERSITY DOMAIN")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                } footer: {
                    Text("This domain will be automatically appended to student emails if only a username or ID is provided.")
                }
            }
            .navigationTitle("University Domain")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        if !draft.isEmpty && !draft.hasPrefix("@") {
                            domain = "@" + draft
                        } else {
                            domain = draft
                        }
                        ClubSettingsStorage.emailDomain = domain
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
            .onAppear {
                draft = domain
            }
        }
    }
}

struct AboutView: View {
    var body: some View {
        List {
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
        iconColor: Color = .appTheme,
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
