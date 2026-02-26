import SwiftUI

struct CreateAttendanceView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate = Date()
    var onCreated: ((Date) -> Void)?
    
    var body: some View {
        Form {
            Section {
                DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
            }
            
            Section {
                Button("Create Attendance") {
                    onCreated?(selectedDate)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("New Attendance")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                }
            }
        }
    }
}

struct CreateAttendanceSheetContent: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        CreateAttendanceView(onCreated: { date in
            let students = StudentStorage.load()
            let attendance = Dictionary(uniqueKeysWithValues: students.map { ($0.id, false) })
            AttendanceStorage.save(date: date, attendance: attendance)
            dismiss()
        })
    }
}

#Preview {
    NavigationStack {
        CreateAttendanceView()
    }
}
