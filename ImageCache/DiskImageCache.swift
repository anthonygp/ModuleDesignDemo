import UIKit

public class DiskImageCache {
    private let directory: URL
    private let maxDiskSize: Int
    private let maxAge: TimeInterval

    public init(directoryName: String = "ImageCache", maxDiskSize: Int = 50 * 1024 * 1024, maxAge: TimeInterval = 60 * 60 * 24 * 7) {
        self.maxDiskSize = maxDiskSize
        self.maxAge = maxAge

        let urls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        self.directory = urls[0].appendingPathComponent(directoryName)

        if !FileManager.default.fileExists(atPath: directory.path) {
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
    }

    private func fileURL(forKey key: String) -> URL {
        let fileName = key.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? UUID().uuidString
        return directory.appendingPathComponent(fileName + ".img")
    }

    public func image(forKey key: String) -> UIImage? {
        let url = fileURL(forKey: key)
        guard FileManager.default.fileExists(atPath: url.path),
              let attr = try? FileManager.default.attributesOfItem(atPath: url.path),
              let creationDate = attr[.creationDate] as? Date,
              Date().timeIntervalSince(creationDate) < maxAge,
              let data = try? Data(contentsOf: url),
              let image = UIImage(data: data) else {
            return nil
        }
        return image
    }

    public func insertImage(_ image: UIImage?, forKey key: String) {
        guard let image = image, let data = image.pngData() else { return }
        let url = fileURL(forKey: key)
        try? data.write(to: url)
        enforceLimits()
    }

    public func removeImage(forKey key: String) {
        let url = fileURL(forKey: key)
        try? FileManager.default.removeItem(at: url)
    }

    public func removeAll() {
        try? FileManager.default.removeItem(at: directory)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    private func enforceLimits() {
        let fileManager = FileManager.default
        guard let files = try? fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey], options: []) else {
            return
        }

        var totalSize = 0
        var fileInfo = [(url: URL, size: Int, date: Date)]()

        for file in files {
            let attrs = try? fileManager.attributesOfItem(atPath: file.path)
            let size = attrs?[.size] as? Int ?? 0
            let date = attrs?[.modificationDate] as? Date ?? Date.distantPast
            totalSize += size
            fileInfo.append((file, size, date))
        }

        if totalSize > maxDiskSize {
            let sortedFiles = fileInfo.sorted { $0.date < $1.date }
            var sizeToFree = totalSize - maxDiskSize

            for info in sortedFiles {
                try? fileManager.removeItem(at: info.url)
                sizeToFree -= info.size
                if sizeToFree <= 0 { break }
            }
        }
    }
}
