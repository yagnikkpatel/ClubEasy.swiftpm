import SwiftUI

enum TaskDifficulty: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var color: Color {
        switch self {
        case .easy: return .green
        case .medium: return .orange
        case .hard: return .red
        }
    }
}

struct TaskItem: Identifiable {
    var id = UUID()
    var title: String
    var assignedStudent: String
    var difficulty: TaskDifficulty
    var isCompleted: Bool
}

struct TasksView: View {
    @State private var tasks: [TaskItem] = []
    
    var body: some View {
        List {
            ForEach(tasks.indices, id: \.self) { index in
                TaskRow(task: $tasks[index])
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Tasks")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct TaskRow: View {
    @Binding var task: TaskItem
    
    var body: some View {
        HStack(spacing: 16) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    task.isCompleted.toggle()
                }
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(task.isCompleted ? Color.appTheme : .secondary)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .strikethrough(task.isCompleted, color: .secondary)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                
                Text(task.assignedStudent)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(task.difficulty.rawValue)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(task.difficulty.color)
                .clipShape(Capsule())
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        TasksView()
    }
}
