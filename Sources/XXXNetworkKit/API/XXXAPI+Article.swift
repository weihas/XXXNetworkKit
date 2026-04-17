//
//  XXXAPI+Article.swift
//  XXXNetworkKit
//
//  Created by WeIHa'S on 2026/4/17.
//

import Foundation
import Moya

public extension XXXAPI {
    
    enum Article {
        /// https://open.bilibili.com/doc/4/b14b77b6-8889-8c8b-2e83-17c5a4c550fb#h2-u8BF7u6C42u53C2u6570
        case add(article: Parameter)
        
        /// https://open.bilibili.com/doc/4/2b5284bd-9a40-247b-8da6-0ef7cd00afd3#h1-u6587u7AE0u7F16u8F91
        case edit(id: Int, article: Parameter)
        
        /// https://open.bilibili.com/doc/4/b63f8918-2add-0fbb-0718-d0537329ed1c#h1-u6587u7AE0u5220u9664
        case delete(ids: [Int])
    }
}

extension XXXAPI.Article: TargetType {
    public var baseURL: URL {
        URL(string: "https://member.bilibili.com/arcopen/fn/article")!
    }
    
    public var path: String {
        switch self {
        case .add:
            return "/add"
        case .edit:
            return "/edit"
        case .delete:
            return "/delete"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .add:
            return .post
        case .edit:
            return .post
        case .delete:
            return .post
        }
    }
    
    public var task: Moya.Task {
        switch self {
        case .add(let article):
            return .requestParameters(parameters: article, encoding: URLEncoding.httpBody)
        case .edit(let id, var article):
            article["id"] = id
            return .requestParameters(parameters: article, encoding: URLEncoding.httpBody)
        case .delete(let ids):
            let parameter: Parameter = ["ids": ids]
            return .requestParameters(parameters: parameter, encoding: URLEncoding.httpBody)
        }
    }
    
    public var headers: [String : String]? {
        return [:]
    }
}
