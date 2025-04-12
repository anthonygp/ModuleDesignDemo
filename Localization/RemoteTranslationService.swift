import Foundation
import UIKit

public protocol RemoteTranslationService {
    func fetchTranslations(for languageCode: String, completion: @escaping (Bool) -> Void)
    func getTranslation(for key: String) -> String?
}

public final class DefaultRemoteTranslationService: RemoteTranslationService {
    private var translations: [String: String] = [:]

    public init() {}

    public func fetchTranslations(for languageCode: String, completion: @escaping (Bool) -> Void) {
        let url = URL(string: "https://api.example.com/translations/\(languageCode).json")!
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let json = try? JSONDecoder().decode([String: String].self, from: data) else {
                completion(false)
                return
            }

            self.translations = json
            completion(true)
        }.resume()
    }

    public func getTranslation(for key: String) -> String? {
        return translations[key]
    }
}
