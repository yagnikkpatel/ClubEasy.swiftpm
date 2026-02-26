import SwiftUI

struct AttendanceHistoryListView: View {
    var refreshTrigger: Int = 0
    @Binding var hasAttendance: Bool
    @State private var dates: [Date] = AttendanceStorage.datesWithAttendance()
    
    init(refreshTrigger: Int = 0, hasAttendance: Binding<Bool>) {
        self.refreshTrigger = refreshTrigger
        self._hasAttendance = hasAttendance
    }
    @State private var listRefreshId = 0
    @State private var filterDate: Date = Calendar.current.startOfDay(for: Date())
    @State private var filterByDate = false
    @State private var showCalendar = false
    
    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }
    
    private var calendar = Calendar.current
    
    private var filteredDates: [Date] {
        guard filterByDate else { return dates }
        let startOfFilter = calendar.startOfDay(for: filterDate)
        return dates.filter { calendar.isDate($0, inSameDayAs: startOfFilter) }
    }
    
    var body: some View {
        List {
            Section {
                Button {
                    showCalendar = true
                } label: {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(.blue)
                        Text(dateFormatter.string(from: filterDate))
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .buttonStyle(.plain)
                Toggle("Filter by selected date", isOn: $filterByDate)
            } header: {
                Text("Calendar")
                    .foregroundStyle(.primary)
            }
            
            if !filteredDates.isEmpty {
                Section {
                    ForEach(filteredDates, id: \.self) { date in
                        NavigationLink {
                            DateWiseAttendanceView(date: date, onSave: {
                                dates = AttendanceStorage.datesWithAttendance()
                                listRefreshId += 1
                            })
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(dateFormatter.string(from: date))
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                    HStack(spacing: 8) {
                                        Text("\(presentCount(for: date)) present")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                        Text("\(absentCount(for: date)) absent")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            AttendanceStorage.delete(for: filteredDates[index])
                        }
                        dates = AttendanceStorage.datesWithAttendance()
                        if dates.isEmpty {
                            hasAttendance = false
                        }
                    }
                }
            } else if filterByDate {
                Section {
                    Text("No attendance for this date")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                }
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(.compact)
        .sheet(isPresented: $showCalendar) {
            NavigationStack {
                Form {
                    Section {
                        DatePicker("Select date", selection: $filterDate, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowBackground(Color.clear)
                }
                .formStyle(.grouped)
                .scrollContentBackground(.hidden)
                .background(Color(.systemGroupedBackground))
                .navigationTitle("Filter by date")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            showCalendar = false
                        }
                    }
                }
            }
        }
        .onAppear {
            dates = AttendanceStorage.datesWithAttendance()
        }
        .onChange(of: refreshTrigger) { _, _ in
            dates = AttendanceStorage.datesWithAttendance()
        }
    }
    
    private func presentCount(for date: Date) -> Int {
        AttendanceStorage.records(for: date).values.filter { $0 }.count
    }
    
    private func absentCount(for date: Date) -> Int {
        AttendanceStorage.records(for: date).values.filter { !$0 }.count
    }
}

#Preview {
    NavigationStack {
        AttendanceHistoryListView(hasAttendance: .constant(true))
    }
}
