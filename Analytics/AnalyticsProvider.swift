import Foundation

protocol AnalyticsProvider {
    func track(event: AnalyticsEvent)
    func shouldTrack(event: AnalyticsEvent) -> Bool
}

protocol EventRouter {
    func route(event: AnalyticsEvent)
}

final class DefaultEventRouter: EventRouter {
    private let providers: [AnalyticsProvider]

    init(providers: [AnalyticsProvider]) {
        self.providers = providers
    }

    func route(event: AnalyticsEvent) {
        providers
            .filter { $0.shouldTrack(event: event) }
            .forEach { $0.track(event: event) }
    }
}
