import Foundation

enum ClubSettingsStorage {
    private static let subtitleKey = "clubSubtitle"
    private static let domainKey = "universityDomain"
    
    static var subtitle: String {
        get { UserDefaults.standard.string(forKey: subtitleKey) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: subtitleKey) }
    }
    
    static var emailDomain: String {
        get { UserDefaults.standard.string(forKey: domainKey) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: domainKey) }
    }
}
