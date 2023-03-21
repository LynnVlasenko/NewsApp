//
//  Models.swift
//  NewsApp
//
//  Created by Алина Власенко on 20.03.2023.
//

import Foundation

struct APIResponse: Codable {
    let articles: [Article]
}
    
struct Article: Codable {
    let source: Source
    let title: String
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String
}

struct Source: Codable {
    let name: String
}

//Model for Cell
class NewsTableViewCellViewModel {
    let title: String
    let subtitle: String
    let imageURL: URL?
    var imageData: Data? = nil//для кешування даних, щоб не завантажувати картинку повторно.
    
    init(
        title: String,
        subtitle: String,
        imageURL: URL?
    ) {
        self.title = title
        self.subtitle = subtitle
        self.imageURL = imageURL
    }
}
