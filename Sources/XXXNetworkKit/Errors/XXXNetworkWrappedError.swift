//
//  XXXNetworkWrappedError.swift
//  XXXNetworkKit
//
//  Created by WeIHa'S on 2026/4/16.
//

import Foundation

/// A custom network error wrapper.
///
/// This error type is generally used when developers manually throw errors,
/// or when the server returns a business error code that is not defined in
/// `XXXNetworkServerError`.
///
/// In such cases, you should coordinate with the backend team and consider
/// adding the missing error code into `XXXNetworkServerError` for proper mapping.
public struct XXXNetworkWrappedError: Error {
    
    /// The error code.
    public let errorCode: Int
    
    /// A localized description of the error.
    public let localizedDescription: String
    
    
    public init(errorCode: Int, description: String? = nil) {
        self.errorCode = errorCode
        self.localizedDescription = description ?? "Unknown error"
    }
}


extension XXXNetworkWrappedError: CustomNSError {
    
    public static var errorDomain: String { "com.XXXNetworkKit.CustomNetworkError" }
    
    public var errorUserInfo: [String : Any] {
        return [NSLocalizedDescriptionKey: self.localizedDescription]
    }
}
