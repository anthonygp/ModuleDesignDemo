import Foundation

// MARK: - TokenProvider.swift
public protocol TokenProvider {
    func getAccessToken() async throws -> String
}

public class AuthTokenProvider: TokenProvider {
    private var token: String?
    private let lock = NSLock()

    public init(initialToken: String? = nil) {
        self.token = initialToken
    }

    public func getAccessToken() async throws -> String {
        lock.lock(); defer { lock.unlock() }
        if let token = token {
            return token
        } else {
            throw URLError(.userAuthenticationRequired)
        }
    }

    public func update(token newToken: String) {
        lock.lock(); token = newToken; lock.unlock()
    }
}

// MARK: - RequestInterceptor.swift
public protocol RequestInterceptor {
    func intercept(_ request: URLRequest) async throws -> URLRequest
}

public class AuthInterceptor: RequestInterceptor {
    private let tokenProvider: TokenProvider

    public init(tokenProvider: TokenProvider) {
        self.tokenProvider = tokenProvider
    }

    public func intercept(_ request: URLRequest) async throws -> URLRequest {
        var newRequest = request
        let token = try await tokenProvider.getAccessToken()
        newRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return newRequest
    }
}

public class LoggingInterceptor: RequestInterceptor {
    public init() {}

    public func intercept(_ request: URLRequest) async throws -> URLRequest {
        print("➡️ Sending request to: \(request.url?.absoluteString ?? "")")
        print("Headers: \(request.allHTTPHeaderFields ?? [:])")
        return request
    }
}

