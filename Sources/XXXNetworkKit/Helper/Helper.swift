//
//  Helper.swift
//  XXXNetworkKit
//
//  Created by WeIHa'S on 2026/1/8.
//

import Foundation
@preconcurrency import Moya
import Alamofire
import os

// MARK: - Type Aliases

/// Unified parameter type used in networking layer.
public typealias Parameter = Alamofire.Parameters

/// Alias for Swift Concurrency Task.
/// If not otherwise specified, `Task` refers to `_Concurrency.Task`.
package typealias Task = _Concurrency.Task


// MARK: - Moya Async Extension

extension MoyaProvider {

    /// Performs a network request and returns a `Response` using Swift concurrency.
    ///
    /// This method wraps Moya's callback-based API into an async/await interface,
    /// and supports cooperative cancellation via `Task`.
    ///
    /// - Parameters:
    ///   - target: The target endpoint to request.
    ///   - progress: Optional upload/download progress callback.
    /// - Returns: A `Response` object containing the server response.
    /// - Throws: A `MoyaError` if the request fails or is cancelled.
    func request(target: Target, progress: ProgressBlock? = nil) async throws -> Response {
        let lock = OSAllocatedUnfairLock<Moya.Cancellable?>(initialState: nil)
        
        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                
                // Ensure task is not already cancelled
                guard !Task.isCancelled else {
                    continuation.resume(throwing: MoyaError.underlying(AFError.explicitlyCancelled, nil))
                    return
                }
                
                let cancellable = request(target, progress: progress) { result in
                    // adapt for Swift6
                    switch result {
                    case .success(let response):
                        continuation.resume(returning: response)
                        
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
                
                lock.withLock { $0 = cancellable }
            }
            
        } onCancel: {
            // Cancel underlying Moya request when the Task is cancelled.
            lock.withLock { $0?.cancel() }
        }
    }
}

extension Encodable {
    
    func asParameters(encoder: JSONEncoder = .init()) throws -> Parameters {
        let data = try encoder.encode(self)
        let object = try JSONSerialization.jsonObject(with: data, options: [])
        
        guard let dict = object as? Parameters else {
            throw EncodingError.invalidValue(
                self,
                .init(
                    codingPath: [],
                    debugDescription: "Top-level object is not a dictionary"
                )
            )
        }
        return dict
    }
}
