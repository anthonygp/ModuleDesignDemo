import UIKit

public class ImageManager {
    private let cache: ImageCacheProtocol
    private let downloader: ImageDownloading

    public init(cache: ImageCacheProtocol = DefaultImageCache(),
                downloader: ImageDownloading = ImageDownloader.shared) {
        self.cache = cache
        self.downloader = downloader
    }

    public func retrieveImage(for url: URL) async throws -> UIImage {
        let key = url.absoluteString

        if let image = cache.image(forKey: key) {
            return image
        }

        let downloaded = try await downloader.download(from: url)
        cache.insertImage(downloaded, forKey: key)
        return downloaded
    }
}

