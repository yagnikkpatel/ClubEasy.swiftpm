import Foundation
import UIKit

enum ProfileImageStorage {
    private static let directoryName = "ProfileImages"
    
    private static var directoryURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(directoryName)
    }
    
    static func save(_ image: UIImage, for studentId: UUID) -> String? {
        let filename = "\(studentId.uuidString).jpg"
        let fileURL = directoryURL.appendingPathComponent(filename)
        
        do {
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
            try data.write(to: fileURL)
            return filename
        } catch {
            return nil
        }
    }
    
    static func load(filename: String) -> UIImage? {
        let fileURL = directoryURL.appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }
    
    static func delete(filename: String) {
        let fileURL = directoryURL.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: fileURL)
    }
}
