import SwiftUI

struct SettingsView: View {
    @State private var showCustomFields = false
    @State private var sections: [CustomFieldSection] = CustomFieldStorage.load()
    @State private var showClubSubtitleEditor = false
    @State private var clubSubtitle: String = ClubSettingsStorage.subtitle
    @State private var showDomainEditor = false
    @State private var emailDomain: String = ClubSettingsStorage.emailDomain
    
    // Attendance Email Settings
    @State private var senderEmail: String = ClubSettingsStorage.senderEmail
    @State private var recipientEmails: [String] = ClubSettingsStorage.recipientEmails
    @State private var boilerplate: String = ClubSettingsStorage.defaultBoilerplate
    
    @State private var showSenderEmailEditor = false
    @State private var showRecipientEditor = false
    @State private var showBoilerplateEditor = false
    
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
                    icon: "envelope",
                    iconColor: .appTheme,
                    title: "Default Sender Email",
                    subtitle: senderEmail.isEmpty ? "None" : senderEmail
                ) {
                    showSenderEmailEditor = true
                }
                
                SettingsRow(
                    icon: "person.2",
                    iconColor: .appTheme,
                    title: "Recipient List",
                    subtitle: "\(recipientEmails.count) recipients"
                ) {
                    showRecipientEditor = true
                }
                
                SettingsRow(
                    icon: "text.quote",
                    iconColor: .appTheme,
                    title: "Default Message",
                    subtitle: boilerplate.isEmpty ? "None" : String(boilerplate.prefix(30)) + (boilerplate.count > 30 ? "..." : "")
                ) {
                    showBoilerplateEditor = true
                }
            } header: {
                Text("EMAIL & ATTENDANCE SHARING")
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
                    ReportFormatDetailView()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "doc.text.below.ecg")
                            .font(.body)
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Report Formats")
                                .font(.body)
                                .foregroundStyle(.primary)
                            Text("PDF & Excel Layout Previews")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } header: {
                Text("REPORT EXPORTS")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            }
            
            Section {
                Link(destination: URL(string: "https://developer.apple.com/learn/swift-coding-club/")!) {
                    HStack(spacing: 12) {
                        Image(systemName: "swift")
                            .font(.body)
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Start Your Club")
                                .font(.body)
                                .foregroundStyle(.primary)
                            Text("Apple Developer Program")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            } header: {
                Text("SWIFT CODING CLUB")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
            } footer: {
                Text("Do you want to start your swift coding club at your university explore this link")
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
        .sheet(isPresented: $showSenderEmailEditor) {
            SenderEmailEditorView(email: $senderEmail)
        }
        .sheet(isPresented: $showRecipientEditor) {
            RecipientEditorView(recipients: $recipientEmails)
        }
        .sheet(isPresented: $showBoilerplateEditor) {
            BoilerplateEditorView(boilerplate: $boilerplate)
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

struct SenderEmailEditorView: View {
    @Binding var email: String
    @Environment(\.dismiss) private var dismiss
    @State private var draft: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Add your email", text: $draft)
                        .font(.body)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                } header: {
                    Text("DEFAULT SENDER EMAIL")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                } footer: {
                    Text("This email will be used as the default sender reference.")
                }
            }
            .navigationTitle("Sender Email")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        email = draft
                        ClubSettingsStorage.senderEmail = draft
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
            .onAppear {
                draft = email
            }
        }
    }
}

struct RecipientEditorView: View {
    @Binding var recipients: [String]
    @Environment(\.dismiss) private var dismiss
    @State private var draftRecipients: [String] = []
    @State private var newEmail: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        TextField("Add recipient email...", text: $newEmail)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        
                        Button {
                            if !newEmail.isEmpty && newEmail.contains("@") {
                                withAnimation {
                                    draftRecipients.append(newEmail)
                                    newEmail = ""
                                }
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(Color.appTheme)
                                .font(.title3)
                        }
                    }
                } header: {
                    Text("ADD RECIPIENT")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
                
                Section {
                    if draftRecipients.isEmpty {
                        Text("No recipients added")
                            .foregroundStyle(.secondary)
                            .italic()
                    } else {
                        ForEach(draftRecipients, id: \.self) { email in
                            Text(email)
                        }
                        .onDelete { indexSet in
                            draftRecipients.remove(atOffsets: indexSet)
                        }
                    }
                } header: {
                    Text("RECIPIENT LIST")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Recipients")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        recipients = draftRecipients
                        ClubSettingsStorage.recipientEmails = draftRecipients
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
            .onAppear {
                draftRecipients = recipients
            }
        }
    }
}

struct BoilerplateEditorView: View {
    @Binding var boilerplate: String
    @Environment(\.dismiss) private var dismiss
    @State private var draft: String = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextEditor(text: $draft)
                        .frame(minHeight: 150)
                } header: {
                    Text("DEFAULT MESSAGE")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                } footer: {
                    Text("This message will be pre-filled when sending attendance reports.")
                }
            }
            .navigationTitle("Default Message")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        boilerplate = draft
                        ClubSettingsStorage.defaultBoilerplate = draft
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
            .onAppear {
                draft = boilerplate
            }
        }
    }
}

