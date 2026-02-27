import SwiftUI
import MessageUI

struct AttendanceEmailShareView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Data sources
    let filterDate: Date?
    
    // State
    @State private var format: AttendanceExportFormat = .pdf
    @State private var recipients: [String] = ClubSettingsStorage.recipientEmails
    @State private var message: String = ClubSettingsStorage.defaultBoilerplate
    @State private var selectedRecipients: Set<String> = Set(ClubSettingsStorage.recipientEmails)
    
    // Mail View State
    @State private var showMailView = false
    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil
    @State private var mailAttachments: [MailAttachment] = []
    
    private var clubTitle: String { "Swift Coding Club" }
    private var clubSubtitle: String { ClubSettingsStorage.subtitle }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Format") {
                    Picker("Export Format", selection: $format) {
                        Text("PDF Report").tag(AttendanceExportFormat.pdf)
                        Text("Excel (CSV)").tag(AttendanceExportFormat.csv)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Sender Reference") {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundStyle(.secondary)
                        Text(ClubSettingsStorage.senderEmail)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section {
                    if recipients.isEmpty {
                        Text("No recipients configured in Settings")
                            .foregroundStyle(.secondary)
                            .italic()
                    } else {
                        ForEach(recipients, id: \.self) { email in
                            Toggle(isOn: binding(for: email)) {
                                Text(email)
                            }
                        }
                    }
                } header: {
                    HStack {
                        Text("RECIPIENTS")
                        Spacer()
                        if !recipients.isEmpty {
                            Button(selectedRecipients.count == recipients.count ? "Deselect All" : "Select All") {
                                if selectedRecipients.count == recipients.count {
                                    selectedRecipients.removeAll()
                                } else {
                                    selectedRecipients = Set(recipients)
                                }
                            }
                            .font(.caption)
                            .foregroundStyle(Color.appTheme)
                        }
                    }
                }
                
                Section("Message") {
                    TextEditor(text: $message)
                        .frame(minHeight: 120)
                }
            }
            .navigationTitle("Send Attendance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Next") {
                        prepareAndSend()
                    }
                    .fontWeight(.bold)
                    .disabled(selectedRecipients.isEmpty || !MFMailComposeViewController.canSendMail())
                }
            }
            .sheet(isPresented: $showMailView) {
                MailView(
                    isShowing: $showMailView,
                    result: $mailResult,
                    recipients: Array(selectedRecipients),
                    subject: "Attendance Report - \(formattedDate)",
                    messageBody: message,
                    attachments: mailAttachments
                )
            }
            .onChange(of: showMailView) { _, isShowing in
                if !isShowing, let result = mailResult {
                    if case .success(let state) = result, state == .sent {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var formattedDate: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: filterDate ?? Date())
    }
    
    private func binding(for email: String) -> Binding<Bool> {
        Binding {
            selectedRecipients.contains(email)
        } set: { newValue in
            if newValue {
                selectedRecipients.insert(email)
            } else {
                selectedRecipients.remove(email)
            }
        }
    }
    
    private func prepareAndSend() {
        let title = clubTitle
        let subtitle = clubSubtitle
        let dateFilter = filterDate
        
        mailAttachments.removeAll()
        
        switch format {
        case .csv:
            if let data = AttendanceExporter.csvData(title: title, subtitle: subtitle, filterDate: dateFilter) {
                mailAttachments.append(MailAttachment(
                    data: data,
                    mimeType: "text/csv",
                    fileName: "Attendance_\(exportTimestamp()).csv"
                ))
            }
        case .pdf:
            let data = AttendanceExporter.pdfData(title: title, subtitle: subtitle, filterDate: dateFilter)
            mailAttachments.append(MailAttachment(
                data: data,
                mimeType: "application/pdf",
                fileName: "Attendance_\(exportTimestamp()).pdf"
            ))
        }
        
        showMailView = true
    }
    
    private func exportTimestamp() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: filterDate ?? Date())
    }
}
