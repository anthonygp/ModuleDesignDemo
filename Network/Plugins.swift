import Foundation

class LoadingIndicator {
    static let shared = LoadingIndicator()
    
    private init() {}
    
    func show() { print("Loading...") }
    
    func hide() { print("hiding.") }
}

// MARK: - NetworkPlugin.swift
public protocol NetworkPlugin {
    func willSend(_ request: URLRequest)
    func didReceive(response: URLResponse?, data: Data?, error: Error?)
}

public class LoadingPlugin: NetworkPlugin {
    public init() {}
    public func willSend(_ request: URLRequest) {
        LoadingIndicator.shared.show()
    }
    public func didReceive(response: URLResponse?, data: Data?, error: Error?) {
        LoadingIndicator.shared.hide()
    }
}

public class TimingPlugin: NetworkPlugin {
    private var startTime: Date?
    public init() {}

    public func willSend(_ request: URLRequest) {
        startTime = Date()
    }

    public func didReceive(response: URLResponse?, data: Data?, error: Error?) {
        if let start = startTime {
            let duration = Date().timeIntervalSince(start)
            print("⏱️ Request completed in \(duration) seconds")
        }
    }
}

public class AnalyticsPlugin: NetworkPlugin {
    public init() {}
    public func willSend(_ request: URLRequest) {
        // Add tracking logic if needed
    }
    public func didReceive(response: URLResponse?, data: Data?, error: Error?) {
        if let error = error {
            print("📊 Analytics: Error occurred - \(error.localizedDescription)")
        } else {
            print("📊 Analytics: Success")
        }
    }
}
