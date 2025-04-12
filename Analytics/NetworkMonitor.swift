import Foundation
import Network

protocol NetworkMonitor {
    var isOnline: Bool { get }
    func addListener(_ listener: @escaping (Bool) -> Void)
}

final class RealNetworkMonitor: NetworkMonitor {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "network-monitor")
    private var listeners: [(Bool) -> Void] = []
    private(set) var isOnline: Bool = true

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            let status = path.status == .satisfied
            self?.isOnline = status
            self?.listeners.forEach { $0(status) }
        }
        monitor.start(queue: queue)
    }

    func addListener(_ listener: @escaping (Bool) -> Void) {
        listeners.append(listener)
    }
}

final class MockNetworkMonitor: NetworkMonitor {
    var isOnline: Bool = false
    private var listeners: [(Bool) -> Void] = []

    func setOnline(_ online: Bool) {
        isOnline = online
        listeners.forEach { $0(online) }
    }

    func addListener(_ listener: @escaping (Bool) -> Void) {
        listeners.append(listener)
    }
}
