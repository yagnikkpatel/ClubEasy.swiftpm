import SwiftUI

struct AttendanceFilterView: View {
    var initialDate: Date? = nil
    @State private var selectedDate: Date
    @State private var students: [Student] = StudentStorage.load()
    
    init(initialDate: Date? = nil) {
        self.initialDate = initialDate
        self._selectedDate = State(initialValue: initialDate ?? Date())
    }
    
    private var attendance: [UUID: Bool] {
        AttendanceStorage.records(for: selectedDate)
    }
    
    private var presentCount: Int {
        attendance.values.filter { $0 }.count
    }
    
    private var absentCount: Int {
        students.count - presentCount
    }
    
    private var hasDataForDate: Bool {
        !attendance.isEmpty
    }
    
    var body: some View {
        List {
            Section {
                DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
            }
            
            if hasDataForDate {
                Section {
                    summaryCard
                }
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                .listRowBackground(Color.clear)
                
                Section {
                    ForEach(students) { student in
                        let isPresent = attendance[student.id, default: false]
                        HStack(spacing: 12) {
                            AttendanceStatusBadge(isPresent: isPresent)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(student.name)
                                    .font(.headline)
                                    .foregroundStyle(isPresent ? .primary : .secondary)
                                Text(student.level)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                    }
                }
            } else {
                Section {
                    Text("No attendance recorded for this date")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                }
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(.compact)
        .onAppear {
            students = StudentStorage.load()
        }
    }
    
    private var summaryCard: some View {
        HStack(spacing: 12) {
            SummaryItem(label: "Total Students", value: "\(students.count)")
            SummaryItem(label: "Present", value: "\(presentCount)")
            SummaryItem(label: "Absent", value: "\(absentCount)")
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct SummaryItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        AttendanceFilterView()
    }
}
