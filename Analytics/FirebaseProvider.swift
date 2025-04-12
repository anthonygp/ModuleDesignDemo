import Foundation

final class FirebaseProvider: AnalyticsProvider {
    func shouldTrack(event: AnalyticsEvent) -> Bool {
        if case .identify = event {
            return false
        }
        return true
    }

    func track(event: AnalyticsEvent) {
        print("📡 [Firebase] Tracked event: \(event)")
    }
}

final class SegmentProvider: AnalyticsProvider {
    func shouldTrack(event: AnalyticsEvent) -> Bool { true }

    func track(event: AnalyticsEvent) {
        print("📊 [Mixpanel] Tracked event: \(event)")
    }
}
