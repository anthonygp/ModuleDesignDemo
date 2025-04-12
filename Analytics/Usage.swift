import Foundation

let encryptionService = MockEncryptionService()
let eventStore = InMemoryEventStore(encryption: encryptionService)

let providers: [AnalyticsProvider] = [FirebaseProvider(), SegmentProvider()]
let router = DefaultEventRouter(providers: providers)

let networkMonitor = RealNetworkMonitor() // Or use MockNetworkMonitor for testing

let analyticsClient = AnalyticsClient(router: router, store: eventStore, networkMonitor: networkMonitor)

