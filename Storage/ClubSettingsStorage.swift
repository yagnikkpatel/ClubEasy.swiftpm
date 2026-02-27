import Foundation

enum ClubSettingsStorage {
    private static let subtitleKey = "clubSubtitle"
    private static let domainKey = "universityDomain"
    
    private static let senderEmailKey = "senderEmail"
    private static let recipientEmailsKey = "recipientEmails"
    private static let boilerplateKey = "defaultBoilerplate"
    
    static var subtitle: String {
        get { UserDefaults.standard.string(forKey: subtitleKey) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: subtitleKey) }
    }
    
    static var emailDomain: String {
        get { UserDefaults.standard.string(forKey: domainKey) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: domainKey) }
    }

    static var senderEmail: String {
        get { UserDefaults.standard.string(forKey: senderEmailKey) ?? "yagnikpatel5253@gmail.com" }
        set { UserDefaults.standard.set(newValue, forKey: senderEmailKey) }
    }

    static var recipientEmails: [String] {
        get { UserDefaults.standard.stringArray(forKey: recipientEmailsKey) ?? [] }
        set { UserDefaults.standard.set(newValue, forKey: recipientEmailsKey) }
    }

    static var defaultBoilerplate: String {
        get { 
            UserDefaults.standard.string(forKey: boilerplateKey) ?? 
            "Hi,\nthis is the student who were present in the today's session"
        }
        set { UserDefaults.standard.set(newValue, forKey: boilerplateKey) }
    }
}
