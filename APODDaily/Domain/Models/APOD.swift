//
//  APOD.swift
//  APODDaily
//
//  Created by Siju Satheesachandran on 08/04/2026.
//

import Foundation

import Foundation

struct APOD: Equatable {
    let title: String
    let explanation: String
    let date: Date
    let media: Media

    enum Media: Equatable {
        case image(Data?, URL?)
        case video(URL, thumbnailURL: URL?)
    }
}
