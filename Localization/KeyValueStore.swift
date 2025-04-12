import Foundation

public protocol KeyValueStore {
    func string(forKey: String) -> String?
    func set(_ value: Any?, forKey: String)
}

extension UserDefaults: KeyValueStore {}
