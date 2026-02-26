import SwiftUI

struct AttendanceView: View {
    @State private var showCreateAttendance = false
    @State private var hasAttendance = AttendanceStorage.datesWithAttendance().isEmpty == false
    @State private var refreshTrigger = 0
    
    var body: some View {
        Group {
            if hasAttendance {
                AttendanceHistoryListView(refreshTrigger: refreshTrigger, hasAttendance: $hasAttendance)
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
            ToolbarItem(placement: .topBarTrailing) {
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
        .onChange(of: showCreateAttendance) { _, isShowing in
            if !isShowing {
                hasAttendance = !AttendanceStorage.datesWithAttendance().isEmpty
                refreshTrigger += 1
            }
        }
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

#Preview {
    NavigationStack {
        AttendanceView()
    }
}
