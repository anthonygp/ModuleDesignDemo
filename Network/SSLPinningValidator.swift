import Foundation

public class SSLPinningValidator: NSObject, URLSessionDelegate {
    private let pinnedCertificates: [Data]

    public init(certNames: [String]) {
        self.pinnedCertificates = certNames.compactMap { name in
            guard let certURL = Bundle.main.url(forResource: name, withExtension: "cer"),
                  let certData = try? Data(contentsOf: certURL) else {
                return nil
            }
            return certData
        }
    }

    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
                           completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        if let serverCert = SecTrustGetCertificateAtIndex(serverTrust, 0) {
            let serverCertData = SecCertificateCopyData(serverCert) as Data
            if pinnedCertificates.contains(serverCertData) {
                completionHandler(.useCredential, URLCredential(trust: serverTrust))
                return
            }
        }

        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}
