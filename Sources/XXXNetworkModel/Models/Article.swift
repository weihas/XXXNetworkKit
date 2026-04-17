//
//  File.swift
//  XXXNetworkKit
//
//  Created by WeIHa'S on 2026/4/17.
//

import Foundation

public struct Article: Codable {
    public let title: String
    public let category: Int
    public let template_id: Int
    public let summary: String
    public let content: String
    public let banner_url: String?
    public let original: Int?
    public let image_urls: String?
    public let tags: String?
    public let list_id: Int?
    public let up_closed_reply: Int?
    public let top_video_bvid: String?
}
