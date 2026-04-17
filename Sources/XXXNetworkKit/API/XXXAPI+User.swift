//
//  XXXAPI+User.swift
//  XXXNetworkKit
//
//  Created by WeIHa'S on 2026/4/16.
//

import Foundation
import Moya

public extension XXXAPI {
    
    /// UserManage
    enum User {
        
        /// https://open.bilibili.com/doc/4/08f935c5-29f1-e646-85a3-0b11c2830558#h1-u67E5u8BE2u7528u6237u5DF2u6388u6743u6743u9650u5217u8868
        case scopes
        
        /// https://open.bilibili.com/doc/4/feb66f99-7d87-c206-00e7-d84164cd701c#h1-u83B7u53D6u5DF2u6388u6743u7528u6237u57FAu7840u516Cu5F00u4FE1u606F
        case info
        
        /// https://open.bilibili.com/doc/4/22e9cc93-1559-f262-0375-bdcefe9257ee#h1--union_id-
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
