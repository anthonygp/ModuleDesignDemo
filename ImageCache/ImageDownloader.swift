import UIKit

public protocol ImageDownloading {
    func download(from url: URL) async throws -> UIImage
}

public class ImageDownloader: ImageDownloading {
    public static let shared = ImageDownloader()

    private let session: URLSession
    private var ongoingRequests: [URL: [CheckedContinuation<UIImage, Error>]] = [:]

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func download(from url: URL) async throws -> UIImage {
        return try await withCheckedThrowingContinuation { continuation in
            if ongoingRequests[url] != nil {
                ongoingRequests[url]?.append(continuation)
                return
            }

            ongoingRequests[url] = [continuation]

            session.dataTask(with: url) { [weak self] data, response, error in
                defer { self?.ongoingRequests[url] = nil }

                if let data = data, let image = UIImage(data: data) {
                    self?.ongoingRequests[url]?.forEach { $0.resume(returning: image) }
                } else {
                    let err = error ?? URLError(.badServerResponse)
                    self?.ongoingRequests[url]?.forEach { $0.resume(throwing: err) }
                }
            }.resume()
        }
    }
}
