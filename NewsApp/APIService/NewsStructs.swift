//
//  NewsStruct.swift
//  NewsApp
//
//  Created by Victor on 3/31/21.
//

import Foundation

struct News: Codable {
    var status: String?
    var totalResults: Int?
    var articles: [Article]?
}

struct Article: Codable {
    var source: ArticleSource?
    var author: String?
    var title: String?
    var description: String?
    var url: String?
    var urlToImage: String?
    var publishedAt: String?
    var content: String?
}

struct ArticleSource: Codable {
    var id: String?
    var name: String?
}
