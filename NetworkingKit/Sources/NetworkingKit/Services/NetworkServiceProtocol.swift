import Foundation

/// Protocol defining the network service interface
public protocol NetworkServiceProtocol: Sendable {
    /// The base URL for all requests
    var baseURL: URL? { get }

    /// Executes a network request and returns the raw response
    func execute(_ request: NetworkRequest) async throws -> NetworkResponse

    /// Executes a network request and decodes the response
    func execute<T: Decodable>(
        _ request: NetworkRequest,
        responseType type: T.Type,
        decoder: JSONDecoder
    ) async throws -> T
}

// MARK: - Default implementations

extension NetworkServiceProtocol {
    public func execute<T: Decodable>(
        _ request: NetworkRequest,
        responseType type: T.Type,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let response = try await execute(request)
        return try response.decode(type, decoder: decoder)
    }
}
