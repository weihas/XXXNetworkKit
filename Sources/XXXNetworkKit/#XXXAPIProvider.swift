//
//  XXXAPIProvider.swift
//  XXXNetworkKit
//
//  Created by WeIHa'S on 2025/10/15.
//

import Foundation
@preconcurrency import Moya
import SwiftyJSON

/// The single shared API request provider for the networking module.
///
/// `XXXAPIProvider` is the unified entry point for all network requests.
/// It is built on top of `MoyaProvider<MultiTarget>` and provides
/// concurrency-friendly async/await APIs.
public final class XXXAPIProvider: MoyaProvider<MultiTarget>, @unchecked Sendable {
    
    /// The global shared instance of `XXXAPIProvider`.
    public static let shared = XXXAPIProvider(plugins: sharedPlugins)
    
    
    /// Shared plugins used for request interception and logging.
    static public var sharedPlugins: [PluginType] {
        #if DEBUG
        return [NetworkLoggerPlugin.custom, TimerLoggerPlugin()]
        #else
        return []
        #endif
    }
    
    /// Performs a network request and decodes the response into a specified `Decodable` type.
    ///
    /// - Parameters:
    ///   - target: The `TargetType` defining the endpoint (path, method, parameters, etc.).
    ///   - progress: Optional progress callback for upload/download tasks.
    ///   - to: The expected response type to decode into. Defaults to `JSON` (SwiftyJSON).
    /// - Returns: A decoded response of type `T`.
    /// - Throws: Throws an error if the request fails, the status code is invalid,
    ///           or decoding fails.
    ///
    /// - Note:
    ///   Although `SwiftyJSON` provides flexibility, it is significantly slower
    ///   than native `Codable`. Benchmarks show up to a **40x performance gap**
    ///   in large or deeply nested JSON structures.
    ///
    ///   For performance-critical scenarios, it is strongly recommended to use
    ///   custom `Codable` models instead of dynamic JSON parsing.
    ///
    /// - Example:
    /// ```swift
    /// struct User: Codable {
    ///     let name: String
    ///     let face: String
    ///     let openid: String
    /// }
    ///
    /// let user = try await XXXAPIProvider.shared.request(XXXAPI.User.info, to: User.self)
    ///
    /// try await XXXAPIProvider.shared.request(XXXAPI.User.delete)
    /// ```
    @concurrent
    @discardableResult
    public func request<T: Decodable>(_ target: TargetType, progress: ProgressBlock? = nil, to: T.Type = JSON.self) async throws -> T {
        let response = try await request(target: MultiTarget(target), progress: progress)
        return try response.mapResult(to: T.self)
    }
}


// MARK: Analysis -
extension Response {
    
    /// The base response wrapper returned by the server.
    struct BaseResponse<T: Decodable>: Decodable {
        
        /// Business status code returned by the server.
        let code: Int
        
        /// Human-readable message describing the response status.
        let message: String
        
        /// The actual payload returned by the server.
        /// This field may be empty depending on the API or error state.
        let data: T?
        
        /// Unique request identifier returned by the server.
        let request_id: String
    }
    
    /// Maps the raw HTTP response into a strongly-typed `Decodable` model.
     ///
     /// This method performs:
     /// 1. HTTP status code validation (must be 0)
     /// 2. Decoding into `BaseResponse<T>`
     /// 3. Business error code validation
     /// 4. Extraction of the final payload
     ///
     /// - Parameter type: The target `Decodable` type to decode into.
     ///                   Defaults to `JSON.self` for flexible parsing.
     ///
     /// - Returns: A decoded model of type `T`.
     ///
     /// - Throws: Throws if HTTP status is invalid, decoding fails,
     ///           or business logic errors are returned by the server.
     ///
     /// - Important:
     ///   `SwiftyJSON` is convenient but significantly slower than `Codable`,
     ///   especially for large or deeply nested JSON structures (up to 40x slower in benchmarks).
     ///
     ///   For performance-sensitive scenarios, prefer strongly typed `Codable` models.
     ///
     /// - Note:
     ///   If the response does not contain a `data` field and the requested type is `JSON`,
     ///   an empty JSON container (`JSON.null`) will be returned.
     ///
     ///   If `T` is not `JSON` and `data` is missing, an assertion failure will occur.
    public func mapResult<T: Decodable>(to type: T.Type = JSON.self) throws -> T {
        
        // Validate HTTP status code (must be 200) before decoding
        let baseResponse = try self.filter(statusCode: 200).map(BaseResponse<T>.self)

        // Business status code must be 0, otherwise throw an error
        guard baseResponse.code == 0 else {
            throw XXXNetworkServerError(rawValue: baseResponse.code)
            ?? XXXNetworkWrappedError(errorCode: baseResponse.code,
                description: "Received an undefined business error code from server"
            )
        }

        // Return successful result
        if let data = baseResponse.data {
            return data
        }

        // If the requested type is JSON and data is nil, return an empty JSON container
        if T.self == JSON.self, let emptyJSON = JSON.null as? T {
            return emptyJSON
        }

        assertionFailure("Missing required 'data' field. Please coordinate with backend.")
        throw XXXNetworkWrappedError(errorCode: -1, description: "Missing required 'data' field")
    }
}
