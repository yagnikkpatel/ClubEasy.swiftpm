import Foundation

enum StudentStorage {
    private static let key = "savedStudents"
    
    static func load() -> [Student] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([Student].self, from: data) else {
            return []
        }
        return decoded
    }
    
    static func save(_ students: [Student]) {
        guard let data = try? JSONEncoder().encode(students) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
