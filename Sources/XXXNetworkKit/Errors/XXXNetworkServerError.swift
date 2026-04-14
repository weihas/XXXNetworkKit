//
//  XXXNetworkServerError.swift
//  XXXNetworkKit
//
//  Created by WeIHa'S on 2026/4/16.
//

import Foundation


/// Server-side error returned from backend.
///
/// The server only provides error codes. The specific error cases need to be
/// defined manually and mapped into this enumeration in order.
///
/// This enum should be extended carefully and kept in sync with backend error definitions.
public enum XXXNetworkServerError: Int, Error {

    /// Invalid parameters (usually missing required parameters)
    case parameterError = 4000

    /// Invalid configuration
    case invalidConfig = 4001

    /// Signature error
    case invalidSignature = 4002

    /// Request expired
    case requestExpired = 4003

    /// Duplicate request
    case duplicateRequest = 4004

    /// Invalid signing method
    case invalidSignMethod = 4005

    /// Invalid signing version
    case invalidSignVersion = 4006

    /// Content-Type must be application/json
    case invalidContentType = 4007

    /// MD5 validation failed
    case md5ValidationFailed = 4008

    /// Accept header must be application/json
    case invalidAcceptHeader = 4009

    /// Server exception
    case serverException = 4010

    /// Internal error
    case internalError = 4011

    /// Unsupported business code
    case unsupportedBizCode = 4012
}

extension XXXNetworkServerError {

    public var localizedDescription: String {
        switch self {

        case .parameterError:
            return "参数错误"

        case .invalidConfig:
            return "配置无效"

        case .invalidSignature:
            return "签名异常"

        case .requestExpired:
            return "请求已过期"

        case .duplicateRequest:
            return "重复请求"

        case .invalidSignMethod:
            return "签名方法异常"

        case .invalidSignVersion:
            return "签名版本异常"

        case .invalidContentType:
            return "Content-Type 必须为 application/json"

        case .md5ValidationFailed:
            return "MD5 校验失败"

        case .invalidAcceptHeader:
            return "Accept 必须为 application/json"

        case .serverException:
            return "服务端异常"

        case .internalError:
            return "内部错误"

        case .unsupportedBizCode:
            return "不支持的 BizCode"
        }
    }
}

extension XXXNetworkServerError: CustomNSError {
    
    public static var errorDomain: String {
        return "com.XXXNetworkKit.ServerError"
    }

    public var errorCode: Int {
        return self.rawValue
    }

    public var errorUserInfo: [String : Any] {
        return [NSLocalizedDescriptionKey: self.localizedDescription]
    }
}
