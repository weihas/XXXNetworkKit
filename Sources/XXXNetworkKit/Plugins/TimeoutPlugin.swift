//
//  TimeoutPlugin.swift
//  XXXNetworkKit
//
//  Created by WeIHa'S on 2025/10/16.
//

import Foundation
import Moya

/// TimeoutPlugin
public struct TimeoutPlugin: PluginType {
    
    private let defaultTimeout: TimeInterval
    private let timeoutForTarget: ((TargetType) -> TimeInterval?)?
    
    /// - Parameters:
    ///   - defaultTimeout: 默认超时时间（秒）
    ///   - timeoutForTarget: 可选闭包，用于为特定 Target 自定义超时
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
