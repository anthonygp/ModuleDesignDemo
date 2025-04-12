import UIKit

public protocol ImageCacheProtocol {
    func image(forKey key: String) -> UIImage?
    func insertImage(_ image: UIImage?, forKey key: String)
    func removeImage(forKey key: String)
    func removeAll()
}


public class DefaultImageCache: ImageCacheProtocol {
    private let memoryCache = NSCache<NSString, UIImage>()
    private let diskCache = DiskImageCache()

    public init() {}

    public func image(forKey key: String) -> UIImage? {
        if let image = memoryCache.object(forKey: key as NSString) {
            return image
        } else if let image = diskCache.image(forKey: key) {
            memoryCache.setObject(image, forKey: key as NSString)
            return image
        }
        return nil
    }

    public func insertImage(_ image: UIImage?, forKey key: String) {
        if let image = image {
            memoryCache.setObject(image, forKey: key as NSString)
        } else {
            memoryCache.removeObject(forKey: key as NSString)
        }
        diskCache.insertImage(image, forKey: key)
    }

    public func removeImage(forKey key: String) {
        memoryCache.removeObject(forKey: key as NSString)
        diskCache.removeImage(forKey: key)
    }

    public func removeAll() {
        memoryCache.removeAllObjects()
        diskCache.removeAll()
    }
}
