//
//  TimerLoggerPlugin.swift
//  XXXNetworkKit
//
//  Created by WeIHa'S on 2025/10/15.
//

import Foundation
import Moya

/// Moya Style TimerLoggerPlugin
final class TimerLoggerPlugin: PluginType {
    
    private var startTime: CFAbsoluteTime?
    
    var configuration: NetworkLoggerPlugin.Configuration {
        NetworkLoggerPlugin.custom.configuration
    }
    
    func willSend(_ request: RequestType, target: TargetType) {
        startTime = CFAbsoluteTimeGetCurrent()
    }
    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        guard let startTime else { return }
        let time = CFAbsoluteTimeGetCurrent() - startTime
        let description = configuration.formatter.entry("Timer", "\(time) s", target)
        configuration.output(target, [description])
    }
}
