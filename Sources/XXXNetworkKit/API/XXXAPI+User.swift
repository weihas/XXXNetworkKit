//
//  XXXAPI+User.swift
//  XXXNetworkKit
//
//  Created by WeIHa'S on 2026/4/16.
//

import Foundation
import Moya

public extension XXXAPI {
    
    /// 用户管理
    enum User {
        
        case scopes
        
        case info
        
        case union_id
    }
}


extension XXXAPI.User: TargetType {
    public var baseURL: URL {
        return URL(string: "https://member.bilibili.com/arcopen/fn/user/account/")!
    }
    
    public var path: String {
        switch self {
        case .scopes:
            return "scopes"
        case .info:
            return "info"
        case .union_id:
            return "union_id"
        }
      
    }
    
    public var method: Moya.Method {
        switch self {
        case .scopes:
            return .get
        case .info:
            return .get
        case .union_id:
            return .post
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .scopes:
            return .requestPlain
        case .info:
            return .requestPlain
        case .union_id:
            return .requestPlain
        }
    }
    
    public var headers: [String : String]? {
        [:]
    }
}
