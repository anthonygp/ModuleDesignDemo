import Foundation

final class AnalyticsClient {
    private let router: EventRouter
    private let store: EventStore
    private let networkMonitor: NetworkMonitor

    init(router: EventRouter, store: EventStore, networkMonitor: NetworkMonitor) {
        self.router = router
        self.store = store
        self.networkMonitor = networkMonitor

        // Auto-flush when network becomes available
        networkMonitor.addListener { [weak self] isOnline in
            if isOnline {
                self?.flush()
            }
        }
    }

    func track(event: AnalyticsEvent) {
        print("📤 Tracking event: \(event)")

        if networkMonitor.isOnline {
            router.route(event: event)
        } else {
            store.save(event)
        }
    }

    func flush() {
        guard networkMonitor.isOnline else { return }

        let events = store.loadAll()
        for event in events {
            router.route(event: event)
            store.remove(event)
        }
    }
}
