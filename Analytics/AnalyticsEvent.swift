import Foundation

enum AnalyticsEvent: Codable, Equatable {
    case identify(name: String)
    case track(name: String, properties: [String: String])
    case logout
}
