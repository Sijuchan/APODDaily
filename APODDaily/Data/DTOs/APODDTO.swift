//
//  APODDTO.swift
//  APODDaily
//
//  Created by Siju Satheesachandran on 08/04/2026.
//


import Foundation

struct APODDTO: Codable {
    let date: String
    let title: String
    let explanation: String
    
    let url: String
    let hdurl: String?
    let mediaType: String
    
    let thumbnailUrl: String?

    enum CodingKeys: String, CodingKey {
        case date, title, explanation, url, hdurl
        case mediaType = "media_type"
        case thumbnailUrl = "thumbnail_url"
    }
}
