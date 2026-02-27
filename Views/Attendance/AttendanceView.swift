import SwiftUI

struct AttendanceView: View {
    @State private var showCreateAttendance = false
    @State private var hasAttendance = AttendanceStorage.datesWithAttendance().isEmpty == false
    @State private var refreshTrigger = 0
    @State private var showExportMenu = false
    @State private var exportItem: ExportItem?
    
    // Shared Filtering State
    @State private var filterByDate = false
    @State private var filterDate = Date()
    
    private var clubTitle: String { "Swift Coding Club" }
    private var clubSubtitle: String { ClubSettingsStorage.subtitle }
    
    var body: some View {
        Group {
            if hasAttendance {
                AttendanceHistoryListView(
                    refreshTrigger: refreshTrigger,
                    hasAttendance: $hasAttendance,
                    filterDate: $filterDate,
                    filterByDate: $filterByDate
                )
            } else {
                emptyState
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .navigationTitle("Attendance")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            if hasAttendance {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        refreshTrigger += 1
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            ToolbarItemGroup(placement: .topBarTrailing) {
                if hasAttendance {
                    Menu {
                        Section("Export Attendance") {
                            Button {
                                exportAttendance(format: .csv)
                            } label: {
                                Label("Export as CSV (Excel)", systemImage: "tablecells")
                            }
                            Button {
                                exportAttendance(format: .pdf)
                            } label: {
                                Label("Export as PDF", systemImage: "doc.richtext")
                            }
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
                Button {
                    showCreateAttendance = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showCreateAttendance) {
            NavigationStack {
                CreateAttendanceSheetContent()
            }
        }
        .sheet(item: $exportItem) { item in
            ShareSheet(activityItems: [item.url])
                .ignoresSafeArea()
        }
        .onChange(of: showCreateAttendance) { _, isShowing in
            if !isShowing {
                hasAttendance = !AttendanceStorage.datesWithAttendance().isEmpty
                refreshTrigger += 1
            }
        }
    }
    
    private func exportAttendance(format: AttendanceExportFormat) {
        let title = clubTitle
        let subtitle = clubSubtitle
        let tmpDir = FileManager.default.temporaryDirectory
        let exportFilterDate = filterByDate ? filterDate : nil
        
        switch format {
        case .csv:
            guard let data = AttendanceExporter.csvData(title: title, subtitle: subtitle, filterDate: exportFilterDate) else { return }
            let url = tmpDir.appendingPathComponent("Attendance_\(exportTimestamp()).csv")
            try? data.write(to: url)
            exportItem = ExportItem(url: url)
        case .pdf:
            let data = AttendanceExporter.pdfData(title: title, subtitle: subtitle, filterDate: exportFilterDate)
            let url = tmpDir.appendingPathComponent("Attendance_\(exportTimestamp()).pdf")
            try? data.write(to: url)
            exportItem = ExportItem(url: url)
        }
    }
    
    private func exportTimestamp() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer(minLength: 0)
            
            Image(systemName: "checkmark.circle")
                .font(.system(size: 64, weight: .light))
                .foregroundStyle(.secondary)
            
            Text("Attendance")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            Text("No attendance data")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }
}

// MARK: - Helpers

struct ExportItem: Identifiable {
    let id = UUID()
    let url: URL
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        AttendanceView()
    }
}
