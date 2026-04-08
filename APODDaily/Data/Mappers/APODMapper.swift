//
//  APODMapper.swift
//  APODDaily
//
//  Created by Siju Satheesachandran on 08/04/2026.
//

import Foundation

enum APODMapper {
    
    static func map(dto: APODDTO, imageData: Data?) throws -> APOD {
        
        
        let date = APODDateFormatter.parse(dto.date)
        
        //====>> Handle video
        
        if dto.mediaType == "video" {
            guard let videoURL = URL(string: dto.url) else {
                throw APODError.invalidURL
            }
            
            return APOD(
                title: dto.title,
                explanation: dto.explanation,
                date: date,
                media: .video(
                    videoURL,
                    thumbnailURL: URL(string:dto.thumbnailUrl ?? "")
                )
            )
        }
        
        //====>> Handle imageURL
        
        let imageURL = URL(string: dto.hdurl ?? dto.url)
        
        
        
        return APOD(
            title: dto.title,
            explanation: dto.explanation,
            date: date,
            media: .image(
                imageData,
                imageURL
            )
        )
    }
}
