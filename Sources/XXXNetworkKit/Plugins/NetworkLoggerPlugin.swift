//
//  NetworkLoggerPlugin.swift
//  XXXNetworkKit
//
//  Created by WeIHa'S on 2025/10/15.
//

import Foundation
@preconcurrency import Moya
import OSLog

extension NetworkLoggerPlugin {
    
    /// Custom LoggerPlugin
    public static let custom: NetworkLoggerPlugin = {
        
        let logger = Logger(subsystem: "com.XXXNetworkKit.logger", category: "Moya")
        
        // 输出为curl + 返回body参数
        var configuration = NetworkLoggerPlugin.Configuration(logOptions: [.verbose, .requestBody])
        
        // 采用log日志输出
        configuration.output = { target, items in
            for item in items {
                logger.debug("\(item, privacy: .public)")
            }
        }
        
        return NetworkLoggerPlugin(configuration: configuration)
    }()
}
