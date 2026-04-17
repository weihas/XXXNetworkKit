//
//  TimeoutPlugin.swift
//  XXXNetworkKit
//
//  Created by WeIHa'S on 2025/10/16.
//

import Foundation
import Moya

/// Timeout Plugin
public struct TimeoutPlugin: PluginType {
    
    private let defaultTimeout: TimeInterval
    private let timeoutForTarget: ((TargetType) -> TimeInterval?)?
    
    /// - Parameters:
    ///   - defaultTimeout: Default timeout interval (seconds)
    ///   - timeoutForTarget: Optional closure to customize timeout for specific targets
    public init(defaultTimeout: TimeInterval = 20,
                timeoutForTarget: ((TargetType) -> TimeInterval?)? = nil) {
        self.defaultTimeout = defaultTimeout
        self.timeoutForTarget = timeoutForTarget
    }

    public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var mutableRequest = request
        let timeout = timeoutForTarget?(target) ?? defaultTimeout
        mutableRequest.timeoutInterval = timeout * 60
        return mutableRequest
    }
}