struct ReportFormatDetailView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // PDF Section
                VStack(alignment: .leading, spacing: 16) {
                    Label("PDF Report Structure", systemImage: "doc.richtext.fill")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        // PDF Header Mockup
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Swift Coding Club")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.appTheme)
                            
                            Text("Parul University")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)
                            
                            Text("Exported: 27 Feb 2026")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            
                            Rectangle()
                                .fill(Color.secondary.opacity(0.3))
                                .frame(height: 0.5)
                                .padding(.top, 4)
                            
                            Text("Date: February 27, 2026   ·   2/2 present")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.top, 8)
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground))
                        
                        // PDF Table Mockup with Horizontal Scroll
                        ScrollView(.horizontal, showsIndicators: false) {
                            VStack(spacing: 0) {
                                HStack(spacing: 0) {
                                    headerCell("#", width: 30)
                                    headerCell("Name", width: 120)
                                    headerCell("Enrollment No.", width: 130)
                                    headerCell("Email ID", width: 180)
                                    headerCell("Yr", width: 30)
                                    headerCell("Sem", width: 35)
                                    headerCell("Status", width: 60, alignment: .trailing)
                                }
                                .padding(.horizontal)
                                .background(Color.appTheme)
                                .clipShape(UnevenRoundedRectangle(topLeadingRadius: 4, topTrailingRadius: 4))
                                
                                row(sr: "1", name: "Arpita Mishra", enroll: "2303051050533", email: "2303051050533@paruluniv..", yr: "3", sem: "6", status: "Present", color: Color(white: 0.2), statusColor: .green)
                                row(sr: "2", name: "Bhavesh Solanki", enroll: "2303051050599", email: "2303051050599@paruluniv..", yr: "3", sem: "6", status: "Present", color: Color(white: 0.15), statusColor: .green, isLast: true)
                            }
                            .padding([.horizontal, .bottom])
                        }
                        .background(Color(.secondarySystemGroupedBackground))
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.secondary.opacity(0.1), lineWidth: 1))
                    .padding(.horizontal)
                    
                    Text("The PDF export includes all student metadata: Name, Enrollment Number, Email, Year, and Semester.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 24)
                }
                
                // Excel Section
                VStack(alignment: .leading, spacing: 16) {
                    Label("Excel / CSV Structure", systemImage: "tablecells.fill")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 0) {
                                excelRow(cells: ["Swift Coding Club", "", "", "", "", "", ""])
                                excelRow(cells: ["Parul University", "", "", "", "", "", ""])
                                excelRow(cells: ["Exported: 27 Feb 2026", "", "", "", "", "", ""])
                                excelRow(cells: ["", "", "", "", "", "", ""])
                                excelRow(cells: ["Date:", "February 27", "2026", "", "", "", ""])
                                excelRow(cells: ["Sr.", "Name", "Enrollment No.", "Email ID", "Year", "Sem", "Status"], isHeader: true)
                                excelRow(cells: ["1", "Arpita Mishra", "2303051050533", "2303051050533@parul...", "3", "6", "Present"])
                                excelRow(cells: ["2", "Bhavesh Solanki", "2303051050599", "2303051050599@parul...", "3", "6", "Present"])
                            }
                            .padding()
                        }
                        .background(Color(.secondarySystemGroupedBackground))
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.secondary.opacity(0.1), lineWidth: 1))
                    .padding(.horizontal)
                    
                    Text("The Excel format mirrors the complete data structure, ensuring all custom fields and identifiers are preserved.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 24)
                }
            }
            .padding(.vertical, 24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Report Formats")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func headerCell(_ text: String, width: CGFloat, alignment: Alignment = .leading) -> some View {
        Text(text)
            .font(.system(size: 9, weight: .bold))
            .frame(width: width, height: 30, alignment: alignment)
            .lineLimit(1)
    }
    
    private func row(sr: String, name: String, enroll: String, email: String, yr: String, sem: String, status: String, color: Color, statusColor: Color, isLast: Bool = false) -> some View {
        HStack(spacing: 0) {
            Text(sr).frame(width: 30, alignment: .leading)
            Text(name).frame(width: 120, alignment: .leading)
            Text(enroll).frame(width: 130, alignment: .leading)
            Text(email).frame(width: 180, alignment: .leading)
            Text(yr).frame(width: 30, alignment: .leading)
            Text(sem).frame(width: 35, alignment: .leading)
            Text(status).frame(width: 60, alignment: .trailing).foregroundStyle(statusColor)
        }
        .font(.system(size: 8))
        .foregroundStyle(.white)
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(color)
        .clipShape(isLast ? UnevenRoundedRectangle(bottomLeadingRadius: 4, bottomTrailingRadius: 4) : UnevenRoundedRectangle())
        .lineLimit(1)
    }
    
    private func excelRow(cells: [String], isHeader: Bool = false) -> some View {
        HStack(spacing: 0) {
            ForEach(0..<cells.count, id: \.self) { i in
                Text(cells[i])
                    .font(.system(size: 9, weight: isHeader ? .bold : .regular, design: .monospaced))
                    .padding(4)
                    .frame(width: excelColumnWidth(for: i), height: 24, alignment: .leading)
                    .background(isHeader ? Color.secondary.opacity(0.1) : Color.clear)
                    .border(Color.secondary.opacity(0.2), width: 0.5)
                    .lineLimit(1)
            }
        }
    }
    
    private func excelColumnWidth(for index: Int) -> CGFloat {
        switch index {
        case 0: return 35
        case 1: return 120
        case 2: return 140
        case 3: return 180
        default: return 60
        }
    }
}
