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
        
        // curl + body
        var configuration = NetworkLoggerPlugin.Configuration(logOptions: [.verbose, .requestBody])
        
        if #available(macOS 11.0, iOS 14.0, watchOS 7.0, tvOS 14.0, *) {
            let logger = Logger(subsystem: "com.XXXNetworkKit.logger", category: "Moya")
            // Use system log output
            configuration.output = { target, items in
                for item in items {
                    logger.debug("\(item, privacy: .public)")
                }
            }
        } else {
            // Fallback on earlier versions
        }
        
        return NetworkLoggerPlugin(configuration: configuration)
    }()
}
