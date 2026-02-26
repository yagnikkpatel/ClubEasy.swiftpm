import SwiftUI

struct AttendanceStatusBadge: View {
    let isPresent: Bool
    var onTap: (() -> Void)? = nil
    
    private var label: String { isPresent ? "P" : "A" }
    private var color: Color { isPresent ? Color.green : Color.red }
    
    var body: some View {
        let badge = Text(label)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 32, height: 32)
            .background(color)
            .clipShape(Circle())
        
        if let onTap {
            Button(action: onTap) { badge }
                .buttonStyle(.plain)
        } else {
            badge
        }
    }
}

struct DateWiseAttendanceView: View {
    @Environment(\.dismiss) private var dismiss
    let date: Date
    var onSave: (() -> Void)? = nil
    @State private var students: [Student] = StudentStorage.load()
    @State private var attendance: [UUID: Bool] = [:]
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
    
    var body: some View {
        List {
            Section {
                Text(formattedDate)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                .listRowInsets(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                .listRowBackground(Color.clear)
            }
            
            Section {
                ForEach(students) { student in
                    HStack(spacing: 16) {
                        AttendanceStatusBadge(isPresent: attendance[student.id, default: false])
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(student.name)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text(student.level)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Toggle("", isOn: Binding(
                            get: { attendance[student.id, default: false] },
                            set: { attendance[student.id] = $0 }
                        ))
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(.compact)
        .navigationTitle("Attendance")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    AttendanceStorage.save(date: date, attendance: attendance)
                    onSave?()
                    dismiss()
                }
                .fontWeight(.semibold)
            }
        }
        .onAppear {
            students = StudentStorage.load()
            attendance = AttendanceStorage.records(for: date)
        }
    }
}

#Preview {
    NavigationStack {
        DateWiseAttendanceView(date: Date())
    }
}
