import UIKit
import Foundation

// MARK: - HTTPMethod.swift
public enum HTTPMethod: String {
    case GET, POST, PUT, DELETE
}

// MARK: - NetworkError.swift
public enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case statusCode(Int)
    case decoding(Error)
    case underlying(Error)
}

// MARK: - APIRequest.swift
public protocol APIRequest {
    associatedtype Response: Decodable

    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var body: Encodable? { get }

    func decode(_ data: Data) throws -> Response
}

extension APIRequest {
    public func decode(_ data: Data) throws -> Response {
        try JSONDecoder().decode(Response.self, from: data)
    }
}

// MARK: - AnyEncodable.swift
public struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void

    public init<T: Encodable>(_ wrapped: T) {
        encodeFunc = wrapped.encode
    }

    public func encode(to encoder: Encoder) throws {
        try encodeFunc(encoder)
    }
}

// MARK: - URLRequestBuilder.swift
public class URLRequestBuilder {
    public static func build(from baseURL: URL, request: some APIRequest) throws -> URLRequest {
        guard let url = URL(string: request.path, relativeTo: baseURL) else {
            throw NetworkError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.headers

        if let body = request.body {
            urlRequest.httpBody = try JSONEncoder().encode(AnyEncodable(body))
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        return urlRequest
    }
}



// MARK: - NetworkErrorHandler.swift
public protocol NetworkErrorHandler {
    func handle(_ error: Error, request: URLRequest) -> Error
}


// MARK: - NetworkClient.swift
public class NetworkClient {
    private let baseURL: URL
    private let session: URLSession
    private let interceptors: [RequestInterceptor]
    private let plugins: [NetworkPlugin]
    private let errorHandler: NetworkErrorHandler?

    public init(
        baseURL: URL,
        sessionConfig: URLSessionConfiguration = .default,
        interceptors: [RequestInterceptor] = [],
        plugins: [NetworkPlugin] = [],
        errorHandler: NetworkErrorHandler? = nil) {
        self.baseURL = baseURL
        self.session = URLSession(configuration: sessionConfig)
        self.interceptors = interceptors
        self.plugins = plugins
        self.errorHandler = errorHandler
    }

    public func send<T: APIRequest>(_ request: T) async throws -> T.Response {
        var urlRequest = try URLRequestBuilder.build(from: baseURL, request: request)

        for interceptor in interceptors {
            urlRequest = try await interceptor.intercept(urlRequest)
        }

        plugins.forEach { $0.willSend(urlRequest) }

        do {
            let (data, response) = try await session.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.statusCode(httpResponse.statusCode)
            }

            let result = try request.decode(data)
            plugins.forEach { $0.didReceive(response: response, data: data, error: nil) }
            return result
        } catch {
            plugins.forEach { $0.didReceive(response: nil, data: nil, error: error) }
            if let errorHandler = errorHandler {
                throw errorHandler.handle(error, request: urlRequest)
            } else {
                throw error
            }
        }
    }
}
