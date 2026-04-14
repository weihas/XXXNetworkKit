//
//  XXXNetworkError.swift
//  XXXNetworkKit
//
//  Created by WeIHa'S on 2026/4/14.
//

import Foundation


import Foundation

/// A unified error protocol for the networking module.
///
/// `XXXNetworkError` defines an abstraction for all networking-related errors.
/// All errors originating from the network layer should conform to this protocol
/// so that the caller can handle error codes and descriptions in a unified way.
///
/// The following types conform to `XXXNetworkError`:
/// - `XXXNetworkMoyaError`: Low-level request errors from Moya.
/// - `XXXNetworkServerError`: Server-side business errors, such as error codes returned from backend (e.g. 9001).
/// - `XXXNetworkWrappedError`: Custom wrapped errors, such as unknown errors or manually constructed errors.
///
/// ### Protocol Inheritance Hierarchy:
/// ```
/// Error
///  └── XXXNetworkError
///       ├── XXXNetworkMoyaError
///       ├── XXXNetworkServerError
///       └── XXXNetworkWrappedError
/// ```
///
/// ### Usage Example:
/// ```swift
/// do {
///     try await XXXAPIProvider.shared.request(...)
///     print("Request Done")
/// } catch XXXNetworkServerError.serverException {
///     // Handle a specific business error, usually used to show user-facing messages
///     showToast(error.localizedDescription)
/// } catch let error as XXXNetworkError where error.isNetworkConnectError {
///     // Use 'where' clause to filter network connection related errors
///     showToast("Network connection error")
/// } catch let error as XXXNetworkError {
///     // Handle all networking module errors
///     print("code: \(error.errorCode)")
/// } catch {
///     // Handle non-network errors
///     print("Unknown error: \(error.localizedDescription)")
/// }
/// ```
///
/// - Important: When catching errors, follow a "from specific to general" order.
public protocol XXXNetworkError: Error {
    
    /// The error code within the given domain.
    var errorCode: Int { get }
    
    /// A localized description of the error.
    var localizedDescription: String { get }
}


// MARK: - Protocol Conformance

extension XXXNetworkMoyaError: XXXNetworkError {
    
}

extension XXXNetworkWrappedError: XXXNetworkError {
    
}

extension XXXNetworkServerError: XXXNetworkError {
    
}


// MARK: - Convenience Methods

public extension XXXNetworkError {
    
    /// Indicates whether the error is a network connectivity issue
    /// (e.g. no internet connection, DNS failure, timeout, etc.).
    var isNetworkConnectError: Bool {
        // Check if it is a Moya error and contains an underlying error
        if case .underlying = (self as? XXXNetworkMoyaError) {
            return true
        }
        return false
    }
}
