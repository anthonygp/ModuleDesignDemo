import Foundation

protocol EncryptionService {
    func encrypt(_ data: Data) -> Data
    func decrypt(_ data: Data) -> Data
}

final class MockEncryptionService: EncryptionService {
    func encrypt(_ data: Data) -> Data {
        return data
    }

    func decrypt(_ data: Data) -> Data {
        return data
    }
}

protocol EventStore {
    func save(_ event: AnalyticsEvent)
    func loadAll() -> [AnalyticsEvent]
    func remove(_ event: AnalyticsEvent)
}

final class InMemoryEventStore: EventStore {
    private var encryptedStore: [Data] = []
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let encryption: EncryptionService

    init(encryption: EncryptionService) {
        self.encryption = encryption
    }

    func save(_ event: AnalyticsEvent) {
        if let data = try? encoder.encode(event) {
            let encrypted = encryption.encrypt(data)
            encryptedStore.append(encrypted)
        }
    }

    func loadAll() -> [AnalyticsEvent] {
        encryptedStore.compactMap { encrypted in
            let decrypted = encryption.decrypt(encrypted)
            return try? decoder.decode(AnalyticsEvent.self, from: decrypted)
        }
    }

    func remove(_ event: AnalyticsEvent) {
        encryptedStore.removeAll {
            let decrypted = encryption.decrypt($0)
            guard let decoded = try? decoder.decode(AnalyticsEvent.self, from: decrypted) else {
                return false
            }
            return decoded == event
        }
    }
}
