import UIKit

public extension Notification.Name {
    static let languageDidChange = Notification.Name("LocalizationKit.languageDidChange")
}

public final class LocalizationManager {
    public static let shared = LocalizationManager()

    private let languageKey = "selectedLanguage"
    private let storage: KeyValueStore
    private var remoteService: RemoteTranslationService?

    public init(storage: KeyValueStore = UserDefaults.standard,
                remoteService: RemoteTranslationService? = nil) {
        self.storage = storage
        self.remoteService = remoteService
        Bundle.setLanguage(currentLanguage) // Load at init
    }

    public func configure(remoteService: RemoteTranslationService?) {
        self.remoteService = remoteService
        loadRemoteTranslations(for: currentLanguage)
    }

    public var currentLanguage: String {
        get {
            storage.string(forKey: languageKey) ?? Locale.preferredLanguages.first ?? "en"
        }
        set {
            storage.set(newValue, forKey: languageKey)
            Bundle.setLanguage(newValue)
            loadRemoteTranslations(for: newValue)
        }
    }

    public func setLanguage(_ language: String) {
        guard language != currentLanguage else { return }
        currentLanguage = language
        NotificationCenter.default.post(name: .languageDidChange, object: nil)
    }

    private func loadRemoteTranslations(for language: String) {
        remoteService?.fetchTranslations(for: language) { success in
            print("Remote translations loaded: \(success)")
        }
    }

    public func localizedString(forKey key: String) -> String {
        if let remote = remoteService?.getTranslation(for: key) {
            return remote
        }
        return NSLocalizedString(key, comment: "")
    }
}
